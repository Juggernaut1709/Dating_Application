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



def fetch_users_from_firestore():
    db = get_firestore_client()
    users_ref = db.collection('users')
    docs = users_ref.stream()

    users = {}
    for doc in docs:
        data = doc.to_dict()
        if 'onboarding_answers' in data and len(data['onboarding_answers']) == 20 and data['onboarding_answers'][0] != -1:
            users[doc.id] = data['onboarding_answers']
    return users

def get_match_detailes(top_matches):
    db = get_firestore_client()
    result = []

    for match_uid, score in top_matches:
        user_doc = db.collection('users').document(match_uid).get()
        if user_doc.exists:
            data = user_doc.to_dict()
            result.append({
                "uid": match_uid,
                "username": data.get("username", ""),
                "shortName": data.get("shortName", ""),
                "age": data.get("age", ""),
                "similarity": round(float(score), 3)
            })

    return result

def send_friend_request(sender_id, receiver_id):
    db = get_firestore_client()
    try:
        db.collection("users").document(sender_id).update({
            "outgoing_friend_requests": firestore.ArrayUnion([receiver_id])
        })

        # Add sender to receiver's incoming requests
        db.collection("users").document(receiver_id).update({
            "incoming_friend_requests": firestore.ArrayUnion([sender_id])
        })

        return {"message": "Friend request sent."}
    except:
        return {"message": "An error has occured."}
    
def friend_request_response(receiver_id, sender_id, decision):
    db = get_firestore_client()
    try:
        if(decision == 1):
            db.collection("users").document(receiver_id).update({
                "incoming_friend_requests": firestore.ArrayRemove([sender_id]),
                "friends": firestore.ArrayUnion([sender_id])
            })

            db.collection("users").document(sender_id).update({
                "outgoing_friend_requests": firestore.ArrayRemove([receiver_id]),
                "friends": firestore.ArrayUnion([receiver_id])
            })

            return {"message": "Friend request accepted."}
        else:
            db.collection("users").document(receiver_id).update({
                "incoming_friend_requests": firestore.ArrayRemove([sender_id]),
            })

            db.collection("users").document(sender_id).update({
                "outgoing_friend_requests": firestore.ArrayRemove([receiver_id]),
            })

            return {"message": "Friend request rejeted."}     
    except:
        return {"message": "An error has occured."}
