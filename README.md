# Ridr — Bike Rental Manager

A minimalist Flutter app (iOS + Android) for managing a bike rental shop:
dashboard, rent bike, add bike, active rentals ("Rent Leisure"), all bikes,
revenue by bike, and all customers.

This package contains the full Dart source (`lib/`), `pubspec.yaml`, and the
app icon (`assets/images/app_icon.png`). The sandbox this was built in has no
Flutter SDK and no access to pub.dev / Google's package servers, so the
`android/` and `ios/` platform folders (which `flutter create` normally
generates) aren't included — you'll generate those once, locally, with the
steps below. This takes about 2 minutes.

## 1. Create the platform shell

In an empty folder, with the Flutter SDK installed:

```bash
flutter create --org com.mrinformative --project-name ridr .
```

This creates `android/`, `ios/`, `test/`, etc., with the unique package
name/bundle id **com.mrinformative.ridr**.

## 2. Copy in this project's files

Copy `lib/`, `assets/`, `pubspec.yaml`, and `analysis_options.yaml` from this
package into the folder you just created, overwriting the generated
`lib/main.dart` and `pubspec.yaml`.

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Generate the app icon

The real logo is at `assets/images/app_icon.png`. Generate all iOS/Android
icon sizes from it:

```bash
flutter pub run flutter_launcher_icons
```

(Already configured in `pubspec.yaml` under `flutter_launcher_icons:`.)

## 5. Set the display app name

- **Android**: in `android/app/src/main/AndroidManifest.xml`, set
  `android:label="Ridr - Bike Rental Manager"`.
- **iOS**: in `ios/Runner/Info.plist`, set `CFBundleDisplayName` and
  `CFBundleName` to `Ridr - Bike Rental Manager`.

## 6. Permissions (camera + photo library for the two ID photos)

- **Android**: `flutter_create` + `image_picker` handle camera automatically
  on modern Android; no manifest change needed for targetSdk 33+.
- **iOS**: add these to `ios/Runner/Info.plist` (required by `image_picker`):

```xml
<key>NSCameraUsageDescription</key>
<string>Ridr needs your camera to take the rider's verification photo and driving licence photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Ridr needs photo library access so you can attach the rider's verification and driving licence photos.</string>
```

## 7. Run it

```bash
flutter run
```

## What's implemented

- **Onboarding** — first launch asks for owner name + shop name (saved with
  `shared_preferences`); home screen greets "Hi, {name}" with the shop name
  beneath it.
- **Dashboard** — All Bikes / Available / Rented counters, plus the six
  action tiles from your mockup.
- **Add Bike** — model, number, colour → saved to a local SQLite DB
  (`sqflite`), instantly available in All Bikes and the Rent Bike picker.
- **Rent Bike** — pick an available bike → fill rider name, age, contact,
  Aadhar number, a "person with bike" photo, a driving-licence photo
  (camera or gallery via `image_picker`, stored in app documents), start/end
  date & time, rent charge, and deposit → "Save trip" marks the bike
  `rented`.
- **Rent Leisure** — active rentals, bike number/colour/due-date; card is
  **green** while within the window and turns **red** once overdue.
  Tapping opens trip details (with the ID photos) and an **End trip** button
  that returns the bike to `available`.
- **All Bikes** — full fleet with an availability badge and a delete action
  (blocked while a bike is currently rented out).
- **Revenue Generated** — total revenue plus a per-bike breakdown, computed
  from completed trips' rent charges.
- **All Customers** — every rental (active + completed), tap through to the
  same trip-detail view.

## Notes on data & images

- Data is stored locally on-device only (SQLite via `sqflite`) — there's no
  backend/sync in this build. That matches the mockup, which is a single-shop
  local records tool.
- ID photos are copied into the app's documents directory and referenced by
  path in the database, so they survive app restarts.
- Currency is shown as `₹`; swap the `₹` literals in `revenue_screen.dart` and
  `rental_form_screen.dart`/`rental_detail_screen.dart` if you need a
  different currency.
