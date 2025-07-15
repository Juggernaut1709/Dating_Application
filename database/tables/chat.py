import datetime
from sqlalchemy import Column, Integer, String, DateTime
from database.database import Base

class Chat(Base):
    __tablename__ = "chats"
    
    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(String, nullable=False)
    user2_id = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)