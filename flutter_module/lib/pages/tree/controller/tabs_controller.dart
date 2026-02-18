import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/base/base_request_controller.dart';
import 'package:flutter_module/entity/tab_entity.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/pages/tree/repository/tabs_repository.dart';
import 'package:flutter_module/logger/logger.dart';

class TabsController
    extends BaseRequestController<TabsRepository, List<TabEntity>>
    with ScrollMixin {
  TabsController(this.type);

  TagType type;

  @override
  void onInit() async {
    super.onInit();
    request = Get.find(tag: type.toString());
    aRequest();
  }

  @override
  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    response = await request.getTab().catchError((error) {
      status = ResponseStatus.fail;
      update();
      return error;
    });
    data = response?.data ?? [];
    status = response?.responseStatus ?? ResponseStatus.loading;
    update();
  }

  @override
  Future<void> onTopScroll() async {
    logger.d("滑到了顶部");
  }

  @override
  Future<void> onEndScroll() async {
    logger.d("滑到了底部");
  }
}
