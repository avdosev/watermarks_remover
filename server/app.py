from sanic import Sanic, response
from sanic_openapi import swagger_blueprint

import os
from environs import Env
from settings import Settings
import tables

import uuid
import aiofiles
import asyncio

from database import setup_database

def make_app(name) -> Sanic:
    env = Env()
    env.read_env()

    app = Sanic(name)    
    app.update_config(Settings())

    if app.config.DEBUG:
        app.blueprint(swagger_blueprint)
    
    setup_database(app)
    app.static('/', app.config.FRONTEND_DIR)
    return app

app = make_app(__name__)

@app.route('/', methods=["GET"])
def main(request):
    return response.file(os.path.join(app.config.FRONTEND_DIR, 'index.html'))

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

@app.route('/api/image/<user_id>/<file_id>', methods=['DELETE'])
async def remove_image(request, user_id, file_id):
    query = tables.images.delete().where(tables.images.c.file_id == file_id and tables.images.c.user_id == user_id)
    await app.db.execute(query)
    return response.empty(status=202)

@app.route('/api/image/<user_id>/<file_id>', methods=['GET'])
async def get_image(request, user_id, file_id):
    query = tables.images.select().where(tables.images.c.user_id == user_id and tables.images.c.id == file_id)
    res = await app.db.fetch_all(query)
    if len(res) == 0:
        return response.empty(status=204)
    
    res = res[0]
    st = res.result_state
    if st is not None and st == 'READY':
        return response.file(res.result_path, filename=res.image_name)
    
    return response.empty(status=206)

@app.route('/api/images/info/<user_id>', methods=['GET'])
async def get_image_info(request, user_id):
    query = tables.images.select().where(tables.images.c.user_id == user_id)
    res = await app.db.fetch_all(query)
    res = [{
        'id': item.id,
        'image_name': item.image_name,
        'result_state': item.result_state,
    } for item in res]
    return response.json(res)

@app.route('/api/worker/image', methods=['GET'])
async def get_work(request):
    query = tables.images.select().where(tables.images.c.result_state == None)
    res = await app.db.fetch_all(query)
    if len(res) == 0:
        return response.json({'file_id': None}, status=204)
    
    res = res[0]

    file_id = res.id

    query = tables.images.update().where(tables.images.c.id == file_id).values(result_state='IN_PROGRESS')
    await app.db.execute(query)

    return response.json({'file_id': file_id})

@app.route('/api/worker/image/data', methods=['GET'])
async def get_image_or_mask(request):
    file_id = request.args['file_id'][0]
    type = request.args['type'][0]
    query = tables.images.select().where(tables.images.c.id == file_id)
    res = await app.db.fetch_all(query)
    res = res[0]

    if type == 'mask':
        return await response.file(res.mask_path)
    else:
        return await response.file(res.image_path)

@app.route('/api/worker/image/<file_id>', methods=['POST'])
async def return_work(request, file_id):
    image_file = request.files['image'][0]
    image_name = os.path.join('local_files', str(uuid.uuid4()))

    async with aiofiles.open(image_name, 'wb') as f:
        await f.write(image_file.body)
    
    query = tables.images.update().where(tables.images.c.id == file_id).values(result_state='READY', result_path=image_name)
    await app.db.execute(query)

    return response.json({'file_id': file_id})

if __name__ == "__main__":
    print(app.config)
    print(app.config.HOST)
    app.run(
        host=app.config.HOST, 
        port=app.config.PORT, 
        debug=app.config.DEBUG,
        auto_reload=app.config.DEBUG,
    )