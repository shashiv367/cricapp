import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Test backend connectivity
Future<void> testBackendConnection() async {
  try {
    developer.log('🔵 [TEST] Testing backend connection...');
    developer.log('🔵 [TEST] Base URL: ${ApiService.baseUrl}');
    
    final uri = Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/health');
    developer.log('🔵 [TEST] Health check URL: $uri');
    
    final response = await http.get(uri).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Connection timeout');
      },
    );
    
    developer.log('✅ [TEST] Backend responded with status: ${response.statusCode}');
    developer.log('✅ [TEST] Response: ${response.body}');
  } catch (e) {
    developer.log('❌ [TEST] Backend connection failed: $e');
    rethrow;
  }
}



