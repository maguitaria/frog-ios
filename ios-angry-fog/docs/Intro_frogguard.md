
# 🐸 FrogGuard — Civic Safety Dashboard

FrogGuard is a SwiftUI-based iOS app that visualizes protest events and privacy leaks from mobile devices. It connects to a FastAPI backend to fetch global event data and user telemetry.


[Feel free to see the demo](https://unioulu-my.sharepoint.com/:v:/g/personal/mglushen22_students_oamk_fi/EdD8NtvrC_BMo5Rj1ixigl0BDo81as9NkNsD8BSeHk48uA?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=goM7de)

![alt text](../screenshots/Selection.png)
## 📱 Features
- 🔐 **Hidden Feature:** Privacy leak panel (long press to activate)
- 🗺️ Live interactive map with protest/conflict data
- 📍 Searchable global incidents (ACLED API & custom reports)
- 🐸 Hidden debug view shows:
  - Device clipboard
  - Battery status
  - Wi-Fi & Bluetooth leakage
- 🔄 Toggle grid/map view
- 🔐 Privacy leak simulation
- 🎨 Clean SwiftUI layout with annotation-based MapKit

![alt text](../screenshots/Screenshot%202025-05-31%20at%2020.25.26.png)
## 🛠 Tech Stack

- SwiftUI + MapKit + CoreLocation
- ACLED Data Integration
- FastAPI + PostgreSQL backend
- WeatherKit (optional)
- RESTful API with JSON

## 📦 Installation

### Requirements
- Xcode 15+
- iOS Simulator or device (iOS 16+)

### Steps

```bash
git clone https://github.com/maguitaria/frog-ios.git
cd frog-ios
open ios-angry-fog.xcodeproj
````

Then run via ⌘+R in Xcode.

## 🔍 Hidden Feature

Long-press on the Home screen or open the `/map` view to reveal leaked device data (e.g., clipboard, SSID, Bluetooth, battery level).

## 🧪 Testing

* Works on simulator (default)
* Optional: Test on device via TestFlight
* Network requests are sent to: `https://frog-ios.onrender.com`

## 📸 Screenshots

![](../screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-05-24%20at%2014.10.55.png)
![](../screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-05-24%20at%2014.11.44.png)

---

## 🤖 Backend Repo

See: [FastAPI Backend →](https://github.com/maguitaria/frog-ios-backend)

````

---

## ⚙️ `README.md` for `frog-ios-backend` (FastAPI)

```markdown
# 🐸 FrogGuard Backend – FastAPI + PostgreSQL

This is the backend API powering the FrogGuard iOS app — a civic safety and privacy data dashboard.

## 🌐 API Features

- `/sisu`: Stores device info and sensor leak data
- `/report`: Stores custom user-submitted incident reports
- `/map`: Visualizes leaked GPS data on an HTML map
- `/incidents`: Lists reports as a table or map
- `/wifi`, `/bluetooth`, `/device_info`: Debug pages with HTML tables

## 💾 Tech Stack

- FastAPI + Uvicorn
- PostgreSQL via `psycopg2`
- Hosted on Render.com
- HTML injection via `re.sub()`

## 🧪 Demo Data

You can post fake device leaks and reports using Postman or Python:

```bash
POST /sisu
POST /report
````

See `demo_data.py` for examples.

## 🗂 Database Schema

Tables under schema `prod`:

* `device_info(device_name, os, user_agent, clipboard, battery_level, charging)`
* `location(latitude, longitude, timestamp)`
* `bluetooth(device_name, mac, signal_strength)`
* `wifi(ssid, bssid, signal_strength)`
* `report(category, description, latitude, longitude, timestamp)`

## 🚀 Local Dev

```bash
cd fastapi_backend
uvicorn main:app --reload
```

### Env Setup

* Python 3.11+
* Install with: `pip install -r requirements.txt`

## 🌍 Production URL

[https://frog-ios.onrender.com](https://frog-ios.onrender.com)

* `/map` → Leaked device locations
* `/incidents` → Protest reports
* `/device_info`, `/wifi`, `/bluetooth` → Tabular debug views

---

## 🔒 Hidden Privacy Feature

Sensitive sensor data (clipboard, battery, Wi-Fi SSID, BT MAC addresses) is sent silently via the `/sisu` endpoint and visualized on the map.

> Intended to raise awareness about mobile privacy risks in a visual way.

---

## 📁 Project Structure

```
fastapi_backend/
├── main.py
├── demo_data.py
├── map.html
├── incidents.html
├── templates/ (optional)
├── static/ (optional)
```

---

## 🧠 Author

Created by Christian Ackermann, Tiberiu-Arthur Nowotny, Mariia Glushenkova [@maguitaria](https://github.com/maguitaria)
Feedback and feature requests welcome!
