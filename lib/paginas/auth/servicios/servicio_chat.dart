// lib/paginas/auth/servicios/servicio_chat.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_social/models/MSG.dart';

class ServicioChat {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;

  /// 1) Envía un mensaje a la sala ordenada entre [uidActual] y [idReceptor].
  Future<void> enviarMensaje(String idReceptor, String mensaje) async {
    final uidActual      = _auth.currentUser!.uid;
    final emailAutor     = _auth.currentUser!.email!;
    final timestamp      = Timestamp.now();
    final nuevoMensaje   = Msg(
      idAutor:     uidActual,
      emailAutor:  emailAutor,
      idReceptor:  idReceptor,
      mensaje:     mensaje,
      timestamp:   timestamp,
    ).devuelveMensaje();

    // Construye el ID de sala único ordenando ambos UIDs
    final usuarios = [uidActual, idReceptor]..sort();
    final salaId   = usuarios.join('_');

    await _firestore
        .collection('SalasChat')
        .doc(salaId)
        .collection('Mensajes')
        .add(nuevoMensaje);
  }

  /// 2) Escucha los mensajes de la conversación entre [idUsuarioActual] y [idReceptor].
  Stream<QuerySnapshot> getMensajes(String idUsuarioActual, String idReceptor) {
    final usuarios = [idUsuarioActual, idReceptor]..sort();
    final salaId   = usuarios.join('_');

    return _firestore
        .collection('SalasChat')
        .doc(salaId)
        .collection('Mensajes')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// 3) Devuelve un Stream de listas de conversaciones activas,
  ///    cada item: { 'partnerId': String, 'last': Timestamp },
  ///    ordenado por 'last' descendente.
  Stream<List<Map<String, dynamic>>> getConversaciones() {
    final uid = _auth.currentUser!.uid;

    return _firestore
      .collection('SalasChat')
      .snapshots()
      .asyncMap((salasSnap) async {
        final List<Map<String, dynamic>> convs = [];

        for (final salaDoc in salasSnap.docs) {
          // Solo las salas que incluyan al usuario actual
          final partes = salaDoc.id.split('_');
          if (!partes.contains(uid)) continue;

          // Coge el último mensaje
          final lastMsgSnap = await salaDoc.reference
            .collection('Mensajes')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

          if (lastMsgSnap.docs.isEmpty) continue;

          final lastTimestamp = lastMsgSnap.docs.first['timestamp'] as Timestamp;
          // Determina el partnerId
          final partnerId = partes[0] == uid ? partes[1] : partes[0];

          convs.add({
            'partnerId': partnerId,
            'last': lastTimestamp,
          });
        }

        // Ordena de más reciente a más antiguo
        convs.sort((a, b) =>
          (b['last'] as Timestamp).compareTo(a['last'] as Timestamp)
        );
        return convs;
      });
  }
}
