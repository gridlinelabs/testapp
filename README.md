# BillSplit AI 💸

A production-ready Flutter app for splitting bills intelligently with AI receipt scanning.

## Features

- **AI Receipt Scanner** — Take a photo of any receipt and let AI parse items & prices
- **Smart Splitting** — Equal split, custom amounts, or by-item assignment
- **Group Management** — Create groups for trips, homes, events
- **Debt Optimization** — Minimal transactions algorithm to settle debts efficiently
- **Firebase Backend** — Real-time sync across all devices
- **Google Sign-In** — One-tap authentication
- **Freemium Model** — 3 groups free, unlimited with Pro

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State | Riverpod 2.x |
| Navigation | GoRouter |
| Backend | Firebase (Auth + Firestore) |
| OCR | Google ML Kit |
| AI Parsing | Claude API (claude-haiku-4-5) |
| Animations | flutter_animate |

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp + router config
├── app_router.dart        # GoRouter route definitions
├── firebase_options.dart  # Firebase configuration
│
├── design/                # Design System
│   ├── colors.dart        # Color palette (light + dark)
│   ├── typography.dart    # Text styles (Sora font)
│   ├── spacing.dart       # Spacing scale (4px grid)
│   ├── buttons.dart       # Button variants
│   └── theme.dart         # Material 3 theme
│
├── models/                # Data models
│   ├── user_model.dart
│   ├── group_model.dart
│   └── expense_model.dart
│
├── services/              # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── ai_service.dart
│
├── providers/             # Riverpod state
│   ├── auth_provider.dart
│   ├── groups_provider.dart
│   └── expenses_provider.dart
│
├── screens/               # Feature screens
│   ├── auth/              # Login, Register, ForgotPassword
│   ├── home/              # Home (groups list + balance)
│   ├── groups/            # Group detail, Create group
│   ├── expenses/          # Add/edit expense
│   ├── scanner/           # AI receipt scanner
│   └── premium/           # Upgrade/paywall screen
│
└── widgets/               # Reusable UI components
    ├── common/            # AppCard, AppTextField, LoadingOverlay
    ├── groups/            # GroupCard, MemberAvatarStack
    └── expenses/          # ExpenseItem, BalanceSummary
```

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK ≥ 3.0
- Dart SDK ≥ 3.0
- Android Studio or VS Code
- Firebase account

### 2. Clone & Install

```bash
git clone <repo-url>
cd billsplit_ai
flutter pub get
```

### 3. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (creates firebase_options.dart automatically)
flutterfire configure --project=your-firebase-project-id
```

Enable in Firebase Console:
- Authentication → Email/Password ✓
- Authentication → Google ✓
- Firestore Database → Create in production mode ✓

### 4. Claude API Key (for AI receipt parsing)

```bash
# Pass at build time
flutter run --dart-define=CLAUDE_API_KEY=your_key_here

# Or set in android/local.properties for development
CLAUDE_API_KEY=your_key_here
```

### 5. Run the app

```bash
flutter run
```

---

## Building for Production

### Debug APK

```bash
flutter build apk --debug
```

### Release APK (requires signing)

```bash
# 1. Create keystore
keytool -genkey -v -keystore release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias billsplit

# 2. Add to android/key.properties (gitignored)
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=billsplit
storeFile=../release-key.jks

# 3. Build
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: only own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Groups: only members can read/write
    match /groups/{groupId} {
      allow read: if request.auth != null &&
        request.auth.uid in resource.data.memberIds;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        request.auth.uid in resource.data.memberIds;
    }

    // Expenses: group members only
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Play Store Listing

### Short Description (80 chars)
> Split bills instantly. Scan receipts with AI. No more awkward math.

### Full Description
> **BillSplit AI** makes splitting expenses with friends effortless.
>
> 📸 **AI Receipt Scanner** — Point your camera at any receipt. Our AI reads every item and price automatically.
>
> ⚡ **Smart Splitting** — Split equally, by exact amounts, or assign items to specific people.
>
> 💰 **Debt Optimization** — Our algorithm calculates the fewest transactions needed to settle up.
>
> 👥 **Groups for Everything** — Create groups for your apartment, road trip, dinner club, or couple.
>
> 🔄 **Real-time Sync** — Everyone sees updates instantly. No more "did you add that?"
>
> **BillSplit AI Pro:**
> - Unlimited groups
> - Unlimited AI scans
> - Expense analytics
> - Export to CSV/PDF
> - Priority support
>
> Free plan includes 3 groups. Upgrade anytime.

### Keywords
splitwise alternative, bill splitter, expense tracker, receipt scanner, group expenses, money split, trip expenses, roommate expenses, bill split app, AI receipt

### Category
Finance

### Content Rating
Everyone

---

## Design System

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#4F46E5` | Buttons, links, active states |
| Primary Light | `#818CF8` | Icons, dark mode |
| Accent | `#10B981` | Success, positive balance |
| Error | `#EF4444` | Negative balance, errors |
| Background | `#F9FAFB` | App background |
| Surface | `#FFFFFF` | Cards, modals |

### Typography
Font: **Sora** (Google Fonts)
- Display: 36–57px, Bold
- Headline: 24–32px, SemiBold
- Title: 14–20px, SemiBold
- Body: 12–16px, Regular
- Label: 11–14px, Medium
- Amount: 18–40px, Bold (financial data)

### Spacing Grid
4px base unit: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80

---

## License

MIT License — see [LICENSE](LICENSE) for details.
