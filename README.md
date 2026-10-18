# CaloraApp

Phone client for the Calora server. Meals, workouts, weight, and profile are saved on the server.

Install the Android app from the latest GitHub release:

https://github.com/PoisonAifih/CaloraApp/releases/latest

On the sign-in screen, set Server to the computer running Calora, for example `http://192.168.1.10:3005`. The Android emulator can keep `http://10.0.2.2:3005`.

When a newer release is published, the app asks to download and install it. Profile also has Check for updates.

To publish an update, raise the version in `pubspec.yaml` (`1.0.1+2` must be higher than the installed build), commit, then:

```
git tag v1.0.1+2
git push origin v1.0.1+2
```

GitHub builds `app-release.apk` and attaches it to that release. The phone installs it over the current app.
