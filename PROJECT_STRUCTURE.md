# Project Structure Documentation

## Core Application Files

### Entry Point
- **`lib/main.dart`** - App entry point with Riverpod ProviderScope and Material routing

### Configuration
- **`lib/config/app_theme.dart`** - Theme definition (colors, typography, component styles)
- **`lib/config/app_localization.dart`** - Multi-language strings (English, Uzbek, Russian)
- **`lib/config/router.dart`** - Go Router configuration and route definitions
- **`lib/config/app_config.dart`** - App constants and feature flags

## Models (Data Classes)

Located in `lib/models/`:
- **`user.dart`** - User model with authentication info
- **`medication.dart`** - Medication schedule and details
- **`medication_adherence.dart`** - Adherence tracking records
- **`chat_message.dart`** - AI chat messages with risk scoring

## Services

Located in `lib/services/`:
- **`api_service.dart`** - HTTP client with JWT authentication interceptor
- **`camera_service.dart`** - Camera initialization and photo capture
- **`tts_service.dart`** - Text-to-speech for accessibility

## State Management (Riverpod Providers)

Located in `lib/providers/`:
- **`auth_provider.dart`** - Authentication state (login, register, logout)
- **`medication_provider.dart`** - Medication list and operations
- **`chat_provider.dart`** - Chat messages and AI interaction
- **`adherence_provider.dart`** - Adherence tracking and history
- **`localization_provider.dart`** - Current language selection
- **`services_provider.dart`** - Camera and TTS service instances

## UI Screens

### Authentication
- **`lib/screens/auth/login_screen.dart`** - Login with email/password
- **`lib/screens/auth/register_screen.dart`** - Registration with validation

### Main App
- **`lib/screens/dashboard/dashboard_screen.dart`** - Home page with adherence stats and today's meds
- **`lib/screens/medications/medications_screen.dart`** - Medication management with add/edit
- **`lib/screens/chat/chat_screen.dart`** - AI chat interface with risk scoring display
- **`lib/screens/settings/settings_screen.dart`** - User preferences, language, notifications

### Features
- **`lib/screens/camera/dot_camera_screen.dart`** - Directly Observed Therapy camera with overlay

## UI Components (Widgets)

Located in `lib/widgets/`:
- **`glassmorphic_container.dart`** - Reusable glassmorphic backdrop effect container
- **`gradient_card.dart`** - Gradient-styled card component
- **`adherence_progress_card.dart`** - Progress indicator for adherence rates
- **`medication_tile.dart`** - List item for medications with actions
- **`bottom_nav_bar.dart`** - Bottom navigation with 4 main sections

## Project Configuration

- **`pubspec.yaml`** - Dependencies and asset declarations
- **`.gitignore`** - Git ignore rules for Flutter projects
- **`README.md`** - Project overview and features
- **`INSTALLATION.md`** - Setup and installation guide

## Key Features by File

### Authentication Flow
1. User enters credentials on `login_screen.dart` or `register_screen.dart`
2. `auth_provider.dart` handles API calls via `api_service.dart`
3. JWT token stored in `shared_preferences`
4. Token automatically included in all API requests via interceptor

### Medication Management
1. User adds medication on `medications_screen.dart`
2. `medication_provider.dart` manages state and API calls
3. `dashboard_screen.dart` displays today's medications
4. User can mark as taken/missed via `medication_tile.dart`

### AI Chat
1. User types message in `chat_screen.dart`
2. `chat_provider.dart` sends to API
3. Response displayed with risk score if applicable
4. Glassmorphic bubbles for visual hierarchy

### Camera Integration
1. User initiates DOT photo capture
2. `camera_service.dart` manages camera lifecycle
3. `dot_camera_screen.dart` displays preview with overlay
4. Photo confirmation dialog before upload

### Localization
1. User selects language in `settings_screen.dart`
2. `localization_provider.dart` saves preference
3. `app_localization.dart` provides translated strings
4. Real-time language switching across all screens

## Data Flow Architecture

```
UI Screens
    ↓
Riverpod Providers (State)
    ↓
Services (API, Camera, TTS)
    ↓
Backend API / Device Services
```

## Color Palette

- **Primary**: Emerald Green (#10B981)
- **Accent**: Cyan (#06B6D4)
- **Background**: Slate 900 (#0F172A)
- **Card**: Slate 800 (#1E293B)
- **Text Primary**: White
- **Text Secondary**: Slate 300
- **Border**: Slate 700

## Responsive Design

- Mobile-first approach with responsive layouts
- Bottom navigation on mobile
- Glassmorphic containers scale with screen size
- Text respects accessibility standards (min 14px)

## Performance Considerations

- Lazy loading of screens via Go Router
- Riverpod state caching to minimize API calls
- Image caching for camera photos
- Efficient database queries with filtered history
- Hot reload support for development

## Future Enhancements

- Push notification system
- Local SQLite database for offline support
- Wearable integration (smartwatch reminders)
- Biometric authentication
- Advanced analytics dashboard
- Caregiver support features
- Medication interaction warnings
