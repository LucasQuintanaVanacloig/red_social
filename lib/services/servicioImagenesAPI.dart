import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServicioImagenesAPI {
  /// URL de tu servidor Flask (ajústala si lo despliegas en otro host)
  // final String baseUrl = "http://localhost:5000";
  final String baseUrl = "http://192.168.1.38:5000";
  // final String baseUrl = "http://192.168.101.152:5000";


  /// Sube un fichero al endpoint POST /images/upload
  /// y devuelve la URL pública que sirve Flask.
  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('$baseUrl/images/upload');
    // Prepara la petición multipart
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    print('→ Enviando multipart a $uri con file: ${file.path}');
    // Envía la petición
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('← Código: ${response.statusCode}');
    print('← Cuerpo: ${response.body}');
    
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body) as Map<String, dynamic>;
    //   return data['url'] as String;
    // } else {
    //   throw Exception('Error al subir imagen (${response.statusCode})');
    // }


     if (response.statusCode == 200) {
    return jsonDecode(response.body)['url'];
  } else {
    throw Exception('Error al subir imagen (${response.statusCode})');
  }
  }
}
