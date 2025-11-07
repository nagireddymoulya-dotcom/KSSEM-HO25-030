import 'package:flutter/material.dart';
import 'package:ameya_app/auth_service.dart';
import 'nutrition_advisor_page.dart';
import 'mental_health_chat_page.dart';
import 'beauty_tips_page.dart';
import 'story_hub_page.dart';
import 'health_map_page.dart'; // Import the new HealthMapPage

class DashboardPage extends StatefulWidget {
  final User user;
  
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentIndex = 0;
  
  HealthMetrics _healthMetrics = HealthMetrics(
    steps: 4500,
    temperature: 0.0,
    heartRate: 80,
    oxygenLevel: 0,
    lastUpdated: DateTime.now(),
  );
  
  // PCOD/Menstrual Tracker Data
  Map<String, dynamic> _pcodData = {
    'lastPeriod': DateTime.now().subtract(Duration(days: 15)),
    'cycleLength': 28,
    'periodLength': 5,
    'symptoms': [],
    'mood': 'Normal',
    'flowIntensity': 'Medium',
    'medications': [],
    'notes': '',
    'nextPredictedPeriod': DateTime.now().add(Duration(days: 13)),
    'currentCycleDay': 15,
    'lastUpdated': DateTime.now(),
  };
  
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  // Custom icons
  final Map<String, IconData> _customIcons = {
    'heart': Icons.favorite,
    'activity': Icons.monitor_heart,
    'mental_health': Icons.psychology,
    'menu_board': Icons.restaurant,
    'direct': Icons.directions_walk,
    'temperature': Icons.thermostat,
    'wind': Icons.air,
    'walk': Icons.directions_walk,
    'meditation': Icons.self_improvement,
    'health': Icons.medical_services,
    'home': Icons.home,
    'home_filled': Icons.home_filled,
    'heart_filled': Icons.favorite,
    'calendar': Icons.calendar_today,
    'calendar_filled': Icons.calendar_month,
    'user': Icons.person,
    'user_filled': Icons.person_2_rounded,
    'add': Icons.add,
    'notification': Icons.notifications,
    'drop': Icons.water_drop,
    'moon': Icons.nightlight_round,
    'edit': Icons.edit,
    'nutrition': Icons.restaurant_menu,
    'chat': Icons.chat,
    'spa': Icons.spa,
    'library': Icons.library_books,
    'flower': Icons.local_florist,
    'cycle': Icons.calendar_today,
    'mood': Icons.emoji_emotions,
    'pill': Icons.medication,
    'pain': Icons.favorite_border,
  };

  // Rainbow colors for health metrics
  final List<Color> _rainbowColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFA726), // Orange
    Color(0xFFFFCA28), // Yellow
    Color(0xFF66BB6A), // Green
    Color(0xFF42A5F5), // Blue
    Color(0xFF5C6BC0), // Indigo
    Color(0xFFAB47BC), // Violet
  ];

  // Symptoms list
  final List<String> _symptomsList = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Mood Swings',
    'Acne',
    'Breast Tenderness',
    'Food Cravings',
    'Back Pain',
    'Nausea'
  ];

  // Mood options
  final List<String> _moodOptions = [
    'Happy',
    'Normal',
    'Sad',
    'Anxious',
    'Irritable',
    'Energetic',
    'Tired'
  ];

  // Flow intensity options
  final List<String> _flowOptions = [
    'Light',
    'Medium',
    'Heavy',
    'Very Heavy'
  ];

  // Explore More Sections
  final List<Map<String, dynamic>> _exploreSections = [
    {
      'icon': 'nutrition', 
      'label': 'Nutrition', 
      'color': Color(0xFF4CAF50),
      'description': 'Diet plans'
    },
    {
      'icon': 'mental_health', 
      'label': 'Mental Health', 
      'color': Color(0xFF2196F3),
      'description': 'Chat support'
    },
    {
      'icon': 'spa', 
      'label': 'Beauty', 
      'color': Color(0xFFE91E63),
      'description': 'Tips & routines'
    },
    {
      'icon': 'library', 
      'label': 'Stories', 
      'color': Color(0xFF9C27B0),
      'description': 'Inspiration hub'
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _loadHealthMetrics();
    _loadPCODData();
    _animationController.forward();
  }

  Future<void> _loadHealthMetrics() async {
    try {
      final metrics = await _authService.getHealthMetrics();
      setState(() {
        _healthMetrics = metrics;
      });
    } catch (e) {
      print('Error loading health metrics: $e');
    }
  }

  Future<void> _loadPCODData() async {
    try {
      final pcodData = await _authService.getPCODData();
      setState(() {
        _pcodData = pcodData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading PCOD data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePCODData(Map<String, dynamic> newData) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final updatedData = await _authService.updatePCODData(newData);
      setState(() {
        _pcodData = updatedData;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cycle updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cycle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPCODTrackerForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PCODForm(
        pcodData: _pcodData,
        onSave: _updatePCODData,
        symptomsList: _symptomsList,
        moodOptions: _moodOptions,
        flowOptions: _flowOptions,
      ),
    );
  }

  // Navigation methods for explore sections
  void _navigateToNutritionAdvisor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NutritionAdvisorPage(user: widget.user)),
    );
  }

  void _navigateToMentalHealthChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MentalHealthChatPage(user: widget.user)),
    );
  }

  void _navigateToBeautyTips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BeautyTipsPage(user: widget.user)),
    );
  }

  void _navigateToStoryHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryHubPage(user: widget.user)),
    );
  }

  // Health tab navigation
  void _onTabTapped(int index) {
    if (index == 1) { // Health tab
      _navigateToHealthPage();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _navigateToHealthPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthMapPage(user: widget.user)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with gradient background
            SliverAppBar(
              expandedHeight: 140,
              collapsedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
                title: _buildCollapsedHeader(),
              ),
            ),

            // Main content with consistent background
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildWelcomeSection(),
                      const SizedBox(height: 20),
                      _buildHealthRainbow(),
                      const SizedBox(height: 20),
                      _buildPCODTracker(),
                      const SizedBox(height: 20),
                      _buildExploreMore(),
                      const SizedBox(height: 20),
                      _buildHealthTips(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCollapsedHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, ${_getShortName(widget.user.name)}!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Welcome back',
              style: TextStyle(
                color: Colors.black12,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(_customIcons['notification']!, color: Colors.white, size: 16),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  String _getShortName(String fullName) {
    if (fullName.length <= 8) return fullName;
    return '${fullName.split(' ')[0]}';
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_getShortName(widget.user.name)}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Wellness',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${_calculateHealthScore()}/100',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: _calculateHealthScore() / 100,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_calculateHealthScore()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Points',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRainbow() {
    final List<Map<String, dynamic>> healthItems = [
      {
        'label': 'Steps',
        'value': _healthMetrics.steps,
        'target': 10000,
        'icon': Icons.directions_walk,
        'color': _rainbowColors[0],
        'displayText': '${_healthMetrics.steps}/10k',
      },
      {
        'label': 'Heart Rate',
        'value': _healthMetrics.heartRate,
        'target': 80,
        'icon': Icons.favorite,
        'color': _rainbowColors[1],
        'displayText': '${_healthMetrics.heartRate} BPM',
      },
      {
        'label': 'Temperature',
        'value': _healthMetrics.temperature,
        'target': 36.5,
        'icon': Icons.thermostat,
        'color': _rainbowColors[2],
        'displayText': '${_healthMetrics.temperature.toStringAsFixed(1)}°C',
      },
      {
        'label': 'Oxygen',
        'value': _healthMetrics.oxygenLevel,
        'target': 98,
        'icon': Icons.air,
        'color': _rainbowColors[3],
        'displayText': '${_healthMetrics.oxygenLevel}%',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Health Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            Spacer(),
            Icon(Icons.auto_awesome, color: Color(0xFF667EEA), size: 16),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: healthItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final double progress = item['value'] / item['target'];
              
              return Padding(
                padding: EdgeInsets.only(bottom: index < healthItems.length - 1 ? 10 : 0),
                child: _buildRainbowBar(
                  item['label'],
                  progress.clamp(0.0, 1.0),
                  item['color'],
                  item['icon'],
                  item['displayText'],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRainbowBar(String label, double progress, Color color, IconData icon, String displayText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPCODTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Cycle Tracker',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today, color: Color(0xFF667EEA), size: 16),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cycle Overview
              _buildCycleOverview(),
              const SizedBox(height: 16),
              
              // Current Status
              _buildCurrentStatus(),
              const SizedBox(height: 16),
              
              // Symptoms & Mood
              _buildSymptomsMoodSection(),
              const SizedBox(height: 16),
              
              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showPCODTrackerForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Update Cycle Info',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildCycleCard(
            'Cycle Day',
            '${_pcodData['currentCycleDay']}',
            Icons.calendar_today,
            Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCycleCard(
            'Next Period',
            '${_formatDate(_pcodData['nextPredictedPeriod'])}',
            Icons.event,
            Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF66BB6A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety, color: Color(0xFF66BB6A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Phase: ${_getCurrentPhase()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flow: ${_pcodData['flowIntensity']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        
        // Mood
        Row(
          children: [
            Icon(Icons.emoji_emotions, color: Color(0xFFFFA726), size: 16),
            const SizedBox(width: 8),
            Text(
              'Mood: ${_pcodData['mood']}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Symptoms
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: (_pcodData['symptoms'] as List).take(3).map((symptom) => 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                symptom,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ).toList(),
        ),
      ],
    );
  }

  String _getCurrentPhase() {
    int day = _pcodData['currentCycleDay'];
    if (day <= 7) return 'Menstrual';
    if (day <= 14) return 'Follicular';
    if (day <= 21) return 'Ovulation';
    return 'Luteal';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  int _calculateHealthScore() {
    int score = 0;
    if (_healthMetrics.steps > 5000) score += 25;
    if (_healthMetrics.heartRate >= 60 && _healthMetrics.heartRate <= 100) score += 25;
    if (_healthMetrics.temperature >= 36.0 && _healthMetrics.temperature <= 37.5) score += 25;
    if (_healthMetrics.oxygenLevel >= 95) score += 25;
    return score;
  }

  Widget _buildExploreMore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Explore Wellness',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            Spacer(),
            Icon(Icons.explore, color: Color(0xFF667EEA), size: 16),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: _exploreSections.length,
          itemBuilder: (context, index) {
            final section = _exploreSections[index];
            final Color sectionColor = section['color'] as Color;
            
            return GestureDetector(
              onTap: () {
                switch (index) {
                  case 0:
                    _navigateToNutritionAdvisor();
                    break;
                  case 1:
                    _navigateToMentalHealthChat();
                    break;
                  case 2:
                    _navigateToBeautyTips();
                    break;
                  case 3:
                    _navigateToStoryHub();
                    break;
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      sectionColor.withOpacity(0.1),
                      sectionColor.withOpacity(0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: sectionColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _customIcons[section['icon']]!,
                          color: sectionColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sectionColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section['description'],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Wellness Tips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            Spacer(),
            Icon(Icons.lightbulb, color: Color(0xFF667EEA), size: 16),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTipCard(
                'Stay Hydrated 💧',
                'Drink 8-10 glasses daily',
                _rainbowColors[4],
              ),
              _buildTipCard(
                'Quality Sleep 🌙',
                '7-9 hours restful sleep',
                _rainbowColors[5],
              ),
              _buildTipCard(
                'Move Daily 🏃',
                '30 mins activity boosts energy',
                _rainbowColors[6],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String subtitle, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(Icons.eco, color: color, size: 14),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped, // Changed to use the new method
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 9),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: _currentIndex == 0 
                    ? BoxDecoration(
                        color: Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(_currentIndex == 0 ? _customIcons['home_filled']! : _customIcons['home']!, size: 18),
            ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_customIcons['health']!, size: 18), // Always highlighted for health
              ),
              label: 'Health',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined, color: Colors.transparent, size: 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: _currentIndex == 3 
                    ? BoxDecoration(
                        color: Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(_currentIndex == 3 ? _customIcons['calendar_filled']! : _customIcons['calendar']!, size: 18),
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: _currentIndex == 4 
                    ? BoxDecoration(
                        color: Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(_currentIndex == 4 ? _customIcons['user_filled']! : _customIcons['user']!, size: 18),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showPCODTrackerForm,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

// PCOD Form Bottom Sheet
class PCODForm extends StatefulWidget {
  final Map<String, dynamic> pcodData;
  final Function(Map<String, dynamic>) onSave;
  final List<String> symptomsList;
  final List<String> moodOptions;
  final List<String> flowOptions;

  const PCODForm({
    Key? key,
    required this.pcodData,
    required this.onSave,
    required this.symptomsList,
    required this.moodOptions,
    required this.flowOptions,
  }) : super(key: key);

  @override
  _PCODFormState createState() => _PCODFormState();
}

class _PCODFormState extends State<PCODForm> {
  late DateTime _lastPeriod;
  late int _cycleLength;
  late int _periodLength;
  late List<String> _selectedSymptoms;
  late String _selectedMood;
  late String _selectedFlow;
  late List<String> _medications;
  late String _notes;

  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lastPeriod = widget.pcodData['lastPeriod'] ?? DateTime.now();
    _cycleLength = widget.pcodData['cycleLength'] ?? 28;
    _periodLength = widget.pcodData['periodLength'] ?? 5;
    _selectedSymptoms = List.from(widget.pcodData['symptoms'] ?? []);
    _selectedMood = widget.pcodData['mood'] ?? 'Normal';
    _selectedFlow = widget.pcodData['flowIntensity'] ?? 'Medium';
    _medications = List.from(widget.pcodData['medications'] ?? []);
    _notes = widget.pcodData['notes'] ?? '';
    _notesController.text = _notes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Update Cycle Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Last Period Date
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  
                  // Cycle Length
                  _buildCycleLengthSlider(),
                  const SizedBox(height: 16),
                  
                  // Period Length
                  _buildPeriodLengthSlider(),
                  const SizedBox(height: 16),
                  
                  // Flow Intensity
                  _buildFlowIntensity(),
                  const SizedBox(height: 16),
                  
                  // Mood
                  _buildMoodSelector(),
                  const SizedBox(height: 16),
                  
                  // Symptoms
                  _buildSymptomsSelector(),
                  const SizedBox(height: 16),
                  
                  // Medications
                  _buildMedicationsInput(),
                  const SizedBox(height: 16),
                  
                  // Notes
                  _buildNotesInput(),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Save Cycle Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Period Start Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_lastPeriod.day}/${_lastPeriod.month}/${_lastPeriod.year}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, color: Color(0xFF667EEA)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleLengthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle Length',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _cycleLength.toDouble(),
                min: 21,
                max: 35,
                divisions: 14,
                label: '$_cycleLength days',
                onChanged: (value) {
                  setState(() {
                    _cycleLength = value.round();
                  });
                },
                activeColor: Color(0xFF667EEA),
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_cycleLength',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667EEA),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodLengthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Period Length',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _periodLength.toDouble(),
                min: 3,
                max: 7,
                divisions: 4,
                label: '$_periodLength days',
                onChanged: (value) {
                  setState(() {
                    _periodLength = value.round();
                  });
                },
                activeColor: Color(0xFFFF6B6B),
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_periodLength',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowIntensity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flow Intensity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.flowOptions.map((flow) => 
            ChoiceChip(
              label: Text(flow),
              selected: _selectedFlow == flow,
              onSelected: (selected) {
                setState(() {
                  _selectedFlow = flow;
                });
              },
              selectedColor: Color(0xFFFF6B6B).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedFlow == flow ? Color(0xFFFF6B6B) : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Mood',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.moodOptions.map((mood) => 
            ChoiceChip(
              label: Text(mood),
              selected: _selectedMood == mood,
              onSelected: (selected) {
                setState(() {
                  _selectedMood = mood;
                });
              },
              selectedColor: Color(0xFFFFA726).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedMood == mood ? Color(0xFFFFA726) : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.symptomsList.map((symptom) => 
            FilterChip(
              label: Text(symptom),
              selected: _selectedSymptoms.contains(symptom),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              selectedColor: Color(0xFF42A5F5).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedSymptoms.contains(symptom) ? Color(0xFF42A5F5) : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicationsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _medicationsController,
                decoration: InputDecoration(
                  hintText: 'Add medication...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addMedication,
              icon: const Icon(Icons.add, color: Color(0xFF667EEA)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _medications.map((med) => 
            Chip(
              label: Text(med),
              onDeleted: () {
                setState(() {
                  _medications.remove(med);
                });
              },
              backgroundColor: Color(0xFF66BB6A).withOpacity(0.1),
              labelStyle: TextStyle(
                color: Color(0xFF66BB6A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any additional notes about your cycle...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            _notes = value;
          },
        ),
      ],
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriod,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastPeriod) {
      setState(() {
        _lastPeriod = picked;
      });
    }
  }

  void _addMedication() {
    if (_medicationsController.text.trim().isNotEmpty) {
      setState(() {
        _medications.add(_medicationsController.text.trim());
        _medicationsController.clear();
      });
    }
  }

  void _saveData() {
    final updatedData = {
      'lastPeriod': _lastPeriod,
      'cycleLength': _cycleLength,
      'periodLength': _periodLength,
      'symptoms': _selectedSymptoms,
      'mood': _selectedMood,
      'flowIntensity': _selectedFlow,
      'medications': _medications,
      'notes': _notes,
      'nextPredictedPeriod': _lastPeriod.add(Duration(days: _cycleLength)),
      'currentCycleDay': DateTime.now().difference(_lastPeriod).inDays + 1,
    };

    widget.onSave(updatedData);
    Navigator.pop(context);
  }
}