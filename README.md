# Sales Friend 📍🤝

A domain-driven mobile application built with Flutter and Firebase, designed to streamline daily field sales reporting, eliminate proxy check-ins through automatic geotagging, and provide managers with real-time field visibility.

---

## The Problem & Motivation

Traditional field sales reporting often relies on manual spreadsheets, end-of-day recaps, or messaging channels. This creates notable friction:
- **Proxy/Inaccurate Check-ins:** Difficulty verifying physical client visits.
- **Reporting Overhead:** Sales reps spend valuable selling time manually noting down addresses and times.
- **Delayed Visibility:** Managers only receive updates hours or days later.

**Sales Friend** addresses these pain points by capturing GPS-verified visit records directly in the field and syncing them instantly to supervisory dashboards via an on-demand linking model.

---

## Key Features

- **Automated GPS Geotagging:** Captures device coordinates and human-readable addresses directly upon logging a visit.
- **Visit Documentation:** Logs client names, visit notes, and timestamps in a structured feed.
- **Visual Verification:** Integrated camera support to capture and store site photos.
- **Manager Access Code System:** A lightweight permission model using unique 6-digit share codes to link managers with field reps without complex account hierarchies.
- **Live Sync:** Real-time visit updates powered by Cloud Firestore.
- **Configurable Settings:** Toggles for high-accuracy GPS resolution, offline cache preferences, and session control.

---

## Tech Stack & Architecture

- **Frontend Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend as a Service:** [Firebase](https://firebase.google.com/)
  - **Firebase Authentication:** Secure email/password session handling
  - **Cloud Firestore:** Real-time NoSQL database for visit streams and share-code verification
  - **Firebase Storage:** Cloud bucket for field photos
- **Hardware Integration:**
  - `geolocator`: High-precision device location capture
  - `image_picker` & `image`: Camera integration and photo processing

---

## Project Structure

```text
lib/
├── models/
│   └── visit_model.dart              # Data models for visit entities
├── screens/
│   ├── dashboard_screen.dart         # Main visit stream and quick actions
│   ├── login_screen.dart             # Authentication entry point
│   ├── new_visit_screen.dart         # Visit creation form with GPS capture
│   ├── visit_detail_screen.dart      # Full visit breakdown with location data
│   ├── share_access_screen.dart      # 6-digit code generator for sales reps
│   ├── manager_dashboard_screen.dart # Manager portal for linked representatives
│   ├── profile_screen.dart           # Representative profile overview
│   └── settings_screen.dart          # App preferences and account actions
├── services/
│   ├── auth_service.dart             # Firebase Auth wrapper
│   └── share_service.dart            # Two-way code generation & Firestore linking logic
└── main.dart                         # Application entry point & theme configuration
