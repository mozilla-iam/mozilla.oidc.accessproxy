from flask import Flask, request, jsonify
from flask_restful import reqparse, Resource, Api

app = Flask(__name__)
api = Api(app)

def options(self):
    pass


class Demo(Resource):
    def get(self):
        return jsonify({"HELLO": "I AM AN API. PLEASED TO MEET YOU. BEEP BEEP."})

api.add_resource(Demo,'/')
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
