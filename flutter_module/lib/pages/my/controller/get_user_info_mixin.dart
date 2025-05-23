import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/base_request_controller.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/pages/my/repository/my_repository.dart';

mixin GetUserInfoMixin
    on BaseRequestController<MyRepository, AccountInfoEntity> {
  var userInfo = "等级 --  排名 --  积分 --";

  Future<String> getUserCoinInfo() async {
    final response = await request.getUserCoinInfo();
    final userInfo =
        "等级 ${response.data?.level ?? "--"}  排名 ${response.data?.rank ?? "--"}  积分 ${response.data?.coinCount ?? "--"}";
    this.userInfo = userInfo;
    AccountService.find.userInfo = userInfo;
    return userInfo;
  }
}
