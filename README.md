# cmandili_driver

## Configuration (build time)

The app no longer reads `.env` (it was bundled in the APK as an asset, so
anyone could read it). Its three public values come in at build time:

1. Copy `dart_defines.example.json` to `dart_defines.json` (git-ignored) and
   fill in `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_MAPS_API_KEY`.
2. Run and build with the file:

   ```
   flutter run --dart-define-from-file=dart_defines.json
   flutter build appbundle --release --dart-define-from-file=dart_defines.json
   ```

Without it the app stops at launch with "Missing SUPABASE_URL...".
Never put a secret in this file: everything in it ends up in the app.
