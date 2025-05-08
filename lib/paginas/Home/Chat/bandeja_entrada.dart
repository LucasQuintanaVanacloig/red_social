import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_social/paginas/Home/Chat/chat.dart';

class BandejaEntrada extends StatelessWidget {
  const BandejaEntrada({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uidActual = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
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
              title: const Text(
                "Mensajes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Usuarios").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error al cargar usuarios", style: TextStyle(color: Colors.white)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final usuarios = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final datosUsuario = usuarios[index].data() as Map<String, dynamic>;

                      if (datosUsuario["uid"] == uidActual) {
                        return const SizedBox.shrink();
                      }

                      final String nombreReceptor = datosUsuario["nombre"] ?? "Sin nombre";
                      final String idReceptor = datosUsuario["uid"];
                      final String email = datosUsuario["email"] ?? "";
                      final String? fotoPerfil = datosUsuario["imagenPerfil"];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(idReceptor: idReceptor),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: fotoPerfil != null && fotoPerfil.isNotEmpty
                                    ? NetworkImage(fotoPerfil)
                                    : const AssetImage("assets/img/placeholder.jpg") as ImageProvider,
                                backgroundColor: Colors.grey.shade400,
                              ),
                              title: Text(
                                nombreReceptor,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                email,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
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
