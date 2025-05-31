from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from typing import List
from datetime import datetime
import psycopg2
import json
import re
import os

# FastAPI app setup
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
DATABASE_URL = "postgresql://frog_guard_prod_user:xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH@oregon-postgres.render.com:5432/frog_guard_prod"


# ----------------------
# Pydantic Models
# ----------------------
class DeviceInfo(BaseModel):
    device_name: str
    os: str
    browser_user_agent: str

class Location(BaseModel):
    latitude: float
    longitude: float

class Wifi(BaseModel):
    ssid: str
    bssid: str
    signal_strength: int

class Bluetooth(BaseModel):
    device_name: str
    device_mac: str
    signal_strength: int

class DataModel(BaseModel):
    device_info: DeviceInfo
    location: Location
    wifi: List[Wifi]
    bluetooth: List[Bluetooth]
    clipboard: str
    battery_level: int
    charging: bool

class Report(BaseModel):
    category: str
    description: str
    location: Location

# ----------------------
# PostgreSQL helpers
# ----------------------
def get_connection():
    return psycopg2.connect(DATABASE_URL)

def insert_into_db(table: str, columns: List[str], values: List[tuple]):
    query = f"INSERT INTO prod.{table} ({', '.join(columns)}) VALUES ({', '.join(['%s'] * len(values[0]))})"
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.executemany(query, values)
            conn.commit()

def fetch_records(table: str):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT * FROM prod.{table};")
            columns = [desc[0] for desc in cur.description]
            return [dict(zip(columns, row)) for row in cur.fetchall()]

# ----------------------
# Data Insertion Logic
# ----------------------
def insert_all(data: DataModel):
    insert_into_db("location", ["latitude", "longitude"], [(data.location.latitude, data.location.longitude)])
    insert_into_db("device_info", ["device_name", "os", "browser_user_agent", "clipboard", "battery_level", "charging"], [
        (data.device_info.device_name, data.device_info.os, data.device_info.browser_user_agent,
         data.clipboard, data.battery_level, data.charging)
    ])
    if data.wifi:
        insert_into_db("wifi", ["ssid", "bssid", "signal_strength"],
                       [(w.ssid, w.bssid, w.signal_strength) for w in data.wifi])
    if data.bluetooth:
        insert_into_db("bluetooth", ["device_name", "device_mac", "signal_strength"],
                       [(b.device_name, b.device_mac, b.signal_strength) for b in data.bluetooth])

def insert_report(report: Report):
    insert_into_db("report", ["category", "description", "latitude", "longitude"], [
        (report.category, report.description, report.location.latitude, report.location.longitude)
    ])

# ----------------------
# Routes
# ----------------------
@app.get("/")
def root():
    return {"message": "🐸 FrogGuard FastAPI backend is live!"}

@app.post("/sisu")
def post_data(data: DataModel):
    insert_all(data)
    return {"status": "✅ Data stored"}

@app.post("/report")
def post_report(report: Report):
    insert_report(report)
    return {"status": "✅ Report stored"}

@app.get("/device_info")
def get_device_info():
    return format_table(fetch_records("device_info"),
                        ["ID", "Device", "OS", "User Agent", "Clipboard", "Battery", "Charging", "Timestamp"])

@app.get("/wifi")
def get_wifi():
    return format_table(fetch_records("wifi"),
                        ["ID", "SSID", "BSSID", "Signal", "Timestamp"])

@app.get("/reports")
def get_reports():
    return fetch_records("report")

@app.get("/bluetooth")
def get_bluetooth():
    return format_table(fetch_records("bluetooth"),
                        ["ID", "Name", "MAC", "Signal", "Timestamp"])

@app.get("/map", response_class=HTMLResponse)
def show_map():
    return serve_html("map.html", fetch_records("location"))

@app.get("/incidents", response_class=HTMLResponse)
def show_incidents():
    return serve_html("incidents.html", fetch_records("report"))

# ----------------------
# HTML & Utility
# ----------------------
def serve_html(filename: str, data):
    with open(filename, "r", encoding="utf-8") as f:
        content = f.read()
    pattern = r'const locationData\s*=\s*(\[[\s\S]*?\]);'
    replacement = f"const locationData = {json.dumps(data, indent=2)};"
    updated = re.sub(pattern, replacement, content)
    return HTMLResponse(content=updated)

def format_table(data, columns):
    html = f"<table border='1'><thead><tr>{''.join(f'<th>{col}</th>' for col in columns)}</tr></thead><tbody>"
    for row in data:
        html += "<tr>" + "".join(f"<td>{val if not isinstance(val, datetime) else val.strftime('%Y-%m-%d %H:%M')}</td>" for val in row) + "</tr>"
    html += "</tbody></table>"
    return HTMLResponse(content=html)
