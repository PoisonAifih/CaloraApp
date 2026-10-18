import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../session.dart';
import 'models.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3005');

class CaloraException implements Exception {
  CaloraException(this.status, this.message);

  final int status;
  final String message;

  @override
  String toString() => message;
}

class CaloraClient {
  CaloraClient({SessionStore? session, http.Client? httpClient, String? baseUrl})
      : session = session ?? MemorySessionStore(),
        httpClient = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? apiBaseUrl;

  final SessionStore session;
  final http.Client httpClient;
  String baseUrl;

  Future<CaloraUser> login(String username, String password) async {
    final json = await _json('POST', '/api/session', body: {'username': username, 'password': password});
    final token = json['sessionToken'];
    if (token is! String || token.isEmpty) {
      throw CaloraException(500, 'Sign in did not return a session');
    }
    await session.write(token);
    return CaloraUser.fromJson(_map(json['user']));
  }

  Future<CaloraUser?> current() async {
    if (await session.read() == null) return null;
    final json = await _json('GET', '/api/session');
    return CaloraUser.fromJson(_map(json['user']));
  }

  Future<void> logout() async {
    try {
      await _send('DELETE', '/api/session');
    } catch (_) {}
    await session.clear();
  }

  Future<Dashboard> dashboard() async {
    final json = await _json('GET', '/api/dashboard');
    return Dashboard.fromJson(json);
  }

  Future<FoodEntry> createFood(Map<String, dynamic> body) async {
    final json = await _json('POST', '/api/food', body: body);
    return FoodEntry.fromJson(json);
  }

  Future<void> deleteFood(String id) async {
    await _json('DELETE', '/api/food/${Uri.encodeComponent(id)}');
  }

  Future<ActivityEntry> createActivity(Map<String, dynamic> body) async {
    final json = await _json('POST', '/api/activity', body: body);
    return ActivityEntry.fromJson(json);
  }

  Future<void> deleteActivity(String id) async {
    await _json('DELETE', '/api/activity/${Uri.encodeComponent(id)}');
  }

  Future<WeightEntry> createWeight(Map<String, dynamic> body) async {
    final json = await _json('POST', '/api/weight', body: body);
    return WeightEntry.fromJson(json);
  }

  Future<Profile> saveProfile(Map<String, dynamic> body) async {
    final json = await _json('PUT', '/api/profile', body: body);
    return Profile.fromJson(json);
  }

  Future<Analysis> analyzePhoto(String path) async {
    final file = File(path);
    final length = await file.length();
    if (length > 5 * 1024 * 1024) {
      throw CaloraException(400, 'Image must be 5 MB or smaller');
    }
    final subtype = _imageSubtype(path);
    if (subtype == null) throw CaloraException(400, 'Use a JPEG, PNG, or WebP photo');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/analyze'));
    final token = await session.read();
    if (token != null) request.headers['Cookie'] = 'calora_session=$token';
    request.files.add(await http.MultipartFile.fromPath('image', path, contentType: MediaType('image', subtype)));
    final streamed = await httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    final json = await _decode(response);
    return Analysis.fromJson(json);
  }

  Future<Map<String, dynamic>> _json(String method, String path, {Map<String, dynamic>? body}) async {
    final response = await _send(method, path, body: body);
    return _decode(response);
  }

  Future<http.Response> _send(String method, String path, {Map<String, dynamic>? body}) async {
    final token = await session.read();
    final headers = <String, String>{
      if (token != null) 'Cookie': 'calora_session=$token',
      if (body != null) 'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$baseUrl$path');
    switch (method) {
      case 'POST':
        return httpClient.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
      case 'PUT':
        return httpClient.put(uri, headers: headers, body: body == null ? null : jsonEncode(body));
      case 'DELETE':
        return httpClient.delete(uri, headers: headers);
      default:
        return httpClient.get(uri, headers: headers);
    }
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    if (response.statusCode == 401) {
      await session.clear();
      throw CaloraException(401, _message(response));
    }
    if (response.statusCode >= 400) {
      throw CaloraException(response.statusCode, _message(response));
    }
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw CaloraException(response.statusCode, 'Unexpected response');
  }

  String _message(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is String) return decoded['error'] as String;
    } catch (_) {}
    return 'Request failed';
  }
}

String? _imageSubtype(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'png';
  if (lower.endsWith('.webp')) return 'webp';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpeg';
  return null;
}

Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic> ? value : <String, dynamic>{};
