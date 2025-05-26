from flask import Flask
from flask_cors import CORS
from controllers.publicaciones_controller import publicaciones_bp
from controllers.images_controller import images_bp
import os

app = Flask(
    __name__,
    static_folder='uploads',       # carpeta donde guardas imágenes
    static_url_path='/uploads'     # sirven como http://<host>/uploads/<file>
)

# Carpeta de subida absoluta
app.config['UPLOAD_FOLDER'] = os.path.join(os.getcwd(), 'uploads')

# Habilitar CORS antes de las rutas
CORS(app)

# Registrar blueprints
app.register_blueprint(images_bp, url_prefix='/images')
app.register_blueprint(publicaciones_bp, url_prefix='/publicaciones')

if __name__ == '__main__':
    # debug=True solo en desarrollo
    app.run(debug=True, host="0.0.0.0")
