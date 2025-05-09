from flask import Flask, request, jsonify
from datetime import datetime
from flask_cors import CORS
import requests
import os
from dotenv import load_dotenv
from flask_sqlalchemy import SQLAlchemy

load_dotenv()

app = Flask(__name__)
CORS(app)

# 🛠 Database config
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv("DATABASE_URL").replace("postgres://", "postgresql://", 1)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# 🧾 Models
class Report(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category = db.Column(db.String(80))
    description = db.Column(db.String(200))
    timestamp = db.Column(db.String(40))

class SimulatedEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    device = db.Column(db.String(80))
    os = db.Column(db.String(80))
    clipboard = db.Column(db.String(500))
    timestamp = db.Column(db.String(40))

# 🌍 Latest user location
latest_location = {"latitude": None, "longitude": None, "timestamp": None}

@app.before_request
def create_tables():
    db.create_all()

@app.route("/")
def home():
    return "🐸 FrogGuard API is running!"

# 🧾 Save incident report
@app.route("/report", methods=["POST"])
def receive_report():
    data = request.json
    report = Report(
        category=data.get("category"),
        description=data.get("description"),
        timestamp=datetime.utcnow().isoformat()
    )
    db.session.add(report)
    db.session.commit()
    print(f"[+] Incident saved to DB: {data}")
    return jsonify({"status": "✅ report saved"})

# 🔍 Get recent reports
@app.route("/reports", methods=["GET"])
def get_reports():
    reports = Report.query.order_by(Report.timestamp.desc()).limit(20).all()
    return jsonify([{
        "category": r.category,
        "description": r.description,
        "timestamp": r.timestamp
    } for r in reports])

# 🧪 Save simulated data
@app.route("/simulate", methods=["POST"])
def receive_simulated_data():
    data = request.json
    entry = SimulatedEntry(
        device=data.get("device"),
        os=data.get("os"),
        clipboard=data.get("clipboard"),
        timestamp=datetime.utcnow().isoformat()
    )
    db.session.add(entry)
    db.session.commit()
    print(f"[!] Simulated entry saved: {data}")
    return jsonify({"status": "🧪 simulated data saved"})

# 🧪 Get simulated entries
@app.route("/simulated", methods=["GET"])
def get_simulated():
    entries = SimulatedEntry.query.order_by(SimulatedEntry.timestamp.desc()).limit(20).all()
    return jsonify([{
        "device": e.device,
        "os": e.os,
        "clipboard": e.clipboard,
        "timestamp": e.timestamp
    } for e in entries])

# 📍 Save latest location
@app.route("/location", methods=["POST"])
def receive_location():
    global latest_location
    data = request.json
    if "latitude" in data and "longitude" in data:
        latest_location = {
            "latitude": data["latitude"],
            "longitude": data["longitude"],
            "timestamp": datetime.utcnow().isoformat()
        }
        print(f"[🐸] Location saved: {latest_location}")
        return jsonify({"status": "📍 location saved"}), 200
    return jsonify({"error": "Missing coordinates"}), 400

# 🌀 Air quality proxy
@app.route("/air", methods=["GET"])
def get_air_quality():
    lat = request.args.get("lat")
    lon = request.args.get("lon")
    api_key = os.getenv("OWM_KEY")

    if not lat or not lon or not api_key:
        return jsonify({"error": "Missing lat/lon or API key"}), 400

    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={api_key}"
    response = requests.get(url)
    return jsonify(response.json()) if response.ok else jsonify({"error": "Failed to fetch data"}), 500

# 🌐 View latest location on map
@app.route("/map", methods=["GET"])
def show_map():
    if not latest_location["latitude"]:
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
        <iframe src="https://maps.google.com/maps?q={lat},{lon}&z=15&output=embed"></iframe>
    </body>
    </html>
    """

# 🧾 Serve dashboard (HTML template)
@app.route("/dashboard")
def dashboard():
    return app.send_static_file("frog_dashboard.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
