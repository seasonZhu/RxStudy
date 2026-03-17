//
//  CategoryPageView.swift
//  RxStudy - SwiftUIApp
//
//  通用分类页面视图
//  支持项目、公众号、体系三种类型，统一展示逻辑
//

import SwiftUI

// MARK: - 通用分类页面

struct CategoryPageView<T: CategoryItem>: View {
    let categoryType: CategoryType
    @State private var viewModel: CategoryPageViewModel<T>

    init(categoryType: CategoryType) {
        self.categoryType = categoryType
        _viewModel = State(initialValue: CategoryPageViewModel(categoryType: categoryType))
    }

    var body: some View {
        contentView
            .navigationBar(categoryType.title)
            .onAppear {
                if viewModel.categories.isEmpty {
                    Task {
                        await viewModel.loadCategories()
                    }
                }
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.categories.isEmpty {
            categoryContentView
        } else if viewModel.isLoading {
            LoadingView(message: "加载中...")
        } else if let error = viewModel.errorMessage {
            ErrorStateView(message: error) {
                Task {
                    await viewModel.loadCategories()
                }
            }
        } else {
            EmptyStateView(icon: "tray", message: "暂无内容")
        }
    }

    // MARK: - 分类内容视图（上下结构 + 横向滑动）

    private var categoryContentView: some View {
        VStack(spacing: 0) {
            // 顶部分类选择器
            categoryPicker

            // 横向滑动的文章列表
            articleList
        }
    }

    // MARK: - 分类选择器

    private var categoryPicker: some View {
        HorizontalCategoryPicker(
            items: viewModel.categories,
            selectedIndex: $viewModel.currentPage,
            idPath: \.id,
            namePath: \.name
        ) { category, _ in
            viewModel.selectCategory(category)
        }
    }

    // MARK: - 横向滑动的文章列表

    private var articleList: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                CategoryArticleListView(
                    viewModel: viewModel,
                    categoryId: category.id ?? 0,
                    categoryName: category.name ?? "",
                    isActive: viewModel.currentPage == index
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

