from flask import Flask, request, jsonify
from datetime import datetime
from flask_cors import CORS
import json
import requests
import os
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
CORS(app)

# In-memory storage (for demo purposes)
incident_reports = []
simulated_data = []
latest_location = {"latitude": None, "longitude": None, "timestamp": None}

@app.route("/")
def home():
    return "🐸 FrogGuard API is running!"

# 🧾 Endpoint to receive anonymous civil safety reports
@app.route("/report", methods=["POST"])
def receive_report():
    data = request.json
    data["timestamp"] = datetime.utcnow().isoformat()
    incident_reports.append(data)
    print(f"[+] Incident received: {data}")
    return jsonify({"status": "✅ report saved"})

# 🧪 Endpoint to receive simulated privacy leak payloads
@app.route("/simulate", methods=["POST"])
def receive_simulated_data():
    data = request.json
    data["timestamp"] = datetime.utcnow().isoformat()
    simulated_data.append(data)
    print(f"[!] Simulated data received: {data}")
    return jsonify({"status": "🧪 simulated data received"})

# 📡 Optional: Receive user GPS location directly
@app.route("/location", methods=["POST"])
def receive_location():
    global latest_location
    data = request.get_json()
    data["timestamp"] = datetime.utcnow().isoformat()
    if "latitude" in data and "longitude" in data:
        latest_location = data
        print(f"[🐸] Frog location updated: {data}")
        return jsonify({"status": "📍 location saved"}), 200
    return jsonify({"error": "Missing coordinates"}), 400

@app.route("/air", methods=["GET"])
def get_air_quality():
    lat = request.args.get("lat")
    lon = request.args.get("lon")
    api_key = os.getenv("OWM_KEY")

    if not lat or not lon or not api_key:
        return jsonify({"error": "Missing lat/lon or API key"}), 400

    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={api_key}"
    response = requests.get(url)

    if response.ok:
        return jsonify(response.json())
    else:
        return jsonify({"error": "Failed to fetch data"}), 500

@app.route("/dashboard", methods=["GET"])
def get_dashboard_data():
    lat = request.args.get("lat")
    lon = request.args.get("lon")

    if not lat or not lon:
        return jsonify({"error": "Missing lat/lon"}), 400

    # Air Quality
    owm_key = os.getenv("OWM_KEY")
    air_url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={owm_key}"
    air_data = requests.get(air_url).json()

    # Conflict Data (ACLED API)
    acled_key = os.getenv("ACLED_KEY")
    acled_url = f"https://api.acleddata.com/acled/read?key={acled_key}&event_date=2024-01-01|{datetime.utcnow().date()}&latitude={lat}&longitude={lon}&limit=5"
    conflict_data = requests.get(acled_url).json()

    return jsonify({
        "air_quality": air_data,
        "conflict_events": conflict_data.get("data", [])
    })

# 🌍 Visual map of last frog scream (HTML UI)
@app.route("/map", methods=["GET"])
def show_map():
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

# 📥 View recent reports & simulated data
@app.route("/reports", methods=["GET"])
def get_reports():
    return jsonify(incident_reports[-20:])

@app.route("/simulated", methods=["GET"])
def get_simulated():
    return jsonify(simulated_data[-20:])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
