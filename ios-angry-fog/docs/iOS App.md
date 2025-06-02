 📦 FrogGuard App — Submission Report

**Project:** ios-angry-fog  
**Author:** Mariia Glushenkova, Christian Ackermann,Arthur-Tiberiu Nowotny 
**Date:** 2 June 2025

---

## ✅ Project Overview

FrogGuard is a civic safety dashboard iOS app built using **SwiftUI**, **MapKit**, **WeatherKit**, and a custom **FastAPI + PostgreSQL** backend. It helps users access emergency data and real-time conflict events with a clean UI and location-aware features.

## 5% Selected Upload 3 A11y or Swift2Rust or local/push notifications

Completion requirements

Select one of following tasks:

- UI-Tests including Accessibility (A11y). Add accessibility information and test at least ONE (single) interaction element (e.g. slider).

---

## 📂 Repository

- GitHub: [GitHub - maguitaria/frog-ios: Crypto IOS application which steals data from user.](https://github.com/maguitaria/frog-ios) or GitLab fh Joanneum [Sign in · GitLab](https://git-iit.fh-joanneum.at/v59y55/ios-app-angry-frog) 

- Backend (FastAPI): https://frog-ios.onrender.com/map

---

## ✅ Requirements Met

| Requirement                    | Status | Notes                                                         |
| ------------------------------ | ------ | ------------------------------------------------------------- |
| Repository with Git + README   | ✅      | Includes README, architecture section, and diagrams           |
| Design Documents               | ✅      | API structure, data flow, and diagrams added                  |
| Source Documentation           | ✅      | Descriptive comments across SwiftUI and backend code          |
| Demo Data                      | ✅      | Populated via Postman JSON and `/sisu` endpoint               |
| Works on Simulator             | ✅      | Verified on iOS Simulator (16 Pro, 18.4)                      |
| Hidden Feature (Privacy Leak)  | ✅      | Bluetooth & WiFi data collected and stored in backend         |
| Security Leak (Bonus)          | ✅      | Clipboard content captured (can be abused)                    |
| Accessibility (A11y) + UI Test | ✅      | Button with `accessibilityLabel` and `UITest` for interaction |
| Useful UI Tests                | ✅      | Reusable function to test interaction on tab and button       |
| Real Device/TestFlight         | 🚧     | Optional, not deployed to TestFlight                          |

---

## 🔍 Hidden Feature Description

- **Privacy Leak:** App collects clipboard, nearby WiFi SSIDs, Bluetooth MACs + signal strength.

- **Security Risk:** User’s clipboard is accessed on every session and stored remotely.

- **Backend:** FastAPI stores leaked data in PostgreSQL; accessible via `/device_info`, `/bluetooth`, `/wifi`.

---

## 🧪 Accessibility Test

**Component tested:**

- `"showCountrySelector"` button in `Travel Mode` tab, `"showReport"` button in `Report` tab

**Details:**

- Added `.accessibilityIdentifier`, `.accessibilityLabel`, `.accessibilityHint`

- Created reusable UI test:
  
  ```swift
  func testTapButtonInTab(tabName: String, buttonId: String, timeout: TimeInterval = 3.0)
  ```

- Verified existence, hittability, and tap action.
  
  

---

## 📊 Architecture Overview

### Frontend (iOS)

- `SwiftUI`, `MapKit`, `WeatherKit`, `CoreLocation`

- Tabs: Home, Map, Report, Travel Mode, Settings

- Views use MVVM structure with `@StateObject` and `@ObservedObject`

### Backend (FastAPI)

- REST API with endpoints:
  
  - `POST /sisu` → Save device + location + WiFi + Bluetooth + clipboard
  
  - `POST /report` → Save incident report
  
  - `GET /map` and `GET /incidents` → Return HTML with JS-filled demo data

### Database

- PostgreSQL via Render

- Tables: `device_info`, `location`, `wifi`, `bluetooth`, `report`

---

## 📁 Included Files

- `/fastapi_backend/main.py` → Full backend logic + data injection

- `ios-angry-fog/Views/MapView.swift` → Event pins, filtered annotations

- `ios-angry-fogUITests.swift` → Accessibility & interaction test

- `map.html`, `incidents.html` → Frontend HTML map views for visualizing data

---

## 📮 Postman + Demo Data

Postman Collection: ✅ Included  
Demo Data: ✅ Added to database via Postman (see `/sisu` endpoint)

---

## 📸 Diagrams

1. **Data Flow** (App → Backend → DB → Rendered Map)

2. **UI Architecture** (TabView + MVVM structure)

(Diagrams are embedded in the `README.md`)

---

## 🏁 How to Run

```bash
# iOS App
Open ios-angry-fog.xcodeproj
Run on iOS Simulator (>= iOS 18.4)

# Backend
cd fastapi_backend
uvicorn main:app --reload
```

---


