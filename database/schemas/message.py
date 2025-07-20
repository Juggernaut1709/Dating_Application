from pydantic import BaseModel
from datetime import datetime

class Message(BaseModel):
    id: int
    chat_id: int
    sender_id: str
    receiver_id: str
    message: str
    timestamp: datetime

    class Config:
        from_attributes = True