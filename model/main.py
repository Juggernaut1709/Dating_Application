from fastapi import FastAPI
from fastapi import Request
import model.match_model as mm

users = []

app = FastAPI()

@app.post("/matches")
async def get_matches(request: Request):
    print("✅ Received request from", request.client.host)
    user_data = await request.json()
    print("📦 Data:", user_data)
    users = mm.fetch_users_from_firestore()
    return mm.get_top_matches(user_data['user_id'], users, top_n=2)