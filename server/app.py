from sanic import Sanic, response
import os
from environs import Env
from databases import Database
from settings import Settings
import tables
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database

def setup_database(app):
    app.db = Database(app.config.DB_URL)

    engine = create_engine(app.config.DB_URL)
    if not database_exists(engine.url):
        create_database(engine.url)

    print(database_exists(engine.url))

    tables.metadata.create_all(engine)

    @app.listener('after_server_start')
    async def connect_to_db(*args, **kwargs):
        await app.db.connect()

    @app.listener('after_server_stop')
    async def disconnect_from_db(*args, **kwargs):
        await app.db.disconnect()

def make_app(name) -> Sanic:
    env = Env()
    env.read_env()

    app = Sanic(name)
    
    app.update_config(Settings())
    setup_database(app)
    app.static('/', app.config.FRONTEND_DIR)
    return app

app = make_app(__name__)

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
async def create_user(request):
    query = tables.users.insert(request.json)
    res = await app.db.execute(query)
    print(res)
    return response.text(str(res))


@app.route('/api/image', methods=['POST'])
def add_image(request):
    pass

@app.route('/api/image', methods=['DELETE'])
def remove_image(request):
    pass

@app.route('/api/image', methods=['GET'])
def get_image(request):
    pass

@app.route('/api/image_info', methods=['GET'])
def get_image_info(request):
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