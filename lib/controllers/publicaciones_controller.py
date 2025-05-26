from flask import Blueprint, request, jsonify, abort
from services.mongo_service import MongoService
from datetime import datetime
from bson import ObjectId

publicaciones_bp = Blueprint('publicaciones', __name__)
mongo = MongoService()

@publicaciones_bp.route('/', methods=['GET'])
def obtener_publicaciones():
    uid = request.args.get('uid')
    if not uid:
        return jsonify({"error": "uid requerido"}), 400
    publicaciones = mongo.get_publicaciones_por_usuario(uid)
    return jsonify(publicaciones)

@publicaciones_bp.route('/', methods=['POST'])
def crear_publicacion():
    data = request.get_json(force=True)
    required = ['uid','usuario','email','descripcion','imagenPost','imagenPerfil']
    if not all(k in data for k in required):
        return jsonify({"error": "Faltan campos", "fields": required}), 400

    nuevo = {
        'uid':           data['uid'],
        'usuario':       data['usuario'],
        'email':         data['email'],
        'descripcion':   data['descripcion'],
        'imagenPost':    data['imagenPost'],
        'imagenPerfil':  data['imagenPerfil'],
        'verificado':    data.get('verificado', False),
        'likes':         data.get('likes', 0),
        'likedBy':       [],              # <-- inicializamos likedBy
        'comentarios':   [],              # array embebido
        'compartidos':   data.get('compartidos', 0),
        'fecha_creacion':datetime.utcnow()
    }
    result = mongo.col.insert_one(nuevo)
    nuevo['_id'] = str(result.inserted_id)
    nuevo['fecha_creacion'] = nuevo['fecha_creacion'].isoformat() + 'Z'
    return jsonify(nuevo), 201

@publicaciones_bp.route('/<post_id>/like', methods=['POST'])
def dar_like(post_id):
    data = request.get_json(force=True)
    uid = data.get('uid')
    if not uid:
        return jsonify({"error": "uid requerido"}), 400

    # Sólo si uid no está en likedBy
    res = mongo.col.update_one(
      { '_id': ObjectId(post_id), 'likedBy': { '$ne': uid } },
      {
        '$inc': { 'likes': 1 },
        '$push': { 'likedBy': uid }
      }
    )
    # Si no matchea, ya había dado like
    pub = mongo.col.find_one({'_id': ObjectId(post_id)})
    if res.matched_count == 0:
        return jsonify({'already': True,  'likes': pub['likes']}), 200

    # Éxito
    return jsonify({'already': False, 'likes': pub['likes']}), 200

@publicaciones_bp.route('/<post_id>/comentarios', methods=['POST'])
def agregar_comentario(post_id):
    data = request.get_json(force=True)
    for f in ('uid','usuario','comentario'):
        if f not in data:
            return jsonify({"error": f"Falta campo {f}"}), 400

    comentario = {
        'uid':        data['uid'],
        'usuario':    data['usuario'],
        'comentario': data['comentario'],
        'fecha':      datetime.utcnow()
    }
    res = mongo.col.update_one(
        {'_id': ObjectId(post_id)},
        {'$push': {'comentarios': comentario}}
    )
    if res.matched_count == 0:
        abort(404)

    # Devolvemos sólo array de comentarios serializado
    pub = mongo.col.find_one({'_id': ObjectId(post_id)})
    out = [
      { **c, 'fecha': c['fecha'].isoformat() + 'Z' }
      for c in pub.get('comentarios', [])
    ]
    return jsonify(out), 200

@publicaciones_bp.route('/<post_id>', methods=['GET'])
def obtener_publicacion(post_id):
    pub = mongo.col.find_one({'_id': ObjectId(post_id)})
    if pub is None:
        abort(404)
    # serializar
    pub['_id'] = str(pub['_id'])
    pub['fecha_creacion'] = pub['fecha_creacion'].isoformat() + 'Z'
    pub['comentarios'] = [
      { **c, 'fecha': c['fecha'].isoformat() + 'Z' }
      for c in pub.get('comentarios', [])
    ]
    return jsonify(pub), 200
