import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthResourcesWidget extends StatelessWidget {
  void _callEmergency(String number) async {
    final String url = 'tel:$number';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Handle error
    }
  }

  void _openWebsite(String url) async {
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
              'Connect with PCOD communities and get support',
              Icons.group,
              Color(0xFFAB47BC),
              () {
                _openWebsite('https://www.womenshealth.gov/');
              },
            ),
            SizedBox(height: 8),
            _buildResourceCard(
              'Mental Health Hotline',
              '24/7 mental health support and counseling',
              Icons.phone_in_talk,
              Color(0xFFFFA726),
              () => _callEmergency('1800-599-0019'),
            ),
            SizedBox(height: 8),
            _buildResourceCard(
              'Women Health Tips',
              'Articles and guides for women health',
              Icons.article,
              Color(0xFF26C6DA),
              () {
                _openWebsite('https://www.healthywomen.org/');
              },
            ),
            SizedBox(height: 8),
            _buildResourceCard(
              'Nutrition Guide',
              'Healthy eating habits and diet plans',
              Icons.restaurant,
              Color(0xFF66BB6A),
              () {
                _openWebsite('https://www.nutrition.gov/');
              },
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
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