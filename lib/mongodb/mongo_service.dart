// mongo_service.dart
import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart' as mongodb;
import 'package:red_social/mongodb/db_conf.dart';

class MongoService {
  mongodb.Db? _db;

  // Conectar con MongoDB
  Future<void> connect() async {
    try {
      _db = await mongodb.Db.create(BDConf().connectionString);
      await _db!.open();
      print("Conexión establecida con MongoDB");
    } catch (e, stackTrace) {
      print("Error al conectar con MongoDB: $e");
      print(stackTrace);
      rethrow;
    }
  }

  // Desconectar de MongoDB
  Future<void> disconnect() async {
    await _db?.close();
  }

  // Obtener la imagen de perfil (en bytes) de un usuario, si existe
  Future<Uint8List?> getImatgePerfil(String uid) async {
    if (_db == null || !_db!.isConnected) {
      return null;
    }
    final collection = _db!.collection("imatges_perfils");
    final doc = await collection.findOne({"id_usuari_firebase": uid});
  
    if (doc != null && doc["imatge"] != null) {
      final bsonImg = doc["imatge"] as mongodb.BsonBinary;
      return bsonImg.byteList;
    }
    return null;
  }
}
