// lib/paginas/Home/Chat/bandeja_entrada.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:red_social/paginas/auth/servicios/servicio_seguidores.dart';
import 'package:red_social/paginas/Home/Chat/chat.dart';

class BandejaEntrada extends StatefulWidget {
  const BandejaEntrada({Key? key}) : super(key: key);

  @override
  State<BandejaEntrada> createState() => _BandejaEntradaState();
}

class _BandejaEntradaState extends State<BandejaEntrada> {
  final String? uidActual = FirebaseAuth.instance.currentUser?.uid;
  final srvSeg = ServicioSeguidores();
  final _fire = FirebaseFirestore.instance;

  late Future<List<_ChatEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadConversaciones();
  }

  Future<List<_ChatEntry>> _loadConversaciones() async {
    if (uidActual == null) return [];
    // 1) obtenemos a quién seguimos
    final seguidos = await srvSeg.obtenerSeguidos(uidActual!);

    // 2) para cada seguido, buscamos el último mensaje
    List<_ChatEntry> lista = [];
    for (final other in seguidos) {
      // idSalaChat (uids ordenados alfabéticamente unidos por "_")
      final ids = [uidActual!, other]..sort();
      final salaId = ids.join('_');

      // buscamos el último mensaje
      final snap = await _fire
          .collection('SalasChat')
          .doc(salaId)
          .collection('Mensajes')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      Timestamp ts = snap.docs.isNotEmpty
        ? snap.docs.first.get('timestamp') as Timestamp
        : Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(0));

      // cargamos datos de perfil del otro usuario
      final userDoc = await _fire.collection('Usuarios').doc(other).get();
      final data = userDoc.data() ?? {};
      lista.add(_ChatEntry(
        uid: other,
        nombre: data['nombre'] as String? ?? 'Sin nombre',
        email:  data['email']  as String? ?? '',
        foto:   data['imagenPerfil'] as String?,
        lastTs: ts,
      ));
    }

    // 3) ordenamos por lastTs descendente
    lista.sort((a, b) => b.lastTs.compareTo(a.lastTs));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53),
              Color(0xFFFD754D),
              Color(0xFFFE8714),
              Color(0xFFFE6900),
              Color(0xFF1A1A40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              toolbarHeight: 50,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text("Mensajes",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Expanded(
              child: FutureBuilder<List<_ChatEntry>>(
                future: _entriesFuture,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Text("Error: ${snap.error}",
                          style: const TextStyle(color: Colors.white)),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.orangeAccent),
                    );
                  }
                  final lista = snap.data!;
                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tienes conversaciones con gente a la que sigues.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: lista.length,
                    itemBuilder: (ctx, i) {
                      final e = lista[i];
                      final hora = DateFormat.Hm().format(e.lastTs.toDate());
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => Chat(idReceptor: e.uid)),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (e.foto != null &&
                                        e.foto!.isNotEmpty)
                                    ? NetworkImage(e.foto!)
                                    : const AssetImage(
                                            "assets/img/placeholder.jpg")
                                        as ImageProvider,
                                backgroundColor: Colors.grey.shade400,
                              ),
                              title: Text(e.nombre,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(e.email,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: Text(hora,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo interno para facilitar el manejo
class _ChatEntry {
  final String uid;
  final String nombre;
  final String email;
  final String? foto;
  final Timestamp lastTs;

  _ChatEntry({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.foto,
    required this.lastTs,
  });
}
