import os
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from firebase_admin import firestore

from firebase_config import init_firebase
from dotenv import load_dotenv

load_dotenv()

# Initialize Firebase app
init_firebase()

# Get Firestore client
db = firestore.client()

def fetch_users_from_firestore():
    users_ref = db.collection('users')
    docs = users_ref.stream()

    users = {}
    for doc in docs:
        data = doc.to_dict()
        if 'onboarding_answers' in data and len(data['onboarding_answers']) == 20 and data['onboarding_answers'][0] is not -1:
            users[doc.id] = data['onboarding_answers']
    return users

def get_top_matches(base_user, user_data, top_n=2):
    if base_user not in user_data:
        return []

    user_ids = list(user_data.keys())
    vectors = np.array([user_data[uid] for uid in user_ids])
    base_vector = np.array(user_data[base_user]).reshape(1, -1)

    similarities = cosine_similarity(base_vector, vectors)[0]

    sim_scores = list(zip(user_ids, similarities))
    sim_scores = [pair for pair in sim_scores if pair[0] != base_user]
    sim_scores.sort(key=lambda x: x[1], reverse=True)

    return sim_scores[:top_n]