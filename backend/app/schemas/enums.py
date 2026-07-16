from enum import Enum

class Species(str, Enum):
    cat = "cat"
    dog = "dog"
    bird = "bird"
    fish = "fish"
    other = "other"

class Gender(str, Enum):
    male = "male"
    female = "female"

class Size(str, Enum):
    small = "small"
    medium = "medium"
    large = "large"

class EnergyLevel(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"

class PetStatus(str, Enum):
    available = "available"
    pending = "pending"
    sold = "sold"

class OrderStatus(str, Enum):
    placed = "placed"
    approved = "approved"
    delivered = "delivered"

class Role(str, Enum):
    user = "user"
    admin = "admin"
