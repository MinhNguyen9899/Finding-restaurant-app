from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from backend.models.user import User
from backend.models.restaurant import Restaurant
from backend.models.category import Category
from backend.models.area import Area
from backend.models.review import Review
from backend.models.favorite import Favorite
from backend.models.contribution import Contribution
from backend.models.search_history import SearchHistory

from backend.routers.restaurant import router as restaurant_router
from backend.routers.auth import router as auth_router
from backend.routers.favorite import router as favorite_router
from backend.routers.review import router as review_router
from backend.routers.search_history import router as search_history_router

app = FastAPI()

app.include_router(auth_router)
app.include_router(restaurant_router)
app.include_router(search_history_router)
app.include_router(review_router)
app.include_router(favorite_router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/")
def root():
    return {
        "success": True,
        "message": "Restaurant API is running"
    }

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"success": False,
                "message": "Validation Error",
                "data": exc.errors()}
    )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"success": False,
                 "message": exc.detail}
    )

@app.exception_handler(Exception)
async def server_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"success": False,
                 "message": "Internal Server Error"}
    )
