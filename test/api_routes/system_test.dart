import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/api/constants.dart';
import 'package:flutunes/api/http.dart';
import 'package:flutunes/models/system_info.dart';
import 'package:flutunes/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'system_test.mocks.dart';

class MockDio extends Mock implements Dio {}

@GenerateMocks([MockDio])
void main() {
  group("System API route", () {
    late final JellyfinClient client;
    late final MockMockDio mockDio;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(
        {
          PreferenceKeys.SERVER_URL.key: TEST_ROOT_URL,
        },
      );
      mockDio = MockMockDio();
      client = JellyfinClient(http: Http(dio: mockDio));

      const Map<String, dynamic> loginResult = {
        "User": {
          "Name": "USER_NAME_TEST",
          "ServerId": "USER_SERVER_ID_TEST",
          "ServerName": "USER_SERVER_NAME_TEST",
          "PrimaryImageTag": "PRIMARY_IMAGE_TAG_TEST",
          "Id": "ID_TEST",
          "EnableAutoLogin": true,
        },
        "SessionInfo": {},
        "AccessToken": "ACCESS_TOKEN_TEST",
        "ServerId": "SERVER_ID_TEST",
      };

      when(mockDio.requestUri(
        Uri.parse("$TEST_ROOT_URL/Users/AuthenticateByName"),
        data: anyNamed("data"),
        options: anyNamed("options"),
      )).thenAnswer(
        (_) async => Response(
          data: loginResult,
          requestOptions: RequestOptions(),
          statusCode: 200,
        ),
      );
    });

    test(
      'info returns a SystemInfo model on success',
      () async {
        // Arrange
        const systemInfoPath = "/System/Info";
        const systemInfoResult = {
          "LocalAddress": "string",
          "ServerName": "string",
          "Version": "string",
          "ProductName": "string",
          "Id": "string",
          "StartupWizardCompleted": true,
          "PackageName": "string",
          "HasPendingRestart": true,
          "IsShuttingDown": true,
          "SupportsLibraryMonitor": true,
          "WebSocketPortNumber": 0,
        };
        when(mockDio.requestUri(Uri.parse("$TEST_ROOT_URL$systemInfoPath"), options: anyNamed("options"))).thenAnswer(
          (_) async => Response(
            data: systemInfoResult,
            requestOptions: RequestOptions(path: systemInfoPath),
            statusCode: 200,
          ),
        );

        // Act
        await client.login("", "");
        final SystemInfoModel response = await client.http.system.info();

        // Assert
        expect(
          () => SystemInfoModel(
            hasPendingRestart: false,
            isShuttingDown: false,
            supportsLibraryMonitor: false,
            webSocketPortNumber: 0,
          ).json,
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}
