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


Product Requirement Document (PRD): Sales Friend v1.0

Product Name: Sales Friend
Document Version: 1.0 (Reverse-Engineered MVP Specification)
Status: Validated Prototype / Functional Baseline
Target Audience: Field Sales Representatives, Regional Sales Managers, Product & Engineering Teams

1. Executive Summary & Problem Statement
Enterprise Customer Relationship Management (CRM) tools are predominantly engineered for upper-level executive forecasting, data compliance, and pipeline auditing. Consequently, field sales representatives face substantial friction: multi-step drop-down menus, complex hierarchy logins, and manual inputs at the end of exhausting transit days.
This operational friction creates two critical systemic failures:
Data Inaccuracy & Stale Records: Representatives batch-log visits late at night or days later from memory, corrupting temporal and geographic integrity.
Managerial Blind Spots: Sales managers lack real-time visibility into ground-level distribution coverage, verified on-site presence, and daily representative cadence.

Sales Friend addresses this operational disconnect by decoupling immediate field activity logging from enterprise administrative overhead. It delivers a lightweight, real-time logging mechanism powered by hardware-verified geolocation and photographic proof, paired with an ad-hoc access architecture for team oversight.

3. Product Vision & Value Proposition
Vision: Enable zero-friction, verified field visibility that reps respect and managers rely upon.
For Field Representatives: Log an on-site visit in under 45 seconds using native camera and GPS integration, eliminating administrative overhead.
For Sales Managers: Gain instant, read-only supervisory visibility into field movements without enterprise directory configuration or IT provisioning.

5. User Personas & Core Journeys
Attribute
Field Representative ("Rohan")
Territory Sales Manager ("Vikram")

 
Context & Environment
Mobile-only, high transit, fluctuating mobile network coverage, client-facing interruptions.
Desktop / Mobile hybrid, oversees 5-15 field executives, focused on cadence and territory proof.

Core Pain Point
Dislikes extensive text inputs and repetitive CRM forms while moving between retail/clinic locations.
Spends hours calling reps to ask "Where are you?" and "Did you visit the assigned counter?"

Primary Goal
Log client interactions with verifiable proof instantly and close daily field duties cleanly.
Verify field execution without imposing demotivating micromanagement processes.


4. Feature Requirements & Functional Specifications
4.1 User Authentication & Identity (FR-01)
Mechanism: Firebase Authentication utilizing Email & Password credentials.
Scope: Session persistence across app restarts; secure token-based access to backend infrastructure.
Error Handling: Clear validation states for malformed email inputs, weak credentials, and network timeouts.

4.2 Hardware Geolocation & Automated Reverse-Geocoding (FR-02)
Mechanism: Device GPS coordinates (Latitude, Longitude) captured on interaction trigger.
Address Resolution: Translates raw coordinates into human-readable geographic descriptors (Area, City, State) using device geocoding.
Integrity: Disallows manual override of coordinates to guarantee visit validity.

4.3 Camera Integration & Proof-of-Work Media Capture (FR-03)
Mechanism: Integration with device camera via native image picking capabilities.
Media Processing: Compressed client-side to minimize payload latency over cellular networks prior to cloud ingestion.
Cloud Storage: Images stored in Firebase Cloud Storage, returning secure reference URIs attached to Firestore records.

4.4 Real-Time Activity Feed & Dashboard (FR-04)
Data Pipeline: Cloud Firestore real-time snapshots streaming updates to client view components.
Information Density: List card presentation displaying Client Name, Resolved Geolocation, Timestamp, and Media Thumbnail.
Deep Dive: Full-screen modal presenting high-resolution photographic proof, raw coordinates, and qualitative notes.

4.5 Decentralized Manager Pairing Protocol (FR-05)
Mechanism: Rep generates an ephemeral/persistent 6-digit numeric pairing token mapped to their profile document.
Access Model: Manager enters the 6-digit token on their client dashboard, attaching a read-only stream listener to the targeted representative's collection.
Decoupling: Eliminates organization-wide hierarchy trees, LDAP syncing, or administrative approval workflows.


5. Technical Architecture & Data Model
5.1 System Architecture
The solution operates on a serverless mobile architecture designed for operational simplicity and real-time synchronization:
Client Layer: Flutter cross-platform runtime handling state, native sensor access (Camera, Location), and reactive UI rendering.
Authentication Layer: Firebase Authentication managing secure identity, session tokens, and access rights.
Database Layer: Google Cloud Firestore executing structured, document-oriented storage with indexed real-time listeners.
Storage Layer: Google Cloud Storage housing unstructured image assets with authenticated access tokens.

5.2 Firestore Schema Specification
// Collection: users
{
  "uid": "string (Primary Key, matches Auth UID)",
  "name": "string",
  "email": "string",
  "managerAccessCode": "string (6-digit unique token)",
  "totalVisitsCount": "integer",
  "createdAt": "timestamp"
}

// Sub-collection / Root Collection: visits
{
  "visitId": "string (Auto-generated UUID)",
  "repId": "string (Foreign Key referencing users.uid)",
  "clientName": "string",
  "notes": "string",
  "photoUrl": "string (Firebase Storage download URL)",
  "location": {
    "latitude": "float64",
    "longitude": "float64",
    "addressString": "string"
  },
  "timestamp": "timestamp (Server timestamp)"
}


6. Non-Functional Requirements & System Constraints
Network Latency Tolerance: The application UI must not lock or hang during image upload over 3G/4G cellular networks; background upload queuing must inform the user through optimistic visual states.
Battery & Resource Footprint: Geolocation sensors must be activated only on-demand when the representative initiates a visit log, avoiding continuous background battery drain.
Read/Write Rules Security: Firestore rules enforce that users can only write to their own visit records, while authorized manager sessions can execute queries filtered strictly by paired manager access codes.


7. Future Roadmap & Post-MVP Backlog
Offline Caching with Sync Engine: Enable offline visit logging with automated SQLite queue syncing once connectivity is restored.
Beat Route Optimization: Integrate route mapping to sequence assigned clients by distance and traffic patterns.
Manager Analytics Export: Single-click CSV/PDF report extraction for weekly and monthly performance evaluations.
Geofencing Verification: Warn or restrict submissions if the GPS reading deviates further than 100 meters from known client coordinates.

