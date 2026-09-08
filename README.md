Sales Friend


Sales Friend is a full-featured field sales enablement and activity tracking mobile application built with Flutter and Firebase. It streamlines on-ground operations by letting field representatives log client visits with automated GPS geotagging, on-site photo proofs, and meeting notes in real time. Designed with managerial oversight in mind, it features a zero-friction pairing mechanism—reps generate a 6-digit access code, allowing managers to monitor field movements, verified visit logs, and live activity streams instantly without complex enterprise onboarding.

Field sales tracking without the bloat. Sales Friend bridges the visibility gap between ground sales teams and management. Reps log client visits with verified location data and photo proof in seconds; managers gain live, read-only dashboard access via a simple 6-digit pairing code. Built end-to-end on Flutter, Cloud Firestore, and Firebase Storage for real-time synchronization and offline-ready responsiveness.

# Sales Friend

A Flutter field sales tracking app with real-time manager access — built for sales teams to log visits, capture proof, and share progress instantly.

## Features

| Feature | Description |
|---------|-------------|
| Firebase Auth | Secure email/password login |
| Visit Logging | Capture client name, location, notes, and photo |
| GPS Tracking | Auto-captures latitude, longitude, and address |
| Real-Time Feed | All visits appear instantly on the dashboard |
| Manager Access | Salesman generates a 6-digit code; manager enters it once to view all visits |
| Visit Details | Full-screen view with photo, timestamp, location, and notes |
| Profile Stats | Total visit count and account info |

## Tech Stack

- **Flutter** — Cross-platform UI
- **Firebase Authentication** — User management
- **Cloud Firestore** — Real-time NoSQL database
- **Firebase Storage** — Photo upload & retrieval
- **image_picker** — Camera/gallery integration
- **Geolocation** — GPS coordinates & address

## Screenshots

*(Add your screenshots here once the app loads on your phone)*

| Login | Dashboard | Add Visit | Detail View | Manager | Profile |
|-------|-----------|-----------|-------------|---------|---------|
| ![login](screenshots/login.png) | ![dash](screenshots/dash.png) | ![add](screenshots/add.png) | ![detail](screenshots/detail.png) | ![manager](screenshots/manager.png) | ![profile](screenshots/profile.png) |

## Architecture
