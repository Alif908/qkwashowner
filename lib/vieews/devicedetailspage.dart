import 'package:flutter/material.dart';
import 'package:qkwashowner/models/api_models.dart';
import 'package:qkwashowner/services/api_service.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;
  final HubStatus hubStatus;

  const DeviceDetailPage({
    Key? key,
    required this.device,
    required this.hubStatus,
  }) : super(key: key);

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final ApiService _apiService = ApiService();

  int _todayCount = 0;
  int _lastWeekCount = 0;
  int _lastMonthCount = 0;

  List<DeviceHistory> _transactionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDeviceHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load device history from API
  Future<void> _loadDeviceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getDeviceHistory(
        deviceId: widget.device.deviceId.toString(),
      );

      if (response.success && response.data != null) {
        setState(() {
          _transactionHistory = response.data!.data;
          _calculateUsageCounts();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load history';
          _isLoading = false;
          // Keep empty list if API fails
          _transactionHistory = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading device history: $e';
        _isLoading = false;
        _transactionHistory = [];
      });
    }
  }

  /// Calculate usage counts for today, last week, and last month
  void _calculateUsageCounts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));

    _todayCount = _transactionHistory.where((history) {
      final historyDate = DateTime(
        history.endTime.year,
        history.endTime.month,
        history.endTime.day,
      );
      return historyDate.isAtSameMomentAs(today);
    }).length;

    _lastWeekCount = _transactionHistory.where((history) {
      return history.endTime.isAfter(lastWeek);
    }).length;

    _lastMonthCount = _transactionHistory.where((history) {
      return history.endTime.isAfter(lastMonth);
    }).length;
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    await _loadDeviceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 186, 203),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QK WASH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                'Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF2196F3),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hub Info Section
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 191, 186, 203),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hub ID #${widget.hubStatus.hubId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.hubStatus.hubName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Text(
                        'BOOK SERVICE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.device.deviceType} ${widget.device.deviceId}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              widget.device.getDeviceIconPath(),
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 20),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: widget.device.getStatusColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.device.deviceId.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 191, 186, 203),
                          ),
                          child: Column(
                            children: [
                              // Usage Statistics
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB2DFDB),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'TODAY',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$_todayCount',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF81C784),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'LAST WEEK',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$_lastWeekCount',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB39DDB),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'LAST MONTH',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$_lastMonthCount',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Transaction History Table
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    // Table Headers
                                    Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "DATE",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 65,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "USER ID",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 90,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "CYCLES",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "AMOUNT",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Table Content
                                    Container(
                                      height: 220,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(
                                          255,
                                          191,
                                          186,
                                          203,
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF2196F3),
                                              ),
                                            )
                                          : _errorMessage != null
                                          ? Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  _errorMessage!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : _transactionHistory.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No transaction history',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : ScrollbarTheme(
                                              data: ScrollbarThemeData(
                                                thumbColor:
                                                    MaterialStateProperty.all(
                                                      const Color(0xFF90CAF9),
                                                    ),
                                                trackColor:
                                                    MaterialStateProperty.all(
                                                      const Color(0xFFE0E0E0),
                                                    ),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                      6,
                                                    ),
                                                radius: const Radius.circular(
                                                  3,
                                                ),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                      true,
                                                    ),
                                                trackVisibility:
                                                    MaterialStateProperty.all(
                                                      true,
                                                    ),
                                              ),
                                              child: Scrollbar(
                                                controller: _scrollController,
                                                child: SingleChildScrollView(
                                                  controller: _scrollController,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // DATE Column
                                                      Container(
                                                        width: 80,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: _transactionHistory
                                                              .map(
                                                                (
                                                                  item,
                                                                ) => _buildCell(
                                                                  item.getFormattedDate(),
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      // USER ID Column
                                                      Container(
                                                        width: 65,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: _transactionHistory
                                                              .map(
                                                                (
                                                                  item,
                                                                ) => _buildCell(
                                                                  item.getUserId(),
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      // CYCLES Column
                                                      Container(
                                                        width: 90,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: _transactionHistory
                                                              .map(
                                                                (
                                                                  item,
                                                                ) => _buildCell(
                                                                  item.washMode,
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      // AMOUNT Column
                                                      Expanded(
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        10,
                                                                      ),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                          ),
                                                          child: Column(
                                                            children: _transactionHistory
                                                                .map(
                                                                  (
                                                                    item,
                                                                  ) => _buildCell(
                                                                    item.amount
                                                                        .toString(),
                                                                  ),
                                                                )
                                                                .toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return SizedBox(
      height: 56,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
