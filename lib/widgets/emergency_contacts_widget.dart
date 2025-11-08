import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsWidget extends StatelessWidget {
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
    {
      'name': 'Women Helpline',
      'number': '1091',
      'icon': Icons.female,
      'color': Colors.purple,
    },
    {
      'name': 'Mental Health',
      'number': '1800-599-0019',
      'icon': Icons.psychology,
      'color': Colors.green,
    },
  ];

  void _callEmergency(String number) async {
    final String url = 'tel:$number';
    
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
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
    );
  }
}