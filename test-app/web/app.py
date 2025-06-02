from flask import Flask
import requests
import logging

app = Flask(__name__)
logging.basicConfig(filename='/var/log/web.log', level=logging.INFO)

@app.route("/")
def home():
    logging.info("Request received on Web Server")
    try:
        r = requests.get("http://<APP_SERVER_PRIVATE_IP>:5000/process")
        return f"Forwarded to App Server: {r.text}"
    except Exception as e:
        return f"Error contacting App Server: {e}"

@app.route("/health")
def health():
    return "Web server is healthy", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
