import 'package:flutunes/models/_base.dart';

class SystemInfoModel extends BaseModel {
  final String? localAddress;
  final String? serverName;
  final String? version;
  final String? productName;
  final String? id;
  final bool? startupWizardCompleted;
  final String? packageName;
  final bool hasPendingRestart;
  final bool isShuttingDown;
  final bool supportsLibraryMonitor;
  final int webSocketPortNumber;

  static SystemInfoModel fromJson(Map<String, dynamic> json) {
    return SystemInfoModel(
      localAddress: json["LocalAddress"],
      serverName: json["ServerName"],
      version: json["Version"],
      productName: json["ProductName"],
      id: json["Id"],
      hasPendingRestart: json["HasPendingRestart"],
      isShuttingDown: json["IsShuttingDown"],
      supportsLibraryMonitor: json["SupportsLibraryMonitor"],
      webSocketPortNumber: json["WebSocketPortNumber"],
    );
  }

  @override
  Map<String, dynamic> get json => throw UnimplementedError("");

  SystemInfoModel({
    this.localAddress,
    this.serverName,
    this.version,
    this.productName,
    this.id,
    this.startupWizardCompleted,
    this.packageName,
    required this.hasPendingRestart,
    required this.isShuttingDown,
    required this.supportsLibraryMonitor,
    required this.webSocketPortNumber,
  });
}
