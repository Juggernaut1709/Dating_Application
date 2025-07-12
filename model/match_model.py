import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

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