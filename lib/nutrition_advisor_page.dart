import 'package:flutter/material.dart';
import 'package:ameya_app/auth_service.dart';

class NutritionAdvisorPage extends StatefulWidget {
  final User user;
  
  const NutritionAdvisorPage({super.key, required this.user});

  @override
  State<NutritionAdvisorPage> createState() => _NutritionAdvisorPageState();
}

class _NutritionAdvisorPageState extends State<NutritionAdvisorPage> {
  final List<Map<String, dynamic>> _nutritionTips = [
    {
      'title': 'Balanced Breakfast',
      'description': 'Start your day with protein and complex carbs for sustained energy',
      'icon': Icons.breakfast_dining,
      'color': Color(0xFF4CAF50),
      'details': [
        'Include protein sources like eggs, Greek yogurt, or nuts',
        'Add complex carbs: oatmeal, whole grain toast',
        'Include fruits for vitamins and fiber',
        'Avoid sugary cereals and pastries'
      ]
    },
    {
      'title': 'Hydration Guide',
      'description': 'Stay properly hydrated throughout the day',
      'icon': Icons.water_drop,
      'color': Color(0xFF2196F3),
      'details': [
        'Drink 8-10 glasses of water daily',
        'Carry a water bottle with you',
        'Drink water before meals',
        'Include hydrating foods like watermelon, cucumber'
      ]
    },
    {
      'title': 'Healthy Snacks',
      'description': 'Choose nutritious snacks over processed options',
      'icon': Icons.fastfood,
      'color': Color(0xFFFF9800),
      'details': [
        'Fresh fruits and vegetables',
        'Nuts and seeds in moderation',
        'Greek yogurt with berries',
        'Hummus with vegetable sticks'
      ]
    },
    {
      'title': 'Portion Control',
      'description': 'Learn proper portion sizes for balanced eating',
      'icon': Icons.kitchen,
      'color': Color(0xFF9C27B0),
      'details': [
        'Use smaller plates',
        'Fill half plate with vegetables',
        'Protein portion should be palm-sized',
        'Carbs portion should be fist-sized'
      ]
    },
  ];

  final List<Map<String, dynamic>> _mealPlans = [
    {
      'day': 'Monday',
      'meals': {
        'Breakfast': 'Oatmeal with berries and nuts',
        'Lunch': 'Grilled chicken salad',
        'Dinner': 'Salmon with quinoa and broccoli',
        'Snacks': 'Apple with peanut butter'
      }
    },
    {
      'day': 'Tuesday',
      'meals': {
        'Breakfast': 'Greek yogurt with honey and fruits',
        'Lunch': 'Vegetable stir-fry with tofu',
        'Dinner': 'Lean beef with sweet potato',
        'Snacks': 'Carrot sticks with hummus'
      }
    },
    {
      'day': 'Wednesday',
      'meals': {
        'Breakfast': 'Whole grain toast with avocado',
        'Lunch': 'Quinoa bowl with vegetables',
        'Dinner': 'Chicken breast with roasted vegetables',
        'Snacks': 'Handful of almonds'
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Advisor'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              child: TabBar(
                labelColor: Color(0xFF4CAF50),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF4CAF50),
                tabs: [
                  Tab(text: 'Nutrition Tips'),
                  Tab(text: 'Meal Plans'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Nutrition Tips Tab
                  ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _nutritionTips.length,
                    itemBuilder: (context, index) {
                      final tip = _nutritionTips[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: tip['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tip['icon'], color: tip['color']),
                          ),
                          title: Text(
                            tip['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(tip['description']),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Key Points:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tip['color'],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...tip['details'].map<Widget>((detail) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(child: Text(detail)),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Meal Plans Tab
                  ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _mealPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _mealPlans[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['day'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              SizedBox(height: 12),
                              ...plan['meals'].entries.map<Widget>((meal) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      child: Text(
                                        '${meal.key}:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        meal.value,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}