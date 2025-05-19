from flask import Blueprint, request, jsonify # type: ignore
from services.mongo_service import MongoService

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
    data = request.json
    required_fields = ['uid', 'descripcion', 'imagenPath']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Faltan campos"}), 400

    mongo.insertar_publicacion(data)
    return jsonify({"message": "Publicación creada"}), 201
