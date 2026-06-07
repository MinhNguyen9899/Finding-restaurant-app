from backend.database import engine, Base

# import toàn bộ model
from backend.models.user import User
from backend.models.restaurant import Restaurant
from backend.models.category import Category
from backend.models.area import Area
from backend.models.review import Review
from backend.models.favorite import Favorite
from backend.models.contribution import Contribution
from backend.models.search_history import SearchHistory

Base.metadata.create_all(bind=engine)

print("Tables created successfully!")