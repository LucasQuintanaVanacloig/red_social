import 'dart:io';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart' as mongodb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:red_social/mongodb/db_conf.dart';
import 'package:path_provider/path_provider.dart';

class ServicioPublicaciones {
  // Instancia de autenticación Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Base de datos Mongo
  mongodb.Db? _db;
  late mongodb.DbCollection _postsCol;

  /// Conectar a MongoDB
  Future<void> connect() async {
    _db = await mongodb.Db.create(BDConf().connectionString);
    await _db!.open();
    _postsCol = _db!.collection('publicaciones');
  }

  /// Desconectar de MongoDB
  Future<void> disconnect() async {
    await _db?.close();
  }

  /// Devuelve el UID del usuario actual
  String? getUsuarioActual() => _auth.currentUser?.uid;

  /// Sube una imagen al sistema de archivos local (o a tu propio storage) y retorna el path
  /// Nota: ajusta esta parte para usar el storage deseado (e.g., AWS S3, servidor propio...)
  Future<String> subirImagen(File imagen) async {
    final uid = getUsuarioActual();
    if (uid == null) throw Exception('Usuario no autenticado');

    // 1) Obtén el directorio permitido de tu app
    final appDir = await getApplicationDocumentsDirectory();
    // final appDir = await getTemporaryDirectory(); // si prefieres temp

    // 2) Crea subcarpeta posts/uid
    final uploadsDir = Directory(path.join(appDir.path, 'posts', uid));
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }

    // 3) Cópialo allí
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imagen.path)}';
    final destPath = path.join(uploadsDir.path, fileName);
    await imagen.copy(destPath);

    return destPath;
  }

  /// Crea un documento de publicación en MongoDB
  Future<void> crearPublicacion({
    required String descripcion,
    required String imagenPath,
  }) async {
    final uid = getUsuarioActual();
    if (uid == null) throw Exception('Usuario no autenticado');

    // Conectar si no conectado
    if (_db == null || !_db!.isConnected) {
      await connect();
    }

    final post = {
      'uid': uid,
      'imagenPath': imagenPath,
      'descripcion': descripcion,
      'likes': 0,
      'comentarios': 0,
      'compartidos': 0,
      'fecha': DateTime.now().toUtc(),
    };
    await _postsCol.insertOne(post);
  }

  /// Obtiene un stream de publicaciones ordenadas por fecha descendente
  Stream<List<Map<String, dynamic>>> obtenerPublicaciones() async* {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    final pipeline = [
      {r'$sort': {'fecha': -1}}
    ];
    final aggStream = _postsCol.aggregateToStream(pipeline);
    await for (final doc in aggStream) {
      yield [doc];
    }
  }

  /// Incrementa likes
  Future<void> darLike(String postId) async {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    await _postsCol.updateOne(
      mongodb.where.id(mongodb.ObjectId.fromHexString(postId)),
      mongodb.modify.inc('likes', 1),
    );
  }

  /// Elimina publicación y opcionalmente su imagen
  Future<void> eliminarPublicacion(String postId) async {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    final doc = await _postsCol.findOne(
      mongodb.where.id(mongodb.ObjectId.fromHexString(postId)),
    );
    if (doc != null) {
      final imagenPath = doc['imagenPath'] as String?;
      if (imagenPath != null) {
        final file = File(imagenPath);
        if (await file.exists()) await file.delete();
      }
    }
    await _postsCol.deleteOne(
      mongodb.where.id(mongodb.ObjectId.fromHexString(postId)),
    );
  }
}
