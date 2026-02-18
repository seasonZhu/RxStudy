import 'package:get/get.dart';
import 'package:flutter_module/example_app/state_mixin_example_page.dart';
import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:flutter_module/pages/coin_rank/view/coin_rank_page.dart';
import 'package:flutter_module/pages/common/unknown_page.dart';
import 'package:flutter_module/pages/home/binding/home_binding.dart';
import 'package:flutter_module/pages/home/binding/hot_key_binding.dart';
import 'package:flutter_module/pages/home/view/hot_key_page.dart';
import 'package:flutter_module/pages/launch/splash_page.dart';
import 'package:flutter_module/pages/launch/welcome_page.dart';
import 'package:flutter_module/pages/main/bindings/main_binding.dart';
import 'package:flutter_module/pages/main/view/main_page.dart';
import 'package:flutter_module/pages/my/binding/login_binding.dart';
import 'package:flutter_module/pages/my/binding/my_binding.dart';
import 'package:flutter_module/pages/my/binding/my_coin_history_binding.dart';
import 'package:flutter_module/pages/my/binding/my_collect_binding.dart';
import 'package:flutter_module/pages/my/binding/register_binding.dart';
import 'package:flutter_module/pages/my/view/login_page.dart';
import 'package:flutter_module/pages/my/view/my_coin_history_page.dart';
import 'package:flutter_module/pages/my/view/my_collect_page.dart';
import 'package:flutter_module/pages/my/view/register_page.dart';
import 'package:flutter_module/pages/home/binding/search_result_binding.dart';
import 'package:flutter_module/pages/home/view/search_result_page.dart';
import 'package:flutter_module/pages/my/view/theme_setting_page.dart';
import 'package:flutter_module/pages/tree/bindings/tabs_binding.dart';
import 'package:flutter_module/pages/tree/view/tabs_page.dart';
import 'package:flutter_module/pages/tree/view/tree_page.dart';
import 'package:flutter_module/pages/web/binding/web_binding.dart';
import 'package:flutter_module/pages/web/view/web_page.dart';
import 'package:flutter_module/routes/middleware/login_middleware.dart';
import 'package:flutter_module/routes/middleware/web_middleware.dart';

abstract class Routes {
  Routes._();

  static const coinRink = '/coinRink';

  static const hotKey = "/hotKey";

  static const searchResult = "/searchResult";

  static const tree = "/tree";

  static const project = "/project";

  static const publicNumber = "/publicNumber";

  static const main = "/main";

  static const login = "/login";

  static const register = "/register";

  static const myCoinHistory = "/myCoinHistory";

  static const myCollect = "/myCollect";

  static const web = "/web/:notShowCollectIcon";

  static const welcome = "/welcome";

  static const splash = "/splash";

  static const unknown = "/unknown";

  static const stateMixinExample = "/stateMixinExample";

  static const themeSetting = "/themeSetting";

  ///页面合集
  static final routePage = [
    GetPage(
      name: coinRink,
      page: () => const CoinRankPage(),
      binding: CoinRankBinding(),
      middlewares: [LoginMiddleware()],
    ),
    GetPage(
      name: hotKey,
      page: () => const HotKeyPage(),
      binding: HotKeyBinding(),
    ),
    GetPage(
      name: searchResult,
      page: () => const SearchResultPage(),
      binding: SearchResultBinding(),
    ),
    GetPage(
      name: tree,
      page: () => const TreePage(),
      binding: TabsBinding(TagType.tree),
    ),
    GetPage(
      name: project,
      page: () => const TabsPage(
        type: TagType.project,
      ),
      binding: TabsBinding(TagType.project),
    ),
    GetPage(
      name: publicNumber,
      page: () => const TabsPage(
        type: TagType.publicNumber,
      ),
      binding: TabsBinding(TagType.publicNumber),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        HomeBinding(),
        TabsBinding(TagType.project),
        TabsBinding(TagType.publicNumber),
        TabsBinding(TagType.tree),
        MyBinding(),
      ],
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: myCoinHistory,
      page: () => const MyCoinHistoryPage(),
      binding: MyCoinHistoryBinding(),
    ),
    GetPage(
      name: myCollect,
      page: () => const MyCollectPage(),
      bindings: [
        MyCollectBinding(),
        WebBinding(),
      ],
    ),
    GetPage(
      name: web,
      page: () => WebPage(),
      binding: WebBinding(),
      middlewares: [WebMiddleware()],
    ),
    GetPage(
      name: stateMixinExample,
      page: () => const StateMixinExamplePage(),
      binding: StateMixinBinding(),
    ),
    GetPage(
      name: unknown,
      page: () => const UnknownPage(),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
    ),
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: themeSetting, page: () => const ThemeSettingPage()),
  ];

  static final unknownPage = GetPage(
    name: Routes.unknown,
    page: () => const UnknownPage(),
  );
}
