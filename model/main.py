from fastapi import FastAPI
from fastapi import Request
import model as model

users = []

app = FastAPI()

@app.post("/matches")
async def get_matches(request: Request):
    print("✅ Received request from", request.client.host)
    user_data = await request.json()
    print("📦 Data:", user_data)
    users = model.fetch_users_from_firestore()
    return model.get_top_matches(user_data, users, top_n=2)