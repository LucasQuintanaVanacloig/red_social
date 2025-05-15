import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioSeguidores {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getUsuarioActualUID() => _auth.currentUser?.uid;

  // 🔁 Seguir a un usuario
  Future<void> seguirUsuario(String uidObjetivo) async {
    final uidActual = getUsuarioActualUID();
    if (uidActual == null || uidActual == uidObjetivo) return;

    final siguiendoRef = _firestore
        .collection('Usuarios')
        .doc(uidActual)
        .collection('Siguiendo')
        .doc(uidObjetivo);

    final seguidorRef = _firestore
        .collection('Usuarios')
        .doc(uidObjetivo)
        .collection('Seguidores')
        .doc(uidActual);

    final usuarioActualRef = _firestore.collection('Usuarios').doc(uidActual);
    final usuarioObjetivoRef = _firestore.collection('Usuarios').doc(uidObjetivo);

    await _firestore.runTransaction((txn) async {
      txn.set(siguiendoRef, {"fecha": FieldValue.serverTimestamp()});
      txn.set(seguidorRef, {"fecha": FieldValue.serverTimestamp()});
      txn.update(usuarioActualRef, {
        "followingCount": FieldValue.increment(1),
      });
      txn.update(usuarioObjetivoRef, {
        "followersCount": FieldValue.increment(1),
      });
    });
  }

  // 🔁 Dejar de seguir
  Future<void> dejarDeSeguir(String uidObjetivo) async {
    final uidActual = getUsuarioActualUID();
    if (uidActual == null || uidActual == uidObjetivo) return;

    final siguiendoRef = _firestore
        .collection('Usuarios')
        .doc(uidActual)
        .collection('Siguiendo')
        .doc(uidObjetivo);

    final seguidorRef = _firestore
        .collection('Usuarios')
        .doc(uidObjetivo)
        .collection('Seguidores')
        .doc(uidActual);

    final usuarioActualRef = _firestore.collection('Usuarios').doc(uidActual);
    final usuarioObjetivoRef = _firestore.collection('Usuarios').doc(uidObjetivo);

    await _firestore.runTransaction((txn) async {
      txn.delete(siguiendoRef);
      txn.delete(seguidorRef);
      txn.update(usuarioActualRef, {
        "followingCount": FieldValue.increment(-1),
      });
      txn.update(usuarioObjetivoRef, {
        "followersCount": FieldValue.increment(-1),
      });
    });
  }

  // ❓ Verificar si lo sigo
  Future<bool> estaSiguiendoA(String uidObjetivo) async {
    final uidActual = getUsuarioActualUID();
    if (uidActual == null) return false;

    final doc = await _firestore
        .collection('Usuarios')
        .doc(uidActual)
        .collection('Siguiendo')
        .doc(uidObjetivo)
        .get();

    return doc.exists;
  }

  // 📄 Obtener lista de seguidos
  Future<List<String>> obtenerSeguidos(String uidUsuario) async {
    final snapshot = await _firestore
        .collection('Usuarios')
        .doc(uidUsuario)
        .collection('Siguiendo')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // 📄 Obtener lista de seguidores
  Future<List<String>> obtenerSeguidores(String uidUsuario) async {
    final snapshot = await _firestore
        .collection('Usuarios')
        .doc(uidUsuario)
        .collection('Seguidores')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
