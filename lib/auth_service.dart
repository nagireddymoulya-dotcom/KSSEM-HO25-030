import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'User',
    );
  }
}

class HealthMetrics {
  final int steps;
  final double temperature;
  final int heartRate;
  final int oxygenLevel;
  final DateTime lastUpdated;

  HealthMetrics({
    required this.steps,
    required this.temperature,
    required this.heartRate,
    required this.oxygenLevel,
    required this.lastUpdated,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      steps: json['steps'] ?? 0,
      temperature: (json['temperature'] ?? 0).toDouble(),
      heartRate: json['heartRate'] ?? 0,
      oxygenLevel: json['oxygenLevel'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'temperature': temperature,
      'heartRate': heartRate,
      'oxygenLevel': oxygenLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class PCODTracker {
  final DateTime lastPeriod;
  final int cycleLength;
  final int periodLength;
  final List<String> symptoms;
  final String mood;
  final String flowIntensity;
  final List<String> medications;
  final String notes;
  final DateTime nextPredictedPeriod;
  final int currentCycleDay;
  final DateTime lastUpdated;

  PCODTracker({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodLength,
    required this.symptoms,
    required this.mood,
    required this.flowIntensity,
    required this.medications,
    required this.notes,
    required this.nextPredictedPeriod,
    required this.currentCycleDay,
    required this.lastUpdated,
  });

  factory PCODTracker.fromJson(Map<String, dynamic> json) {
    return PCODTracker(
      lastPeriod: DateTime.parse(json['lastPeriod'] ?? DateTime.now().toIso8601String()),
      cycleLength: json['cycleLength'] ?? 28,
      periodLength: json['periodLength'] ?? 5,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood'] ?? 'Normal',
      flowIntensity: json['flowIntensity'] ?? 'Medium',
      medications: List<String>.from(json['medications'] ?? []),
      notes: json['notes'] ?? '',
      nextPredictedPeriod: DateTime.parse(json['nextPredictedPeriod'] ?? DateTime.now().add(Duration(days: 28)).toIso8601String()),
      currentCycleDay: json['currentCycleDay'] ?? 1,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastPeriod': lastPeriod.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'symptoms': symptoms,
      'mood': mood,
      'flowIntensity': flowIntensity,
      'medications': medications,
      'notes': notes,
      'nextPredictedPeriod': nextPredictedPeriod.toIso8601String(),
      'currentCycleDay': currentCycleDay,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class AuthService {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // For Physical Device (replace with your computer IP)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  final _storage = const FlutterSecureStorage();

  Future<User?> registerUser(String name, String email, String password) async {
    try {
      print('Attempting to register user: $email with name: $name');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if response is HTML (error)
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<html>')) {
        throw Exception('Backend server returned HTML instead of JSON. Check if server is running correctly.');
      }

      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // Store token
        await _storage.write(key: 'token', value: data['token']);
        print('Registration successful for user: ${data['user']['name']} (${data['user']['email']})');
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Registration failed with status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Cannot connect to server. Make sure backend is running. Details: $e');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      print('Attempting to login user: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if response is HTML (error)
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<html>')) {
        throw Exception('Backend server returned HTML instead of JSON. Check if server is running correctly.');
      }

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Store token
        await _storage.write(key: 'token', value: data['token']);
        print('Login successful for user: ${data['user']['name']} (${data['user']['email']})');
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Login failed with status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Cannot connect to server. Make sure backend is running. Details: $e');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Delete token from secure storage
      await _storage.delete(key: 'token');
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, we should clear the token
      await _storage.delete(key: 'token');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      print('Token found: ${token != null}');
      
      if (token == null) {
        print('No token found - user not authenticated');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Current user response status: ${response.statusCode}');
      print('Current user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        print('Current user loaded: ${user.name} (${user.email})');
        return user;
      } else {
        print('Failed to get current user: ${response.statusCode}');
        // If token is invalid, clear it
        if (response.statusCode == 401) {
          await logout();
        }
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Health Metrics Methods
  Future<HealthMetrics> getHealthMetrics() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/health/metrics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return HealthMetrics.fromJson(data['metrics']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch health metrics');
      }
    } catch (e) {
      throw Exception('Health metrics error: $e');
    }
  }

  Future<HealthMetrics> updateHealthMetric(String metric, dynamic value) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Updating metric: $metric with value: $value');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/health/metrics/$metric'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'value': value}),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      // Check for HTML response first
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<html>')) {
        throw Exception('Server returned HTML error page. Check backend logs.');
      }

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return HealthMetrics.fromJson(data['metrics']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update health metric');
      }
    } catch (e) {
      print('Update health metric error: $e');
      throw Exception('Update health metric error: $e');
    }
  }

  Future<HealthMetrics> updateAllHealthMetrics({
    int? steps,
    double? temperature,
    int? heartRate,
    int? oxygenLevel,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.patch(
        Uri.parse('$baseUrl/health/metrics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'steps': steps,
          'temperature': temperature,
          'heartRate': heartRate,
          'oxygenLevel': oxygenLevel,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return HealthMetrics.fromJson(data['metrics']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update health metrics');
      }
    } catch (e) {
      throw Exception('Update health metrics error: $e');
    }
  }

  // PCOD/Menstrual Tracker Methods
  // In your AuthService class, update the getPCODData method:

Future<Map<String, dynamic>> getPCODData() async {
  try {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Fetching PCOD data...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/pcod/tracker'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    print('PCOD data response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final trackerData = data['tracker'] ?? {};
      
      // Convert date strings to DateTime objects
      final processedData = _processPCODData(trackerData);
      print('PCOD data loaded successfully');
      return processedData;
    } else if (response.statusCode == 404) {
      // No tracker data found, return default data
      print('No PCOD tracker data found, returning default data');
      return _getDefaultPCODData();
    } else {
      throw Exception('Failed to fetch PCOD data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching PCOD data: $e');
    // Return default data if backend is not available
    return _getDefaultPCODData();
  }
}

// Helper method to process PCOD data and convert dates
Map<String, dynamic> _processPCODData(Map<String, dynamic> data) {
  try {
    // Convert date strings to DateTime objects
    DateTime? lastPeriod;
    DateTime? nextPredictedPeriod;
    DateTime? lastUpdated;

    if (data['lastPeriod'] != null) {
      if (data['lastPeriod'] is String) {
        lastPeriod = DateTime.parse(data['lastPeriod']);
      } else if (data['lastPeriod'] is DateTime) {
        lastPeriod = data['lastPeriod'];
      }
    }

    if (data['nextPredictedPeriod'] != null) {
      if (data['nextPredictedPeriod'] is String) {
        nextPredictedPeriod = DateTime.parse(data['nextPredictedPeriod']);
      } else if (data['nextPredictedPeriod'] is DateTime) {
        nextPredictedPeriod = data['nextPredictedPeriod'];
      }
    }

    if (data['lastUpdated'] != null) {
      if (data['lastUpdated'] is String) {
        lastUpdated = DateTime.parse(data['lastUpdated']);
      } else if (data['lastUpdated'] is DateTime) {
        lastUpdated = data['lastUpdated'];
      }
    }

    return {
      'lastPeriod': lastPeriod ?? DateTime.now().subtract(const Duration(days: 15)),
      'cycleLength': data['cycleLength'] ?? 28,
      'periodLength': data['periodLength'] ?? 5,
      'symptoms': List<String>.from(data['symptoms'] ?? []),
      'mood': data['mood'] ?? 'Normal',
      'flowIntensity': data['flowIntensity'] ?? 'Medium',
      'medications': List<String>.from(data['medications'] ?? []),
      'notes': data['notes'] ?? '',
      'nextPredictedPeriod': nextPredictedPeriod ?? DateTime.now().add(const Duration(days: 13)),
      'currentCycleDay': data['currentCycleDay'] ?? 15,
      'lastUpdated': lastUpdated ?? DateTime.now(),
    };
  } catch (e) {
    print('Error processing PCOD data: $e');
    return _getDefaultPCODData();
  }
}

// Also update the updatePCODData method:

Future<Map<String, dynamic>> updatePCODData(Map<String, dynamic> data) async {
  try {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Updating PCOD data...');
    
    // Process and calculate cycle data
    final updatedData = _calculateCycleData(data);
    
    // Convert DateTime objects to strings for JSON
    final dataForBackend = _prepareDataForBackend(updatedData);
    
    final response = await http.post(
      Uri.parse('$baseUrl/pcod/tracker'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(dataForBackend),
    ).timeout(const Duration(seconds: 10));

    print('PCOD update response status: ${response.statusCode}');
    print('PCOD update response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final trackerData = responseData['tracker'] ?? updatedData;
      
      // Process the response data to convert date strings back to DateTime
      final processedData = _processPCODData(trackerData);
      print('PCOD data updated successfully');
      return processedData;
    } else {
      throw Exception('Failed to update PCOD data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating PCOD data: $e');
    // If backend fails, still return the calculated data
    return _calculateCycleData(data);
  }
}

// Helper method to prepare data for backend (convert DateTime to String)
Map<String, dynamic> _prepareDataForBackend(Map<String, dynamic> data) {
  final Map<String, dynamic> backendData = Map.from(data);
  
  // Convert DateTime objects to ISO strings
  if (backendData['lastPeriod'] is DateTime) {
    backendData['lastPeriod'] = (backendData['lastPeriod'] as DateTime).toIso8601String();
  }
  
  if (backendData['nextPredictedPeriod'] is DateTime) {
    backendData['nextPredictedPeriod'] = (backendData['nextPredictedPeriod'] as DateTime).toIso8601String();
  }
  
  if (backendData['lastUpdated'] is DateTime) {
    backendData['lastUpdated'] = (backendData['lastUpdated'] as DateTime).toIso8601String();
  }
  
  return backendData;
}

// Update the _calculateCycleData method:

Map<String, dynamic> _calculateCycleData(Map<String, dynamic> data) {
  DateTime lastPeriod;
  
  // Handle different types of lastPeriod input
  if (data['lastPeriod'] is String) {
    lastPeriod = DateTime.parse(data['lastPeriod']);
  } else if (data['lastPeriod'] is DateTime) {
    lastPeriod = data['lastPeriod'];
  } else {
    lastPeriod = DateTime.now().subtract(const Duration(days: 15));
  }
  
  final cycleLength = data['cycleLength'] ?? 28;
  final periodLength = data['periodLength'] ?? 5;
  
  // Calculate next predicted period
  final nextPredictedPeriod = lastPeriod.add(Duration(days: cycleLength));
  
  // Calculate current cycle day
  final today = DateTime.now();
  final currentCycleDay = today.difference(lastPeriod).inDays + 1;
  
  return {
    ...data,
    'lastPeriod': lastPeriod,
    'cycleLength': cycleLength,
    'periodLength': periodLength,
    'nextPredictedPeriod': nextPredictedPeriod,
    'currentCycleDay': currentCycleDay > 0 ? currentCycleDay : 1,
    'lastUpdated': DateTime.now(),
  };
}

// Default PCOD data for new users
Map<String, dynamic> _getDefaultPCODData() {
  final defaultLastPeriod = DateTime.now().subtract(const Duration(days: 15));
  final defaultCycleLength = 28;
  
  return {
    'lastPeriod': defaultLastPeriod,
    'cycleLength': defaultCycleLength,
    'periodLength': 5,
    'symptoms': ['Cramps', 'Headache'],
    'mood': 'Normal',
    'flowIntensity': 'Medium',
    'medications': ['Pain reliever'],
    'notes': 'Feeling okay today',
    'nextPredictedPeriod': defaultLastPeriod.add(Duration(days: defaultCycleLength)),
    'currentCycleDay': 15,
    'lastUpdated': DateTime.now(),
  };
}

  // Additional PCOD methods for more specific operations
  Future<Map<String, dynamic>> updatePCODSymptoms(List<String> symptoms) async {
    try {
      final currentData = await getPCODData();
      final updatedData = {
        ...currentData,
        'symptoms': symptoms,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      return await updatePCODData(updatedData);
    } catch (e) {
      print('Error updating PCOD symptoms: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePCODMood(String mood) async {
    try {
      final currentData = await getPCODData();
      final updatedData = {
        ...currentData,
        'mood': mood,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      return await updatePCODData(updatedData);
    } catch (e) {
      print('Error updating PCOD mood: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePCODFlowIntensity(String flowIntensity) async {
    try {
      final currentData = await getPCODData();
      final updatedData = {
        ...currentData,
        'flowIntensity': flowIntensity,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      return await updatePCODData(updatedData);
    } catch (e) {
      print('Error updating PCOD flow intensity: $e');
      rethrow;
    }
  }

  // Method to get cycle statistics
  Future<Map<String, dynamic>> getPCODStatistics() async {
    try {
      final pcodData = await getPCODData();
      
      // Calculate some basic statistics
      final statistics = {
        'averageCycleLength': pcodData['cycleLength'],
        'averagePeriodLength': pcodData['periodLength'],
        'commonSymptoms': _getCommonSymptoms(pcodData['symptoms']),
        'moodPatterns': _analyzeMoodPatterns(pcodData),
        'cycleRegularity': 'Regular', // This would be calculated from historical data
      };
      
      return statistics;
    } catch (e) {
      print('Error getting PCOD statistics: $e');
      return {};
    }
  }

  // Helper methods for statistics
  List<String> _getCommonSymptoms(List<dynamic> symptoms) {
  if (symptoms.isEmpty) return [];
  
  // Count symptom frequency
  final symptomCount = <String, int>{};
  for (final symptom in symptoms) {
    final symptomStr = symptom.toString();
    symptomCount[symptomStr] = (symptomCount[symptomStr] ?? 0) + 1;
  }
  
  // Return top 3 most common symptoms
  final sortedEntries = symptomCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  return sortedEntries
      .take(3)
      .map((entry) => entry.key)
      .toList();
}
  String _analyzeMoodPatterns(Map<String, dynamic> data) {
    // Simple mood analysis based on current data
    // In a real app, this would analyze historical patterns
    final mood = data['mood'];
    if (mood == 'Happy' || mood == 'Energetic') {
      return 'Positive';
    } else if (mood == 'Sad' || mood == 'Anxious' || mood == 'Irritable') {
      return 'Needs Support';
    } else {
      return 'Stable';
    }
  }
}