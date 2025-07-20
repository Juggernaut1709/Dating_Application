from database_str import engine, Base
from tables.chat import Chat
from database.tables.message import Message

print("🔧 Creating tables in the database...")
Base.metadata.create_all(bind=engine)
print("✅ Done!")