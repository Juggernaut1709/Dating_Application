import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
from math import radians, cos, sin, asin, sqrt

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



def fetch_users_from_firestore(user_id, distance):
    db = get_firestore_client()
    users_ref = db.collection('users')
    docs = users_ref.stream()

    # Get the current user's location
    current_user = db.collection('users').document(user_id).get().to_dict()
    if not current_user or 'location' not in current_user:
        return {}

    current_lat = current_user['location']['latitude']
    current_lon = current_user['location']['longitude']

    users = {}
    for doc in docs:

        data = doc.to_dict()

        print(f"🧠 Checking user: {doc.id}")

        if 'onboarding_answers' not in data:
            print(f"⛔ Skipped {doc.id}: missing onboarding_answers")
            continue
        if len(data['onboarding_answers']) != 20:
            print(f"⛔ Skipped {doc.id}: not 20 answers ({len(data['onboarding_answers'])})")
            continue
        if data['onboarding_answers'][0] == -1:
            print(f"⛔ Skipped {doc.id}: first answer is -1")
            continue

        if 'onboarding_answers' in data and len(data['onboarding_answers']) == 20 and data['onboarding_answers'][0] != -1:
            if distance == 1001:
                users[doc.id] = data['onboarding_answers']
                print(f"✅ Added {doc.id} (distance ignored)")
            elif 'location' in data:
                user_lat = data['location']['latitude']
                user_lon = data['location']['longitude']

                # Convert coordinates to radians
                lat1, lon1, lat2, lon2 = map(radians, [current_lat, current_lon, user_lat, user_lon])

                # Haversine formula
                dlon = lon2 - lon1
                dlat = lat2 - lat1
                a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                c = 2 * asin(sqrt(a))
                r = 6371  # Radius of Earth in kilometers
                calculated_distance = c * r

                # If user is within the specified distance, include them
                if calculated_distance <= distance:
                    users[doc.id] = data['onboarding_answers']

    return users

def get_match_details(top_matches):
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
        # Store as dict with id and role 'F'
        sender_request = {"id": receiver_id, "role": "F"}
        receiver_request = {"id": sender_id, "role": "F"}

        db.collection("users").document(sender_id).update({
            "outgoing_requests": firestore.ArrayUnion([sender_request])
        })

        db.collection("users").document(receiver_id).update({
            "incoming_requests": firestore.ArrayUnion([receiver_request])
        })

        return {"message": "Friend request sent."}
    except Exception:
        return {"message": "An error has occured."}
    
def send_love_request(sender_id, match_id):
    db = get_firestore_client()
    try:
        match_doc = db.collection("users").document(match_id).get()
        if match_doc.exists:
            match_data = match_doc.to_dict()
            lovers = match_data.get("lover", [])
            if lovers:
                return {"message": "User already has a lover."}
        else:
            return {"message": "Match user not found."}
        user_doc = db.collection("users").document(sender_id).get()
        user_match = user_doc.to_dict()
        lovers = user_match.get("lover", [])
        if lovers:
            return {"message": "You cheat!!!"}
        
        sender_request = {"id": match_id, "role": "L"}
        match_request = {"id": sender_id, "role": "L"}

        db.collection("users").document(sender_id).update({
            "outgoing_requests": firestore.ArrayUnion([sender_request])
        })

        db.collection("users").document(match_id).update({
            "incoming_requests": firestore.ArrayUnion([match_request])
        })

        return {"message": "Love request sent."}
    except Exception:
        return {"message": "An error has occured."}

def request_response(receiver_id, sender_id, role, decision):
    db = get_firestore_client()
    try:
        if(decision == 1):
            if(role == "F"):
                db.collection("users").document(receiver_id).update({
                    "incoming_requests": firestore.ArrayRemove([{"id": sender_id, "role": "F"}]),
                    "friends": firestore.ArrayUnion([sender_id])
                })

                db.collection("users").document(sender_id).update({
                    "outgoing_requests": firestore.ArrayRemove([{"id": receiver_id, "role": "F"}]),
                    "friends": firestore.ArrayUnion([receiver_id])
                })

                return {"message": "Friend request accepted."}
            elif (role == "L"):
                db.collection("users").document(receiver_id).update({
                    "incoming_requests": firestore.ArrayRemove([{"id": sender_id, "role": "L"}]),
                    "lover": sender_id
                })

                db.collection("users").document(sender_id).update({
                    "outgoing_requests": firestore.ArrayRemove([{"id": receiver_id, "role": "L"}]),
                    "lover": receiver_id
                })

                return {"message": "Love request accepted."}
            else:
                return {"message": "Invalid role."}
        else:
            db.collection("users").document(receiver_id).update({
                "incoming_requests": firestore.ArrayRemove([{"id": sender_id, "role": role}]),
            })

            db.collection("users").document(sender_id).update({
                "outgoing_requests": firestore.ArrayRemove([{"id": receiver_id, "role": role}]),
            })

            return {"message": "Request rejected."}
    except:
        return {"message": "An error has occured."}
    
def unfriend_user(user_id, friend_id):
    db = get_firestore_client()
    try:
        db.collection("users").document(user_id).update({
            "friends": firestore.ArrayRemove([friend_id])
        })

        db.collection("users").document(friend_id).update({
            "friends": firestore.ArrayRemove([user_id])
        })

        return {"message": "success"}
    except:
        return {"message": "An error has occured."}

