import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qkwashowner/models/api_models.dart';

class ApiService {
  static const String baseUrl = 'https://api.qkwash.com/api';

 
  late final http.Client _client;

  
  static ApiService? _instance;

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  
  ApiService._internal() {
    _client = http.Client();
  }

  
  ApiService.withClient(http.Client client) : _client = client;

  
  String? _sessionToken;
  String? _userEmail;
  Owner? _currentOwner;

  
  String? get sessionToken => _sessionToken;
  String? get userEmail => _userEmail;
  Owner? get currentOwner => _currentOwner;
  bool get isLoggedIn => _sessionToken != null && _userEmail != null;

  
  void clearSession() {
    _sessionToken = null;
    _userEmail = null;
    _currentOwner = null;
  }

  
  bool _isJsonResponse(String body) {
    final trimmed = body.trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  
  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      if (!_isJsonResponse(response.body)) {
        throw FormatException(
          'Server returned HTML instead of JSON. '
          'Status: ${response.statusCode}\n'
          'Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        );
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw FormatException('Failed to parse JSON: ${e.toString()}');
      }
    } else {
      if (_isJsonResponse(response.body)) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Request failed: ${response.statusCode}',
        );
      } else {
        throw Exception(
          'Endpoint not found (${response.statusCode}). '
          'The API path may be incorrect.\n'
          'Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        );
      }
    }
  }

  /// 1  Login
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      print(' Login URL: $baseUrl/owner/login');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/owner/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'owneremailid': email,
              'ownerpassword': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print(' Response: ${response.statusCode}');

      final data = _parseResponse(response);
      final loginResponse = LoginResponse.fromJson(data);

      _sessionToken = loginResponse.token;
      _userEmail = email;
      _currentOwner = loginResponse.owner;

      print(' Login successful');
      return ApiResponse.success(loginResponse);
    } catch (e) {
      print(' Login error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// 2 Show Hub Device Status List
  Future<ApiResponse<DeviceStatusResponse>> getDeviceStatus() async {
    if (!isLoggedIn) {
      return ApiResponse.error('Not logged in');
    }

    try {
      print(' Device Status URL: $baseUrl/ownerdashboard/devicestatus');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/ownerdashboard/devicestatus'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _userEmail,
              'sessionToken': _sessionToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print(' Response: ${response.statusCode}');

      final data = _parseResponse(response);
      final deviceStatusResponse = DeviceStatusResponse.fromJson(data);

      print(' Device status fetched');
      return ApiResponse.success(deviceStatusResponse);
    } catch (e) {
      print(' Device status error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// 3 Device Information
  Future<ApiResponse<DeviceInfoResponse>> getDeviceInfo() async {
    if (!isLoggedIn) {
      return ApiResponse.error('Not logged in');
    }

    try {
      print(' Device Info URL: $baseUrl/ownerdashboard/deviceinfo');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/ownerdashboard/deviceinfo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _userEmail,
              'sessionToken': _sessionToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print(' Response: ${response.statusCode}');

      final data = _parseResponse(response);
      final deviceInfoResponse = DeviceInfoResponse.fromJson(data);

      print(' Device info fetched');
      return ApiResponse.success(deviceInfoResponse);
    } catch (e) {
      print(' Device info error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// 4 getDeviceHistory
  Future<ApiResponse<DeviceHistoryResponse>> getDeviceHistory({
    required String deviceId,
  }) async {
    if (!isLoggedIn) {
      return ApiResponse.error('Not logged in');
    }

    
    final endpoints = [
      '$baseUrl/ownerdashboard/devicehistory',
      '$baseUrl/owner/dashboard/devicehistory', 
      '$baseUrl/devicehistory', 
      'https://api.qkwash.com/ownerdashboard/devicehistory', 
    ];

    Exception? lastError;

    for (var endpoint in endpoints) {
      try {
        print(' Trying Device History URL: $endpoint');

        final response = await _client
            .post(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': _userEmail,
                'sessionToken': _sessionToken,
                'deviceId': deviceId,
              }),
            )
            .timeout(const Duration(seconds: 30));

        print(' Response: ${response.statusCode}');

        if (response.statusCode == 200 && _isJsonResponse(response.body)) {
          final data = jsonDecode(response.body);
          final deviceHistoryResponse = DeviceHistoryResponse.fromJson(data);

          print('Device history fetched from: $endpoint');
          print(' Found ${deviceHistoryResponse.data.length} records');
          return ApiResponse.success(deviceHistoryResponse);
        } else if (response.statusCode != 404) {
          // If not 404, try to parse the error
          final data = _parseResponse(response);
          final deviceHistoryResponse = DeviceHistoryResponse.fromJson(data);
          return ApiResponse.success(deviceHistoryResponse);
        }

        print(' Endpoint not found, trying next...');
      } catch (e) {
        print(' Failed with: $e');
        lastError = e as Exception?;
        continue;
      }
    }

    print(' All endpoints failed - returning empty history');
    
    return ApiResponse.success(
      DeviceHistoryResponse(message: 'No endpoint available', data: []),
    );
  }

  /// getDeviceHistoryCustom
  Future<ApiResponse<DeviceHistoryResponse>> getDeviceHistoryCustom({
    required String deviceId,
    required String customEndpoint,
  }) async {
    if (!isLoggedIn) {
      return ApiResponse.error('Not logged in');
    }

    try {
      print(' Custom Device History URL: $customEndpoint');

      final response = await _client
          .post(
            Uri.parse(customEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _userEmail,
              'sessionToken': _sessionToken,
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print(' Response: ${response.statusCode}');
      print(
        ' Body preview: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
      );

      final data = _parseResponse(response);
      final deviceHistoryResponse = DeviceHistoryResponse.fromJson(data);

      print(
        ' Device history fetched: ${deviceHistoryResponse.data.length} records',
      );
      return ApiResponse.success(deviceHistoryResponse);
    } catch (e) {
      print(' Device history error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  void logout() {
    print(' Logging out');
    clearSession();
  }
}

///  API Response 
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}
