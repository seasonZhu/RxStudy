import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_module/generated/assets.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:flutter_module/pages/common/my_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_module/extension/string_extension.dart';
import 'package:flutter_module/routes/routes.dart';
import 'package:flutter_module/pages/common/info_cell.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/home/controller/home_controller.dart';
import 'package:flutter_module/pages/common/refresh_header_footer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("首页"),
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.search),
          onPressed: (() => Get.toNamed(Routes.hotKey)),
        ),
      ),
      child: StatusView<HomeController>(
        contentBuilder: (controller) {
          return SmartRefresher(
            enablePullUp: true,
            header: const RefreshHeader(),
            footer: const RefreshFooter(),
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: CustomScrollView(
              slivers: <Widget>[
                /// 随便把一个Widget放到CustomScrollView中的slivers它是不认识的,通过SliverToBoxAdapter适配器包裹就可以了
                SliverToBoxAdapter(
                  child: AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Swiper(
                      itemBuilder: (BuildContext itemContext, int index) {
                        if (controller.banners.length >= index) {
                          return CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl: controller.banners[index].imagePath,
                            placeholder: (context, url) => Image.asset(
                              Assets.assetsImagesPlaceholder,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                      itemCount: controller.banners.length,
                      pagination: const SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                            color: Colors.grey, activeColor: Colors.blue),
                      ),
                      autoplay: controller.swiperAutoPlay,
                      autoplayDisableOnInteraction: true,
                      onTap: (index) {
                        logger.d(index);
                        Get.toNamed("/web/true",
                            arguments: controller.banners[index]);
                      },
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (content, index) {
                      final model = controller.dataSource[index];
                      return InfoCell(
                        model: model,
                        callback: (_) async {
                          logger.d("点击了");
                          if (model.id == 24742) {
                            if (model.link != null) {
                              final url = Uri.parse(
                                  model.link.toString().replaceHtmlElement);
                              if (await canLaunchUrl(url)) {
                                launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                Get.snackbar(
                                  "",
                                  "请安装手机QQ",
                                  duration: const Duration(seconds: 1),
                                );
                              }
                            }
                          } else {
                            Get.toNamed(Routes.web, arguments: model);
                          }
                        },
                      );
                    },
                    childCount: controller.dataSource.length,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  /// 使用自定义的MyListView进行布局
  Widget _myListView() {
    return MyListView(
      banner: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Swiper(
          itemBuilder: (BuildContext itemContext, int index) {
            if (controller.banners.length >= index) {
              return CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: controller.banners[index].imagePath,
                placeholder: (context, url) => Image.asset(
                  Assets.assetsImagesPlaceholder,
                ),
              );
            } else {
              return Container();
            }
          },
          itemCount: controller.banners.length,
          pagination: const SwiperPagination(),
          autoplay: controller.swiperAutoPlay,
          autoplayDisableOnInteraction: true,
          onTap: (index) {
            logger.d(index);
            Get.toNamed("/web/true", arguments: controller.banners[index]);
          },
        ),
      ),
      itemBuilder: (context, index) {
        final model = controller.dataSource[index];
        return InfoCell(
          model: model,
          callback: (_) async {
            logger.d("点击了");
            if (model.id == 24742) {
              if (model.link != null) {
                final url = Uri.parse(model.link.toString().replaceHtmlElement);
                if (await canLaunchUrl(url)) {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar(
                    "",
                    "请安装手机QQ",
                    duration: const Duration(seconds: 1),
                  );
                }
              }
            } else {
              Get.toNamed(Routes.web, arguments: model);
            }
          },
        );
      },
      itemCount: controller.dataSource.length,
    );
  }
}
