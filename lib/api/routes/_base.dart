import 'package:flutunes/api/http.dart';

abstract class BaseRoute {
  final Http client;

  BaseRoute(this.client);
}
