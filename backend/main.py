from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from models.user import User
from models.restaurant import Restaurant
from models.category import Category
from models.area import Area
from models.review import Review
from models.favorite import Favorite
from models.contribution import Contribution
from models.search_history import SearchHistory

from routers.restaurant import router as restaurant_router
from routers.auth import router as auth_router
from routers.favorite import router as favorite_router
from routers.review import router as review_router
from routers.search_history import router as search_history_router

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
