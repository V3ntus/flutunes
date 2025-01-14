import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/api/constants.dart';
import 'package:flutunes/api/http.dart';
import 'package:flutunes/api/routes/users.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'auth_test.mocks.dart';

class MockDio extends Mock implements Dio {}

@GenerateMocks([MockDio])
void main() {
  group(
    "Users API route",
    () {
      late JellyfinClient client;
      late MockMockDio mockDio;

      test('PreferenceKeys toString == key', () {
        expect(
          PreferenceKeys.values[0].toString(),
          equals(PreferenceKeys.values[0].key),
        );
      });

      setUp(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(
          {
            PreferenceKeys.SERVER_URL.key: TEST_ROOT_URL,
          },
        );
        mockDio = MockMockDio();
        client = JellyfinClient(http: Http(dio: mockDio));
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
          when(mockDio.requestUri(
            Uri.parse("$TEST_ROOT_URL$loginPath"),
            data: anyNamed("data"),
            options: anyNamed("options"),
          )).thenAnswer(
            (Invocation real) async {
              if (real.namedArguments[Symbol("data")]["Pw"] == "incorrect") {
                return Response(
                  requestOptions: RequestOptions(path: loginPath),
                  statusCode: 401,
                );
              }
              return Response(
                data: loginResult,
                requestOptions: RequestOptions(path: loginPath),
                statusCode: 200,
              );
            },
          );

          // Act
          expect(client.http.currentUser, isNull);
          expect(
            () async => await client.http.request("POST", Uri.parse(TEST_ROOT_URL)),
            throwsA(isA<StateError>()),
          );
          final authResponse = await client.login(TEST_ROOT_URL, "", "");

          // Assert
          expect(authResponse, isA<UserModel>());
          expect(authResponse.json, equals(loginResult["User"]));
          expect(client.http.accessToken, equals("ACCESS_TOKEN_TEST"));
          expect(client.http.currentUser, isNotNull);

          expect(
            () async => await client.login(TEST_ROOT_URL, "", "incorrect").then(
                  (u) async => expect(client.http.currentUser, isNull),
                ),
            throwsA(isA<IncorrectCredentialsError>()),
          );
        },
      );
    },
  );
}
