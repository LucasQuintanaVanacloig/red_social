from pymongo import MongoClient
import certifi
import ssl

print("SSL:", ssl.OPENSSL_VERSION)
uri = "mongodb+srv://jheremyvalda:Soporte%40@cluster0.kxrdejw.mongodb.net/?retryWrites=true&tls=true"
client = MongoClient(uri)
# client = MongoClient(uri, tls=True, tlsCAFile=certifi.where())

try:
    client.admin.command('ping')
    print("✅ Conexión exitosa con MongoDB Atlas")
except Exception as e:
    print(f"❌ Error al conectar: {e}")
