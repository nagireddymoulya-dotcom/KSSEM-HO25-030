import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class EnhancedMentalHealthService {
  // API Keys
  final String _groqApiKey;
  final String _huggingFaceKey;
  final String _cohereApiKey;
  final String _pineconeApiKey;
  
  // Base URLs
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _huggingFaceUrl = 'https://api-inference.huggingface.co/models';
  static const String _cohereUrl = 'https://api.cohere.ai/v1/classify';
  static const String _pineconeUrl = 'https://your-pinecone-index.pinecone.io';

  EnhancedMentalHealthService()
      : _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '',
        _huggingFaceKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '',
        _cohereApiKey = dotenv.env['COHERE_API_KEY'] ?? '',
        _pineconeApiKey = dotenv.env['PINECONE_API_KEY'] ?? '';

  // Main method to get AI response with RAG and NLP
  Future<Map<String, dynamic>> getEnhancedAIResponse({
    required String message,
    required String userId,
    required String userName,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    try {
      // Step 1: Perform sentiment analysis and crisis detection
      final sentiment = await _analyzeSentimentWithNLP(message);
      final crisisLevel = await _detectCrisisLevel(message, sentiment);
      
      // Step 2: If crisis detected, handle immediately
      if (crisisLevel == CrisisLevel.severe) {
        return _buildCrisisResponse(userName);
      }
      
      // Step 3: Retrieve relevant knowledge from RAG system
      final relevantKnowledge = await _retrieveRelevantKnowledge(
        message, 
        sentiment, 
        userId
      );
      
      // Step 4: Get LLM response with context
      final llmResponse = await _getLLMResponseWithRAG(
        message: message,
        userName: userName,
        sentiment: sentiment,
        crisisLevel: crisisLevel,
        relevantKnowledge: relevantKnowledge,
        conversationHistory: conversationHistory,
      );
      
      return llmResponse;
      
    } catch (e) {
      // Fallback to intelligent local responses
      return _getLocalIntelligentResponse(message, userName);
    }
  }

  // NLP Sentiment Analysis
  Future<SentimentAnalysis> _analyzeSentimentWithNLP(String text) async {
    try {
      // Try Cohere first for accurate sentiment analysis
      if (_cohereApiKey.isNotEmpty) {
        final response = await http.post(
          Uri.parse(_cohereUrl),
          headers: {
            'Authorization': 'Bearer $_cohereApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'texts': [text],
            'model': 'embed-english-v2.0',
          }),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return SentimentAnalysis.fromCohere(data);
        }
      }
      
      // Fallback to Hugging Face sentiment analysis
      if (_huggingFaceKey.isNotEmpty) {
        final hfResponse = await http.post(
          Uri.parse('$_huggingFaceUrl/cardiffnlp/twitter-roberta-base-sentiment-latest'),
          headers: {'Authorization': 'Bearer $_huggingFaceKey'},
          body: jsonEncode({'inputs': text}),
        );
        
        if (hfResponse.statusCode == 200) {
          final data = jsonDecode(hfResponse.body);
          return SentimentAnalysis.fromHuggingFace(data);
        }
      }
      
    } catch (e) {
      print('Sentiment analysis error: $e');
    }
    
    // Final fallback to keyword-based analysis
    return _fallbackSentimentAnalysis(text);
  }

  // RAG System - Retrieve Relevant Mental Health Knowledge
  Future<List<String>> _retrieveRelevantKnowledge(
    String query, 
    SentimentAnalysis sentiment,
    String userId,
  ) async {
    try {
      if (_pineconeApiKey.isNotEmpty) {
        // Generate query embedding
        final queryEmbedding = await _generateEmbedding(query);
        
        // Query vector database
        final response = await http.post(
          Uri.parse('$_pineconeUrl/query'),
          headers: {
            'Content-Type': 'application/json',
            'Api-Key': _pineconeApiKey,
          },
          body: jsonEncode({
            'vector': queryEmbedding,
            'topK': 5,
            'includeMetadata': true,
            'filter': {
              'sentiment': sentiment.primaryEmotion,
              'userId': userId, // Personalize results
            }
          }),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return _extractKnowledgeFromResults(data);
        }
      }
    } catch (e) {
      print('RAG retrieval error: $e');
    }
    
    // Fallback to static knowledge base
    return _getStaticKnowledge(query, sentiment);
  }

  // LLM with RAG Context
  Future<Map<String, dynamic>> _getLLMResponseWithRAG({
    required String message,
    required String userName,
    required SentimentAnalysis sentiment,
    required CrisisLevel crisisLevel,
    required List<String> relevantKnowledge,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    try {
      // Use Groq for fast inference
      if (_groqApiKey.isNotEmpty) {
        final response = await http.post(
          Uri.parse(_groqUrl),
          headers: {
            'Authorization': 'Bearer $_groqApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'messages': _buildRAGEnhancedMessages(
              message, userName, sentiment, crisisLevel, 
              relevantKnowledge, conversationHistory,
            ),
            'model': 'llama2-70b-4096',
            'temperature': 0.7,
            'max_tokens': 500,
            'stream': false,
          }),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final aiResponse = data['choices'][0]['message']['content'];
          return _parseEnhancedAIResponse(aiResponse, sentiment, crisisLevel);
        }
      }
    } catch (e) {
      print('Groq API error: $e');
    }
    
    // Fallback to local responses
    return _getLocalIntelligentResponse(message, userName);
  }

  List<Map<String, dynamic>> _buildRAGEnhancedMessages(
    String message,
    String userName,
    SentimentAnalysis sentiment,
    CrisisLevel crisisLevel,
    List<String> relevantKnowledge,
    List<Map<String, dynamic>> history,
  ) {
    return [
      {
        'role': 'system',
        'content': '''
You are a compassionate, professional mental health assistant with access to evidence-based therapeutic techniques.

USER CONTEXT:
- Name: $userName
- Current Sentiment: ${sentiment.primaryEmotion} (confidence: ${(sentiment.confidence * 100).toStringAsFixed(1)}%)
- Crisis Level: ${crisisLevel.name}
- Detected Emotions: ${sentiment.detectedEmotions.join(', ')}

RELEVANT KNOWLEDGE:
${relevantKnowledge.join('\n')}

THERAPEUTIC APPROACH:
1. Use evidence-based techniques (CBT, DBT, Mindfulness)
2. Provide validation and empathy
3. Offer practical coping strategies
4. Maintain professional boundaries
5. Suggest professional help when appropriate
6. Use the user's name naturally in conversation

CRISIS PROTOCOLS:
- If crisis level is severe, provide immediate crisis resources
- If moderate, suggest professional consultation
- Always validate feelings and provide hope

RESPONSE FORMAT (JSON):
{
  "response": "your compassionate response",
  "therapeutic_technique": "CBT/Mindfulness/DBT/etc",
  "resources": ["resource1", "resource2"],
  "follow_up_questions": ["question1", "question2"],
  "suggest_professional_help": false,
  "coping_strategy": "specific strategy suggestion"
}
'''
      },
      ...history.take(10).map((msg) => {
        'role': msg['isUser'] ? 'user' : 'assistant',
        'content': msg['text'],
      }),
      {
        'role': 'user',
        'content': message,
      },
    ];
  }

  // Crisis Detection with NLP
  Future<CrisisLevel> _detectCrisisLevel(String message, SentimentAnalysis sentiment) async {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end it all', 'want to die', 'better off dead',
      'harm myself', 'self harm', 'cutting', 'overdose', 'no way out'
    ];
    
    final urgentKeywords = [
      'panic attack', 'can\'t breathe', 'losing control', 'emergency', 'help now'
    ];
    
    final lowerMessage = message.toLowerCase();
    
    bool hasCrisisKeywords = crisisKeywords.any((keyword) => lowerMessage.contains(keyword));
    bool hasUrgentKeywords = urgentKeywords.any((keyword) => lowerMessage.contains(keyword));
    
    if (hasCrisisKeywords) {
      return CrisisLevel.severe;
    } else if (hasUrgentKeywords || sentiment.score < -0.7) {
      return CrisisLevel.moderate;
    } else if (sentiment.score < -0.3) {
      return CrisisLevel.mild;
    }
    
    return CrisisLevel.none;
  }

  // Helper Methods
  Future<List<double>> _generateEmbedding(String text) async {
    try {
      if (_huggingFaceKey.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$_huggingFaceUrl/sentence-transformers/all-MiniLM-L6-v2'),
          headers: {'Authorization': 'Bearer $_huggingFaceKey'},
          body: jsonEncode({'inputs': text}),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List && data.isNotEmpty) {
            return List<double>.from(data[0]);
          }
        }
      }
    } catch (e) {
      print('Embedding generation error: $e');
    }
    
    // Simple fallback embedding
    return List<double>.filled(384, 0.1);
  }

  List<String> _extractKnowledgeFromResults(Map<String, dynamic> data) {
    final matches = data['matches'] as List? ?? [];
    return matches.map<String>((match) {
      return match['metadata']?['content']?.toString() ?? '';
    }).where((content) => content.isNotEmpty).toList();
  }

  List<String> _getStaticKnowledge(String query, SentimentAnalysis sentiment) {
    // Static mental health knowledge base
    final knowledgeBase = {
      'anxiety': [
        'Cognitive Behavioral Therapy (CBT) techniques for anxiety include identifying and challenging negative thought patterns.',
        'Deep breathing exercises can help reduce anxiety symptoms by activating the parasympathetic nervous system.',
        'Progressive muscle relaxation involves tensing and relaxing different muscle groups to reduce physical anxiety symptoms.',
      ],
      'depression': [
        'Behavioral activation is an effective technique for depression that involves scheduling pleasant activities.',
        'Mindfulness-based cognitive therapy can help prevent relapse in depression.',
        'Regular exercise has been shown to be as effective as medication for mild to moderate depression.',
      ],
      'stress': [
        'The 4-7-8 breathing technique can quickly reduce stress: inhale for 4 seconds, hold for 7, exhale for 8.',
        'Time management strategies like the Pomodoro technique can help reduce work-related stress.',
        'Setting healthy boundaries is crucial for managing interpersonal stress.',
      ],
    };
    
    final lowerQuery = query.toLowerCase();
    for (final topic in knowledgeBase.keys) {
      if (lowerQuery.contains(topic)) {
        return knowledgeBase[topic]!;
      }
    }
    
    return [
      'Active listening and validation are fundamental therapeutic skills.',
      'Self-care practices like adequate sleep, nutrition, and exercise support mental health.',
      'Social connection and support networks are protective factors for mental wellbeing.',
    ];
  }

  Map<String, dynamic> _parseEnhancedAIResponse(
    String aiResponse, 
    SentimentAnalysis sentiment, 
    CrisisLevel crisisLevel,
  ) {
    try {
      final parsed = jsonDecode(aiResponse);
      return {
        'response': parsed['response'] ?? aiResponse,
        'resources': parsed['resources'] ?? [],
        'follow_up_questions': parsed['follow_up_questions'] ?? [],
        'suggest_professional_help': parsed['suggest_professional_help'] ?? false,
        'therapeutic_technique': parsed['therapeutic_technique'] ?? 'Supportive Listening',
        'coping_strategy': parsed['coping_strategy'] ?? 'Mindful breathing',
        'sentiment_analysis': sentiment.toJson(),
        'crisis_level': crisisLevel.name,
      };
    } catch (e) {
      // If JSON parsing fails, use the text as response
      return {
        'response': aiResponse,
        'resources': [],
        'follow_up_questions': [],
        'suggest_professional_help': false,
        'therapeutic_technique': 'Supportive Listening',
        'coping_strategy': 'Mindful breathing',
        'sentiment_analysis': sentiment.toJson(),
        'crisis_level': crisisLevel.name,
      };
    }
  }

  Map<String, dynamic> _getLocalIntelligentResponse(String message, String userName) {
    final lowerMessage = message.toLowerCase();
    
    // Crisis detection
    if (_isCrisisMessage(lowerMessage)) {
      return _buildCrisisResponse(userName);
    }

    // Context-aware responses based on message content
    if (lowerMessage.contains('anxious') || lowerMessage.contains('anxiety') || lowerMessage.contains('panic')) {
      return _buildAnxietyResponse(userName);
    } else if (lowerMessage.contains('depress') || lowerMessage.contains('sad') || lowerMessage.contains('hopeless')) {
      return _buildDepressionResponse(userName);
    } else if (lowerMessage.contains('stress') || lowerMessage.contains('overwhelm') || lowerMessage.contains('pressure')) {
      return _buildStressResponse(userName);
    } else if (lowerMessage.contains('angry') || lowerMessage.contains('anger') || lowerMessage.contains('frustrat')) {
      return _buildAngerResponse(userName);
    } else if (lowerMessage.contains('sleep') || lowerMessage.contains('insomnia') || lowerMessage.contains('tired')) {
      return _buildSleepResponse(userName);
    } else if (lowerMessage.contains('lonely') || lowerMessage.contains('alone') || lowerMessage.contains('isolated')) {
      return _buildLonelinessResponse(userName);
    } else if (lowerMessage.contains('happy') || lowerMessage.contains('good') || lowerMessage.contains('better')) {
      return _buildPositiveResponse(userName);
    } else {
      return _buildGeneralSupportResponse(userName);
    }
  }

  bool _isCrisisMessage(String message) {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end it all', 'want to die', 'better off dead',
      'harm myself', 'self harm', 'cutting', 'overdose', 'no way out'
    ];
    return crisisKeywords.any((keyword) => message.contains(keyword));
  }

  Map<String, dynamic> _buildAnxietyResponse(String userName) {
    return {
      'response': "I understand anxiety can feel overwhelming, $userName. When anxiety strikes, try the 5-4-3-2-1 grounding technique: Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. This can help bring you back to the present moment.",
      'resources': [
        {'title': 'Anxiety Grounding Techniques', 'type': 'Exercise'},
        {'title': 'Calming Breathing Exercises', 'type': 'Audio'},
      ],
      'follow_up_questions': [
        'Where do you feel the anxiety in your body?',
        'What situations trigger these feelings?',
        'Would you like to try a progressive muscle relaxation exercise?'
      ],
      'suggest_professional_help': true,
      'therapeutic_technique': 'CBT - Grounding Techniques',
      'coping_strategy': '5-4-3-2-1 Grounding',
      'sentiment_analysis': {'score': -0.5, 'confidence': 0.8, 'primary_emotion': 'anxious', 'detected_emotions': ['anxiety']},
      'crisis_level': 'mild',
    };
  }

  Map<String, dynamic> _buildDepressionResponse(String userName) {
    return {
      'response': "It sounds like you're carrying a heavy weight, $userName. Depression can make everything feel difficult. Remember that these feelings are valid, and they won't last forever. Even small activities like taking a shower or going for a short walk can be meaningful steps forward.",
      'resources': [
        {'title': 'Depression Self-Help Guide', 'type': 'Guide'},
        {'title': 'Behavioral Activation Techniques', 'type': 'Exercise'},
      ],
      'follow_up_questions': [
        'What activities usually bring you joy, even if just a little?',
        'How has your sleep and appetite been?',
        'Is there someone in your life you feel comfortable talking to?'
      ],
      'suggest_professional_help': true,
      'therapeutic_technique': 'Behavioral Activation',
      'coping_strategy': 'Small Achievable Goals',
      'sentiment_analysis': {'score': -0.6, 'confidence': 0.8, 'primary_emotion': 'sad', 'detected_emotions': ['depression']},
      'crisis_level': 'mild',
    };
  }

  Map<String, dynamic> _buildStressResponse(String userName) {
    return {
      'response': "Stress can feel like too much to handle, $userName. Try breaking things down into smaller, manageable steps. The 4-7-8 breathing technique can help: inhale for 4 seconds, hold for 7, exhale for 8. Repeat 4 times.",
      'resources': [
        {'title': 'Stress Management Techniques', 'type': 'Guide'},
        {'title': 'Time Management Strategies', 'type': 'Article'},
      ],
      'follow_up_questions': [
        'What specific situations are causing the most stress?',
        'What helps you relax when you feel overwhelmed?',
        'Would you like to explore some boundary-setting techniques?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Mindfulness',
      'coping_strategy': '4-7-8 Breathing',
      'sentiment_analysis': {'score': -0.4, 'confidence': 0.8, 'primary_emotion': 'stressed', 'detected_emotions': ['stress']},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildAngerResponse(String userName) {
    return {
      'response': "Anger is a natural emotion that can be challenging to manage, $userName. When you feel anger building, try the STOP technique: Stop, Take a breath, Observe your feelings, Proceed mindfully. This creates space between the trigger and your response.",
      'resources': [
        {'title': 'Anger Management Techniques', 'type': 'Guide'},
        {'title': 'Mindfulness for Anger', 'type': 'Exercise'},
      ],
      'follow_up_questions': [
        'What typically triggers these angry feelings?',
        'How does your body feel when you get angry?',
        'What has helped you manage anger in the past?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Emotion Regulation',
      'coping_strategy': 'STOP Technique',
      'sentiment_analysis': {'score': -0.3, 'confidence': 0.8, 'primary_emotion': 'angry', 'detected_emotions': ['anger']},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildSleepResponse(String userName) {
    return {
      'response': "Sleep issues can really impact your wellbeing, $userName. Try establishing a relaxing bedtime routine: avoid screens an hour before bed, create a comfortable sleep environment, and practice deep breathing. Consistency is key for improving sleep quality.",
      'resources': [
        {'title': 'Sleep Hygiene Guide', 'type': 'Guide'},
        {'title': 'Guided Sleep Meditation', 'type': 'Audio'},
      ],
      'follow_up_questions': [
        'How many hours of sleep are you typically getting?',
        'Do you have trouble falling asleep or staying asleep?',
        'What does your current bedtime routine look like?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Sleep Hygiene',
      'coping_strategy': 'Bedtime Routine',
      'sentiment_analysis': {'score': -0.2, 'confidence': 0.8, 'primary_emotion': 'tired', 'detected_emotions': ['fatigue']},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildLonelinessResponse(String userName) {
    return {
      'response': "Feeling lonely can be incredibly difficult, $userName. Remember that many people experience loneliness, and it doesn't mean you're alone. Even small connections can help - consider reaching out to an old friend or joining an online community about your interests.",
      'resources': [
        {'title': 'Building Social Connections', 'type': 'Guide'},
        {'title': 'Mindfulness for Loneliness', 'type': 'Exercise'},
      ],
      'follow_up_questions': [
        'What kind of connections are you missing right now?',
        'What activities make you feel connected to others?',
        'Have you considered joining any groups or communities?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Social Connection',
      'coping_strategy': 'Reach Out',
      'sentiment_analysis': {'score': -0.4, 'confidence': 0.8, 'primary_emotion': 'lonely', 'detected_emotions': ['isolation']},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildPositiveResponse(String userName) {
    return {
      'response': "That's wonderful to hear, $userName! 😊 Celebrating positive moments and good feelings is so important for mental health. What's contributing to your good mood today?",
      'resources': [
        {'title': 'Gratitude Journaling', 'type': 'Exercise'},
        {'title': 'Mindfulness Practices', 'type': 'Guide'},
      ],
      'follow_up_questions': [
        'What helped create these positive feelings?',
        'How can you carry this positive energy forward?',
        'Is there someone you can share this good mood with?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Positive Psychology',
      'coping_strategy': 'Gratitude Practice',
      'sentiment_analysis': {'score': 0.7, 'confidence': 0.8, 'primary_emotion': 'happy', 'detected_emotions': ['joy']},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildGeneralSupportResponse(String userName) {
    return {
      'response': "Thank you for sharing that with me, $userName. I'm here to listen and support you. It takes courage to talk about your feelings. Would you like to tell me more about what's on your mind?",
      'resources': [
        {'title': 'Mental Health Resources', 'type': 'Guide'},
        {'title': 'Self-Care Strategies', 'type': 'Article'},
      ],
      'follow_up_questions': [
        'How long have you been feeling this way?',
        'What usually helps you feel better?',
        'Is there anything specific you\'d like support with today?'
      ],
      'suggest_professional_help': false,
      'therapeutic_technique': 'Supportive Listening',
      'coping_strategy': 'Self-Reflection',
      'sentiment_analysis': {'score': 0.0, 'confidence': 0.8, 'primary_emotion': 'neutral', 'detected_emotions': []},
      'crisis_level': 'none',
    };
  }

  Map<String, dynamic> _buildCrisisResponse(String userName) {
    return {
      'response': "I'm very concerned about what you're sharing, $userName. Your safety is the most important thing right now. Please contact emergency services immediately or call the National Suicide Prevention Lifeline at 988. You're not alone, and there are people who want to help you right now.",
      'resources': [
        {'title': 'National Suicide Prevention Lifeline', 'type': 'Hotline', 'contact': '988'},
        {'title': 'Crisis Text Line', 'type': 'Text', 'contact': 'Text HOME to 741741'},
        {'title': 'Emergency Services', 'type': 'Emergency', 'contact': '911'},
      ],
      'follow_up_questions': [
        'Are you safe right now?',
        'Can you contact someone who can be with you?',
        'Would you like me to help you find local emergency services?'
      ],
      'suggest_professional_help': true,
      'therapeutic_technique': 'Crisis Intervention',
      'coping_strategy': 'Immediate safety planning',
      'sentiment_analysis': {'score': -0.9, 'confidence': 0.9, 'primary_emotion': 'crisis', 'detected_emotions': ['urgent']},
      'crisis_level': 'severe',
    };
  }

  SentimentAnalysis _fallbackSentimentAnalysis(String text) {
    // Simple keyword-based sentiment analysis
    final positiveWords = ['good', 'great', 'happy', 'better', 'well', 'improved', 'excited', 'joy', 'love'];
    final negativeWords = ['bad', 'terrible', 'sad', 'worse', 'awful', 'hopeless', 'angry', 'hate', 'depressed'];
    
    int score = 0;
    final words = text.toLowerCase().split(' ');
    
    for (final word in words) {
      if (positiveWords.contains(word)) score++;
      if (negativeWords.contains(word)) score--;
    }
    
    final normalizedScore = words.isNotEmpty ? score / words.length : 0.0;
    
    String primaryEmotion;
    if (normalizedScore > 0.3) {
      primaryEmotion = 'positive';
    } else if (normalizedScore < -0.3) {
      primaryEmotion = 'negative';
    } else {
      primaryEmotion = 'neutral';
    }
    
    return SentimentAnalysis(
      score: normalizedScore,
      confidence: 0.7,
      primaryEmotion: primaryEmotion,
      detectedEmotions: [],
    );
  }
}

// Enhanced Data Models
class SentimentAnalysis {
  final double score; // -1 to 1
  final double confidence; // 0 to 1
  final String primaryEmotion;
  final List<String> detectedEmotions;

  SentimentAnalysis({
    required this.score,
    required this.confidence,
    required this.primaryEmotion,
    required this.detectedEmotions,
  });

  factory SentimentAnalysis.fromCohere(Map<String, dynamic> data) {
    // Parse Cohere sentiment response
    return SentimentAnalysis(
      score: 0.0, // Would parse from actual response
      confidence: 0.8,
      primaryEmotion: 'neutral',
      detectedEmotions: [],
    );
  }

  factory SentimentAnalysis.fromHuggingFace(Map<String, dynamic> data) {
    // Parse Hugging Face sentiment response
    return SentimentAnalysis(
      score: 0.0, // Would parse from actual response
      confidence: 0.8,
      primaryEmotion: 'neutral',
      detectedEmotions: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'confidence': confidence,
      'primary_emotion': primaryEmotion,
      'detected_emotions': detectedEmotions,
    };
  }
}

enum CrisisLevel { none, mild, moderate, severe }