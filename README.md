
## 🐸 FrogGuard: iOS + Python Privacy Awareness App

![alt text](./ios-angry-fog/screenshots/Screenshot 2025-05-24 at 14.10.32.png) 

![alt text](image.png)
**FrogGuard** is a playful and satirical mobile application built to explore privacy, surveillance, and emergency safety through a fictional frog-themed interface. Built using **SwiftUI** on the frontend and **Python Flask** for the backend, this app mimics real-world scenarios in a humorous but thought-provoking way.


Figma link for UI design : [UI design](https://www.figma.com/design/SswFEXF8e8v0aPOke8CxBk/Untitled?node-id=1-1188&t=n3Mnd1enVA5zbIcz-1)

---

### 📱 iOS App (SwiftUI)

#### Features:

* **Privacy Settings**

  * Fake “Secure Mode”
  * Optional clipboard and location tracking toggles
* **Developer Options**

  * Test Mode switch
  * Reset app data
* **Global Map**

  * View worldwide incidents such as protests, accidents, and blockades
* **Incident Reporting**

  * Report events under categories like: Protest, Police Blockade, Medical Accident, Other
* **Insights Tab**

  * Displays simulated data access and report history
* **Travel Mode**

  * Emergency contacts and safety tips per country
  * Embassy locator feature
* **Frog Species**

  * Fun classification (e.g., “Angry Screamer”)

---

### 🌐 Backend (Python + Flask)

#### API Endpoints:

| Method | Endpoint           | Description                       |
| ------ | ------------------ | --------------------------------- |
| POST   | `/storestolen`     | Simulate device data being stored |
| GET    | `/getlateststolen` | Retrieve latest fake data record  |
| POST   | `/report`          | Submit incident report            |
| GET    | `/reports`         | View recent 20 reports            |

#### Example POST /report payload:

```json
{
  "category": "Protest",
  "description": "Political protest on Weidinger Strasse"
}
```

#### Tech:

* Flask + Flask-CORS
* PostgreSQL on Render
* SQLAlchemy ORM
* `.env` configuration:

  ```
  DATABASE_URL=postgresql://username:password@host:port/dbname
  ```

---

### 🚀 Getting Started

#### iOS (Xcode)

1. Open the project in Xcode (`FrogGuard.xcodeproj`)
2. Set backend URL in `Environment.swift`
3. Run on device or simulator (iOS 18.3+)

#### Python (Backend)

```bash
pip install -r requirements.txt
python server.py
```

---

### ⚠️ Disclaimer

> This is a satire app created for learning and experimentation. It does **not** collect real personal data unless explicitly enabled by the user. Use responsibly.

---

## 👥 Team

- iOS Devs: Christian Ackermann, Mariia Glushenkova, Arthur Nowotny
- Android Repo: [Arthur Nowotny](https://git-iit.fh-joanneum.at/nowotnyt19/angry-frog)
---