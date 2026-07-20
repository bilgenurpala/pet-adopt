# Pet Adoption Frontend

A Flutter application for a modern Pet Adoption platform.

This project provides a responsive user interface for browsing pets, viewing pet details, managing favorites, chatting with an AI assistant, and integrating with a backend REST API.

---

# Features

- Browse available pets
- Search pets by name or breed
- Filter pets by species
- View pet details
- Add or remove favorite pets
- Responsive layout for mobile, tablet and desktop
- AI Chat interface
- Repository-based architecture
- Provider state management
- Backend-ready API layer

---

# Project Structure

```
lib/
│
├── core/
│
├── features/
│   ├── pets/
│   ├── ai/
│   ├── profile/
│   └── settings/
│
├── providers/
│
├── repositories/
│
└── services/
```

---

# Getting Started

Install dependencies

```bash
flutter pub get
```

Run the application

```bash
flutter run
```

Analyze the project

```bash
flutter analyze
```

Run all tests

```bash
flutter test
```

---

# Testing

Current automated tests include:

- Widget Tests
  - Application startup
  - Home Page
  - Favorites Page
  - Pet Detail Page
  - Navigation

- Provider Tests
  - FavoritesProvider
  - PetProvider

- Repository Tests
  - PetRepository

---

# Architecture

This project follows a layered architecture.

```
UI
│
▼
Provider
│
▼
Repository
│
▼
API Service
│
▼
Backend
```

The architecture allows the frontend to switch between mock data and backend APIs with minimal changes.

---

# Current Status

Completed

- Responsive UI
- Favorites functionality
- Search and filtering
- Provider architecture
- Repository layer
- API service preparation
- Widget tests
- Provider tests
- Repository tests

In Progress

- Authentication integration
- Backend API integration
- Production data flow

---

# Technologies

- Flutter
- Dart
- Provider
- Dio
- REST API

---

# License

This project was developed for the 2026 Internship Program.