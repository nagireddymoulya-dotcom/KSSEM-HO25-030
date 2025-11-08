import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ameyaa_app/auth_service.dart';
import 'enhanced_mental_health_service.dart';

class MentalHealthChatPage extends StatefulWidget {
  final User user;
  
  const MentalHealthChatPage({super.key, required this.user});

  @override
  State<MentalHealthChatPage> createState() => _MentalHealthChatPageState();
}

class _MentalHealthChatPageState extends State<MentalHealthChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<EnhancedChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final EnhancedMentalHealthService _aiService = EnhancedMentalHealthService();
  
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isSpeaking = false;
  
  // Voice services - removed speech_to_text
  final FlutterTts _tts = FlutterTts();
  
  // Quick prompts based on user context
  List<String> _quickPrompts = [
    "I'm feeling anxious today",
    "How can I manage stress?",
    "I've been having trouble sleeping",
    "Can you suggest coping strategies?",
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadUserContext();
  }

  Future<void> _initializeServices() async {
    // Initialize text to speech only
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    
    // Load initial message
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  Future<void> _loadUserContext() async {
    try {
      // Load user's health data to personalize experience
      final healthMetrics = await AuthService().getHealthMetrics();
      final pcodData = await AuthService().getPCODData();
      
      // Update quick prompts based on user data
      _updateQuickPrompts(healthMetrics, pcodData);
      
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  void _updateQuickPrompts(HealthMetrics healthMetrics, Map<String, dynamic> pcodData) {
    final personalizedPrompts = [..._quickPrompts];
    
    // Add personalized prompts based on health data
    if (healthMetrics.heartRate > 90) {
      personalizedPrompts.add("My heart rate is high, what should I do?");
    }
    
    if (healthMetrics.steps < 3000) {
      personalizedPrompts.add("I haven't been active today");
    }
    
    // Add PCOD-related prompts
    final currentPhase = _getCurrentPhase(pcodData['currentCycleDay'] ?? 1);
    if (currentPhase == 'Menstrual') {
      personalizedPrompts.add("I'm on my period and feeling uncomfortable");
    } else if (currentPhase == 'PMS') {
      personalizedPrompts.add("I'm experiencing PMS symptoms");
    }
    
    setState(() {
      _quickPrompts = personalizedPrompts;
    });
  }

  String _getCurrentPhase(int cycleDay) {
    if (cycleDay <= 7) return 'Menstrual';
    if (cycleDay <= 14) return 'Follicular';
    if (cycleDay <= 21) return 'Ovulation';
    return 'PMS';
  }

  void _addWelcomeMessage() {
    _addBotMessage(
      "Hello ${widget.user.name}! 👋 I'm your enhanced mental health companion with advanced AI support.\n\n"
      "I can understand your emotions, provide evidence-based therapeutic techniques, "
      "and access a comprehensive mental health knowledge base to support you.\n\n"
      "How are you feeling today?",
      messageType: MessageType.welcome
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(EnhancedChatMessage(
        text: message,
        isUser: true,
        time: DateTime.now(),
      ));
      _isLoading = true;
    });
    
    _messageController.clear();
    _scrollToBottom();

    try {
      // Get enhanced AI response with RAG and NLP
      final response = await _aiService.getEnhancedAIResponse(
        message: message,
        userId: widget.user.id,
        userName: widget.user.name,
        conversationHistory: _messages.map((msg) => {
          'text': msg.text,
          'isUser': msg.isUser,
          'time': msg.time.toIso8601String(),
        }).toList(),
      );

      setState(() {
        _isLoading = false;
        _messages.add(EnhancedChatMessage(
          text: response['response'],
          isUser: false,
          time: DateTime.now(),
          messageType: MessageType.normal,
          resources: response['resources'] ?? [],
          followUpQuestions: response['follow_up_questions'] ?? [],
          therapeuticTechnique: response['therapeutic_technique'],
          copingStrategy: response['coping_strategy'],
          sentimentAnalysis: response['sentiment_analysis'],
          crisisLevel: response['crisis_level'],
        ));
      });

      _scrollToBottom();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(EnhancedChatMessage(
          text: "I apologize for the technical difficulty. Let's try that again. How are you feeling right now?",
          isUser: false,
          time: DateTime.now(),
          messageType: MessageType.error,
        ));
      });
      _scrollToBottom();
    }
  }

  void _sendQuickPrompt(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  // Simple voice recording simulation
  void _toggleRecording() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Show recording UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mic, color: Colors.red),
              const SizedBox(width: 8),
              Text('Recording... Speak now', style: GoogleFonts.inter()),
            ],
          ),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: 'Stop',
            onPressed: () => _toggleRecording(),
          ),
        ),
      );
    } else {
      // Simulate voice-to-text result
      _simulateVoiceToText();
    }
  }

  void _simulateVoiceToText() {
    // Simulate common mental health phrases
    final simulatedPhrases = [
      "I've been feeling really anxious lately",
      "I can't seem to focus on anything",
      "My sleep has been terrible this week",
      "I'm feeling overwhelmed with work",
      "I've been having panic attacks",
      "I feel lonely and isolated",
    ];
    
    final randomPhrase = simulatedPhrases[DateTime.now().millisecondsSinceEpoch % simulatedPhrases.length];
    
    setState(() {
      _messageController.text = randomPhrase;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice input: "$randomPhrase"', style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _speakMessage(String text) async {
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
    // Note: awaitSpeakCompletion might not be available in all versions
    // Remove this line if it causes issues
    setState(() => _isSpeaking = false);
  }

  Widget _buildMessageBubble(EnhancedChatMessage message) {
    final isCrisis = message.crisisLevel == 'severe';
    final sentiment = message.sentimentAnalysis;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Iconsax.health, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sentiment indicator for user messages
                if (message.isUser && sentiment != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSentimentIndicator(sentiment),
                      ],
                    ),
                  ),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCrisis 
                      ? Colors.red.withOpacity(0.1)
                      : message.isUser 
                        ? const Color(0xFF667EEA)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: isCrisis 
                      ? Border.all(color: Colors.red, width: 2)
                      : message.isUser 
                        ? null
                        : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: GoogleFonts.inter(
                          color: message.isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      
                      // Therapeutic technique and coping strategy
                      if (!message.isUser && message.therapeuticTechnique != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667EEA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  message.therapeuticTechnique!,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF667EEA),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (message.copingStrategy != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message.copingStrategy!,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      
                      if (isCrisis)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Iconsax.warning_2, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Crisis Support Activated',
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn().scale(),
                
                // Voice play button for bot messages
                if (!message.isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton(
                      icon: Icon(
                        _isSpeaking ? Iconsax.stop : Iconsax.voice_cricle,
                        size: 16,
                        color: const Color(0xFF667EEA),
                      ),
                      onPressed: () => _speakMessage(message.text),
                    ),
                  ),
                
                // Follow-up questions
                if (!message.isUser && message.followUpQuestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: message.followUpQuestions.take(3).map((question) {
                        return ActionChip(
                          label: Text(
                            question,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          onPressed: () => _sendQuickPrompt(question),
                          backgroundColor: Colors.blue[50],
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Iconsax.user, color: Colors.grey, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator(Map<String, dynamic> sentiment) {
    final score = sentiment['score'] ?? 0.0;
    final primaryEmotion = sentiment['primary_emotion'] ?? 'neutral';
    final confidence = sentiment['confidence'] ?? 0.0;
    
    Color color;
    IconData icon;
    String label;
    
    if (score > 0.3) {
      color = Colors.green;
      icon = Iconsax.emoji_happy;
      label = 'Positive';
    } else if (score < -0.3) {
      color = Colors.red;
      icon = Iconsax.emoji_sad;
      label = 'Negative';
    } else {
      color = Colors.orange;
      icon = Iconsax.emoji_normal;
      label = 'Neutral';
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label (${(confidence * 100).toInt()}%)',
          style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildQuickPrompts() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                _quickPrompts[index],
                style: GoogleFonts.inter(fontSize: 12),
              ),
              onPressed: () => _sendQuickPrompt(_quickPrompts[index]),
              backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
              labelStyle: const TextStyle(
                color: Color(0xFF667EEA),
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.health, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDots(),
                const SizedBox(width: 8),
                Text(
                  'Analyzing with AI...',
                  style: GoogleFonts.inter(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTypingDots() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTypingDot(0),
          _buildTypingDot(1),
          _buildTypingDot(2),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA),
        shape: BoxShape.circle,
      ),
      curve: Curves.easeInOut,
    );
  }

  void _showAdvancedResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Iconsax.health, color: Color(0xFF667EEA)),
            const SizedBox(width: 8),
            Text(
              'AI Mental Health Resources',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResourceItem('Crisis Text Line', 'Text HOME to 741741', Iconsax.message),
              _buildResourceItem('National Suicide Prevention', '988', Iconsax.call),
              _buildResourceItem('SAMHSA Helpline', '1-800-662-4357', Iconsax.heart),
              _buildResourceItem('Emergency Services', '911', Iconsax.warning_2),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Features Active:',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAIFeature('Real-time Sentiment Analysis'),
                    _buildAIFeature('Crisis Detection'),
                    _buildAIFeature('Therapeutic Techniques'),
                    _buildAIFeature('Knowledge Base Access'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String title, String contact, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF667EEA)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: GoogleFonts.inter())),
          Text(
            contact,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Iconsax.tick_circle, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Text(feature, style: GoogleFonts.inter(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'AI Mental Health Support',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: _showAdvancedResources,
            tooltip: 'AI Resources & Features',
          ),
          IconButton(
            icon: const Icon(Iconsax.chart),
            onPressed: _showSentimentAnalytics,
            tooltip: 'Sentiment Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick prompts
          _buildQuickPrompts(),
          const SizedBox(height: 8),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input area with simplified voice button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Simplified voice recording button
                IconButton(
                  icon: Icon(
                    _isRecording ? Iconsax.stop_circle : Iconsax.microphone_2,
                    color: _isRecording ? Colors.red : const Color(0xFF667EEA),
                    size: 24,
                  ),
                  onPressed: _toggleRecording,
                ),
                
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Share how you are feeling...',
                      hintStyle: GoogleFonts.inter(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Iconsax.send_2, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSentimentAnalytics() {
    // Calculate sentiment trends from messages
    final userMessages = _messages.where((msg) => msg.isUser && msg.sentimentAnalysis != null).toList();
    
    if (userMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sentiment data available yet')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sentiment Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Emotional Trends', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ...userMessages.take(5).map((msg) => _buildSentimentItem(msg)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentItem(EnhancedChatMessage message) {
    final sentiment = message.sentimentAnalysis!;
    final score = sentiment['score'] ?? 0.0;
    final emotion = sentiment['primary_emotion'] ?? 'neutral';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            score > 0.3 ? Iconsax.emoji_happy : 
            score < -0.3 ? Iconsax.emoji_sad : Iconsax.emoji_normal,
            size: 16,
            color: score > 0.3 ? Colors.green : score < -0.3 ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.text.length > 30 ? '${message.text.substring(0, 30)}...' : message.text,
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          Text(
            emotion,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: score > 0.3 ? Colors.green : score < -0.3 ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _addBotMessage(String text, {MessageType messageType = MessageType.normal}) {
    setState(() {
      _messages.add(EnhancedChatMessage(
        text: text,
        isUser: false,
        time: DateTime.now(),
        messageType: messageType,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

// Enhanced Data Models
class EnhancedChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final MessageType messageType;
  final List<dynamic> resources;
  final List<String> followUpQuestions;
  final String? therapeuticTechnique;
  final String? copingStrategy;
  final Map<String, dynamic>? sentimentAnalysis;
  final String? crisisLevel;

  const EnhancedChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.messageType = MessageType.normal,
    this.resources = const [],
    this.followUpQuestions = const [],
    this.therapeuticTechnique,
    this.copingStrategy,
    this.sentimentAnalysis,
    this.crisisLevel,
  });
}

enum MessageType { welcome, normal, error, crisis, info }