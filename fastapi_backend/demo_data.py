# demo_data.py

import requests

BASE_URL = "https://frog-ios.onrender.com"

def post_sisu():
    payload = {
        "device_info": {
            "device_name": "iPhone 15 Pro",
            "os": "iOS 17.4",
            "browser_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X)",
        },
        "location": {
            "latitude": 48.2082,
            "longitude": 16.3738
        },
        "wifi": [
            {"ssid": "CafeNet", "bssid": "00:11:22:33:44:55", "signal_strength": -45},
            {"ssid": "HomeWiFi", "bssid": "66:77:88:99:AA:BB", "signal_strength": -60}
        ],
        "bluetooth": [
            {"device_name": "AirPods Pro", "device_mac": "AA:BB:CC:DD:EE:FF", "signal_strength": -50},
            {"device_name": "Car Audio", "device_mac": "11:22:33:44:55:66", "signal_strength": -70}
        ],
        "clipboard": "Sensitive clipboard content",
        "battery_level": 85,
        "charging": True
    }
    response = requests.post(f"{BASE_URL}/sisu", json=payload)
    print("POST /sisu:", response.status_code, response.json())

def post_report():
    payload = {
        "category": "Protest",
        "description": "Peaceful protest in Vienna city center.",
        "location": {
            "latitude": 48.2082,
            "longitude": 16.3738
        }
    }
    response = requests.post(f"{BASE_URL}/report", json=payload)
    print("POST /report:", response.status_code, response.json())

if __name__ == "__main__":
    post_sisu()
    post_report()
