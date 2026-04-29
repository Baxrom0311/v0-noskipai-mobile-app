# NoSkipAI - Medication Adherence App

A Flutter mobile application that helps users manage their medication adherence with AI-powered chat support and visual reminders.

## Features

- **Authentication**: Secure JWT-based login and registration
- **Medication Management**: Add and track multiple medications with custom schedules
- **Adherence Tracking**: Monitor medication adherence with visual progress indicators
- **AI Chat Assistant**: Get personalized medication advice and adherence tips
- **Multi-language Support**: English, Uzbek, and Russian support
- **Glassmorphic UI**: Modern, beautiful interface with glassmorphic design components
- **Dark Mode**: Optimized dark theme for comfortable viewing

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   ├── app_theme.dart       # Theme configuration
│   ├── app_localization.dart # Localization strings
│   └── router.dart          # Route configuration
├── models/
│   ├── user.dart
│   ├── medication.dart
│   ├── medication_adherence.dart
│   └── chat_message.dart
├── services/
│   └── api_service.dart     # API client with JWT auth
├── providers/
│   ├── auth_provider.dart
│   ├── medication_provider.dart
│   ├── chat_provider.dart
│   ├── adherence_provider.dart
│   └── localization_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── medications/
│   │   └── medications_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── glassmorphic_container.dart
    ├── gradient_card.dart
    ├── adherence_progress_card.dart
    ├── medication_tile.dart
    └── bottom_nav_bar.dart
```

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client with JWT interceptor
- **shared_preferences**: Local storage
- **go_router**: Navigation
- **google_fonts**: Custom fonts
- **camera**: Photo capture for visual DOT
- **flutter_tts**: Text-to-speech for accessibility
- **intl**: Localization support

## Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- iOS 11+ or Android 5+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd noskipai
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## API Integration

The app connects to a backend API at `https://api.noskipai.dev/v1` with the following endpoints:

- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /medications` - Fetch user medications
- `POST /medications` - Add new medication
- `POST /adherence` - Log medication adherence
- `GET /adherence/history` - Get adherence history
- `POST /chat` - Send message to AI assistant
- `GET /chat/history` - Fetch chat history

## Configuration

Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://api.noskipai.dev/v1';
```

## Features in Development

- [x] Authentication (Login/Register)
- [x] Medication management
- [x] Adherence tracking
- [x] AI Chat with risk scoring
- [ ] Push notifications
- [ ] Wearable integration
- [ ] Advanced analytics
- [ ] Multi-device sync

## License

This project is licensed under the MIT License - see the LICENSE file for details.
