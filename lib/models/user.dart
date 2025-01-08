class UserModel {
  final String name;
  final String? serverId;
  final String? serverName;
  final String? primaryImageTag;
  final String id;
  final bool enableAutoLogin;

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["Name"],
      serverId: json["ServerId"],
      serverName: json["ServerName"],
      primaryImageTag: json["PrimaryImageTag"],
      id: json["Id"],
      enableAutoLogin: json["EnableAutoLogin"],
    );
  }

  Map<String, dynamic> get json => {
    "Name": name,
    "ServerId": serverId,
    "ServerName": serverName,
    "PrimaryImageTag": primaryImageTag,
    "Id": id,
    "EnableAutoLogin": enableAutoLogin,
  };

  UserModel({
    required this.name,
    this.serverId,
    this.serverName,
    this.primaryImageTag,
    required this.id,
    required this.enableAutoLogin,
  });
}
