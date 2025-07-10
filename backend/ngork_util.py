from pyngrok import ngrok
from backend.firebase_config import get_firestore_client

def start_ngrok_and_update_firestore(port: int = 8000):
    public_url = ngrok.connect(port).public_url
    print(f"🌍 Ngrok tunnel started: {public_url}")
    
    db = get_firestore_client()
    db.collection("url").document("url").set({"url": public_url})
    
    return public_url