# 🐸 FrogGuard Backend — FastAPI + PostgreSQL

This is the backend service for the **FrogGuard iOS app**, which simulates privacy leaks and visualizes civil conflict incidents. It stores location data, device telemetry, and user-submitted reports, and serves both JSON APIs and HTML visualizations.

---

## 🌐 Hosted API

Base URL: **https://frog-ios.onrender.com**

### Key Endpoints

| Endpoint        | Method | Description                                 |
|-----------------|--------|---------------------------------------------|
| `/sisu`         | POST   | Stores leaked device data (location, sensors) |
| `/report`       | POST   | Submits an incident report with geo-coords  |
| `/map`          | GET    | Shows all stored locations on a map         |
| `/incidents`    | GET    | Shows all reports on a map                  |
| `/device_info`  | GET    | Table of all collected device info          |
| `/wifi`         | GET    | Table of all collected Wi-Fi data           |
| `/bluetooth`    | GET    | Table of all collected Bluetooth devices    |

---

## 📦 Features

- 📡 PostgreSQL + psycopg2
- 🧩 FastAPI RESTful endpoints
- 📊 HTML-based map + table rendering
- 🛠️ Handles timestamp conversion and injection into `map.html`
- 📥 Accepts Postman and Python test payloads
- 🔒 Simulates real-world privacy risk exposure (clipboard, Wi-Fi, Bluetooth)

---

## 🧪 Demo Data

Use `demo_data.py` or Postman collection to populate test entries:

```bash
python demo_data.py
