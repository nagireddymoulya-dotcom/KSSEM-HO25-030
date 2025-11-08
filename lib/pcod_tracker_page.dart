import 'package:flutter/material.dart';
import 'package:ameyaa_app/auth_service.dart';
import 'package:ameyaa_app/api_service.dart';

class PCODTrackerPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic> pcodData;
  final Function(Map<String, dynamic>) onDataUpdate;

  const PCODTrackerPage({
    Key? key,
    required this.user,
    required this.pcodData,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  _PCODTrackerPageState createState() => _PCODTrackerPageState();
}

class _PCODTrackerPageState extends State<PCODTrackerPage> {
  late Map<String, dynamic> _pcodData;
  bool _isLoading = false;
  List<Map<String, dynamic>> _cycleHistory = [];
  Map<String, dynamic> _statistics = {};

  // Rainbow colors for the design
  final List<Color> _rainbowColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFA726), // Orange
    Color(0xFFFFCA28), // Yellow
    Color(0xFF66BB6A), // Green
    Color(0xFF42A5F5), // Blue
    Color(0xFF5C6BC0), // Indigo
    Color(0xFFAB47BC), // Violet
  ];

  @override
  void initState() {
    super.initState();
    _pcodData = widget.pcodData;
    _loadCycleHistory();
    _loadStatistics();
  }

  Future<void> _loadCycleHistory() async {
    try {
      final history = await ApiService.getPCODTracker();
      setState(() {
        _cycleHistory = List<Map<String, dynamic>>.from(history['history'] ?? []);
      });
    } catch (e) {
      print('Error loading cycle history: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await ApiService.getPCODStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _updateTracker() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedData = await ApiService.updatePCODTracker(_pcodData);
      setState(() {
        _pcodData = updatedData;
        _isLoading = false;
      });

      widget.onDataUpdate(_pcodData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tracker updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update tracker: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Cycle Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_rainbowColors[3]),
              ),
            )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRainbowHeader(),
                  SizedBox(height: 20),
                  _buildCycleOverview(),
                  SizedBox(height: 20),
                  _buildCurrentStatus(),
                  SizedBox(height: 20),
                  _buildStatistics(),
                  SizedBox(height: 20),
                  _buildCycleHistory(),
                  SizedBox(height: 20),
                  _buildAIInsights(),
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildRainbowHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _rainbowColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Cycle Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track your menstrual health',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleOverview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRainbowCycleCard('Cycle Day', '${_pcodData['currentCycleDay']}', Icons.calendar_today, _rainbowColors[0]),
              _buildRainbowCycleCard('Next Period', _formatDate(_pcodData['nextPredictedPeriod']), Icons.event, _rainbowColors[2]),
              _buildRainbowCycleCard('Phase', _getCurrentPhase(), Icons.autorenew, _rainbowColors[4]),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width - 80) * ((_pcodData['currentCycleDay'] ?? 1) / (_pcodData['cycleLength'] ?? 28)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_rainbowColors[0], _rainbowColors[3]],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day 1',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                'Cycle Progress',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              Text(
                'Day ${_pcodData['cycleLength'] ?? 28}',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRainbowCycleCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_rainbowColors[1], _rainbowColors[3]],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildRainbowStatusItem('Mood', _pcodData['mood'] ?? 'Normal', Icons.emoji_emotions, _rainbowColors[0]),
          _buildRainbowStatusItem('Flow', _pcodData['flowIntensity'] ?? 'Medium', Icons.water_drop, _rainbowColors[2]),
          _buildRainbowStatusItem('Symptoms', '${(_pcodData['symptoms'] as List).length} recorded', Icons.medical_services, _rainbowColors[4]),
        ],
      ),
    );
  }

  Widget _buildRainbowStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_rainbowColors[2], _rainbowColors[5]],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Cycle Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('Avg Cycle', '${_statistics['avgCycleLength'] ?? 28} days', _rainbowColors[0]),
              _buildStatCard('Avg Period', '${_statistics['avgPeriodLength'] ?? 5} days', _rainbowColors[2]),
              _buildStatCard('Regularity', '${_statistics['regularity'] ?? 'Regular'}', _rainbowColors[4]),
              _buildStatCard('Symptoms', '${_statistics['commonSymptoms']?.length ?? 0} common', _rainbowColors[6]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleHistory() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_rainbowColors[3], _rainbowColors[6]],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Recent Cycles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Spacer(),
              Text(
                'View All',
                style: TextStyle(
                  color: _rainbowColors[4],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _cycleHistory.isEmpty
              ? Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(Icons.history, color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'No cycle history available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: _cycleHistory.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final cycle = entry.value;
                    return _buildRainbowHistoryItem(cycle, index);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildRainbowHistoryItem(Map<String, dynamic> cycle, int index) {
  Color itemColor = _rainbowColors[index % _rainbowColors.length];
  final cycleLength = cycle['cycleLength']?.toString() ?? 'N/A';
  final periodLength = cycle['periodLength']?.toString() ?? 'N/A';
  final startDate = cycle['startDate']?.toString() ?? '';
  
  String formattedDate = 'N/A';
  if (startDate.isNotEmpty) {
    try {
      formattedDate = _formatDate(DateTime.parse(startDate));
    } catch (e) {
      formattedDate = 'N/A';
    }
  }
  
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: itemColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: itemColor.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.calendar_today, color: itemColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$cycleLength Day Cycle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '$periodLength day period • $formattedDate',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'View',
            style: TextStyle(
              color: itemColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildAIInsights() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_rainbowColors[6].withOpacity(0.1), _rainbowColors[2].withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_rainbowColors[5], _rainbowColors[1]],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _rainbowColors[3].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI Powered',
                  style: TextStyle(
                    color: _rainbowColors[3],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Based on your cycle patterns, here are personalized insights:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInsightCard('💊', 'Track medication effectiveness', _rainbowColors[0]),
              _buildInsightCard('🥗', 'Nutrition helps with symptoms', _rainbowColors[2]),
              _buildInsightCard('🧘', 'Yoga reduces cycle stress', _rainbowColors[4]),
              _buildInsightCard('📊', 'Good regularity pattern', _rainbowColors[6]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String emoji, String text, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPhase() {
    int day = _pcodData['currentCycleDay'] ?? 1;
    if (day <= 7) return 'Menstrual';
    if (day <= 14) return 'Follicular';
    if (day <= 21) return 'Ovulation';
    return 'Luteal';
  }

  String _formatDate(dynamic date) {
  if (date == null) return 'N/A';
  if (date is DateTime) {
    return '${date.day}/${date.month}';
  }
  if (date is String) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}';
    } catch (e) {
      return 'N/A';
    }
  }
  return 'N/A';
}
}