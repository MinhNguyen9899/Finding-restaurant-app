from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from backend.database import SessionLocal

from backend.auth.dependencies import get_current_user

from backend.models.restaurant import Restaurant
from backend.models.area import Area
from backend.models.category import Category
from backend.models.search_history import SearchHistory

from backend.schemas.restaurant import RestaurantCreate, RestaurantUpdate, RestaurantResponse
from backend.crud.restaurant import (
    get_restaurant_by_id,
    create_restaurant as create_restaurant_crud,
    delete_restaurant as delete_restaurant_crud,
    update_restaurant as update_restaurant_crud,
    get_restaurants_by_category as get_restaurants_by_category_crud,
    get_restaurants_by_area as get_restaurants_by_area_crud,
    get_top_rated_restaurants as get_top_rated_restaurants_crud
    )

from utils.response import success_response

from enum import Enum
from math import radians, cos, sin, asin, sqrt

router = APIRouter(tags=["restaurants"])

class SortBy(str, Enum):
    relevance = "relevance"
    rating = "rating"
    reviews = "reviews"

# tạo session DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Hàm tính khoảng cách giữa hai điểm trên bản đồ
def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Radius of Earth in kilometers

    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    distance = R * c
    return distance

# API lấy danh sách quán gần vị trí người dùng
@router.get('/restaurants/nearby')
def get_nearby_restaurants(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    restaurants = db.query(Restaurant).filter(
        Restaurant.latitude.isnot(None),
        Restaurant.longitude.isnot(None)
    ).all()

    nearby_restaurants = []

    for r in restaurants:
        distance = calculate_distance(latitude, longitude, r.latitude, r.longitude)
        nearby_restaurants.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "address": r.address,
            "average_rating": r.average_rating,
            "distance_km": round(distance, 2)
            })      

    nearby_restaurants.sort(key=lambda x: x["distance_km"])

    return {"success": True,
            "message": "Nearby restaurants retrieved successfully",
            "data": nearby_restaurants[:limit]}

# API lấy danh sách quán
@router.get("/restaurants")
def get_restaurants(page: int = Query(1, ge=1),
                    limit: int = Query(20, ge=1, le=100),
                    min_rating: float = Query(0.0, ge=0.0, le=5.0),

                    keyword: str | None = None,
                    category_id: int | None = None,
                    area_id: int | None = None,

                    sort_by: SortBy = Query(SortBy.relevance),
                    db: Session = Depends(get_db)):
    query = db.query(Restaurant)

    query = query.filter(Restaurant.average_rating >= min_rating)

    if keyword:
        query = query.filter(
            Restaurant.restaurant_name.ilike(
                f"%{keyword.strip()}%"
            )
        )

    if category_id:
        query = (
            query
                .join(Restaurant.categories)
                .filter(Category.category_id == category_id)
        )

    if area_id:
        query = query.filter(
            Restaurant.area_id == area_id
        )

    if sort_by == SortBy.rating:
        query = query.order_by(
            Restaurant.average_rating.desc()
        )
    elif sort_by == SortBy.reviews:
        query = query.order_by(
            Restaurant.review_count.desc()
        )
    else:
        query = query.order_by(
            Restaurant.restaurant_name.asc()
        )

    total = query.count()

    skip = (page - 1) * limit
    
    restaurants = query.offset(skip).limit(limit).all()

    result= []

    for r in restaurants:
        result.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "address": r.address,
            "phone": r.phone,
            "average_rating": r.average_rating,
            "review_count": r.review_count,
            "category_ids": [str(c.category_id) for c in r.categories],
            "area_id": r.area_id
        })
    return {"success": True,
            "message": "Restaurants retrieved successfully",
            "data": result,
            "pagination": {
                "page": page,
                "limit": limit,
                "total": total
            }
        }

# API tìm kiếm quán
@router.get("/restaurants/search")
def search_restaurants(
    query: str = Query(...),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    min_rating: float = Query(0.0, ge=0.0, le=5.0),
    sort_by: SortBy = Query(SortBy.relevance),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    skip = (page - 1) * limit

    query = query.strip()
    if not query:
        raise HTTPException(
            status_code=400,
            detail="Query cannot be empty"
        )

    existing_history = db.query(SearchHistory).filter(
        SearchHistory.user_id == current_user["user_id"],
        SearchHistory.keyword.ilike(f"%{query}%")
    ).first()

    if existing_history:
        db.delete(existing_history)
        
    history = SearchHistory(
        user_id=current_user["user_id"],
        keyword=query
    )
    db.add(history)
    try:
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")

    restaurants_query = db.query(Restaurant).filter(
        Restaurant.restaurant_name.ilike(f"%{query}%"),
        Restaurant.average_rating >= min_rating
    )

    if sort_by == SortBy.rating:
        restaurants_query = restaurants_query.order_by(Restaurant.average_rating.desc())
    elif sort_by == SortBy.reviews:
        restaurants_query = restaurants_query.order_by(Restaurant.review_count.desc())
    else:
        restaurants_query = restaurants_query.order_by(Restaurant.restaurant_name.asc())

    total = restaurants_query.count()

    restaurants = restaurants_query.offset(skip).limit(limit).all()

    if not restaurants:
        return {"success": False,
                "message": "No restaurants found",
                "data": []}

    result = []
    for r in restaurants:
        result.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "address": r.address,
        })
    return {"success": True,
            "message": "Restaurants found",
            "data": result,
            "pagination": {
                "page": page,
                "limit": limit,
                "total": total
            }
        }

@router.get("/restaurants/category/{category_id}")
def get_restaurants_by_category(category_id: int, db: Session = Depends(get_db)):
    restaurants = get_restaurants_by_category_crud(db, category_id)

    if not restaurants:
        raise HTTPException(
            status_code=404,
            detail="No restaurants found"
        )

    result = []
    for r in restaurants:
        result.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "address": r.address,
        })
    return success_response(
        message="Restaurants retrived successfully",
        data=result
    )

# API lấy chi tiết quán
@router.get("/restaurants/{restaurant_id}", response_model=RestaurantResponse)
def get_restaurant_details(restaurant_id: str, db: Session = Depends(get_db)):
    restaurant = db.query(Restaurant).filter(
        Restaurant.restaurant_id == restaurant_id
    ).first()

    if not restaurant:
        raise HTTPException(
            status_code=404,
            detail="Restaurant not found")

    return {
        "restaurant_id": restaurant.restaurant_id,
        "restaurant_name": restaurant.restaurant_name,
        "address": restaurant.address,
        "phone": restaurant.phone,
        "description": restaurant.description,
        "latitude": restaurant.latitude,
        "longitude": restaurant.longitude,
        "price_range": restaurant.price_range,
        "status": restaurant.status.value if restaurant.status else None,
        "average_rating": restaurant.average_rating,
        "review_count": restaurant.review_count,
        "category_ids": [str(c.category_id) for c in restaurant.categories],
        "area_id": restaurant.area_id
    }

# API tạo quán mới
@router.post("/restaurants")
def create_restaurant(
    data: RestaurantCreate,
    db: Session = Depends(get_db)
):
    try:
        new_restaurant = create_restaurant_crud(db, data)
    
        return {"success": True,
            "message": "Restaurant created successfully",
            "data": new_restaurant}

    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")

# API xóa quán
@router.delete("/restaurants/{restaurant_id}")
def delete_restaurant(restaurant_id: str, db: Session = Depends(get_db)):
    restaurant = get_restaurant_by_id(db, restaurant_id)

    if not restaurant:
        raise HTTPException(
            status_code=404,
            detail="Restaurant not found")
    try:
        delete_restaurant_crud(db, restaurant)

    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")

    return success_response(
        message="Restaurant deleted successfully"
    )

# API cập nhật thông tin quán
@router.put ("/restaurants/{restaurant_id}")
def update_restaurant(
    restaurant_id: str,
    data: RestaurantUpdate,
    db: Session = Depends(get_db)
):
    restaurant = get_restaurant_by_id(db, restaurant_id)

    if not restaurant:
        raise HTTPException(
            status_code=404,
            detail="Restaurant not found")

    try:
        updated_restaurant = update_restaurant_crud(db, restaurant, data)

    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")

    return {"success": True,
            "message": "Restaurant updated successfully",
            "data": updated_restaurant}

# API lấy danh sách danh mục
@router.get('/categories')
def get_categories(db: Session = Depends(get_db)):
    categories = db.query(Category).all()
    result = []
    for c in categories:
        result.append({
            "category_id": c.category_id,
            "category_name": c.category_name
        })
    return success_response(
        message="Categories retrived successfully",
        data= result
    )

# API lấy danh sách khu vực
@router.get('/areas')
def get_areas(db: Session = Depends(get_db)):
    areas = db.query(Area).all()
    result = []
    for a in areas:
        result.append({
            "area_id": a.area_id,
            "area_name": a.area_name,
            "parent_area_id": a.parent_area_id
        })
    return success_response(
        message="Areas retrived successfully",
        data= result
    )

# API lấy danh sách quán theo khu vực
@router.get('/restaurants/area/{area_id}')
def get_restaurants_by_area(area_id: int, db: Session = Depends(get_db)):
    restaurants = get_restaurants_by_area_crud(db, area_id)

    if not restaurants:
        raise HTTPException(
            status_code=404,
            detail="No restaurants found"
        )

    result = []
    for r in restaurants:
        result.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "address": r.address,
        })
    return success_response(
        message="Restaurants by area retrived successfully",
        data= result
    )

# API lấy danh sách quán theo đánh giá cao nhất
@router.get('/restaurants/top-rated')
def get_top_rated_restaurants(db: Session = Depends(get_db)):
    restaurants = get_top_rated_restaurants_crud(db)

    result = []
    for r in restaurants:
        result.append({
            "restaurant_id": r.restaurant_id,
            "restaurant_name": r.restaurant_name,
            "average_rating": r.average_rating,
            "review_count": r.review_count
        })
    return success_response(
        message="Restaurants by top-rated retrived successfully",
        data= result
    )

# API tính khoảng cách từ vị trí người dùng đến quán
@router.get("/restaurants/{restaurant_id}/distance")
def get_distance_to_restaurant(
    restaurant_id: str,
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    db: Session = Depends(get_db)
):
    restaurant = get_restaurant_by_id(db, restaurant_id)

    if not restaurant:
        raise HTTPException(
            status_code=404,
            detail="Restaurant not found")

    if restaurant.latitude is None or restaurant.longitude is None:
        raise HTTPException(
            status_code=400,
            detail="Restaurant does not have location data")

    distance = calculate_distance(latitude, longitude, restaurant.latitude, restaurant.longitude)

    return {"success": True,
            "message": "Distance calculated successfully",
            "data": {
                "restaurant_id": restaurant.restaurant_id,
                "restaurant_name": restaurant.restaurant_name,
                "distance_km": round(distance, 2)
            }}

# API lấy lịch sử tìm kiếm của người dùng
@router.get("/search-history")
def get_search_history(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    history = db.query(SearchHistory).filter(SearchHistory.user_id == current_user["user_id"]).order_by(SearchHistory.searched_at.desc()).all()
    result = []
    for h in history:
        result.append({
            "history_id": h.history_id,
            "keyword": h.keyword,
            "searched_at": h.searched_at.isoformat() if h.searched_at else None
        })
    return {"success": True,
            "message": "Search history retrieved successfully",
            "data": result}

# API xóa lịch sử tìm kiếm của người dùng
@router.delete("/search-history/{history_id}")
def delete_search_history(history_id: str, db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    history = db.query(SearchHistory).filter(SearchHistory.history_id == history_id, SearchHistory.user_id == current_user["user_id"]).first()
    if not history:
        raise HTTPException(
            status_code=404,
            detail="Search history not found")
    
    db.delete(history)
    try: 
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")

    return {"success": True,
            "message": "Search history deleted successfully"}
