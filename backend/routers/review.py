from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.database import get_db

from backend.models.review import Review
from backend.models.restaurant import Restaurant
from backend.schemas.review import ReviewCreate, ReviewResponse
from backend.auth.dependencies import get_current_user

router = APIRouter(prefix="/reviews", tags=["reviews"])

# API tạo đánh giá cho quán
@router.post("/{restaurant_id}")
def create_review(
    restaurant_id: str,
    review: ReviewCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    restaurant = db.query(Restaurant).filter(Restaurant.restaurant_id == restaurant_id).first()

    
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")

    user_id = current_user["user_id"]

    existing_review = db.query(Review).filter(
        Review.user_id == user_id,
        Review.restaurant_id == restaurant_id
    ).first()

    if existing_review:
        raise HTTPException(
            status_code=400,
            detail="You have already reviewed this restaurant"
        )

    new_review = Review(
        user_id=user_id,
        restaurant_id=restaurant_id,
        rating=review.rating,
        comment=review.comment
    )

    db.add(new_review)
    db.commit()
    db.refresh(new_review)

    reviews = db.query(Review).filter(Review.restaurant_id == restaurant_id).all()
    restaurant.review_count = len(reviews)
    restaurant.average_rating = sum(r.rating for r in reviews) / len(reviews) if reviews else 0


    db.commit()
    db.refresh(restaurant)

    return new_review

# API lấy danh sách đánh giá của quán
@router.get("/restaurants/{restaurant_id}", response_model=list[ReviewResponse])
def get_reviews(restaurant_id: str, db: Session = Depends(get_db)):
    reviews = db.query(Review).filter(Review.restaurant_id == restaurant_id).all()
    return reviews

# API xóa đánh giá
@router.delete("/{review_id}")
def delete_review(review_id: str, db: Session = Depends(get_db),):
    review = db.query(Review).filter(Review.review_id == review_id).first()

    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    restaurant = db.query(Restaurant).filter(Restaurant.restaurant_id == review.restaurant_id).first()

    db.delete(review)
    db.commit()

    reviews = db.query(Review).filter(Review.restaurant_id == restaurant.restaurant_id).all()
    restaurant.review_count = len(reviews)
    if len(reviews) > 0:
        restaurant.average_rating = sum(r.rating for r in reviews) / len(reviews)
    else:
        restaurant.average_rating = 0
    db.commit()

    return {"message": "Review deleted successfully"}
