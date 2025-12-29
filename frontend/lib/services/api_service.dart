import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ApiService {
  // Update this to your backend URL based on your setup:
  // For Android emulator, use: 'http://10.0.2.2:4000/api'
  // For iOS simulator, use: 'http://localhost:4000/api'
  // For physical Android device, use your computer's local IP: 'http://192.168.x.x:4000/api'
  // 
  // To find your computer's IP:
  // Windows: Run 'ipconfig' in CMD and look for "IPv4 Address" under your active network adapter
  // Mac/Linux: Run 'ifconfig' or 'ip addr' and look for your local network IP (usually 192.168.x.x)
  // 
  // IMPORTANT: Make sure your phone and computer are on the same WiFi network!
  static const String baseUrl = 'https://ballista-4d2o.onrender.com/api'; // Render.com backend URL
  // static const String baseUrl = 'http://10.0.2.2:4000/api'; // Android emulator (10.0.2.2 = localhost from emulator)
  // static const String baseUrl = 'http://localhost:4000/api'; // iOS simulator or web

  /// Test backend connectivity
  static Future<bool> testConnection() async {
    try {
      developer.log('🔵 [API] Testing connection to $baseUrl/health');
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      developer.log('✅ [API] Connection test successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      developer.log('❌ [API] Connection test failed: $e');
      return false;
    }
  }

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        final errorMsg = body['message'] ?? body['error'] ?? 'Request failed';
        developer.log('❌ [API] HTTP Error ${response.statusCode}: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      developer.log('❌ [API] Failed to parse response: ${response.body}');
      throw Exception('Failed to parse server response');
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    try {
      developer.log('🔵 [API] POST $baseUrl/auth/signup');
      developer.log('🔵 [API] Body: email=$email, role=$role');
      
      final uri = Uri.parse('$baseUrl/auth/signup'); // Should be: https://ballista-4d2o.onrender.com/api/auth/signup
      developer.log('🔵 [API] Full URL: $uri');
      
      final requestBody = json.encode({
        'email': email,
        'password': password,
        'role': role,
        'fullName': fullName,
        'phone': phone,
      });
      
      // Test connection first (with longer timeout for Render.com cold start)
      developer.log('🔵 [API] Testing connection before signup...');
      final healthUrl = '${baseUrl.replaceAll('/api', '')}/api/health';
      developer.log('🔵 [API] Testing URL: $healthUrl');
      try {
        final testResponse = await http
            .get(Uri.parse(healthUrl))
            .timeout(const Duration(seconds: 60)); // Longer timeout for Render.com cold start
        developer.log('✅ [API] Connection test successful: ${testResponse.statusCode}');
      } catch (e, stackTrace) {
        developer.log('⚠️ [API] Connection test failed (will still try signup): $e');
        // Don't throw error - continue with signup attempt (cold start might just be slow)
      }

      developer.log('🔵 [API] Sending signup request...');
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: requestBody,
      ).timeout(
        const Duration(seconds: 60), // Longer timeout for Render.com cold start (30-60 seconds)
        onTimeout: () {
          developer.log('❌ [API] Signup request timed out after 60 seconds');
          throw http.ClientException('Request timed out. Backend server may be starting up (takes 30-60 seconds). Please try again.');
        },
      );
      
      developer.log('🔵 [API] Response status: ${response.statusCode}');
      developer.log('🔵 [API] Response body: ${response.body}');
      
      return await _handleResponse(response);
    } on http.ClientException catch (e) {
      developer.log('❌ [API] Network error during signup: $e');
      developer.log('❌ [API] Error message: ${e.message}');
      developer.log('❌ [API] Error URI: ${e.uri}');
      throw Exception('Network error: ${e.message}. Cannot connect to backend server. Please check your internet connection.');
    } on FormatException catch (e) {
      developer.log('❌ [API] Format error during signup: $e');
      throw Exception('Invalid server response format');
    } catch (e, stackTrace) {
      developer.log('❌ [API] Signup request failed: $e', error: e, stackTrace: stackTrace);
      if (e.toString().contains('TimeoutException') || e.toString().contains('timed out')) {
        throw Exception('Request timed out. Check your internet connection and ensure backend is running.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('🔵 [API] POST $baseUrl/auth/login');
      developer.log('🔵 [API] Body: email=$email');
      
      // Test connection first (with longer timeout for Render.com cold start)
      developer.log('🔵 [API] Testing connection before login...');
      final healthUrl = '${baseUrl.replaceAll('/api', '')}/api/health';
      developer.log('🔵 [API] Testing URL: $healthUrl');
      try {
        final testResponse = await http
            .get(Uri.parse(healthUrl))
            .timeout(const Duration(seconds: 60)); // Longer timeout for Render.com cold start
        developer.log('✅ [API] Connection test successful: ${testResponse.statusCode}');
      } catch (e, stackTrace) {
        developer.log('⚠️ [API] Connection test failed (will still try login): $e');
        // Don't throw error - continue with login attempt (cold start might just be slow)
      }
      
      final uri = Uri.parse('$baseUrl/auth/login');
      developer.log('🔵 [API] Full URL: $uri');
      
      developer.log('🔵 [API] Sending login request...');
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 60), // Longer timeout for Render.com cold start (30-60 seconds)
        onTimeout: () {
          developer.log('❌ [API] Login request timed out after 60 seconds');
          throw http.ClientException('Request timed out. Backend server may be starting up (takes 30-60 seconds). Please try again.');
        },
      );
      
      developer.log('🔵 [API] Response status: ${response.statusCode}');
      developer.log('🔵 [API] Response body: ${response.body}');
      
      return await _handleResponse(response);
    } on http.ClientException catch (e) {
      developer.log('❌ [API] Network error during login: $e');
      developer.log('❌ [API] Error message: ${e.message}');
      developer.log('❌ [API] Error URI: ${e.uri}');
      throw Exception('Network error: ${e.message}. Cannot connect to backend server. Please check your internet connection.');
    } on FormatException catch (e) {
      developer.log('❌ [API] Format error during login: $e');
      throw Exception('Invalid server response format');
    } catch (e, stackTrace) {
      developer.log('❌ [API] Login request failed: $e', error: e, stackTrace: stackTrace);
      if (e.toString().contains('TimeoutException') || e.toString().contains('timed out')) {
        throw Exception('Request timed out. Check your internet connection and ensure backend is running.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? fullName,
    String? phone,
    String? email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );
    return await _handleResponse(response);
  }

  // Location endpoints
  static Future<Map<String, dynamic>> listLocations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createOrGetLocation({
    required String token,
    required String name,
    String? address,
    String? city,
    String? state,
    String? country,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'name': name,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
      }),
    );
    return await _handleResponse(response);
  }

  // Player endpoints
  static Future<Map<String, dynamic>> listPlayers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getPlayerStats({
    required String token,
    required String playerId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$playerId/stats'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updatePlayerProfile({
    required String token,
    required String playerId,
    String? fullName,
    String? phone,
    String? email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/players/$playerId/profile'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );
    return await _handleResponse(response);
  }

  // Umpire endpoints
  static Future<Map<String, dynamic>> createMatch({
    required String token,
    required String teamAName,
    required String teamBName,
    String? locationId,
    String? locationName,
    int overs = 20,
    String? date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/umpire/matches'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'teamAName': teamAName,
        'teamBName': teamBName,
        if (locationId != null) 'locationId': locationId,
        if (locationName != null) 'locationName': locationName,
        'overs': overs,
        if (date != null) 'date': date,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> listUmpireMatches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/umpire/matches'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMatchDetails({
    required String token,
    required String matchId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/umpire/matches/$matchId'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMatchScore({
    required String token,
    required String matchId,
    int? teamAScore,
    int? teamAWkts,
    double? teamAOvers,
    int? teamBScore,
    int? teamBWkts,
    double? teamBOvers,
    int? target,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/score'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (teamAScore != null) 'teamAScore': teamAScore,
        if (teamAWkts != null) 'teamAWkts': teamAWkts,
        if (teamAOvers != null) 'teamAOvers': teamAOvers,
        if (teamBScore != null) 'teamBScore': teamBScore,
        if (teamBWkts != null) 'teamBWkts': teamBWkts,
        if (teamBOvers != null) 'teamBOvers': teamBOvers,
        if (target != null) 'target': target,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> addPlayerToMatch({
    required String token,
    required String matchId,
    String? playerId,
    required String teamId,
    String? playerName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/umpire/matches/$matchId/players'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (playerId != null) 'playerId': playerId,
        'teamId': teamId,
        if (playerName != null) 'playerName': playerName,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updatePlayerStats({
    required String token,
    required String matchId,
    required String playerStatId,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    int? wickets,
    double? overs,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/player-stats/$playerStatId'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (runs != null) 'runs': runs,
        if (balls != null) 'balls': balls,
        if (fours != null) 'fours': fours,
        if (sixes != null) 'sixes': sixes,
        if (wickets != null) 'wickets': wickets,
        if (overs != null) 'overs': overs,
      }),
    );
    return await _handleResponse(response);
  }

  // User endpoints
  static Future<Map<String, dynamic>> listMatches({
    required String token,
    String? status,
    int limit = 50,
  }) async {
    final uri = Uri.parse('$baseUrl/user/matches').replace(queryParameters: {
      if (status != null) 'status': status,
      'limit': limit.toString(),
    });
    final response = await http.get(
      uri,
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMatchScoreboard({
    required String token,
    required String matchId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/matches/$matchId/scoreboard'),
      headers: await _getHeaders(token: token),
    );
    return await _handleResponse(response);
  }
}

