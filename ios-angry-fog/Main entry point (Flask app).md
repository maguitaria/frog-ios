# 🐸 FrogGuard Backend – Technical Documentation

---

## 📌 Overview

FrogGuard is a lightweight Python-Flask API that serves as a backend for capturing incident reports, simulated device data, user locations, and environmental data. The system is designed to interface with a frontend UI and database hosted on Render.

---

## 📦 Technologies Used

- **Python 3**

- **Flask**

- **Flask-SQLAlchemy**

- **Flask-CORS**

- **PostgreSQL**

- **Render.com (Deployment)**

- **OpenWeatherMap API**

---

## 🛢️ Database Schema (PostgreSQL)

### `users`

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

### `locations`

```sql
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    altitude DOUBLE PRECISION,
    accuracy DOUBLE PRECISION,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES users(id)
);
```

### `bluetooth_devices`

```sql
CREATE TABLE bluetooth_devices (
    id SERIAL PRIMARY KEY,
    device_name VARCHAR(255),
    device_mac VARCHAR(17) UNIQUE,
    signal_strength INT,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES users(id)
);
```

### `wifi_networks`

```sql
CREATE TABLE wifi_networks (
    id SERIAL PRIMARY KEY,
    ssid VARCHAR(255),
    bssid VARCHAR(17) UNIQUE,
    signal_strength INT,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES users(id)
);
```

### `reports`

```python
class Report(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category = db.Column(db.String(80))
    description = db.Column(db.String(200))
    timestamp = db.Column(db.String(40))
```

### `simulated_entries`

```python
class SimulatedEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    device = db.Column(db.String(80))
    os = db.Column(db.String(80))
    clipboard = db.Column(db.String(500))
    timestamp = db.Column(db.String(40))
```

---

## 🌐 Existing API Routes

| Route        | Method | Description                                |
| ------------ | ------ | ------------------------------------------ |
| `/`          | GET    | Health check                               |
| `/simulate`  | POST   | Save simulated device/OS/clipboard entry   |
| `/simulated` | GET    | Retrieve latest 20 simulated entries       |
| `/location`  | POST   | Save latest device location                |
| `/map`       | GET    | Render latest location on embedded map     |
| `/air`       | GET    | Proxy air quality data from OpenWeatherMap |
| `/dashboard` | GET    | Serve static dashboard HTML                |

---

## 📌 To-Implement Routes

| Planned Route      | Method | Description                                                            | Assigned      |
| ------------------ | ------ | ---------------------------------------------------------------------- | ------------- |
| `/storestolen`     | POST   | Store raw/stolen data sent from frontend (clipboard, etc.)             | Mariia        |
| `/getlateststolen` | GET    | Retrieve the most recent raw/stolen data for display                   | Arthur        |
| /reports           | GET    | Retrieve latest 20 reports ( is on backend, test SQL query connection) | Arthur/Mariia |
| /report            | POST   | Save a user-submitted incident report                                  | Arthur/Mariia |

---

## 📂 File Structure

```plaintext
project-root/
│
├── server.py             # Main entry point (Flask app)
├── .env                  # API keys and DB URL
├── requirements.txt      # Python dependencies
├── static/
│   └── frog_dashboard.html  # Simple dashboard page
```

---

## 🚀 Render Deployment

### Build Command

```bash
cd ios-angry-fog && pip install -r requirements.txt
```

### Start Command

```bash
cd ios-angry-fog && python server.py
```

### Deploy Hook (Private)

```
https://api.render.com/deploy/srv-d0dl5oidbo4c738m25qg?key=3ZaJQD-9MDk
```

---

## 🔑 PostgreSQL Connection

- **Database URL:**  
  `postgresql://frog_guard_prod_user:<password>@...render.com/frog_guard_prod`

- **Connection via CLI:**

```bash
PGPASSWORD=yourpassword psql -h yourhost -U frog_guard_prod_user frog_guard_prod
```

### **Connections**

**Hostname dpg-d0f11ac9c44c738j0s0g-a**

An internal hostname used by your Render services.

**Port**

5432

**Database**

frog_guard_prod

**Username**

frog_guard_prod_user

**Password**

xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH

**Internal Database URL**

postgresql://frog_guard_prod_user:xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH@dpg-d0f11ac9c44c738j0s0g-a/frog_guard_prod

**External Database URL**

postgresql://frog_guard_prod_user:xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH@dpg-d0f11ac9c44c738j0s0g-a.oregon-postgres.render.com/frog_guard_prod

**PSQL Command**

PGPASSWORD=xJxHxbuPQ4jtQLbVyc3LaKdQnNtiV8nH psql -h dpg-d0f11ac9c44c738j0s0g-a.oregon-postgres.render.com -U frog_guard_prod_user frog_guard_prod

---

## 👥 Team Responsibilities

| Name      | Role                                           |
| --------- | ---------------------------------------------- |
| Mariia    | Frontend API integration, simulator routes     |
| Arthur    | Backend development, DB logic, new route setup |
| Christian | Backend UI: display reports and data in HTML   |

---

## 🧪 Testing SQL Queries

```sql
-- All users
SELECT * FROM users;

-- Locations for user ID 1
SELECT * FROM locations WHERE user_id = 1;

-- Bluetooth devices with strong signal
SELECT * FROM bluetooth_devices WHERE signal_strength > -60;

-- Latest simulated clipboard entry
SELECT clipboard FROM simulated_entry ORDER BY timestamp DESC LIMIT 1;
```


