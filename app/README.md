# fieldnotes_app

Offline-first field notes app (Flutter + BLoC + Hive + REST).

## Run
1. Start backend (`backend/` README) + XAMPP MySQL.
2. `flutter pub get`
3. Emulator: `ApiConfig.baseUrl` is already `http://10.0.2.2:8080`.
   Real device: set your PC LAN IP in `lib/core/config.dart`.
4. `flutter run`

## What maps to the task
- Register/login online via backend, JWT kept in SharedPreferences.
- Customers -> Sites -> Notes CRUD, all writes hit Hive first (dirty flag),
  so create/edit/delete works offline; sync pushes in parent->child order
  then pulls server state.
- Reinstall/restore: login -> pull() downloads everything.
- Search notes by title/description/site/customer; filter by status
  (+ site filter in bloc API).
- Location button (geolocator, permission requested properly),
  camera/gallery (image_picker, Android permissions in manifest).
- Settings -> Default Note Status in SharedPreferences only, never synced.
- `flutter test` covers model relations/serialization.
