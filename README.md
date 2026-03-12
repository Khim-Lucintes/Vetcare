# VetCare Flutter Prototype

A basic veterinary mobile application built with Flutter. This prototype includes:

- Pet profiles (add/view pets)
- Vaccination schedules with reminders
- Doctor availability (static)
- Barangay emergency contact screen with call button
- Pet care tip fetched from a REST API (https://catfact.ninja/fact)
- Simple state management using Provider

---

## Project Structure

```
lib/
  models/
    pet.dart
    vaccine.dart
  screens/
    home_screen.dart
    pet_details_screen.dart
  services/
    api_service.dart
    pet_provider.dart
  main.dart
pubspec.yaml
```

## Dependencies

This app uses the following packages:

- `provider` for state management
- `http` for REST API calls
- `url_launcher` for emergency call functionality

## Setup & Run

1. **Install Flutter** on your machine following the official guide: https://flutter.dev/docs/get-started/install
2. In a terminal navigate to the project folder:
   ```
   cd "c:\Users\admin\Documents\Visual Studio 2010\VETCARE SYSTEM"
   ```
3. If this directory does not yet contain the standard Flutter project files (`android/`, `ios/` etc.), you can initialize them by running:
   ```bash
   flutter create .
   ```
   You only need to do this once; subsequent updates can just replace the `lib/` code and `pubspec.yaml`.
4. Fetch packages:
   ```bash
   flutter pub get
   ```
5. Launch an emulator or connect an Android device.
6. Run the app:
   ```bash
   flutter run
   ```

## Generating an APK

To build an Android application package (APK), execute:

```bash
flutter build apk
```

The resulting file will be located in `build/app/outputs/flutter-apk/app-release.apk`.

### Installing APK on a device

1. Enable USB debugging on your Android device.
2. Connect the device to your computer via USB.
3. Install the APK using `adb`:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
4. Alternatively, copy the APK to the device and open it to install.

## Notes

- The vaccination reminder is simulated with a `SnackBar` when a schedule is within one day.
- Doctor availability and emergency contacts are static data.
- The pet care tip is fetched from the Cat Fact API each time the home screen loads.

This simple app is suitable as a student project prototype and can be extended with persistent storage, real notifications, authentication, etc.
