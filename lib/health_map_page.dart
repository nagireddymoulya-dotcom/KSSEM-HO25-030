import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart'; // Import the file that contains User class

class HealthMapPage extends StatefulWidget {
  final User user;
  
  const HealthMapPage({super.key, required this.user});

  @override
  State<HealthMapPage> createState() => _HealthMapPageState();
}

class _HealthMapPageState extends State<HealthMapPage> {
  int _selectedCategory = 0;
  
  final List<Map<String, dynamic>> _healthCategories = [
    {
      'title': 'Hospitals',
      'icon': Icons.local_hospital,
      'color': Color(0xFFFF6B6B),
      'searchQuery': 'hospitals',
      'description': 'Find nearby hospitals and emergency care'
    },
    {
      'title': 'Clinics',
      'icon': Icons.medical_services,
      'color': Color(0xFF42A5F5),
      'searchQuery': 'medical clinics',
      'description': 'Local clinics and health centers'
    },
    {
      'title': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': Color(0xFF66BB6A),
      'searchQuery': 'pharmacies',
      'description': '24/7 pharmacies and drug stores'
    },
    {
      'title': 'GYN Specialists',
      'icon': Icons.female,
      'color': Color(0xFFAB47BC),
      'searchQuery': 'gynecologist',
      'description': 'Women health specialists'
    },
    {
      'title': 'Mental Health',
      'icon': Icons.psychology,
      'color': Color(0xFFFFA726),
      'searchQuery': 'mental health centers',
      'description': 'Therapists and counseling centers'
    },
    {
      'title': 'Yoga & Wellness',
      'icon': Icons.self_improvement,
      'color': Color(0xFF26C6DA),
      'searchQuery': 'yoga studios',
      'description': 'Yoga and wellness centers'
    },
  ];

  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Emergency',
      'number': '112',
      'icon': Icons.emergency,
      'color': Colors.red,
    },
    {
      'name': 'Ambulance',
      'number': '102',
      'icon': Icons.airline_seat_flat,
      'color': Colors.orange,
    },
    {
      'name': 'Police',
      'number': '100',
      'icon': Icons.local_police,
      'color': Colors.blue,
    },
    {
      'name': 'Fire Department',
      'number': '101',
      'icon': Icons.fire_extinguisher,
      'color': Colors.redAccent,
    },
  ];

  void _openMaps(String searchQuery) async {
    final String url = 'https://www.google.com/maps/search/$searchQuery';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _callEmergency(String number) async {
    final String url = 'tel:$number';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF667EEA),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Health Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Find healthcare services near you',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Emergency Contacts Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _emergencyContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _emergencyContacts[index];
                      return GestureDetector(
                        onTap: () => _callEmergency(contact['number']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: contact['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: contact['color'].withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: contact['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(contact['icon'], color: Colors.white, size: 20),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      contact['number'],
                                      style: TextStyle(
                                        color: contact['color'],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Health Services Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, color: Color(0xFF667EEA), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Find Healthcare Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap on any category to find nearby services on Google Maps',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Health Categories Grid
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = _healthCategories[index];
                  return GestureDetector(
                    onTap: () => _openMaps(category['searchQuery']),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            category['color'].withOpacity(0.1),
                            category['color'].withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(category['icon'], color: category['color'], size: 24),
                          ),
                          SizedBox(height: 12),
                          Text(
                            category['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              category['description'],
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _healthCategories.length,
              ),
            ),
          ),

          // Additional Resources
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildResourceCard(
                    'PCOD Support Groups',
                    'Connect with PCOD communities',
                    Icons.group,
                    Color(0xFFAB47BC),
                    () {
                      // Navigate to PCOD support page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening PCOD support resources...'),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  _buildResourceCard(
                    'Mental Health Hotline',
                    '24/7 mental health support',
                    Icons.phone_in_talk,
                    Color(0xFFFFA726),
                    () => _callEmergency('1800-599-0019'), // Example mental health hotline
                  ),
                  SizedBox(height: 8),
                  _buildResourceCard(
                    'Women Health Tips',
                    'Articles and guides',
                    Icons.article,
                    Color(0xFF26C6DA),
                    () {
                      // Navigate to health tips
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening health resources...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}