// In api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
const String baseUrl = 'http://10.74.47.55:3000/api';
class ApiService {
  // ✅ Use localhost when using 'adb reverse tcp:3000 tcp:3000' for physical devices
  
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator
  // static const String baseUrl = 'http://your-server-ip:3000/api'; // (This is a less reliable backup)

  static final AuthService _authService = AuthService();

  // ⭐️ ONLY ONE DEFINITION OF _getHeaders() SHOULD EXIST ⭐️
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    
    // 💡 DEBUG LINE: Check the value of the token
    print('DEBUG: Token retrieved for API call: $token'); 
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // ... rest of your methods like getHealthReports(), createHealthReport(), etc.
  
  // The rest of your methods will call the one, correct _getHeaders() above.

  
  // Health Reports API
  static Future<List<dynamic>> getHealthReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health/reports'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reports'] ?? [];
      } else {
        throw Exception('Failed to load health reports');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // In api_service.dart (find your existing createHealthReport and replace it)

static Future<dynamic> createHealthReport({
  required String title,
  required String description,
  required String location,
  required String type,
  required String severity,
  String? placeName,
  String? city,
  String? district,
  double? latitude,
  double? longitude,
}) async {
  try {
    final Map<String, dynamic> reportData = {
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'severity': severity,
      // Optional fields
      if (placeName != null && placeName.isNotEmpty) 'placeName': placeName,
      if (city != null && city.isNotEmpty) 'city': city,
      if (district != null && district.isNotEmpty) 'district': district,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/health/reports'),
      headers: await _getHeaders(),
      body: json.encode(reportData),
    ).timeout(const Duration(seconds: 30)); // Added 30s timeout here as well

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create health report');
    }
  } catch (e) {
    throw Exception('Network error during report creation: $e');
  }
}

  // Health Metrics API
  static Future<dynamic> getHealthMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health/metrics'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load health metrics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> updateHealthMetrics(Map<String, dynamic> metrics) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/health/metrics'),
        headers: await _getHeaders(),
        body: json.encode(metrics),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update health metrics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PCOD Tracker API - Add the missing methods
  static Future<dynamic> getPCODTracker() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pcod/tracker'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load PCOD tracker');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> updatePCODTracker(Map<String, dynamic> tracker) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pcod/tracker'),
        headers: await _getHeaders(),
        body: json.encode(tracker),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update PCOD tracker');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> getPCODStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pcod/statistics'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load PCOD statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add the missing methods for symptoms, medications, and mood
  static Future<List<dynamic>> getSymptoms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pcod/symptoms'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['symptoms'] ?? [];
      } else {
        throw Exception('Failed to load symptoms');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> addSymptom(Map<String, dynamic> symptom) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pcod/symptoms'),
        headers: await _getHeaders(),
        body: json.encode(symptom),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add symptom');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getMedications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pcod/medications'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['medications'] ?? [];
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getMoodData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pcod/mood'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['moodData'] ?? [];
      } else {
        throw Exception('Failed to load mood data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> logMood(Map<String, dynamic> mood) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pcod/mood'),
        headers: await _getHeaders(),
        body: json.encode(mood),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to log mood');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> startNewCycle(Map<String, dynamic> cycle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pcod/cycles'),
        headers: await _getHeaders(),
        body: json.encode(cycle),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start new cycle');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Location search method
  static Future<List<dynamic>> searchLocations(String query) async {
    try {
      // Using OpenStreetMap Nominatim API for location search
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to search locations');
      }
    } catch (e) {
      throw Exception('Location search error: $e');
    }
  }
  // Add to ApiService class
  
// Story Hub API Methods
static Future<Map<String, dynamic>> getStories({
  int page = 1,
  int limit = 10,
  String category = 'all',
  String sortBy = 'createdAt',
}) async {
  try {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != 'all') 'category': category,
      'sortBy': sortBy,
    };

    print('Fetching stories with params: $queryParams');
    
    final response = await http.get(
      Uri.parse('$baseUrl/stories').replace(queryParameters: queryParams),
      headers: await _getHeaders(),
    );

    print('Stories API response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Stories data received: ${data['stories']?.length ?? 0} stories');
      return data;
    } else {
      print('Stories API error: ${response.body}');
      throw Exception('Failed to load stories: ${response.statusCode}');
    }
  } catch (e) {
    print('Stories network error: $e');
    throw Exception('Network error: $e');
  }
}

// Add this debug method
static Future<Map<String, dynamic>> getStoriesDebug() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/debug'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Debug failed: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Debug error: $e');
  }
}
static Future<Map<String, dynamic>> createStory({
  required String title,
  required String content,
  required String category,
  List<String> tags = const [],
  bool isAnonymous = true,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/stories'),
      headers: await _getHeaders(),
      body: json.encode({
        'title': title,
        'content': content,
        'category': category,
        'tags': tags,
        'isAnonymous': isAnonymous,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create story');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}
// In api_service.dart

static Future<Map<String, dynamic>> likeStory(String storyId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/stories/$storyId/like'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to like story');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

static Future<List<dynamic>> getStoryCategories() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/categories'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['categories'] ?? [];
    } else {
      throw Exception('Failed to load categories');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

static Future<List<dynamic>> getMyStories() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/my-stories'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['stories'] ?? [];
    } else {
      throw Exception('Failed to load your stories');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

static Future<void> deleteStory(String storyId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/stories/$storyId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete story');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}
}