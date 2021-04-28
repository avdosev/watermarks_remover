from sanic import Sanic, response
import os
from environs import Env
from databases import Database
from settings import Settings
import tables
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database
import uuid
import aiofiles
import asyncio

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
    return response.json({'user_id': str(res)})

@app.route('/api/user', methods=['GET'])
async def access_user(request):
    print(request.args)
    query = tables.users.select(tables.users.c.id).where(tables.users.c.email == request.args['email'][0] and tables.users.c.password == request.args['password'][0])
    print(query)
    res = await app.db.fetch_all(query)
    print(res)
    if len(res) > 0:
        res = res[0]
        return response.json({'user_id': res.id, 'status': 'success'})
    else:
        return response.json({'user_id': -1, 'status': 'failed'})


@app.route('/api/image/<user_id:int>', methods=['POST'])
async def add_image(request, user_id):
    user_id = 1
    if 'image' not in request.files or 'mask' not in request.files:
        return response.json({'status': 'failed'}, status=400)
    image_file = request.files['image'][0]
    mask_file = request.files['mask'][0]
    image_name = os.path.join('local_files', str(uuid.uuid4()))
    mask_name = os.path.join('local_files', str(uuid.uuid4()))

    async with aiofiles.open(image_name, 'wb') as f:
        await f.write(image_file.body)

    async with aiofiles.open(mask_name, 'wb') as f2:
        await f2.write(mask_file.body)

    query = tables.images.insert({
        'user_id': user_id,
        'image_name': image_file.name,
        'image_path': image_name,
        'mask_path': mask_name,
        'result_path': None,
        'result_state': None
    })
    file_id = await app.db.execute(query)

    return response.json({'status': 'success', 'name': image_file.name, 'id': file_id})


@app.route('/api/image/<user_id>', methods=['DELETE'])
def remove_image(request):
    pass

@app.route('/api/image/<user_id>', methods=['GET'])
def get_image(request, id):
    pass

@app.route('/api/image_info/<user_id>', methods=['GET'])
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