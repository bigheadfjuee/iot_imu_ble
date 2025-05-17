# iot_imu_ble

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Dev

## launcher icons

https://pub.dev/packages/flutter_launcher_icons

1. dart run flutter_launcher_icons:generate
2. 把 icon 放在 assets/icon/icon.png
3. 編輯 flutter_launcher_icons.yaml 
4. dart run flutter_launcher_icons:main

# rename app

flutter pub add rename_app
dart run rename_app:main all="My App Name"

# Run
flutter run -d chrome
flutter run -d M2101K7BNY # Redmi Note 10S
flutter run -d 2407FPN8EG # Xiami 14T Pro

# Build
flutter build apk --release --verbose