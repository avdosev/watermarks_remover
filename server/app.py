from flask import Flask, render_template, json, request
from flask import jsonify, send_from_directory

app = Flask(__name__)

@app.route('/')
def main():
    pass

def remove_watermark():
    pass

def improve_image():
    pass

def remove_watermark_from_video():
    pass

if __name__ == "__main__":
    app.run()