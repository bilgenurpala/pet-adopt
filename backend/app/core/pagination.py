from fastapi import Query

class PaginationParams:
    def __init__(
        self,
        page: int = Query(1, ge=1),
        size: int = Query(10, ge=1, le=100),
    ):
        self.page = page
        self.size = size
    
    @property
    def offset(self) -> int:
        return(self.page - 1) * self.size
    

def paginate(items: list, total: int, params: PaginationParams) -> dict:
    return {"items": items, "page": params.page, "size": params.size, "total": total}