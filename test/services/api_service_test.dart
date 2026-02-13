import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:qkwashowner/services/api_service.dart';

class MockHttpClient extends Mock implements http.Client {}

// Create a Fake Uri class
class FakeUri extends Fake implements Uri {}

void main() {
  late ApiService apiService;
  late MockHttpClient mockClient;

  // ADD THIS - Register fallback value for Uri
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    apiService = ApiService.withClient(mockClient);
  });

  group('Login API Test', () {
    test('Login success returns ApiResponse.success', () async {
      final mockResponse = {
        "message": "Login successful",
        "token": "abc123",
        "owner": {
          "ownerid": 1,
          "owneremailid": "test@mail.com",
          "ownername": "Test",
          "ownerhubid": "H1",
        },
      };

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await apiService.login(
        email: "test@mail.com",
        password: "123456",
      );

      expect(result.success, true);
      expect(result.data?.token, "abc123");
      expect(result.data?.owner.ownerId, 1);
      expect(apiService.isLoggedIn, true);
    });

    test('Login failure returns ApiResponse.error', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({"message": "Invalid credentials"}), 401),
      );

      final result = await apiService.login(
        email: "wrong@mail.com",
        password: "wrong",
      );

      expect(result.success, false);
      expect(result.errorMessage, contains("Invalid credentials"));
      expect(apiService.isLoggedIn, false);
    });
  });

  group('DeviceStatus Not Logged In Test', () {
    test('Returns error when not logged in', () async {
      final result = await apiService.getDeviceStatus();

      expect(result.success, false);
      expect(result.errorMessage, "Not logged in");
    });
  });
}
