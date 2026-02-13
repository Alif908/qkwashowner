import 'package:flutter/material.dart';

/// Loginrespose
class LoginResponse {
  final String message;
  final String token;
  final Owner owner;

  LoginResponse({
    required this.message,
    required this.token,
    required this.owner,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      owner: Owner.fromJson(json['owner'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'token': token, 'owner': owner.toJson()};
  }
}

///  Model
class Owner {
  final int ownerId;
  final String ownerEmailId;
  final String? ownerName;
  final String ownerHubId;

  Owner({
    required this.ownerId,
    required this.ownerEmailId,
    this.ownerName,
    required this.ownerHubId,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      ownerId: json['ownerid'] ?? 0,
      ownerEmailId: json['owneremailid'] ?? '',
      ownerName: json['ownername'],
      ownerHubId: json['ownerhubid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerid': ownerId,
      'owneremailid': ownerEmailId,
      'ownername': ownerName,
      'ownerhubid': ownerHubId,
    };
  }
}

/// Device Status Response
class DeviceStatusResponse {
  final String message;
  final List<HubStatus> hubs;

  DeviceStatusResponse({required this.message, required this.hubs});

  factory DeviceStatusResponse.fromJson(Map<String, dynamic> json) {
    return DeviceStatusResponse(
      message: json['message'] ?? '',
      hubs:
          (json['hubs'] as List<dynamic>?)
              ?.map((hub) => HubStatus.fromJson(hub))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'hubs': hubs.map((hub) => hub.toJson()).toList(),
    };
  }
}

/// hub status model
class HubStatus {
  final String hubId;
  final String hubName;
  final int todayEarnings;
  final int lastMonthEarnings;
  final int totalEarnings;
  final int todayWashes;
  final int todayDryers;

  HubStatus({
    required this.hubId,
    required this.hubName,
    required this.todayEarnings,
    required this.lastMonthEarnings,
    required this.totalEarnings,
    required this.todayWashes,
    required this.todayDryers,
  });

  factory HubStatus.fromJson(Map<String, dynamic> json) {
    return HubStatus(
      hubId: json['hubid'] ?? '',
      hubName: json['hubname'] ?? '',
      todayEarnings: json['todayEarnings'] ?? 0,
      lastMonthEarnings: json['lastMonthEarnings'] ?? 0,
      totalEarnings: json['totalEarnings'] ?? 0,
      todayWashes: json['todayWashes'] ?? 0,
      todayDryers: json['todayDryers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hubid': hubId,
      'hubname': hubName,
      'todayEarnings': todayEarnings,
      'lastMonthEarnings': lastMonthEarnings,
      'totalEarnings': totalEarnings,
      'todayWashes': todayWashes,
      'todayDryers': todayDryers,
    };
  }
}

/// device info respnse
class DeviceInfoResponse {
  final String message;
  final List<HubInfo> hubs;

  DeviceInfoResponse({required this.message, required this.hubs});

  factory DeviceInfoResponse.fromJson(Map<String, dynamic> json) {
    return DeviceInfoResponse(
      message: json['message'] ?? '',
      hubs:
          (json['hubs'] as List<dynamic>?)
              ?.map((hub) => HubInfo.fromJson(hub))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'hubs': hubs.map((hub) => hub.toJson()).toList(),
    };
  }
}

/// hubinfo model
class HubInfo {
  final String hubId;
  final String hubName;
  final List<Device> devices;

  HubInfo({required this.hubId, required this.hubName, required this.devices});

  factory HubInfo.fromJson(Map<String, dynamic> json) {
    return HubInfo(
      hubId: json['hubid'] ?? '',
      hubName: json['hubname'] ?? '',
      devices:
          (json['devices'] as List<dynamic>?)
              ?.map((device) => Device.fromJson(device))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hubid': hubId,
      'hubname': hubName,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }
}


/// Device Model
class Device {
  final int deviceId;
  final String deviceType;
  final String deviceStatus;
  final String deviceCondition;

  Device({
    required this.deviceId,
    required this.deviceType,
    required this.deviceStatus,
    required this.deviceCondition,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceid'] ?? 0,
      deviceType: json['devicetype'] ?? '',
      deviceStatus: json['devicestatus'] ?? '',
      deviceCondition: json['devicecondition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceid': deviceId,
      'devicetype': deviceType,
      'devicestatus': deviceStatus,
      'devicecondition': deviceCondition,
    };
  }

  // Get combined display status 
  String getDisplayStatus() {
    
    if (deviceCondition.toLowerCase() == 'maintenance' ||
        deviceCondition.toLowerCase() == 'not working') {
      return deviceCondition;
    }
   
    return deviceStatus;
  }

  // get status color - Based on condition + status
  Color getStatusColor() {
    final condition = deviceCondition.toLowerCase();
    final status = deviceStatus.toLowerCase();

    print(
      '🎨 getStatusColor - Device ID: $deviceId, Condition: "$deviceCondition", Status: "$deviceStatus"',
    );

    // Check condition first (Maintenance/Not Working = Red)
    if (condition == 'maintenance' || condition == 'not working') {
      print('   🔴 Returning RED (Maintenance/Not Working)');
      return const Color(0xFFF44336); // Red
    }

    // Check if device is running/busy (Blue)
    if (status == 'running' || status == 'busy') {
      print('   🔵 Returning BLUE (Running/Busy)');
      return const Color(0xFF2196F3); // Blue
    }

    // If condition is good and status is ready (Green)
    if ((condition == 'good' || condition == '') &&
        (status == 'ready' || status == 'online')) {
      print('   ✅ Returning GREEN (Ready/Online)');
      return const Color(0xFF4CAF50); // Green
    }

    // Offline
    if (status == 'offline') {
      print('   🔴 Returning RED (Offline)');
      return const Color(0xFFF44336); // Red
    }

    print('   ⚪ Returning GRAY (Unknown)');
    return const Color(0xFF9E9E9E); // Gray
  }

  // get status icon - Based on your design image
  IconData getStatusIcon() {
    final condition = deviceCondition.toLowerCase();
    final status = deviceStatus.toLowerCase();

    print(
      '🔰 getStatusIcon - Device ID: $deviceId, Condition: "$deviceCondition", Status: "$deviceStatus"',
    );

    // Maintenance/Not Working → Wrench icon
    if (condition == 'maintenance' || condition == 'not working') {
      print('   🔧 Returning wrench icon (Maintenance)');
      return Icons.build; // Wrench icon
    }

    // Running/Busy → Hourglass icon
    if (status == 'running' || status == 'busy') {
      print('   ⏳ Returning hourglass icon (Running)');
      return Icons.hourglass_empty; // Hourglass icon
    }

    // Ready/Online/Good → Clock icon
    if (status == 'ready' || status == 'online' || condition == 'good') {
      print('   ⏰ Returning clock icon (Ready)');
      return Icons.access_time; // Clock icon
    }

    // Offline
    if (status == 'offline') {
      print('   ❌ Returning offline icon');
      return Icons.wifi_off;
    }

    print('   ❓ Returning help icon (Unknown)');
    return Icons.help_outline;
  }

  // get device icon path - Same logic
  String getDeviceIconPath() {
    final status = deviceStatus.toLowerCase();

    print(
      '🖼️  getDeviceIconPath - Device ID: $deviceId, Status: "$deviceStatus"',
    );

    // Show running machine icon if device is running/busy
    if (status == 'running' || status == 'busy') {
      print('   🏃 Returning running machine image');
      return 'assets/images/ruuning machine.png';
    }
    // Otherwise show static machine icon
    else {
      print('   🔌 Returning online and maintenance image');
      return 'assets/images/online and maintaince.png';
    }
  }
}

class DeviceHistoryResponse {
  final String message;
  final List<DeviceHistory> data;

  DeviceHistoryResponse({required this.message, required this.data});

  factory DeviceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DeviceHistoryResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((history) => DeviceHistory.fromJson(history))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((history) => history.toJson()).toList(),
    };
  }
}

/// Device History Model
class DeviceHistory {
  final DateTime endTime;
  final String userMobileNo;
  final String washMode;
  final int amount;

  DeviceHistory({
    required this.endTime,
    required this.userMobileNo,
    required this.washMode,
    required this.amount,
  });

  factory DeviceHistory.fromJson(Map<String, dynamic> json) {
    return DeviceHistory(
      endTime: DateTime.parse(
        json['device_booked_user_end_time'] ?? DateTime.now().toIso8601String(),
      ),
      userMobileNo: json['device_booked_user_mobile_no'] ?? '',
      washMode: json['booked_user_selected_wash_mode'] ?? '',
      amount: json['booked_user_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_booked_user_end_time': endTime.toIso8601String(),
      'device_booked_user_mobile_no': userMobileNo,
      'booked_user_selected_wash_mode': washMode,
      'booked_user_amount': amount,
    };
  }

  // format date
  String getFormattedDate() {
    return '${endTime.day.toString().padLeft(2, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.year.toString().substring(2)}';
  }

  //  format time
  String getFormattedTime() {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // get user ID (last 4 digits of mobile)
  String getUserId() {
    if (userMobileNo.length >= 4) {
      return 'U${userMobileNo.substring(userMobileNo.length - 4)}';
    }
    return 'U0000';
  }
}
