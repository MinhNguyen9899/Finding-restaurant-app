from sqlalchemy.orm import Session
from backend.models.restaurant import Restaurant
from backend.models.category import Category
import uuid

# CRUD cho Restaurant
def get_all_restaurants(db: Session,skip: int = 0, limit: int = 20):
    return db.query(Restaurant).offset(skip).limit(limit).all()

# Tìm kiếm quán theo tên
def search_restaurants_by_name(db: Session, query: str, skip: int = 0, limit: int = 20):
    return db.query(Restaurant).filter(
        Restaurant.restaurant_name.ilike(f"%{query.strip()}%")
    ).offset(skip).limit(limit).all()

# Lấy quán theo ID
def get_restaurant_by_id(db: Session, restaurant_id: str):
    return db.query(Restaurant).filter(Restaurant.restaurant_id == restaurant_id).first()

# Lấy quán theo danh mục
def get_restaurants_by_category(db: Session, category_id: int):
    return db.query(Restaurant).filter(Restaurant.categories.any(category_id=category_id)).all()

# Lấy quán theo khu vực
def get_restaurants_by_area(db: Session, area_id: int):
    return db.query(Restaurant).filter(Restaurant.area_id == area_id).all()

# Lấy quán được đánh giá cao nhất
def get_top_rated_restaurants(db: Session):
    return db.query(Restaurant).order_by(Restaurant.average_rating.desc()).limit(10).all()

# Tạo quán mới
def create_restaurant(db: Session, data):
    new_restaurant = Restaurant(
        restaurant_id=str(uuid.uuid4()),
        restaurant_name=data.restaurant_name,
        address=data.address,
        phone=data.phone,
        description=data.description,
        latitude=data.latitude,
        longitude=data.longitude,
        price_range=data.price_range,
        status=data.status,
        area_id=data.area_id
    )

    db.add(new_restaurant)

    if data.category_ids:
        categories = db.query(Category).filter(Category.category_id.in_(data.category_ids)).all()
        if data.category_ids and len(categories) != len(data.category_ids):
            raise ValueError("One or mỏe category_ids are invalid")
        new_restaurant.categories = categories

    db.commit()
    db.refresh(new_restaurant)
    
    return new_restaurant

# Cập nhật thông tin quán
def update_restaurant(db: Session, restaurant: Restaurant, data):
    if data.restaurant_name is not None:
        restaurant.restaurant_name = data.restaurant_name
    if data.address is not None:
        restaurant.address = data.address
    if data.phone is not None:
        restaurant.phone = data.phone
    if data.description is not None:
        restaurant.description = data.description
    if data.latitude is not None:
        restaurant.latitude = data.latitude
    if data.longitude is not None:
        restaurant.longitude = data.longitude
    if data.price_range is not None:
        restaurant.price_range = data.price_range
    if data.status is not None:
        restaurant.status = data.status
    if data.area_id is not None:
        restaurant.area_id = data.area_id

    if data.category_ids is not None:
        categories = db.query(Category).filter(Category.category_id.in_(data.category_ids)).all()
        restaurant.categories = categories

    db.commit()
    db.refresh(restaurant)

    return restaurant


# Xóa quán
def delete_restaurant(db: Session, restaurant: Restaurant):
    db.delete(restaurant)
    db.commit()