import Foundation

// 隔离网络依赖，分类协议扩展仍使用应用中的真实源码。
final class ProjectAPIService {
    func fetchTags() async throws -> [ProjectTagModel] { [.init(id: 1, name: "项目", children: nil)] }
    func fetchProjectList(tagId: Int, page: Int) async throws -> Page<InfoModel> { try makePage(id: tagId, page: page) }
}
final class PublicNumberAPIService {
    func fetchTags() async throws -> [PublicNumberTagModel] { [.init(id: 2, name: "公众号")] }
    func fetchArticleList(accountId: Int, page: Int) async throws -> Page<InfoModel> { try makePage(id: accountId, page: page) }
}
final class TreeAPIService {
    func fetchTags() async throws -> [TreeTagModel] { [.init(id: 3, name: "体系", children: nil)] }
    func fetchArticleList(tagId: Int, page: Int) async throws -> Page<InfoModel> { try makePage(id: tagId, page: page) }
}

func makePage(id: Int, page: Int) throws -> Page<InfoModel> {
    let data = Data("{\"curPage\":\(page),\"pageCount\":3,\"datas\":[{\"id\":\(id)}]}".utf8)
    return try JSONDecoder().decode(Page<InfoModel>.self, from: data)
}

enum TestFailure: LocalizedError {
    case expected
    var errorDescription: String? { "测试请求失败" }
}

final class ControlledSource: CategorySource {
    let title = "测试分类"
    var failCategories = false
    var failArticles = false
    var calls: [(Int, Int)] = []
    var pending: CheckedContinuation<Page<InfoModel>, Error>?
    var pauseNext = false

    func fetchCategories() async throws -> [ProjectTagModel] {
        if failCategories { throw TestFailure.expected }
        return [.init(id: 10, name: "甲", children: nil), .init(id: 20, name: "乙", children: nil)]
    }

    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel> {
        calls.append((id, page))
        if failArticles { throw TestFailure.expected }
        if pauseNext {
            pauseNext = false
            return try await withCheckedThrowingContinuation { pending = $0 }
        }
        return try makePage(id: id * 100 + page, page: page)
    }
}

@main
struct CategorySourceTests {
    @MainActor
    static func main() async throws {
        // 三个真实协议扩展分别保持模型、标题及参数转发。
        let project = ProjectAPIService()
        let publicNumber = PublicNumberAPIService()
        let tree = TreeAPIService()
        let _: [ProjectTagModel] = try await project.fetchCategories()
        let _: [PublicNumberTagModel] = try await publicNumber.fetchCategories()
        let _: [TreeTagModel] = try await tree.fetchCategories()
        precondition(project.title == "项目" && publicNumber.title == "公众号" && tree.title == "体系")
        let projectPage = try await project.fetchArticleList(id: 11, page: 2)
        let publicPage = try await publicNumber.fetchArticleList(id: 22, page: 2)
        let treePage = try await tree.fetchArticleList(id: 33, page: 2)
        precondition(projectPage.datas?.first?.id == 11 && projectPage.curPage == 2)
        precondition(publicPage.datas?.first?.id == 22 && publicPage.curPage == 2)
        precondition(treePage.datas?.first?.id == 33 && treePage.curPage == 2)

        let source = ControlledSource()
        let model = CategoryPageViewModel(source: source)
        source.failCategories = true
        await model.loadCategories()
        precondition(model.errorMessage != nil && !model.isLoading)
        source.failCategories = false
        await model.loadCategories()
        precondition(model.categories.count == 2 && model.errorMessage == nil)
        precondition(source.calls.isEmpty, "分类加载不应预加载文章")
        let first = model.articleViewModels[10]!
        let second = model.articleViewModels[20]!
        await first.loadIfNeeded()
        await first.loadIfNeeded()
        precondition(source.calls.count == 1 && source.calls[0] == (10, 1))
        model.currentPage = 1
        await second.loadIfNeeded()
        model.currentPage = 0
        await first.loadIfNeeded()
        await model.loadCategories()
        precondition(model.articleViewModels[10] === first && model.articleViewModels[20] === second)
        precondition(source.calls.count == 2 && second.articles.first?.id == 2001)

        // 失败不推进页码，重试仍请求第二页。
        source.failArticles = true
        await first.loadMoreIfNeeded(first.articles.last!)
        precondition(first.errorMessage != nil && !first.isLoadingMore && first.articles.count == 1)
        source.failArticles = false
        await first.loadMoreIfNeeded(first.articles.last!)
        precondition(source.calls.last! == (10, 2) && first.articles.count == 2)

        // 刷新取代在途分页，旧响应不得追加或重置新状态。
        source.pauseNext = true
        let oldRequest = Task { await first.loadMoreIfNeeded(first.articles.last!) }
        while source.pending == nil { await Task.yield() }
        await first.refresh()
        precondition(first.articles.count == 1 && first.articles.first?.id == 1001)
        source.pending!.resume(returning: try makePage(id: 999, page: 3))
        source.pending = nil
        await oldRequest.value
        precondition(first.articles.count == 1 && first.articles.first?.id == 1001)
        precondition(!first.isLoading && !first.isLoadingMore && first.hasMoreData)

        // 取消请求的返回值不进入列表，加载状态恢复。
        let cancelledModel = CategoryArticleListViewModel(categoryId: 30, source: source)
        source.pauseNext = true
        let cancelled = Task { await cancelledModel.refresh() }
        while source.pending == nil { await Task.yield() }
        cancelled.cancel()
        source.pending!.resume(returning: try makePage(id: 888, page: 1))
        source.pending = nil
        await cancelled.value
        precondition(cancelledModel.articles.isEmpty && !cancelledModel.isLoading && !cancelledModel.isInitialized)
        await cancelledModel.loadIfNeeded()
        precondition(cancelledModel.isInitialized)
        print("分类来源测试通过：三种适配、分类重试、按需加载、分类状态复用、分页重试、旧响应隔离、取消恢复")
    }
}
