import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.petsafe.com'; // cambia esto cuando tengas la URL real

  // Headers que se envían en cada petición
  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET
  static Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
    );
    return _procesarRespuesta(response);
  }

  // POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  // PUT
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  // DELETE
  static Future<dynamic> delete(String endpoint, {String? token}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
    );
    return _procesarRespuesta(response);
  }

  // Procesa la respuesta y lanza error si algo va mal
  static dynamic _procesarRespuesta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado. Vuelve a iniciar sesión.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}