import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/models/user.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'auth_test.mocks.dart';

class MockDio extends Mock implements Dio {}

@GenerateMocks([MockDio])
void main() {
  group(
    "auth",
    () {
      late final JellyfinClient client;
      late final MockMockDio mockDio;

      setUp(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({
          "SERVER_URL": TEST_ROOT_URL,
        });
        mockDio = MockMockDio();
        client = JellyfinClient(dio: mockDio);
      });

      test(
        'login returns a User model on success',
        () async {
          // Arrange
          const testUserUUID = "5b9720dd-f1c6-4fe8-9de2-b7d746469529";
          const loginPath = "/Users/AuthenticateByName";
          const Map<String, dynamic> loginResult = {
            "User": {
              "Name": "USER_NAME_TEST",
              "ServerId": "USER_SERVER_ID_TEST",
              "ServerName": "USER_SERVER_NAME_TEST",
              "PrimaryImageTag": "PRIMARY_IMAGE_TAG_TEST",
              "Id": testUserUUID,
              "EnableAutoLogin": true,
            },
            "SessionInfo": {},
            "AccessToken": "ACCESS_TOKEN_TEST",
            "ServerId": "SERVER_ID_TEST",
          };
          when(mockDio.post(TEST_ROOT_URL + loginPath, data: anyNamed("data"))).thenAnswer(
            (_) async => Response(
              data: loginResult,
              requestOptions: RequestOptions(path: loginPath),
              statusCode: 200,
            ),
          );

          // Act
          final authResponse = await client.authenticateByName("", "");

          // Assert
          expect(authResponse, isA<UserModel>());
          expect(authResponse.json, equals(loginResult["User"]));
          expect(client.accessToken, equals("ACCESS_TOKEN_TEST"));
        },
      );
    },
  );
}
