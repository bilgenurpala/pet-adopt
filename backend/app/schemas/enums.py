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
    adopted = "adopted" 

class ApplicationStatus(str, Enum):  
    pending = "pending"
    approved = "approved"
    rejected = "rejected"
    completed = "completed"

class Role(str, Enum):
    user = "user"
    admin = "admin"
