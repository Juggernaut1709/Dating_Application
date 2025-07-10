import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

firebase_app = None

def init_firebase():
    global firebase_app
    if not firebase_admin._apps:
        key_path = os.getenv("FIREBASE_KEY_PATH")
        if not key_path or not os.path.exists(key_path):
            raise FileNotFoundError(f"Firebase service account file not found at {key_path}")
        cred = credentials.Certificate(key_path)
        firebase_app = firebase_admin.initialize_app(cred)

def get_firestore_client():
    if not firebase_admin._apps:
        init_firebase()
    return firestore.client()
