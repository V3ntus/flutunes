import 'package:dio/dio.dart';
import 'package:flutunes/api/routes/_base.dart';
import 'package:flutunes/models/system_info.dart';

class System extends BaseRoute {
  System(super.client);

  Future<SystemInfoModel> info() async {
    final Response response = await client.request(
      "GET",
      ((await client.baseUri()).replace(path: "/System/Info")),
    );

    return SystemInfoModel.fromJson(response.data);
  }
}
