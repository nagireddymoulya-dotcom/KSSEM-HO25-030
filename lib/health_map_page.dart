import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'health_reports_page.dart';
import 'add_health_report_page.dart';
import 'health_map_view.dart';

class HealthMapPage extends StatefulWidget {
  final User user;
  
  const HealthMapPage({super.key, required this.user});

  @override
  State<HealthMapPage> createState() => _HealthMapPageState();
}

class _HealthMapPageState extends State<HealthMapPage> {

  void _navigateToHealthReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthReportsPage(user: widget.user),
      ),
    );
  }

  void _navigateToAddReport() {
  // Convert User object to Map
  final userMap = {
    'id': widget.user.id,
    'name': widget.user.name,
    'email': widget.user.email,
    // Add any other user properties you need
  };
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddHealthReportPage(user: userMap),
    ),
  );
}

  void _navigateToHealthMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthMapView(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildHeaderSection(),
          _buildEmergencyContactsSection(),
          _buildActionButtonsSection(),
          _buildHealthCategoriesSection(),
          _buildHealthResourcesSection(),
        ],
      ),
    );
  }

  SliverAppBar _buildHeaderSection() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF667EEA),
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
    );
  }

  SliverToBoxAdapter _buildEmergencyContactsSection() {
    final List<Map<String, dynamic>> emergencyContacts = [
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

    void callEmergency(String number) async {
      final String url = 'tel:$number';
      // TODO: Implement phone call functionality
      print('Calling: $url'); // Using the variable
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = emergencyContacts[index];
                return GestureDetector(
                  onTap: () => callEmergency(contact['number']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (contact['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (contact['color'] as Color).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: contact['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(contact['icon'] as IconData, color: Colors.white, size: 20),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                contact['number'] as String,
                                style: TextStyle(
                                  color: contact['color'] as Color,
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
    );
  }

  SliverToBoxAdapter _buildActionButtonsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'View Health Map',
                    Icons.map,
                    Colors.blue,
                    _navigateToHealthMapView,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Add Report',
                    Icons.add_circle,
                    Colors.green,
                    _navigateToAddReport,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'View Reports',
                    Icons.list_alt,
                    Colors.purple,
                    _navigateToHealthReports,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Emergency',
                    Icons.emergency,
                    Colors.red,
                    () {
                      // Handle emergency action
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHealthCategoriesSection() {
    final List<Map<String, dynamic>> healthCategories = [
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
    ];

    void openMaps(String searchQuery) async {
      final String url = 'https://www.google.com/maps/search/$searchQuery';
      // TODO: Implement maps opening functionality
      print('Opening maps: $url'); // Using the variable
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Color(0xFF667EEA), size: 20),
                const SizedBox(width: 8),
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
            const SizedBox(height: 8),
            Text(
              'Tap on any category to find nearby services on Google Maps',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: healthCategories.length,
              itemBuilder: (context, index) {
                final category = healthCategories[index];
                return GestureDetector(
                  onTap: () => openMaps(category['searchQuery'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (category['color'] as Color).withOpacity(0.1),
                          (category['color'] as Color).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
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
                            color: (category['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(category['icon'] as IconData, color: category['color'] as Color, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            category['description'] as String,
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
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHealthResourcesSection() {
    return SliverToBoxAdapter(
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
            const SizedBox(height: 12),
            _buildResourceCard(
              'PCOD Support Groups',
              'Connect with PCOD communities and get support',
              Icons.group,
              Color(0xFFAB47BC),
              () {
                // Open PCOD support resources
              },
            ),
            const SizedBox(height: 8),
            _buildResourceCard(
              'Mental Health Hotline',
              '24/7 mental health support and counseling',
              Icons.phone_in_talk,
              Color(0xFFFFA726),
              () {
                // Call mental health hotline
              },
            ),
            const SizedBox(height: 8),
            _buildResourceCard(
              'Women Health Tips',
              'Articles and guides for women health',
              Icons.article,
              Color(0xFF26C6DA),
              () {
                // Open health resources
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
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