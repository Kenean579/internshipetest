# Service Hub: Mini Service Catalog & Request App

A premium, production-ready Flutter application for service providers (clinics, salons, repair shops) to manage their catalog and receive customer requests. This project was built for the **Qelem Meda Technologies Internship Practical Assessment**.

## 🚀 Key Features

- **Provider Management**: Full registration and login for providers with fields like `company_name` and `license_number`.
- **Dynamic Catalog**: Real-time management of service categories and items.
- **Computed Pricing**: Automatic calculation of total prices including VAT and discounts.
- **Public Portfolio**: Providers can share their unique catalog link with customers.
- **Service Requests**: Customers can submit requests directly via the public catalog.
- **Resilient Media**: Integrated with `Catbox.moe` for decentralized image hosting and robust error handling.

## 🛠 Tech Stack

- **Framework**: Flutter
- **Database**: Firebase Firestore (Real-time NoSQL)
- **Auth**: Firebase Auth
- **Storage**: Catbox.moe API Integration
- **Design**: Executive Professional (Neutral Slate & Navy)

## 📥 Setup Instructions

### 1. Prerequisites
- Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed.
- Access to a terminal with Git.

### 2. Installation
Clone the repository and install dependencies:
```bash
git clone <repository-url>
cd intershipetest
flutter pub get
```

### 3. Firebase Configuration
The project is already configured with a test Firebase instance. If you need to use your own:
1. Create a project on [Firebase Console](https://console.firebase.google.com/).
2. Add an Android/iOS app.
3. Replace the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).

### 4. Running the App
Launch the application on your preferred device:
```bash
flutter run
```

## 🧪 Seeding & Test Data

To quickly evaluate the app, you can use the built-in data seeder.
1. Log in or explore as a guest.
2. In the **Provider Dashboard**, the seeder has already pre-populated the following test accounts:
   - **User 1**: `kenean@example.com`
   - **User 2**: `hailukenean@example.com`
   - **Common Password**: `hakfm12345` (Note: These are seeded placeholders).

## 📊 Compliance Mapping

| Requirement | Implementation |
| :--- | :--- |
| **Provider Auth** | Firebase Auth + custom Firestore profile fields. |
| **Category CRUD** | Real-time streams via `DbService`. |
| **Computed Price** | Dynamic model getters in `ServiceItem`. |
| **Public Page** | Unique `slug` based landing logic. |
| **Seeder** | `DataSeeder` utility with multi-account support. |

---
*Built for Qelem Meda Technologies intenshipe test.*
