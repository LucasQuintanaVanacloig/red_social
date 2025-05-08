import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_social/models/MSG.dart';

class ServicioChat {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsuarios() {
    return _firestore.collection("Usuarios").snapshots().map((event) {
      return event.docs.map((document) {
        return document.data();
      }).toList();
    });
  }

  Future<void> enviarMensaje(String idReceptor, String mensaje) async {
    //sala chat entre 2 ususarios, se hace partir de ambos uids
    String idUsuarioActual = _auth.currentUser!.uid;
    String emailUsuaioActual = _auth.currentUser!.email!;
    Timestamp timestamp = Timestamp.now();

    Msg nuevoMensaje = Msg(
        idAutor: idUsuarioActual,
        emailAutor: emailUsuaioActual,
        idReceptor: idReceptor,
        mensaje: mensaje,
        timestamp: timestamp);

    List<String> idUsuarios = [idUsuarioActual, idReceptor];
    idUsuarios.sort(); //ordena lista a-z

    String idSalaChat = idUsuarios.join("_");

    await _firestore
        .collection("SalasChat")
        .doc(idSalaChat)
        .collection("Mensajes")
        .add(nuevoMensaje.devuelveMensaje());
  }

  Stream<QuerySnapshot> getMensajes(String idUsuarioActual, String idReceptor) {
    //creamos idSalaChat
    List<String> idUsuarios = [idUsuarioActual, idReceptor];
    idUsuarios.sort();
    String idSalaChat = idUsuarios.join("_");

    //devulve los mensajes de esta sala
    return _firestore
        .collection("SalasChat")
        .doc(idSalaChat)
        .collection("Mensajes")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
