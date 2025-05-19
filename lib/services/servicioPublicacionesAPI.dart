import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioPublicacionesAPI {
  // final String baseUrl = "http://192.168.174.2:5000"; // Usa 127.0.0.1 si es web, 10.0.2.2 en emulador Android
  // final String baseUrl = "http://192.168.101.152:5000";
  final String baseUrl = "http://192.168.101.152:5000";



  Future<List<Map<String, dynamic>>> cargarPublicaciones(String uid) async {
    final url = Uri.parse('$baseUrl/publicaciones?uid=$uid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Error al cargar publicaciones");
    }
  }

  Future<void> crearPublicacion({
    required String uid,
    required String descripcion,
    required String imagenPath,
    required String fecha,
  }) async {
    // final url = Uri.parse('$baseUrl/publicaciones');
    final url = Uri.parse('$baseUrl/publicaciones/'); // ✅ con la barra final
    final body = {
      "uid": uid,
      "descripcion": descripcion,
      "imagenPath": imagenPath,
      "fecha": fecha
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Error al crear publicación");
    }
  }
}
