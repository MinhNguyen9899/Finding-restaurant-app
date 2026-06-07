from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models.favorite import Favorite
from backend.models.restaurant import Restaurant
from backend.schemas.favorite import FavoriteResponse
from backend.auth.dependencies import get_current_user
import uuid

router = APIRouter(prefix="/favorites", tags=["favorites"])

# tạo session DB
@router.post("/{restaurant_id}", response_model=FavoriteResponse)
def add_favorite(restaurant_id: str, db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    restaurant = db.query(Restaurant).filter(Restaurant.restaurant_id == restaurant_id).first()
    
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")
    
    existing_favorite = db.query(Favorite).filter(Favorite.user_id == current_user["user_id"], Favorite.restaurant_id == restaurant_id).first()

    if existing_favorite:
        raise HTTPException(status_code=400, detail="Restaurant already in favorites")

    new_favorite = Favorite(
        user_id=current_user["user_id"],
        restaurant_id=restaurant_id
    )

    db.add(new_favorite)
    db.commit()
    db.refresh(new_favorite)

    return new_favorite

# API lấy danh sách quán yêu thích của người dùng
@router.get("/", response_model=list[FavoriteResponse])
def get_favorites(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    favorites = db.query(Favorite).filter(Favorite.user_id == current_user["user_id"]).all()
    return favorites


@router.delete("/{restaurant_id}")
def remove_favorite(restaurant_id: str, db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    favorite = db.query(Favorite).filter(Favorite.user_id == current_user["user_id"], Favorite.restaurant_id == restaurant_id).first()

    if not favorite:
        raise HTTPException(status_code=404, detail="Favorite not found")

    db.delete(favorite)
    db.commit()

    return {"message": "Favorite removed successfully"}

