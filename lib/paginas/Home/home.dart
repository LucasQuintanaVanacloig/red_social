import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_social/paginas/Home/Chat/bandeja_entrada.dart';
import 'package:red_social/paginas/auth/servicios/servicio_seguidores.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';
import 'package:red_social/componentes/ComentariosScreen.dart';

// —————————————————————————————————————————————
// Home que carga la lista de posts y usa PostCard
// —————————————————————————————————————————————

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();  // <- público
}

class HomeState extends State<Home> {       // <- público
  final _auth   = FirebaseAuth.instance;
  final _srvSeg = ServicioSeguidores();
  final _srvPub = ServicioPublicacionesAPI();

  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    refreshPosts();
  }

  /// Método público para refrescar la lista
  void refreshPosts() {
    setState(() {
      _postsFuture = _loadPosts();
    });
  }

  Future<List<Map<String, dynamic>>> _loadPosts() async {
    final uidAct = _auth.currentUser!.uid;
    final segs  = await _srvSeg.obtenerSeguidos(uidAct);
    final filtro = {...segs, uidAct}.toList();
    final listas = await Future.wait(
      filtro.map((u) => _srvPub.cargarPublicaciones(u)
        .catchError((_) => <Map<String, dynamic>>[])),
    );
    final all = listas.expand((l) => l).toList();
    all.sort((a, b) {
      final da = DateTime.tryParse(a['fecha_creacion'] ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['fecha_creacion'] ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53), Color(0xFFFD754D),
              Color(0xFFFE8714), Color(0xFFFE6900),
              Color(0xFF1A1A40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              toolbarHeight: 40,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text("Para ti",
                style: TextStyle(color: Colors.white,fontSize:20,fontWeight:FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BandejaEntrada())
                  ),
                ),
              ],
            ),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _postsFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white)
                    );
                  }
                  final posts = snap.data ?? [];
                  if (posts.isEmpty) {
                    return const Center(
                      child: Text("No hay publicaciones de tus seguidos todavía.",
                        style: TextStyle(color: Colors.white70))
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom:20),
                    itemCount: posts.length,
                    itemBuilder: (_, i) {
                      return PostCard(
                        posts[i],
                        onLikeOrComment: refreshPosts,
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

// —————————————————————————————————————————————
// PostCard: maneja su propio estado de likes/comentarios
// —————————————————————————————————————————————

class PostCard extends StatefulWidget {
  final Map<String,dynamic> postData;
  final VoidCallback onLikeOrComment;

  const PostCard(this.postData,{ required this.onLikeOrComment, super.key });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likes;
  late int comentarios;
  bool alreadyLiked = false;

  @override
  void initState(){
    super.initState();
    likes = widget.postData['likes'] as int? ?? 0;
    final cf = widget.postData['comentarios'];
    comentarios = cf is int ? cf : (cf as List).length;
  }

  void _doLike() async {
    if (alreadyLiked) return;
    final postId = widget.postData['_id'] as String;
    final uid    = FirebaseAuth.instance.currentUser!.uid;
    final res    = await ServicioPublicacionesAPI()
                    .incrementarLikes(postId, uid);
    setState(() {
      alreadyLiked = !(res['already'] as bool);
      likes        = res['likes'] as int;
    });
    widget.onLikeOrComment();
  }

  void _openComments() async {
    final postId = widget.postData['_id'] as String;
    final newCount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => ComentariosScreen(postId: postId)),
    );
    if (newCount != null) {
      setState(() => comentarios = newCount);
      widget.onLikeOrComment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.postData;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:12,horizontal:20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Cabecera —
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(data["imagenPerfil"] ?? ""),
                  ),
                  const SizedBox(width:10),
                  Text(data["usuario"] ?? "Usuario",
                    style: const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert,color:Colors.white),
                    onPressed: (){},
                  ),
                ],
              ),
            ),

            // — Imagen —
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(data["imagenPost"] ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_,__,___)=>Image.asset("assets/img/placeholder.jpg")),
            ),

            // — Descripción —
            if ((data['descripcion'] as String?)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:10,vertical:8),
                child: Text(data['descripcion'],
                  style: const TextStyle(color:Colors.white70),
                ),
              ),

            // — Botones —
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:10,vertical:6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      alreadyLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white
                    ),
                    onPressed: _doLike,
                  ),
                  Text("$likes",style:const TextStyle(color:Colors.white)),
                  const SizedBox(width:12),
                  IconButton(
                    icon: const Icon(Icons.comment,color:Colors.white),
                    onPressed: _openComments,
                  ),
                  Text("$comentarios",style:const TextStyle(color:Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
