<p align="center">
  <img src="https://raw.githubusercontent.com/eskiu-lang/eskiu/main/assets/logo.png" alt="Eskiu, a kitten with a ball of yarn" width="140">
</p>

<h2 align="center">ui-package-template</h2>
<p align="center">A starting point for a package with native code, for apps on eskiu-lang/ui.</p>
<p align="center"><sub>Part of the <a href="https://github.com/eskiu-lang">Eskiu</a> project</sub></p>

<p align="center">
  <a href="https://github.com/eskiu-lang/ui-package-template/actions/workflows/ci.yml"><img src="https://github.com/eskiu-lang/ui-package-template/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT"></a>
</p>

---

A package that brings a platform service to every app that adds it: Eskiu functions on top,
Objective-C, Java (or Kotlin, C) and JavaScript underneath, and a `ui.toml` with what the
platforms need. The template's package works as it is: `use_battery()` reports the battery's
charge on iOS, Android and the web. Replace it with yours.
[location](https://github.com/eskiu-lang/ui-location),
[notifications](https://github.com/eskiu-lang/ui-notifications),
[camera](https://github.com/eskiu-lang/ui-camera),
[barcode](https://github.com/eskiu-lang/ui-barcode),
[pedometer](https://github.com/eskiu-lang/ui-pedometer),
[securestore](https://github.com/eskiu-lang/ui-securestore) and
[svg](https://github.com/eskiu-lang/ui-svg) are built the same way.

## Start

1. **Use this template** on GitHub (or clone it), then name your package:

   ```bash
   tools/rename.sh mything      # mypackage -> mything, MyPackage -> Mything
   ```

2. Write the Eskiu side in `src/mything.esk`, and each platform's side in `native/`.
3. Run the tests on your computer, and the example on a device:

   ```bash
   eskiuc test
   cd examples/demo && ui run ios      # or android, web
   ```

4. Tag a version and push it: apps add it with
   `eskiuc add mything --git https://github.com/you/mything --rev v0.1.0`.

## What is in it

| Path | What it is |
|---|---|
| `src/mypackage.esk` | The Eskiu side, what apps import as `<mypackage>`: the externs, the channel's messages and the hook. |
| `native/ios/mypackage.m` | The externs on iOS, in Objective-C (`ui_native.h` is on the path; Swift works too). |
| `native/android/MyPackage.java`, `mypackage.c` | The work in Java, and the externs in C that call it through JNI. |
| `native/web/mypackage.js` | The externs on the web, as an emscripten library. |
| `ui.toml` | Frameworks, plist entries, permissions, Maven libraries, Swift packages, receivers. |
| `tests/mypackage.esk` | Tests that run on the computer: stand-ins for the externs, and the events a platform would send. |
| `examples/demo` | An app that uses the package, with the package as a path dependency. |
| `.github/workflows/ci.yml` | The tests on Linux and macOS, and the example type-checked. |

## How the parts talk

```
Eskiu  use_battery() ──use_mount──▶ mypackage_start()          (an extern)
                                         │
native  UIDevice / BatteryManager / navigator.getBattery
                                         │
         ui_native_emit("mypackage", "battery 82 1")   (any thread; to the UI thread)
                                         │
Eskiu  use_native_event("mypackage", ...) ──▶ the scope renders again
```

- **Calls into native code** are `extern` functions. Each platform defines them: C or
  Objective-C functions on iOS and Android (Android's call into Java through `ui_jni_env()` and
  `ui_find_class()`), functions of an emscripten library on the web.
- **Answers come back as events** on a channel: `ui_native_emit` (iOS, C on Android),
  `UiActivity.emit` (Java) or `Module.uiEmit` (the web). The payload is a string.
- **A hook** reads them with `use_native_event` and starts and stops the service with
  `use_mount`, so it runs while a component that uses it is mounted. A hook that keeps a
  closure from the app uses its own slot (`ui_slot(10, &tag)`), as `use_notification_opened`
  does in notifications.
- **Native views** are `NativeView(style, "type", on_event)` in Eskiu and a factory each
  platform registers: see `CameraView` in camera.

[Native code](https://github.com/eskiu-lang/ui/blob/main/docs/native.md) in the ui docs has
the whole platform side: `ui_view_controller()` and `UiActivity.startForResult` to present
system screens, `UiActivity.requestPermissions`, `UiActivity.onIntent`, Gradle and Swift
packages.

## License

MIT
