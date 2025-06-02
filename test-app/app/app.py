from flask import Flask
import logging

app = Flask(__name__)
logging.basicConfig(filename='/var/log/app.log', level=logging.INFO)

@app.route("/process")
def process():
    logging.info("App Server processed a request")
    return "App Server Processed Request"

@app.route("/health")
def health():
    return "App server is healthy", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
