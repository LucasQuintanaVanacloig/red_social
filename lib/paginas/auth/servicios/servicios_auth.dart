import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiciosAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Obtener usuario actual
  String? getUsuarioActualUID() {
    return _auth.currentUser?.uid;
  }

  // ✅ Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ✅ Registro con control de errores y nombre
  Future<String?> registrarUsuario(String email, String password, String nombre) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _guardarDatosUsuario(cred.user!, email, nombre);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "Este correo ya está registrado.";
        case "invalid-email":
          return "El formato del correo no es válido.";
        case "weak-password":
          return "La contraseña es demasiado débil.";
        default:
          return "Error: ${e.message}";
      }
    } catch (e) {
      return "Error inesperado: $e";
    }
  }

  // ✅ Login con validación de existencia en Firestore
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore.collection("Usuarios").doc(cred.user!.uid).get();

      if (!doc.exists) {
        await _guardarDatosUsuario(cred.user!, email, "");
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return "Error al iniciar sesión: ${e.message}";
    }
  }

  // ✅ Obtener nombre del usuario actual
  Future<String?> obtenerNombreUsuario() async {
    try {
      String? uid = getUsuarioActualUID();
      if (uid == null) return null;

      DocumentSnapshot doc = await _firestore.collection("Usuarios").doc(uid).get();
      if (doc.exists) {
        return doc.get("nombre") ?? "";
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Actualizar nombre del usuario
  Future<void> actualizarNombreUsuario(String nuevoNombre) async {
    try {
      String? uid = getUsuarioActualUID();
      if (uid != null) {
        await _firestore.collection("Usuarios").doc(uid).update({
          "nombre": nuevoNombre,
        });
      }
    } catch (e) {
      print("Error al actualizar el nombre: $e");
    }
  }

  // 🔒 Método privado para guardar datos de usuario
  Future<void> _guardarDatosUsuario(User user, String email, String nombre) async {
    await _firestore.collection("Usuarios").doc(user.uid).set({
      "uid": user.uid,
      "email": email,
      "nombre": nombre,
      "fecha_creacion": FieldValue.serverTimestamp(),
    });
  }
}
