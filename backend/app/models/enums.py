from enum import Enum


class Species(str, Enum):
    CAT = "cat"
    DOG = "dog"
    BIRD = "bird"
    FISH = "fish"
    OTHER = "other"


class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"


class Size(str, Enum):
    SMALL = "small"
    MEDIUM = "medium"
    LARGE = "large"


class EnergyLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class PetStatus(str, Enum):
    AVAILABLE = "available"
    PENDING = "pending"
    ADOPTED = "adopted"


class ApplicationStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    COMPLETED = "completed"


class Role(str, Enum):
    USER = "user"
    ADMIN = "admin"
