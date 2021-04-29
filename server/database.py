from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database
from databases import Database
import tables

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