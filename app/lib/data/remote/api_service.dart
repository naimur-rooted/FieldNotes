import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';

class ApiService {
  String? _token;

  Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('token');
  }

  Future<void> saveAuth(String token, int userId, String name, String email) async {
    _token = token;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', token);
    await p.setInt('userId', userId);
    await p.setString('userName', name);
    await p.setString('userEmail', email);
  }

  Future<void> clearAuth() async {
    _token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    await p.remove('userId');
    await p.remove('userName');
    await p.remove('userEmail');
  }

  bool get isLoggedIn => _token != null;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Register failed'));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Login failed'));
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Failed to send verification code'));
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Verification failed'));
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Failed to reset password'));
  }

  Future<List<dynamic>> getCustomers() async {
    final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/customers'), headers: _headers);
    if (r.statusCode == 200) return jsonDecode(r.body) as List;
    throw Exception(_msg(r, 'Load customers failed'));
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> b) => _post('/api/customers', b);
  Future<Map<String, dynamic>> updateCustomer(int id, Map<String, dynamic> b) => _put('/api/customers/$id', b);
  Future<void> deleteCustomer(int id) => _delete('/api/customers/$id');

  Future<List<dynamic>> getSites({int? customerId}) async {
    final q = customerId == null ? '' : '?customerId=$customerId';
    final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/sites$q'), headers: _headers);
    if (r.statusCode == 200) return jsonDecode(r.body) as List;
    throw Exception(_msg(r, 'Load sites failed'));
  }

  Future<Map<String, dynamic>> createSite(Map<String, dynamic> b) => _post('/api/sites', b);
  Future<Map<String, dynamic>> updateSite(int id, Map<String, dynamic> b) => _put('/api/sites/$id', b);
  Future<void> deleteSite(int id) => _delete('/api/sites/$id');

  Future<List<dynamic>> getNotes({int? siteId, String? status, String? q}) async {
    final params = <String>[];
    if (siteId != null) params.add('siteId=$siteId');
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (q != null && q.isNotEmpty) params.add('q=${Uri.encodeComponent(q)}');
    final qs = params.isEmpty ? '' : '?${params.join('&')}';
    final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/notes$qs'), headers: _headers);
    if (r.statusCode == 200) return jsonDecode(r.body) as List;
    throw Exception(_msg(r, 'Load notes failed'));
  }

  Future<Map<String, dynamic>> createNote(Map<String, dynamic> b) => _post('/api/notes', b);
  Future<Map<String, dynamic>> updateNote(int id, Map<String, dynamic> b) => _put('/api/notes/$id', b);
  Future<void> deleteNote(int id) => _delete('/api/notes/$id');

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> b) async {
    final r = await http.post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers, body: jsonEncode(b));
    if (r.statusCode == 200 || r.statusCode == 201) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Request failed'));
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> b) async {
    final r = await http.put(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers, body: jsonEncode(b));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception(_msg(r, 'Request failed'));
  }

  Future<void> _delete(String path) async {
    final r = await http.delete(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers);
    if (r.statusCode == 200 || r.statusCode == 204) return;
    throw Exception(_msg(r, 'Request failed'));
  }

  String _msg(http.Response r, String fallback) {
    try {
      final j = jsonDecode(r.body);
      if (j is Map && j['message'] != null) return j['message'].toString();
    } catch (_) {}
    return '$fallback (${r.statusCode})';
  }
}
