# CaloraApp

Phone client for the Calora server. Meals, workouts, weight, and profile are saved on the server.

Install the Android app from the latest GitHub release:

https://github.com/PoisonAifih/CaloraApp/releases/latest

On the sign-in screen, set Server to the computer running Calora, for example `http://192.168.1.10:3005`. The Android emulator can keep `http://10.0.2.2:3005`.

When a newer release is published, the app asks to download and install it. Profile also has Check for updates.

Every push to `main` builds the next Android release. The build number is the number of commits on `main`, and the phone installs that release over the current app.
