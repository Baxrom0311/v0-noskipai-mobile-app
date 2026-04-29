# Installation & Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter**: Version 3.0 or higher
- **Dart**: Version 3.0 or higher
- **Android Studio** or **Xcode** (for iOS development)
- **Git**
- **Visual Studio Code** or **Android Studio IDE**

### Install Flutter

1. Download Flutter from: https://flutter.dev/docs/get-started/install
2. Extract the Flutter SDK
3. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

4. Verify installation:
   ```bash
   flutter --version
   flutter doctor
   ```

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/noskipai.git
cd noskipai
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Get Dependencies with Build Runner (for code generation)

```bash
flutter pub run build_runner build
```

## Running the App

### Android

1. Connect an Android device or start an emulator:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Or run in release mode:
   ```bash
   flutter run --release
   ```

### iOS

1. Install iOS dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. Connect an iPhone or start the iOS Simulator:
   ```bash
   open -a Simulator
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. Or run in release mode:
   ```bash
   flutter run --release
   ```

## Environment Configuration

### 1. API Configuration

Update the API base URL in `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'https://your-api-domain.com/v1';
```

### 2. Camera Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture medication visuals</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select medication images</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for text-to-speech</string>
```

### 3. Build Configuration

For Android, update `android/app/build.gradle`:

```gradle
android {
    ...
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

For iOS, update `ios/Podfile`:

```ruby
platform :ios, '11.0'
```

## Troubleshooting

### Common Issues

**1. Gradle Build Fails**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**2. Pod Install Issues**
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

**3. Build Cache Issues**
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build
```

**4. Emulator not detected**
```bash
flutter emulators --launch <emulator_id>
# Wait for emulator to fully boot
flutter run
```

## Development Workflow

### Hot Reload

During development, use hot reload to see changes instantly:

```bash
# Press 'r' in terminal while app is running
r  # Hot reload
R  # Hot restart
q  # Quit
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS IPA
```bash
flutter build ios --release
# Follow Xcode build instructions
```

## Testing

Run unit tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/services/api_service_test.dart
```

## Code Generation

The project uses Riverpod generator for state management. After modifying providers, regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (auto-regenerate on file changes):
```bash
flutter pub run build_runner watch
```

## Debugging

### Enable Debug Logging

Add this to `main.dart`:
```dart
import 'package:dio/dio.dart';

// In ApiService initialization
_dio.interceptors.add(LoggingInterceptor());
```

### VS Code Debugging

1. Install Dart and Flutter extensions
2. Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    }
  ]
}
```

3. Press F5 to start debugging

## Next Steps

1. Connect to your backend API
2. Implement push notifications
3. Add Firebase analytics
4. Set up CI/CD pipeline
5. Deploy to App Store and Google Play

## Support

For issues and questions:
- GitHub Issues: https://github.com/yourusername/noskipai/issues
- Documentation: https://flutter.dev/docs
