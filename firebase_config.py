import os
import firebase_admin
from firebase_admin import credentials

def init_firebase():
    key_path = os.getenv("FIREBASE_KEY_PATH", ".secrets/serviceAccountKey.json")
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
