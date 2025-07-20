from pydantic import BaseModel
from datetime import date

class Chat(BaseModel):
    id: int
    user1_id: str
    user2_id: str
    created_at: date

    class Config:
        from_attributes = True