from sanic_envconfig import EnvConfig


class Settings(EnvConfig):
    DEBUG: bool = True
    HOST: str = '127.0.0.1'
    PORT: int = 8000
    DB_URL: str = 'sqlite:///local_db.db'
    FRONTEND_DIR: str = '../web/build/web'