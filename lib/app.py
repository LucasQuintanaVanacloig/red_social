from flask import Flask # type: ignore
from flask_cors import CORS # type: ignore
from controllers.publicaciones_controller import publicaciones_bp

app = Flask(__name__)
CORS(app)

# Registrar rutas
app.register_blueprint(publicaciones_bp, url_prefix='/publicaciones')

if __name__ == '__main__':
    # app.run(debug=True)
    app.run(debug=True, host="0.0.0.0")
