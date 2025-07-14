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
    users = fb.fetch_users_from_firestore()
    top_matches = mm.get_top_matches(user_data['user_id'], users, top_n=2)
    return fb.get_match_detailes(top_matches)

@app.post("/send_friend_request")
async def send_friend_request(request: Request):
    print("✅ Received request from", request.client.host)
    data = await request.json()
    print("📦 Data:", data)
    return fb.send_friend_request(data['user_id'], data['friend_id'])

@app.post("/friend_request_response")
async def friend_request_response(request: Request):
    print("✅ Received request from", request.client.host)
    data = await request.json()
    print("📦 Data:", data)
    return fb.friend_request_response(data['user_id'], data['friend_id'], data['decision'])

@app.post("/unfriend_user")
async def unfriend_user(request: Request):
    print("✅ Received request from", request.client.host)
    data = await request.json()
    print("📦 Data:", data)
    return fb.unfriend_user(data['user_id'], data['friend_id'])