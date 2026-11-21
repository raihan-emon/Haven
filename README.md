# Haven

A lightweight Material Expressive Android client for [Wallhaven.cc](https://wallhaven.cc) built with Flutter.

## Why I Made This
There are very few Wallhaven apps on Android, and most of them are either missing stuff or abandoned. I wanted something lightweight that actually worked for me—with API key support and a way to back up and restore favorites.

> **Fair warning:** This is my **first and last release**. I'm lazy af, short on time, and building on a potato PC. If you want more features or updates, **fork it**—or don't.

## What Makes It Different
- **API Key Support:** Add your Wallhaven API key, with an option to include or leave out your key when exporting backups.
- **Export & Import Favorites + API Key:** Save and restore your local favorites, layout settings, theme settings, and (optionally) API key in a `.json` file. Favorites stay local inside the app because the Wallhaven API key doesn't add favorites directly to your Wallhaven account.
- **Lightweight & Material Expressive:** Small split-ABI APKs (~17-20 MB) with Auto/Light/Dark modes, Pure Black (AMOLED) dark mode, Expressive pill styling, and auto-hiding floating navigation and search bars.
- **Grid & Viewer Controls:** Staggered and uniform grids, adjustable columns and rounded corners, full-screen viewing with pinch/double-tap zoom, metadata/tags, and saving directly to `Pictures/Wallhaven`.

## Download
Grab the APK for your phone from the [Releases](../../releases) page:
- `arm64-v8a` - most modern 64-bit Android phones
- `armeabi-v7a` - older 32-bit phones
- `x86_64` - emulators / x86 devices

## Build from Source
```bash
git clone [https://github.com/raihan-emon/Haven.git](https://github.com/raihan-emon/Haven.git)
cd Haven
flutter pub get
flutter build apk --release --split-per-abi
