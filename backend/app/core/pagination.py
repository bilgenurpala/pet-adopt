from fastapi import Query


class PaginationParams:
    def __init__(
        self,
        page: int = Query(1, ge=1),
        per_page: int = Query(10, ge=1, le=100),
    ):
        self.page = page
        self.per_page = per_page

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.per_page


def paginate(items: list, total: int, params: PaginationParams) -> dict:
    return {
        "items": items,
        "page": params.page,
        "per_page": params.per_page,
        "total": total,
    }
