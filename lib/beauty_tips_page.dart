import 'package:flutter/material.dart';
import 'package:ameya_app/auth_service.dart';

class BeautyTipsPage extends StatefulWidget {
  final User user;
  
  const BeautyTipsPage({super.key, required this.user});

  @override
  State<BeautyTipsPage> createState() => _BeautyTipsPageState();
}

class _BeautyTipsPageState extends State<BeautyTipsPage> {
  final List<Map<String, dynamic>> _beautyTips = [
    {
      'category': 'Skincare Routine',
      'icon': Icons.spa,
      'color': Color(0xFFE91E63),
      'tips': [
        {
          'title': 'Morning Routine',
          'steps': [
            'Gentle cleanser for your skin type',
            'Vitamin C serum for brightness',
            'Moisturizer with SPF 30+',
            'Light eye cream if needed'
          ]
        },
        {
          'title': 'Evening Routine',
          'steps': [
            'Double cleanse to remove makeup and impurities',
            'Exfoliate 2-3 times weekly',
            'Treatment serums (retinol, hyaluronic acid)',
            'Rich night moisturizer',
            'Eye cream'
          ]
        }
      ]
    },
    {
      'category': 'Hair Care',
      'icon': Icons.face_retouching_natural,
      'color': Color(0xFF9C27B0),
      'tips': [
        {
          'title': 'Daily Care',
          'steps': [
            'Use sulfate-free shampoo',
            'Condition from mid-length to ends',
            'Avoid hot water when washing',
            'Pat dry instead of rubbing'
          ]
        },
        {
          'title': 'Weekly Treatments',
          'steps': [
            'Deep conditioning mask once a week',
            'Scalp massage for blood circulation',
            'Hair oil treatment for dry ends',
            'Trim split ends regularly'
          ]
        }
      ]
    },
    {
      'category': 'Wellness & Beauty',
      'icon': Icons.favorite,
      'color': Color(0xFFF44336),
      'tips': [
        {
          'title': 'Lifestyle Habits',
          'steps': [
            'Get 7-8 hours of quality sleep',
            'Stay hydrated - 8 glasses daily',
            'Eat antioxidant-rich foods',
            'Exercise regularly for circulation'
          ]
        },
        {
          'title': 'Natural Remedies',
          'steps': [
            'Green tea for antioxidants',
            'Aloe vera for skin soothing',
            'Coconut oil for hair and skin',
            'Honey for natural moisturizing'
          ]
        }
      ]
    },
    {
      'category': 'Makeup Tips',
      'icon': Icons.palette,
      'color': Color(0xFF673AB7),
      'tips': [
        {
          'title': 'Natural Look',
          'steps': [
            'Start with moisturized skin',
            'Use lightweight foundation or tinted moisturizer',
            'Cream blush for natural flush',
            'Define brows and add mascara',
            'Tinted lip balm for hydration'
          ]
        },
        {
          'title': 'Skin Preparation',
          'steps': [
            'Always start with clean skin',
            'Use primer for smooth application',
            'Let skincare absorb before makeup',
            'Set with light powder if needed'
          ]
        }
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beauty & Wellness Tips'),
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _beautyTips.length,
        itemBuilder: (context, index) {
          final category = _beautyTips[index];
          return Card(
            margin: EdgeInsets.only(bottom: 20),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(category['icon'], color: category['color']),
                      ),
                      SizedBox(width: 12),
                      Text(
                        category['category'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: category['color'],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...category['tips'].map<Widget>((tipSection) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipSection['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      ...tipSection['steps'].map<Widget>((step) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.arrow_forward_ios, color: category['color'], size: 12),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      SizedBox(height: 16),
                    ],
                  )).toList(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDailyBeautyChallenge,
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
        child: Icon(Icons.emoji_events),
        tooltip: 'Daily Beauty Challenge',
      ),
    );
  }

  void _showDailyBeautyChallenge() {
    final challenges = [
      'Drink an extra glass of water today',
      'Take 5 minutes for deep breathing',
      'Apply SPF if going outside',
      'Compliment yourself in the mirror',
      'Try a new hairstyle',
      'Use that face mask you\'ve been saving',
      'Massage your scalp for 2 minutes',
      'Apply hand cream before bed'
    ];
    
    final randomChallenge = challenges[(DateTime.now().day % challenges.length)];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFE91E63)),
            SizedBox(width: 8),
            Text('Daily Beauty Challenge'),
          ],
        ),
        content: Text(
          'Your challenge for today:\n\n"$randomChallenge"\n\nComplete this simple task to boost your beauty routine!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('I\'ll do it!', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }
}