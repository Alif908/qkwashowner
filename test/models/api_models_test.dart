import 'package:flutter_test/flutter_test.dart';
import 'package:qkwashowner/models/api_models.dart';

void main() {

  group('LoginResponse Model Test', () {

    test('LoginResponse fromJson parses correctly', () {

      final json = {
        "message": "Login successful",
        "token": "abc123",
        "owner": {
          "ownerid": 10,
          "owneremailid": "test@mail.com",
          "ownername": "Test Owner",
          "ownerhubid": "HUB001"
        }
      };

      final result = LoginResponse.fromJson(json);

      expect(result.message, "Login successful");
      expect(result.token, "abc123");
      expect(result.owner.ownerId, 10);
      expect(result.owner.ownerEmailId, "test@mail.com");
      expect(result.owner.ownerHubId, "HUB001");
    });
  });

  group('DeviceStatusResponse Model Test', () {

    test('Parses hub list correctly', () {

      final json = {
        "message": "Success",
        "hubs": [
          {
            "hubid": "H1",
            "hubname": "Main Hub",
            "todayEarnings": 1000,
            "lastMonthEarnings": 20000,
            "totalEarnings": 50000,
            "todayWashes": 10,
            "todayDryers": 5
          }
        ]
      };

      final result = DeviceStatusResponse.fromJson(json);

      expect(result.hubs.length, 1);
      expect(result.hubs.first.hubName, "Main Hub");
      expect(result.hubs.first.todayWashes, 10);
    });
  });

  group('Device Helper Methods Test', () {

    test('getStatusColor returns correct color for running', () {

      final device = Device(
        deviceId: 1,
        deviceType: "Washer",
        deviceStatus: "running",
        deviceCondition: "good",
      );

      expect(device.getStatusColor().value, 0xFF2196F3);
    });

    test('DeviceHistory getUserId returns last 4 digits', () {

      final history = DeviceHistory(
        endTime: DateTime(2024, 1, 1, 10, 30),
        userMobileNo: "9876543210",
        washMode: "Quick",
        amount: 50,
      );

      expect(history.getUserId(), "U3210");
      expect(history.getFormattedDate(), "01-01-24");
      expect(history.getFormattedTime(), "10:30");
    });
  });
}
