import sqlalchemy

metadata = sqlalchemy.MetaData()

users = sqlalchemy.Table(
    'users',
    metadata,
    sqlalchemy.Column('id', sqlalchemy.Integer, primary_key=True, autoincrement=True),
    sqlalchemy.Column('email', sqlalchemy.String(length=100)),
    sqlalchemy.Column('password', sqlalchemy.String(length=60)),
)

images = sqlalchemy.Table(
    'images',
    metadata,
    sqlalchemy.Column('id', sqlalchemy.String(), primary_key=True),
    sqlalchemy.Column('user_id', sqlalchemy.Integer()),
    sqlalchemy.Column('image_path', sqlalchemy.String()),
    sqlalchemy.Column('mask_path', sqlalchemy.String()),
    sqlalchemy.Column('result_path', sqlalchemy.String()),
    sqlalchemy.Column('result_state', sqlalchemy.String()),
)