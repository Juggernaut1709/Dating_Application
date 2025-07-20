import datetime
from fastapi import FastAPI, Request, WebSocket, WebSocketDisconnect, Depends, Query
from backend.utils import get_or_create_chat
import model.match_model as mm
from backend.ngork_util import start_ngrok_and_update_firestore
import backend.firebase as fb
from backend.connection_manager import ConnectionManager
from database.database_str import SessionLocal
from database.tables.message import Message
from database.schemas.message import Message as MessageSchema

# Initialize Firebase once
fb.init_firebase()

# Start ngrok and update Firestore
start_ngrok_and_update_firestore(port=8000)

app = FastAPI()
manager = ConnectionManager()

@app.post("/matches")
async def get_matches(request: Request):
    print("✅ Received request from", request.client.host)
    user_data = await request.json()
    print("📦 Data:", user_data)
    users = fb.fetch_users_from_firestore(user_data['user_id'], user_data['distance'])
    top_matches = mm.get_top_matches(user_data['user_id'], users, top_n=2)
    return fb.get_match_details(top_matches)

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

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_json()
            sender_id = data["sender_id"]
            receiver_id = data["receiver_id"]
            message_text = data["message"]

            # Save message in DB
            db = SessionLocal()
            chat_id = get_or_create_chat(db, sender_id, receiver_id)
            message = Message(
                chat_id=chat_id,
                sender_id=sender_id,
                receiver_id=receiver_id,
                message=message_text,
                timestamp=datetime.datetime.utcnow()
            )
            db.add(message)
            db.commit()
            db.refresh(message)
            db.close()

            # Send message to receiver if online
            await manager.send_personal_message({
                "sender_id": sender_id,
                "message": message_text,
                "timestamp": str(message.timestamp)
            }, receiver_id)

    except WebSocketDisconnect:
        manager.disconnect(user_id)

@app.get("/chat/history")
def get_chat_history(sender_id: str = Query(...), receiver_id: str = Query(...)):
    db = SessionLocal()
    try:
        chat_id = get_or_create_chat(db, sender_id, receiver_id)
        messages = db.query(Message).filter(
            Message.chat_id == chat_id
        ).order_by(Message.timestamp.asc()).all()
        
        result = []
        for msg in messages:
            try:
                result.append(MessageSchema.from_orm(msg))
            except Exception as e:
                print("❌ Failed to convert message:")
                print("    Message dict:", msg.__dict__)
                print("    Error:", repr(e))
        
        return result
    finally:
        db.close()

