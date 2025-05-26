import os, uuid
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename

# 1️⃣ Definimos el blueprint
images_bp = Blueprint('images', __name__)

# 2️⃣ Extensiones permitidas
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# 3️⃣ Ruta POST /images/upload
@images_bp.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    if not allowed_file(file.filename):
        return jsonify({'error': 'Tipo de archivo no soportado'}), 400

    # Nombre único
    ext = secure_filename(file.filename).rsplit('.', 1)[1]
    filename = f"{uuid.uuid4().hex}.{ext}"

    # Carpeta desde app.config (la definiremos en app.py)
    upload_folder = current_app.config['UPLOAD_FOLDER']
    os.makedirs(upload_folder, exist_ok=True)
    save_path = os.path.join(upload_folder, filename)
    file.save(save_path)

    # URL de acceso público: /uploads/<filename>
    url = f"{request.host_url}uploads/{filename}"
    return jsonify({'url': url}), 200
