
# 🧱 Architecture: FrogGuard App + Backend

## Overview

FrogGuard consists of two main components:

1. **iOS App (SwiftUI)**
2. **Backend API (FastAPI + PostgreSQL)**

Together, they simulate real-time privacy leaks and civil incident reporting.

---

## 1. iOS App (SwiftUI)

### 📱 Features

- Map view with `MapKit` and event annotations
- Grid view of incident reports
- Hidden privacy panel (long press)
- Calls backend endpoints using `URLSession` with JSON
- Uses `@ObservedObject` to bind `APIService` data
- Stores and filters events from `/map`, `/report`, `/sisu`
- Accessibility (A11y) + UI Test, Button with `accessibilityLabel` and `UITest` for interaction 


---

## 2. FastAPI Backend

### 🔧 Responsibilities

- Accepts POSTs of device metadata + coordinates
- Writes to PostgreSQL (schema: `prod`)
- Serves HTML visualizations with JS-injected data (via `re.sub()`)
- Converts `datetime` fields to `.isoformat()` for JSON compatibility
- Returns HTML tables for `/wifi`, `/bluetooth`, `/device_info`

---

## 🔀 Data Flow

````

\[iOS Device] ── /sisu ──► \[FastAPI] ──► PostgreSQL
\[iOS Device] ── /report ─► \[FastAPI] ──► PostgreSQL
▲
/map, /incidents (HTML with locationData injected)

````

---

## 📦 Data Example: POST /sisu

```json
{
  "device_info": {
    "device_name": "iPhone 15 Pro",
    "os": "iOS 17.4",
    "browser_user_agent": "Mozilla..."
  },
  "location": {
    "latitude": 48.2082,
    "longitude": 16.3738
  },
  "wifi": [
    {"ssid": "Cafe_WiFi", "bssid": "00:11:22", "signal_strength": -48}
  ],
  "bluetooth": [
    {"device_name": "AirPods", "device_mac": "AA:BB:CC", "signal_strength": -60}
  ],
  "clipboard": "🔐 My passport number",
  "battery_level": 84,
  "charging": true
}
````

---

## 🔐 Hidden Feature Handling

* Leaked data from `/sisu` is visualized in-app in a panel.
* Triggered via long-press gesture in `MapView.swift`.
* Data shown: battery %, clipboard, Wi-Fi SSIDs, Bluetooth names.

---

## 🛡️ Notes

* All HTML injection uses safe `json.dumps()` with `default=str`
* Production deployed via Render.com
* DB access locked via `prod` schema + secret URL

