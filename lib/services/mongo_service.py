from pymongo import MongoClient
import os
from dotenv import load_dotenv

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

    def get_publicaciones_por_usuario(self, uid):
        docs = self.col.find({"uid": uid}).sort("fecha", -1)
        return [
            {
                "_id": str(doc["_id"]),
                "uid": doc["uid"],
                "descripcion": doc.get("descripcion", ""),
                "imagenPath": doc.get("imagenPath", ""),
                "fecha": doc.get("fecha"),
                "likes": doc.get("likes", 0),
                "comentarios": doc.get("comentarios", 0),
                "compartidos": doc.get("compartidos", 0),
            }
            for doc in docs
        ]

    def insertar_publicacion(self, data):
        self.col.insert_one({
            "uid": data["uid"],
            "descripcion": data["descripcion"],
            "imagenPath": data["imagenPath"],
            "fecha": data.get("fecha"),
            "likes": 0,
            "comentarios": 0,
            "compartidos": 0
        })
