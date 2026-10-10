# Invoice Now

A complete offline-first Flutter mobile application for generating simple bills and invoices, now upgraded with seamless real-time cloud syncing!

## 📱 Download & Install

You can install the app directly on your Android device by downloading the latest release APK.

1. Navigate to the **[Releases](../../releases)** section of this repository.
2. Download the `app-release.apk` file.
3. Open the downloaded file on your Android device.
4. When prompted, allow installation from unknown sources to install the app.

---

## ✨ Features

- **Google Sign-In & Authentication:** Secure your business data with Firebase Auth.
- **Real-time Cloud Sync:** Your bills and data instantly sync across all your devices using Firebase Cloud Firestore.
- **Offline Support:** Full offline capabilities using Hive local storage. Create bills without internet, and they will sync when you come back online!
- **Sales & Purchase Bills:** Separate dedicated screens and histories for both sales invoices and purchase bills.
- **Generate Professional PDFs:** Create A4-sized PDF invoices with custom business logos and UPI QR codes.
- **Analytics Dashboard:** Visualize your monthly sales and purchase statistics.
- **Smart Calculations:** Automatically calculates totals, taxes, discounts, and converts final amounts to Indian currency words.
- **Notifications & Reminders:** Scheduled local notifications to remind you of pending payments.
- **Sharing & Printing:** Share PDFs directly via WhatsApp, Email, or print them directly from your phone.

## 🛠️ Technology Stack

- **Framework:** Flutter & Dart
- **Backend/Database:** Firebase (Auth, Firestore)
- **Local Database:** Hive
- **PDF Generation:** `pdf` and `printing` packages
- **UI:** Glassmorphism UI elements, Google Fonts, Cupertino Icons

## ⚙️ Getting Started (For Developers)

### Prerequisites
- Flutter SDK (>= 3.2.0)
- Android Studio / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/Bill-App.git
   cd Bill-App
   ```

2. **Get the dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase:**
   This project uses Firebase. You will need to create your own Firebase project, configure Firebase Authentication (Google Sign-in), and Cloud Firestore. 
   Generate your own `google-services.json` and `firebase_options.dart` files using the `flutterfire` CLI, as the original API keys are NOT tracked in this repository for security purposes.

4. **Run the application:**
   ```bash
   flutter run
   ```

5. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```

## 🔒 Security Note
All sensitive files (`google-services.json`, `firebase_options.dart`, `firebase.json`) have been added to `.gitignore` and wiped from the Git history to prevent API leaks. When cloning this repo, please supply your own Firebase configuration files.
