# Chronomancer

http://iconmaster.info/Chronomancer

An online build planner for Chronicon.

## Building

You will need Dart, version 2.12 exactly.

```pwsh
pub get
pub run build_runner build --release --delete-conflicting-outputs -o web:build
```

The artifacts will be in the `build` directory. From there, you can clone in the `pages` branch into that folder to see how the website has changed.
