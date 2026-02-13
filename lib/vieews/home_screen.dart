import 'package:flutter/material.dart';
import 'package:qkwashowner/models/api_models.dart';
import 'package:qkwashowner/services/api_service.dart';
import 'package:qkwashowner/vieews/devicedetailspage.dart';
import 'package:qkwashowner/vieews/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  HubStatus? _hubStatus;
  List<Device> _devices = [];
  bool _isLoadingStatus = true;
  bool _isLoadingDevices = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadDeviceStatus(), _loadDeviceInfo()]);
  }

  Future<void> _loadDeviceStatus() async {
    setState(() {
      _isLoadingStatus = true;
      _errorMessage = null;
    });

    final response = await _apiService.getDeviceStatus();

    if (mounted) {
      setState(() {
        _isLoadingStatus = false;
        if (response.success && response.data != null) {
          if (response.data!.hubs.isNotEmpty) {
            _hubStatus = response.data!.hubs.first;
          }
        } else {
          _errorMessage = response.errorMessage;
        }
      });
    }
  }

  Future<void> _loadDeviceInfo() async {
    setState(() {
      _isLoadingDevices = true;
    });

    final response = await _apiService.getDeviceInfo();

    if (mounted) {
      setState(() {
        _isLoadingDevices = false;
        if (response.success && response.data != null) {
          if (response.data!.hubs.isNotEmpty) {
            _devices = response.data!.hubs.first.devices;
          }
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      _apiService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 186, 203),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'QK WASH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _handleLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.logout, color: Colors.black, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF2196F3),
        backgroundColor: Colors.white,
        child: _errorMessage != null
            ? _buildErrorView()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hub Info Section
                    _buildHubInfoSection(),
                    const SizedBox(height: 16),
                    // Earnings Cards Section
                    _buildEarningsSection(),
                    const SizedBox(height: 20),
                    // Your Devices Section
                    _buildDevicesSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubInfoSection() {
    if (_isLoadingStatus) {
      return Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 191, 186, 203),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(width: 100, height: 12, child: LinearProgressIndicator()),
            SizedBox(height: 8),
            SizedBox(width: 150, height: 16, child: LinearProgressIndicator()),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 191, 186, 203),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hub ID #${_hubStatus?.hubId ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hubStatus?.hubName.toUpperCase() ?? 'NO HUB',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildEarningCard(
                  title: "Today's Earnings",
                  amount: '\$ ${_hubStatus?.todayEarnings ?? 0}',
                  color: const Color(0xFFB2DFDB),
                  washes: _hubStatus?.todayWashes ?? 0,
                  dryers: _hubStatus?.todayDryers ?? 0,
                  isLoading: _isLoadingStatus,
                ),
                const SizedBox(height: 10),
                _buildEarningCard(
                  title: "Last Month's Earnings",
                  amount: '\$ ${_hubStatus?.lastMonthEarnings ?? 0}',
                  color: const Color(0xFF81C784),
                  isLoading: _isLoadingStatus,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildEarningCard(
              title: 'Total Earnings',
              amount: '\$ ${_hubStatus?.totalEarnings ?? 0}',
              color: const Color.fromARGB(255, 132, 126, 186),
              height: 300,
              isLoading: _isLoadingStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningCard({
    required String title,
    required String amount,
    required Color color,
    int? washes,
    int? dryers,
    double? height,
    required bool isLoading,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: height != null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(height: 8),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (washes != null && dryers != null) ...[
                  // const SizedBox(height: ),
                  Row(
                    children: [
                      Text(
                        '$washes washes',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$dryers dryers',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildDevicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Devices',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 13),
            // Device List
            SizedBox(
              height: 240,
              child: _isLoadingDevices
                  ? const Center(child: CircularProgressIndicator())
                  : _devices.isEmpty
                  ? const Center(
                      child: Text(
                        'No devices found',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  : ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 141, 193, 236),
                        ),
                        trackColor: MaterialStateProperty.all(
                          Colors.grey.shade300,
                        ),
                        thickness: MaterialStateProperty.all(4),
                        radius: const Radius.circular(8),
                        thumbVisibility: MaterialStateProperty.all(true),
                        trackVisibility: MaterialStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(right: 12, bottom: 4),
                          itemCount: _devices.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return _buildDeviceCard(device: device);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({required Device device}) {
    print(
      "homepage Device ${device.deviceId} status: [${device.deviceStatus}]",
    );
    return GestureDetector(
      onTap: () {
        if (_hubStatus != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DeviceDetailPage(device: device, hubStatus: _hubStatus!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFBBDEFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Device Icon
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                device.getDeviceIconPath(),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            // Device Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${device.deviceType} ${device.deviceId}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Machine ID',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '#${device.deviceId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Status Indicator and Icon
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Indicator Dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: device.getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                // Status Icon
                Icon(
                  device.getStatusIcon(),
                  color: Colors.white.withOpacity(0.75),
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
