from pymongo import MongoClient
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

class MongoService:
    def __init__(self):
        uri = os.getenv("MONGO_URI")
        if not uri:
            raise Exception("MONGO_URI no está definida")

        self.client = MongoClient(
            uri,
            tls=True,
            tlsAllowInvalidCertificates=True
        )

        self.db = self.client['test']
        self.col = self.db['publicaciones']

    def insertar_publicacion(self, data):
        self.col.insert_one({
            'uid': data['uid'],
            'usuario': data['usuario'],
            'email': data['email'],
            'descripcion': data['descripcion'],
            'imagenPost': data['imagenPost'],
            'imagenPerfil': data['imagenPerfil'],
            'verificado': data.get('verificado', False),
            'likes': data.get('likes', 0),
            'comentarios': data.get('comentarios', []),
            'compartidos': data.get('compartidos', 0),
            'fecha_creacion': data.get('fecha_creacion', datetime.utcnow()),
        })

    def get_publicaciones_por_usuario(self, uid):
        docs = self.col.find({'uid': uid}).sort('fecha_creacion', -1)
        return [
            {
                '_id': str(doc['_id']),
                'uid': doc['uid'],
                'usuario': doc.get('usuario'),
                'email': doc.get('email'),
                'descripcion': doc.get('descripcion'),
                'imagenPost': doc.get('imagenPost'),
                'imagenPerfil': doc.get('imagenPerfil'),
                'verificado': doc.get('verificado', False),
                'likes': doc.get('likes', 0),
                'comentarios': doc.get('comentarios', []),
                'compartidos': doc.get('compartidos', 0),
                'fecha_creacion': doc.get('fecha_creacion'),
            }
            for doc in docs
        ]
