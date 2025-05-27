// lib/paginas/Home/Chat/chat.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_social/paginas/auth/servicios/servicio_chat.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  final String idReceptor;
  const Chat({Key? key, required this.idReceptor}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late final String _idActual;
  late final Future<String> _nombreReceptorFut;

  @override
  void initState() {
    super.initState();
    _idActual = ServiciosAuth().getUsuarioActualUID()!;
    _nombreReceptorFut = _loadNombreReceptor();

    // scroll down when keyboard appears or on open
    _focusNode.addListener(() {
      Future.delayed(const Duration(milliseconds: 500), _scrollDown);
    });
    Future.delayed(const Duration(milliseconds: 500), _scrollDown);
  }

  Future<String> _loadNombreReceptor() async {
    final doc = await FirebaseFirestore.instance
      .collection('Usuarios')
      .doc(widget.idReceptor)
      .get();
    if (doc.exists && doc.data()!.containsKey('nombre')) {
      return doc.get('nombre') as String;
    }
    return 'Chat';
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _enviarMensaje() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ServicioChat().enviarMensaje(widget.idReceptor, text);
    _controller.clear();
    FocusScope.of(context).requestFocus(_focusNode);
    Future.delayed(const Duration(milliseconds: 50), _scrollDown);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<String>(
          future: _nombreReceptorFut,
          builder: (ctx, snap) {
            return Text(
              snap.data ?? 'Chat',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
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
              // Mensajes
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: ServicioChat()
                      .getMensajes(_idActual, widget.idReceptor),
                  builder: (ctx, snap) {
                    if (snap.hasError) {
                      return const Center(
                          child: Text("Error cargando mensajes",
                              style: TextStyle(color: Colors.white)));
                    }
                    if (!snap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.orangeAccent));
                    }
                    final docs = snap.data!.docs;
                    return ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      children: docs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        final isMine = data['idAutor'] == _idActual;
                        final msg = data['mensaje'] as String? ?? '';
                        final ts = (data['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                        final hora = DateFormat.Hm().format(ts);
                        return _BubbleMsg(
                          mensaje: msg,
                          esMio: isMine,
                          hora: hora,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Input
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: (_) => _enviarMensaje(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Escribe tu mensaje...",
                          hintStyle:
                              const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _enviarMensaje,
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

class _BubbleMsg extends StatelessWidget {
  final String mensaje;
  final bool esMio;
  final String hora;
  const _BubbleMsg({
    Key? key,
    required this.mensaje,
    required this.esMio,
    required this.hora,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment:
            esMio ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esMio
                    ? const Color.fromARGB(255, 86, 23, 7)
                    : const Color.fromARGB(255, 255, 98, 41),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hora,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
