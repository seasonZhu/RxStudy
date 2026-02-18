abstract class Api {

  /// 初始化方法私有化
  Api._();

  // baseUrl
  static const String baseUrl = 'https://www.wanandroid.com/';

  // 首页banner
  static const String getBanner = 'banner/json';

  // 首页文章列表
  static const String getArticleList = 'article/list/';

  // 首页置顶文章列表
  static const String getTopArticleList = 'article/top/json';

  // 首页搜索热词
  static const String getSearchHotKey = 'hotkey/json';

  //搜索 https://www.wanandroid.com/article/query/0/json
  static const String postQueryKey = 'article/query/';

  // 项目分类
  static const String getProjectClassify = 'project/tree/json';

  // 项目分类列表 https://www.wanandroid.com/project/list/0/json
  static const String getProjectClassifyList = 'project/list/';

  // 公众号
  static const String getPublicNumber = 'wxarticle/chapters/json';

  // 公众号文章列表
  static const String getPublicNumberList = 'wxarticle/list/';

  // 登录
  static const String postLogin = 'user/login';

  // 注册
  static const String postRegister = 'user/register';

  // 登录退出
  static const String getLogout = 'user/logout/json';

  // 收藏站内文章 lg/collect/1165/json
  static const String postCollectArticle = 'lg/collect/';

  // 取消收藏站内文章 lg/uncollect_originId/1165/json
  static const String postUnCollectArticle = 'lg/uncollect_originId/';

  // 收藏文章列表
  static const String getCollectArticleList = 'lg/collect/list/';

  // 积分排行榜 lg/coin/list/1/json
  static const String getRankingList = 'coin/rank/';

  // 个人积分获取列表
  static const String getCoinList = 'lg/coin/list/';

  // 个人积分
  static const String getUserCoinInfo = 'lg/coin/userinfo/json';

  // 体系
  static const String getTree = "tree/json";

  // 体系详细 article/list/0/json?cid=1 其实和getArticleList接口一样
  static const String getTreeDetailList = "article/list/";
}