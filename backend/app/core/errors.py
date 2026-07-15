from http import HTTPStatus

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

def problem_response(request: Request, status: int, detail: str) -> JSONResponse:
    return JSONResponse(
        status_code = status,
        content={
            "type": "about:blank",
            "title": HTTPStatus(status).phrase,
            "status": status,
            "detail": detail,
            "instance": request.url.path,
        },
        media_type="application/problem+json",
    )

async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return problem_response(request, exc.status_code, str(exc.detail))

def add_exception_handlers(app: FastAPI) -> None:
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    first = exc.errors()[0]
    field = ".".join(str(x) for x in first["loc"])
    return problem_response(request, 422, f"{field}: {first['msg']}")

async def unhandled_exception_handler(request: Request, exc: Exception):
    return problem_response(request, 500, "An unexpected error occurred.")