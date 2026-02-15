# Budjar - Firebase Setup Guide

## Current Status

The app is configured with Firebase Authentication but **requires Cloud Firestore to be enabled** for sync functionality.

## ⚠️ **Important: Firestore Setup Required**

If you see errors like "PERMISSION_DENIED" or "Cloud Firestore API has not been used", you need to enable Cloud Firestore:

1. **Go to Firebase Console**: https://console.firebase.google.com/project/budjar-8d2e9
2. **Enable Cloud Firestore API**: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=budjar-8d2e9
3. **Create Firestore Database**:
   - Click on "Firestore Database" in the left menu
   - Click "Create database"
   - Choose "Start in test mode" (for development)
   - Select a location close to you

## Firebase Configuration

### For Development (Current Setup)

- The app uses mock authentication and offline storage
- No actual Firebase project is required
- Perfect for testing and development

### For Production (When Ready)

Replace the placeholder values in the following files:

#### 1. `lib/firebase_options.dart`

Replace demo values with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
  appId: 'YOUR_ACTUAL_WEB_APP_ID',
  // ... other values
);
```

#### 2. `web/index.html`

Update the firebaseConfig object with your actual values:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_WEB_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  // ... other values
};
```

#### 3. `android/app/google-services.json`

Replace with your actual Google Services file from Firebase Console.

## Features Working in Development Mode

- ✅ User Authentication (mock)
- ✅ Local Data Storage (SQLite/SharedPreferences)
- ✅ Theme Switching (Light/Dark)
- ✅ Expense Tracking
- ✅ Budget Management
- ✅ Analytics and Charts
- ✅ Account Management

## Getting Your Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project: `project-168145515138`
3. Add your web app
4. Copy the configuration values
5. Replace the demo values in the files above

## Note

The app will automatically switch to Firebase mode once proper configuration is provided.
