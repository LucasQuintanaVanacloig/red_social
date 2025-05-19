from pymongo import MongoClient
import certifi
import ssl

print("SSL:", ssl.OPENSSL_VERSION)
uri = "mongodb+srv://jheremyvalda:Soporte@cluster0.kxrdejw.mongodb.net/test?retryWrites=true&w=majority"
client = MongoClient(uri, tls=True, tlsCAFile=certifi.where())

try:
    client.admin.command('ping')
    print("✅ Conexión exitosa con MongoDB Atlas")
except Exception as e:
    print(f"❌ Error al conectar: {e}")
