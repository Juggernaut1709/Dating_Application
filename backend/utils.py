from database.tables.chat import Chat
from sqlalchemy.orm import Session

def get_or_create_chat(db: Session, user1: str, user2: str) -> int:
    chat = db.query(Chat).filter(
        ((Chat.user1_id == user1) & (Chat.user2_id == user2)) |
        ((Chat.user1_id == user2) & (Chat.user2_id == user1))
    ).first()

    if chat:
        return chat.id

    new_chat = Chat(user1_id=user1, user2_id=user2)
    db.add(new_chat)
    db.commit()
    db.refresh(new_chat)
    return new_chat.id