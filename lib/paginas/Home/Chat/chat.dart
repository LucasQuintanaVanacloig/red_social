import 'package:flutter/material.dart';
import 'package:red_social/paginas/auth/servicios/servicio_chat.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat extends StatefulWidget {
  final String idReceptor;
  const Chat({super.key, required this.idReceptor});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        hacerScrollAbajo();
      });
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      hacerScrollAbajo();
    });
  }

  void hacerScrollAbajo() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void enviarMensaje() {
    if (_controller.text.trim().isNotEmpty) {
      ServicioChat().enviarMensaje(widget.idReceptor, _controller.text.trim());
      _controller.clear();
      FocusScope.of(context).requestFocus(_focusNode);
      Future.delayed(const Duration(milliseconds: 50), () {
        hacerScrollAbajo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final idActual = ServiciosAuth().getUsuarioActualUID();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: ServicioChat().getMensajes(idActual!, widget.idReceptor),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Text("Error cargando mensajes.");
                    if (!snapshot.hasData) return const Text("Cargando...");

                    return ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        bool esMiMensaje = data['idAutor'] == idActual;

                        return GestureDetector(
                          onLongPress: () async {
                            if (esMiMensaje) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Eliminar mensaje"),
                                  content: const Text("¿Seguro que quieres eliminar este mensaje?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancelar"),
                                      onPressed: () => Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: const Text("Eliminar"),
                                      onPressed: () => Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await doc.reference.delete();
                              }
                            }
                          },
                          child: Align(
                            alignment: esMiMensaje ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                data['mensaje'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: (_) => enviarMensaje(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Escribe tu mensaje...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: enviarMensaje,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
