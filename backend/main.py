from fastapi import FastAPI, Request
import model.match_model as mm
from backend.ngork_util import start_ngrok_and_update_firestore
import backend.firebase as fb

# Initialize Firebase once
fb.init_firebase()

# Start ngrok and update Firestore
start_ngrok_and_update_firestore(port=8000)

app = FastAPI()

@app.post("/matches")
async def get_matches(request: Request):
    print("✅ Received request from", request.client.host)
    user_data = await request.json()
    print("📦 Data:", user_data)
    users = mm.fetch_users_from_firestore()
    return mm.get_top_matches(user_data['user_id'], users, top_n=2)

@app.post("/send_frined_request")
async def send_freind_request(request: Request):
    print("✅ Received request from", request.client.host)
    data = await request.json()
    print("📦 Data:", data)