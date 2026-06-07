from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models.search_history import SearchHistory
from backend.schemas.search_history import SearchHistoryCreate, SearchHistoryResponse
from backend.auth.dependencies import get_current_user

router = APIRouter(prefix="/search_history", tags=["search_history"])

@router.get("/", response_model=list[SearchHistoryResponse])
def get_search_history(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    history = db.query(SearchHistory).filter(SearchHistory.user_id == current_user["user_id"]).order_by(SearchHistory.seached_at.desc()).limit(20).all()
    return history
