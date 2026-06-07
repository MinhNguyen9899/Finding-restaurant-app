from database import engine, Base

# import toàn bộ model
from models.user import User
from models.restaurant import Restaurant
from models.category import Category
from models.area import Area
from models.review import Review
from models.favorite import Favorite
from models.contribution import Contribution
from models.search_history import SearchHistory

Base.metadata.create_all(bind=engine)

print("Tables created successfully!")