import 'package:flutter/material.dart';
import 'package:ameyaa_app/auth_service.dart';
import 'package:ameyaa_app/api_service.dart';

class StoryHubPage extends StatefulWidget {
  final User user;
  
  const StoryHubPage({super.key, required this.user});

  @override
  State<StoryHubPage> createState() => _StoryHubPageState();
}

class _StoryHubPageState extends State<StoryHubPage> {
  List<dynamic> _stories = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String _selectedCategory = 'all';
  String _selectedSort = 'createdAt';
  bool _hasMoreStories = true;

  final List<Map<String, dynamic>> _defaultStories = [
  {
    'id': '1',
    'title': 'My 50lb Weight Loss Journey',
    'author': 'Sarah Chen',
    'readTime': 5,
    'category': 'Fitness Transformation',
    'content': 'After years of struggling with my weight, I decided to make a change. I started with small steps - walking 30 minutes a day and cutting out sugary drinks. Within 6 months, I lost 50 pounds and gained so much confidence! The key was consistency and finding activities I actually enjoyed.',
    'likes': 24,
    'hasLiked': false,
    'isAnonymous': false,
  },
  {
    'id': '2',
    'title': 'Overcoming Anxiety Through Meditation',
    'author': 'Alex Thompson',
    'readTime': 4,
    'category': 'Mental Health',
    'content': 'Living with anxiety was exhausting until I discovered meditation. Starting with just 5 minutes a day, I gradually built a practice that changed my life. Now I can manage my anxiety and feel more present in every moment.',
    'likes': 18,
    'hasLiked': false,
    'isAnonymous': true,
  },
  {
    'id': '3',
    'title': 'My Wellness Journey: From Burnout to Balance',
    'author': 'Maria Garcia',
    'readTime': 6,
    'category': 'Wellness Journey',
    'content': 'Working 80-hour weeks left me burned out and unhappy. I decided to prioritize my health by setting boundaries, practicing yoga, and learning to say no. Today, I have more energy and joy than ever before.',
    'likes': 32,
    'hasLiked': false,
    'isAnonymous': false,
  },
  {
    'id': '4',
    'title': 'Plant-Based Transformation',
    'author': 'James Wilson',
    'readTime': 3,
    'category': 'Nutrition Transformation',
    'content': 'Switching to a plant-based diet improved my energy levels, digestion, and overall health. I never realized how much food could impact how I feel every day!',
    'likes': 15,
    'hasLiked': false,
    'isAnonymous': false,
  },
  {
    'id': '5',
    'title': 'Recovery After Knee Surgery',
    'author': 'Dr. Lisa Park',
    'readTime': 7,
    'category': 'Recovery Story',
    'content': 'After knee surgery, I thought my active lifestyle was over. But with proper rehabilitation and patience, I\'m now back to hiking and even training for a 5K. Recovery taught me the power of perseverance.',
    'likes': 29,
    'hasLiked': false,
    'isAnonymous': false,
  },
  {
    'id': '6',
    'title': 'My Fitness Mindset Shift',
    'author': 'David Kim',
    'readTime': 4,
    'category': 'Fitness Mindset',
    'content': 'I used to hate exercise until I changed my mindset. Instead of focusing on weight loss, I started celebrating what my body could DO. Now I look forward to my workouts!',
    'likes': 21,
    'hasLiked': false,
    'isAnonymous': true,
  },
  {
    'id': '7',
    'title': 'Living with Chronic Pain',
    'author': 'Emma Roberts',
    'readTime': 8,
    'category': 'Medical Journey',
    'content': 'My journey with chronic pain has been challenging, but I\'ve learned to manage it through a combination of medication, physical therapy, and mindfulness. Sharing my story helps me feel less alone.',
    'likes': 45,
    'hasLiked': false,
    'isAnonymous': false,
  },
  {
    'id': '8',
    'title': 'Simple Lifestyle Changes That Transformed My Health',
    'author': 'Mike Johnson',
    'readTime': 5,
    'category': 'Lifestyle Change',
    'content': 'Small changes made a big difference: walking after meals, drinking more water, and prioritizing sleep. Sometimes the simplest habits have the biggest impact on our wellbeing.',
    'likes': 27,
    'hasLiked': false,
    'isAnonymous': false,
  },
];
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _loadStories(),
        _loadCategories(),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
      // Use default stories if API fails
      setState(() {
        _stories = _defaultStories;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStories() async {
    try {
      final response = await ApiService.getStories(
        page: _currentPage,
        category: _selectedCategory,
        sortBy: _selectedSort,
      );
      
      setState(() {
        if (_currentPage == 1) {
          _stories = response['stories'] ?? [];
        } else {
          _stories.addAll(response['stories'] ?? []);
        }
        _hasMoreStories = _currentPage < (response['totalPages'] ?? 1);
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading stories: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getStoryCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadMoreStories() async {
    if (_isLoadingMore || !_hasMoreStories) return;
    
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    
    await _loadStories();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _currentPage = 1;
      _isLoading = true;
    });
    await _loadStories();
  }

  Future<void> _likeStory(int index, String storyId) async {
    try {
      final response = await ApiService.likeStory(storyId);
      
      setState(() {
        final story = _stories[index];
        _stories[index] = {
          ...story,
          'likes': response['likes'],
          'hasLiked': response['hasLiked'],
        };
      });
    } catch (e) {
      print('Error liking story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like story')),
      );
    }
  }

  void _showCreateStoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateStoryDialog(
        onStoryCreated: _refreshStories,
        categories: _categories,
      ),
    );
  }

  void _showStoryDetails(Map<String, dynamic> story, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StoryDetailsBottomSheet(
        story: story,
        index: index,
        onLike: _likeStory,
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        selectedSort: _selectedSort,
        onApply: (category, sort) {
          setState(() {
            _selectedCategory = category;
            _selectedSort = sort;
            _currentPage = 1;
          });
          _refreshStories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Hub'),
        backgroundColor: Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateStoryDialog,
        backgroundColor: Color(0xFF9C27B0),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshStories,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _stories.length + (_hasMoreStories ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _stories.length) {
                    return _isLoadingMore
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox();
                  }
                  
                  final story = _stories[index];
                  return _buildStoryCard(story, index);
                },
              ),
            ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story, int index) {
    final color = _getCategoryColor(story['category']);
    
    return GestureDetector(
      onTap: () => _showStoryDetails(story, index),
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryEmoji(story['category']),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story['title'] ?? 'Untitled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'By ${story['author'] ?? 'Anonymous'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                story['content'] ?? '',
                style: TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      story['category'] ?? 'Other',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.favorite, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${story['likes'] ?? 0}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.schedule, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${story['readTime'] ?? 0} min read',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Spacer(),
                  if (story['hasLiked'] == true)
                    Icon(Icons.favorite, size: 12, color: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Fitness Transformation': Color(0xFF667EEA),
      'Mental Health': Color(0xFF4CAF50),
      'Wellness Journey': Color(0xFFE91E63),
      'Nutrition Transformation': Color(0xFFFF9800),
      'Fitness Mindset': Color(0xFF9C27B0),
      'Recovery Story': Color(0xFF2196F3),
      'Medical Journey': Color(0xFFFF5722),
      'Lifestyle Change': Color(0xFF795548),
      'Other': Color(0xFF607D8B),
    };
    return colors[category] ?? Color(0xFF607D8B);
  }

  String _getCategoryEmoji(String category) {
    final emojis = {
      'Fitness Transformation': '🏃‍♀️',
      'Mental Health': '🧠',
      'Wellness Journey': '🧘‍♀️',
      'Nutrition Transformation': '🥗',
      'Fitness Mindset': '💪',
      'Recovery Story': '🌟',
      'Medical Journey': '🏥',
      'Lifestyle Change': '✨',
      'Other': '📖',
    };
    return emojis[category] ?? '📖';
  }
}

// Create Story Dialog
class CreateStoryDialog extends StatefulWidget {
  final Function onStoryCreated;
  final List<dynamic> categories;

  const CreateStoryDialog({
    required this.onStoryCreated,
    required this.categories,
  });

  @override
  _CreateStoryDialogState createState() => _CreateStoryDialogState();
}

class _CreateStoryDialogState extends State<CreateStoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Other';
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  Future<void> _submitStory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.createStory(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        isAnonymous: _isAnonymous,
      );

      Navigator.pop(context);
      widget.onStoryCreated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Story published successfully!')),
      );
    } catch (e) {
      print('Error creating story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish story')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Your Story',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a compelling title...',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length > 100) {
                  return 'Title must be less than 100 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                ...widget.categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )),
                if (!widget.categories.contains('Other'))
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Your Story',
                border: OutlineInputBorder(),
                hintText: 'Share your inspiring journey...',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              maxLength: 2000,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please share your story';
                }
                if (value.length > 2000) {
                  return 'Story must be less than 2000 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value!;
                    });
                  },
                ),
                Text('Post anonymously'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9C27B0),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'Publish Story',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Story Details Bottom Sheet
class StoryDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> story;
  final int index;
  final Function(int, String) onLike;

  const StoryDetailsBottomSheet({
    required this.story,
    required this.index,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(story['category']);
    
    return Container(
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
                    color: color,
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
              story['title'] ?? 'Untitled',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Text(
                    (story['author'] ?? 'A')[0],
                    style: TextStyle(color: color),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['author'] ?? 'Anonymous',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${story['readTime'] ?? 0} min read • ${story['category'] ?? 'Other'}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () => onLike(index, story['id']),
                  icon: Icon(
                    story['hasLiked'] == true ? Icons.favorite : Icons.favorite_border,
                    color: story['hasLiked'] == true ? Colors.red : Colors.grey,
                  ),
                ),
                Text('${story['likes'] ?? 0}'),
              ],
            ),
            SizedBox(height: 24),
            Text(
              story['content'] ?? '',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
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
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Fitness Transformation': Color(0xFF667EEA),
      'Mental Health': Color(0xFF4CAF50),
      'Wellness Journey': Color(0xFFE91E63),
      'Nutrition Transformation': Color(0xFFFF9800),
      'Fitness Mindset': Color(0xFF9C27B0),
      'Recovery Story': Color(0xFF2196F3),
      'Medical Journey': Color(0xFFFF5722),
      'Lifestyle Change': Color(0xFF795548),
      'Other': Color(0xFF607D8B),
    };
    return colors[category] ?? Color(0xFF607D8B);
  }
}

// Filter Bottom Sheet
class FilterBottomSheet extends StatefulWidget {
  final List<dynamic> categories;
  final String selectedCategory;
  final String selectedSort;
  final Function(String, String) onApply;

  const FilterBottomSheet({
    required this.categories,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onApply,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Stories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('all', 'All Categories'),
              ...widget.categories.map((category) => _buildCategoryChip(category, category)),
            ],
          ),
          SizedBox(height: 20),
          Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('createdAt', 'Newest First'),
              _buildSortChip('likes', 'Most Liked'),
            ],
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedCategory, _selectedSort);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9C27B0),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = value;
        });
      },
    );
  }
}