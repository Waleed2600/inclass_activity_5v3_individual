@"
# Digital Pet (Flutter)

Features:
- Name input, happiness & hunger, mood tint via ColorFiltered
- Hunger auto-increases every 30s; win/loss logic
- Extras: Energy bar + Activity dropdown (Play/Feed/Nap/Walk)

## Run
flutter pub get
flutter run -d windows   # or: -d chrome

## Build APK (for submission)
flutter build apk --release
"@ | Out-File -Encoding UTF8 README.md

git add README.md
git commit -m "Add README with run/build instructions"
git push
