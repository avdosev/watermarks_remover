from sanic import Sanic, response
import os
from environs import Env
from databases import Database
from settings import Settings

def setup_database():
    global app
    app.db = Database(app.config.DB_URL)

    @app.listener('after_server_start')
    async def connect_to_db(*args, **kwargs):
        await app.db.connect()

    @app.listener('after_server_stop')
    async def disconnect_from_db(*args, **kwargs):
        await app.db.disconnect()

def make_app() -> Sanic:
    env = Env()
    env.read_env()

    app = Sanic(__name__)
    
    app.update_config(Settings())
    app.static('/', app.config.FRONTEND_DIR)
    return app

app = make_app()

@app.route('/', methods=["GET"])
def main(request):
    return response.file(os.path.join(app.config.FRONTEND_DIR, 'index.html'))

# @app.route('/', methods=['POST'])
# def upload_image(request):
#     # check if the post request has the file part
#     if 'file' not in request.files:
#         return response.json({'status': 'failed'}, status=400)
#     file = request.files['file']
#     file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
#     file_id = None # todo
#     return response.json({'status': 'success', 'file_id': file_id})

@app.route('/api/user', methods=['POST'])
def create_user(request):
    pass


if __name__ == "__main__":
    print(app.config)
    print(app.config.HOST)
    app.run(
        host=app.config.HOST, 
        port=app.config.PORT, 
        debug=app.config.DEBUG,
        auto_reload=app.config.DEBUG,
    )