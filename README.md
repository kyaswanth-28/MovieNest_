# Movie App — Flutter Recruitment Task

A complete starter implementation for the 2nd-year Flutter recruitment task.

## Features
- Mock login with session persistence
- TMDB popular movies
- TMDB movie search
- Movie detail screen
- Loading and error states
- Retry button
- Clean dark movie UI
- Logout
- API key kept outside UI code via `--dart-define`

## Setup

1. Install Flutter.
2. Create a TMDB API key from TMDB.
3. Run:

```bash
flutter pub get
flutter run --dart-define=TMDB_API_KEY=YOUR_TMDB_API_KEY
```

For Android release:

```bash
flutter build apk --release --dart-define=TMDB_API_KEY=YOUR_TMDB_API_KEY
```

The generated APK will be under:

`build/app/outputs/flutter-apk/app-release.apk`

## Important
Do not commit your real API key to GitHub. The app reads it from `String.fromEnvironment`.

## Login
This is intentionally a mock/basic authentication flow as allowed by the task.
Any non-empty email and password can log in. The session is stored locally.

## Suggested GitHub workflow

```bash
git init
git add .
git commit -m "Initial movie app"
git branch -M main
git remote add origin YOUR_PUBLIC_GITHUB_REPO
git push -u origin main
```
