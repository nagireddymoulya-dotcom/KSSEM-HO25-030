import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthCategoriesWidget extends StatelessWidget {
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
    {
      'title': 'Dentists',
      'icon': Icons.medical_information,
      'color': Color(0xFF9575CD),
      'searchQuery': 'dentist',
      'description': 'Dental clinics and specialists'
    },
    {
      'title': 'Physiotherapy',
      'icon': Icons.accessibility,
      'color': Color(0xFF4DB6AC),
      'searchQuery': 'physiotherapy',
      'description': 'Physical therapy centers'
    },
  ];

  void _openMaps(String searchQuery) async {
    final String url = 'https://www.google.com/maps/search/$searchQuery';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
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
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // This method is called from the parent to build the grid
  Widget buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _healthCategories.length,
      itemBuilder: (context, index) {
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
    );
  }
}