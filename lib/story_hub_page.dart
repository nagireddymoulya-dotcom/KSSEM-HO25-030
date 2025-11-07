import 'package:flutter/material.dart';
import 'package:ameya_app/auth_service.dart';

class StoryHubPage extends StatefulWidget {
  final User user;
  
  const StoryHubPage({super.key, required this.user});

  @override
  State<StoryHubPage> createState() => _StoryHubPageState();
}

class _StoryHubPageState extends State<StoryHubPage> {
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'My 50lb Weight Loss Journey',
      'author': 'Sarah Chen',
      'readTime': '5 min read',
      'category': 'Fitness Transformation',
      'image': '🏃‍♀️',
      'color': Color(0xFF667EEA),
      'content': '''
After years of struggling with my weight, I decided to make a change. It started with small steps - literally! I began walking 30 minutes every day and making healthier food choices.

The first month was tough, but seeing those initial 8 pounds come off kept me motivated. I incorporated strength training and found activities I actually enjoyed, like hiking and swimming.

One year later, I've lost 50 pounds and gained so much more - confidence, energy, and a new outlook on life. The journey taught me that consistency beats intensity every time.
''',
      'keyPoints': [
        'Started with 30-minute daily walks',
        'Focused on sustainable changes',
        'Lost 50 pounds in 12 months',
        'Found activities I genuinely enjoy'
      ]
    },
    {
      'title': 'Overcoming Anxiety Through Mindfulness',
      'author': 'Mike Rodriguez',
      'readTime': '7 min read',
      'category': 'Mental Health',
      'image': '🧠',
      'color': Color(0xFF4CAF50),
      'content': '''
Anxiety had been my constant companion for over a decade. It affected my work, relationships, and overall quality of life. Traditional therapy helped, but I needed something more.

I discovered mindfulness meditation through a friend. At first, sitting with my thoughts for even 5 minutes felt impossible. But I persisted, starting with just one minute and gradually building up.

Six months into my practice, I noticed significant changes. The panic attacks became less frequent, and when anxiety did arise, I had tools to manage it. Mindfulness didn't eliminate anxiety, but it gave me the power to respond rather than react.
''',
      'keyPoints': [
        'Started with 1-minute meditation sessions',
        'Practiced daily mindfulness',
        'Reduced panic attack frequency',
        'Learned to respond rather than react'
      ]
    },
    {
      'title': '30 Days of Yoga Changed Everything',
      'author': 'Priya Patel',
      'readTime': '4 min read',
      'category': 'Wellness Journey',
      'image': '🧘‍♀️',
      'color': Color(0xFFE91E63),
      'content': '''
As a busy software engineer, I spent most of my days sitting. My back hurt, I had constant tension headaches, and I felt disconnected from my body.

I challenged myself to 30 days of yoga - just 20 minutes each morning. The first week was humbling. I couldn't touch my toes and my balance was terrible.

By day 30, not only could I touch my toes, but my back pain had vanished, my headaches were gone, and I felt more centered than ever. Yoga became my daily anchor in a chaotic world.
''',
      'keyPoints': [
        '20 minutes of daily yoga',
        'Eliminated chronic back pain',
        'Improved flexibility and balance',
        'Found mental clarity and focus'
      ]
    },
    {
      'title': 'From Fast Food to Whole Foods',
      'author': 'David Kim',
      'readTime': '6 min read',
      'category': 'Nutrition Transformation',
      'image': '🥗',
      'color': Color(0xFFFF9800),
      'content': '''
I used to live on fast food and processed meals. Cooking felt like a chore, and healthy eating seemed expensive and complicated. My energy levels were constantly low, and I wasn't happy with how I felt or looked.

The turning point came when I learned basic meal prep. I started with one healthy meal a day, then two, until eventually I was cooking most of my meals. I discovered that healthy food could be delicious and satisfying.

Now, I meal prep every Sunday, saving time and money while eating nutritious meals. My energy has skyrocketed, and I've never felt better. The best part? I actually enjoy cooking now!
''',
      'keyPoints': [
        'Started with one healthy meal daily',
        'Learned basic meal prep techniques',
        'Increased energy levels significantly',
        'Saved money while eating better'
      ]
    },
    {
      'title': 'Healing My Relationship with Exercise',
      'author': 'Jessica Williams',
      'readTime': '5 min read',
      'category': 'Fitness Mindset',
      'image': '💪',
      'color': Color(0xFF9C27B0),
      'content': '''
For years, I saw exercise as punishment - something I had to do because I ate "bad" foods. This mindset made me dread workouts and eventually quit every exercise program I started.

The shift happened when I stopped focusing on calories burned and started focusing on how movement made me feel. I tried different activities until I found what brought me joy: dancing, hiking, and strength training.

Now I move because it makes me feel strong, capable, and happy. Exercise is no longer punishment; it's self-care. This mental shift has made all the difference in maintaining a consistent routine.
''',
      'keyPoints': [
        'Shifted from punishment to self-care mindset',
        'Found joyful movement activities',
        'Focused on feelings rather than calories',
        'Maintained consistency through enjoyment'
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Hub'),
        backgroundColor: Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return GestureDetector(
            onTap: () => _showStoryDetails(story),
            child: Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: story['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          story['image'],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'By ${story['author']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: story['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  story['category'],
                                  style: TextStyle(
                                    color: story['color'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                story['readTime'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStoryDetails(Map<String, dynamic> story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inspiration Story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: story['color'],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                story['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: story['color'].withOpacity(0.1),
                    child: Text(
                      story['author'][0],
                      style: TextStyle(color: story['color']),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story['author'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${story['readTime']} • ${story['category']}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                story['content'],
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Key Takeaways:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: story['color'],
                ),
              ),
              SizedBox(height: 12),
              ...story['keyPoints'].map<Widget>((point) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: story['color'], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              SizedBox(height: 32),
              Center(
                child: Text(
                  'Keep inspiring others with your journey! 🌟',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}