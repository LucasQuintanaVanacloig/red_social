import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioPublicacionesAPI {
  final String baseUrl = "http://192.168.1.38:5000";

  Future<List<Map<String, dynamic>>> cargarPublicaciones(String uid) async {
    final url = Uri.parse('$baseUrl/publicaciones?uid=$uid');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception("Error al cargar publicaciones: ${resp.statusCode}");
    }
    final data = jsonDecode(resp.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> obtenerPublicacion(String postId) async {
    final url = Uri.parse('$baseUrl/publicaciones/$postId');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception("Publicación no encontrada (${resp.statusCode})");
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<void> crearPublicacion({
    required String uid,
    required String usuario,
    required String email,
    required String descripcion,
    required String imagenPost,
    required String imagenPerfil,
    bool verificado = false,
  }) async {
    final url = Uri.parse('$baseUrl/publicaciones/');
    final body = {
      "uid": uid,
      "usuario": usuario,
      "email": email,
      "descripcion": descripcion,
      "imagenPost": imagenPost,
      "imagenPerfil": imagenPerfil,
      "verificado": verificado,
      "likes": 0,
      "comentarios": <Map<String, dynamic>>[],
      "compartidos": 0,
      "fecha_creacion": DateTime.now().toUtc().toIso8601String(),
    };
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 201) {
      throw Exception("Error al crear publicación: ${resp.statusCode}");
    }
  }

  /// Incrementa likes (pasa el uid para que el backend haga el check)
  Future<Map<String, dynamic>> incrementarLikes(String postId, String uid) async {
    final url = Uri.parse('$baseUrl/publicaciones/$postId/like');
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'uid': uid}),
    );
    if (resp.statusCode != 200) {
      throw Exception("No se pudo dar like: ${resp.statusCode}");
    }
    // devuelve {already: bool, likes: int}
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> agregarComentario({
    required String postId,
    required String uid,
    required String usuario,
    required String comentario,
  }) async {
    final url = Uri.parse('$baseUrl/publicaciones/$postId/comentarios');
    final body = {
      'uid': uid,
      'usuario': usuario,
      'comentario': comentario,
    };
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      throw Exception("Error al agregar comentario: ${resp.statusCode}");
    }
    final data = jsonDecode(resp.body) as List;
    return data.cast<Map<String, dynamic>>();
  }
}
