# App Cloner BD — Starter Project

Flutter + Kotlin Android starter. This is the foundation milestone, not yet a full app-cloning engine.

## Included
- Premium Flutter dashboard with Dark/Light theme
- Installed launchable-app scanner through Kotlin MethodChannel
- Search and app list
- Native capability response that explicitly reports cloning as unavailable in this starter
- Android launcher-intent package visibility (avoids broad QUERY_ALL_PACKAGES permission)

## Important Android limitation
A normal third-party app cannot silently create a fully isolated copy of arbitrary installed apps. Android managed/work profiles generally require a separately provisioned profile and an authorized profile-owner/device-policy-controller flow. This starter does not bypass Android security or claim to clone apps.

## Create the Flutter platform scaffolding
Install Flutter SDK and Android Studio/Android SDK, then run:

```bash
flutter create --org com.appclonerbd app_cloner_bd
```

Copy/merge the `lib/` directory from this archive into the generated project.
Replace the generated `android/app/src/main/AndroidManifest.xml` and `MainActivity.kt` with the supplied files. Keep the generated Gradle wrapper and Flutter Gradle plugin files from your installed Flutter version.

Then run:

```bash
cd app_cloner_bd
flutter pub get
flutter analyze
flutter test
flutter run
```

## Android package name
`com.appclonerbd.app_cloner_bd`

If your generated project uses a different Kotlin package path, move `MainActivity.kt` to:
`android/app/src/main/kotlin/com/appclonerbd/app_cloner_bd/MainActivity.kt`
and ensure the `namespace` and `applicationId` in `android/app/build.gradle(.kts)` match.

## Current milestone status
- [x] Flutter dashboard and theme switching
- [x] Kotlin MethodChannel
- [x] Launcher-app discovery
- [x] Search/filter UI
- [ ] Managed Profile provisioning / profile-owner integration
- [ ] Real clone installation and lifecycle management
- [ ] Device matrix testing and release signing


## Build APK with GitHub Actions
1. Upload the extracted project contents to a GitHub repository on the `main` branch.
2. Open **Actions** and select **Build App Cloner BD (Debug APK)**.
3. Run workflow manually, or push a commit to `main`.
4. When the workflow completes, open its run and download the `app-cloner-bd-debug-apk` artifact.

The workflow generates the Flutter Android platform scaffolding using the current stable Flutter channel, overlays this source, runs analysis and unit tests, and builds a debug APK. This workflow has been authored but has not been executed in this environment.
