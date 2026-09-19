import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user.dart';

/// Adresse de l'API Spring Boot.
/// - Émulateur Android : 10.0.2.2 pointe vers le localhost de la machine hôte.
/// - Appareil physique / production : remplacer par l'URL publique (ex: Cloud Run).
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------- AUTH ----------------

  static Future<AuthUser> register(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fullName': fullName, 'email': email, 'password': password}),
    );
    return _handleAuthResponse(response);
  }

  static Future<AuthUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleAuthResponse(response);
  }

  static Future<AuthUser> _handleAuthResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final user = AuthUser.fromJson(json);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setString('fullName', user.fullName);
      return user;
    }
    throw Exception(_extractError(response));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('fullName');
  }

  // ---------------- TASKS ----------------

  static Future<List<Task>> fetchTasks({String? status, String? search}) async {
    final headers = await _authHeaders();
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    }
    throw Exception(_extractError(response));
  }

  static Future<Task> createTask(Task task) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractError(response));
  }

  static Future<Task> updateTask(int id, Task task) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractError(response));
  }

  static Future<void> deleteTask(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception(_extractError(response));
    }
  }

  static String _extractError(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? 'Erreur inconnue';
    } catch (_) {
      return 'Erreur ${response.statusCode}';
    }
  }
}
