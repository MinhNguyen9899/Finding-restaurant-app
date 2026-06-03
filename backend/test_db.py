# import model
from models.user import User
from models.restaurant import Restaurant
from models.category import Category
from models.area import Area
from models.review import Review
from models.favorite import Favorite
from models.contribution import Contribution

# import session DB
from database import SessionLocal

# tạo kết nối DB
db = SessionLocal()

try:
    # query tất cả restaurant
    data = db.query(Restaurant).all()

    # nếu không có dữ liệu
    if not data:
        print("No restaurants found.")

    # in dữ liệu
    for r in data:
        print(r. restaurant_id, "-" ,r.restaurant_name )

except Exception as e:
    print("ERROR:", e)

finally:
    db.close()