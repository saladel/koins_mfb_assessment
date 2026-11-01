# Koins MFB - Savings Application Assessment

A modern, responsive, offline-first fintech savings application built with **Flutter**,
**Riverpod**, **Hive**, and **Clean Architecture**.

---

## 🎯 Task Objective

The objective of this technical assessment is to build a simple savings application for a digital
bank. The application enables users to:

- Log in securely using mock authentication.
- View available savings plans/products and inspect detailed parameters for each.
- Create new personalized savings plans with input validation.
- View an interactive savings dashboard with aggregated account balance, quick actions, recent
  plans, and financial insights.
- View and manage user profile details and handle session logout.

> **Emphasis**: The core objective highlights **Clean Architecture**, **modern Material 3 UI**,
> **high performance**, and **maintainable code** rather than overly complex business logic.

---

## 📋 Task Requirements

### 1. Functional Requirements

- **Login Screen**:
    - Email Address & Password input fields with visibility toggle.
    - Validation: Required fields, valid email format, minimum 8-character password.
    - Mock authentication accepting demo credentials (`test@bank.com` / `Password123`) and
      navigating to the Dashboard on success.
    - Non-functional *Forgot Password* and *Register* action links with feedback notifications.
- **Dashboard Screen**:
    - Time-aware greeting (`Good Morning / Afternoon / Evening, John Doe`).
    - Total Savings aggregate balance in Naira (`₦850,000`).
    - Quick Action shortcuts (*Create Savings*, *View Products*).
    - Recent Savings section displaying up to 3 savings plans (Plan Name, Amount, Frequency,
      Progress).
- **Savings Products Screen**:
    - List of savings products (*Target Savings 12% 12 Months*, *Fixed Deposit 18% 6 Months*,
      *Education Savings 10% Flexible*, *Vacation Savings 8% Flexible*).
    - Cards displaying Product Name, Interest Rate, Short Description, and a *"View Details"*
      button.
- **Savings Details Screen**:
    - Detailed product parameter breakdown (Plan Name, Interest Rate, Minimum Deposit, Duration,
      Description).
    - Pinned *"Create Savings"* call-to-action button that pre-selects the product type on the
      creation form.
- **Create Savings Screen**:
    - Form fields: Savings Name, Product Type (Dropdown), Target Amount, Monthly Contribution,
      Duration (Dropdown), and Create button.
    - Validation: All fields required and numerical amounts validated against minimum deposit rules.
    - On Success: Displays `"Savings Created Successfully"` SnackBar, persists the plan, and returns
      to the Dashboard.
- **Profile Screen**:
    - Displays user profile information (Full Name, Email Address, Phone Number).
    - Logout button with confirmation dialog that clears Hive local session and redirects to the
      Login screen.

### 2. Technical & Non-Functional Requirements

- **UI Requirements**: Material 3 styling, responsive layouts, consistent typography, proper
  spacing, loading indicators, empty states, and error state views.
- **Architecture**: Strict Clean Architecture separation into `core/`, `data/` (models,
  repositories, services), `providers/`, `screens/`, and `widgets/`.
- **State Management**: Reactive state management with Flutter Riverpod (`Notifier`,
  `AsyncNotifier`, `FutureProvider`, `Provider`).
- **Local Storage**: Local persistence using Hive (`hive_ce_flutter`) for user sessions, cached
  product catalogues, savings plans, and an offline outbox sync queue.
- **Error & Offline Resilience**: Custom `ApiException` handling, Dio timeout error translation,
  offline plan creation with outbox queuing (`PlanQueuedException`), and auto-sync on network
  reconnection or pull-to-refresh.

---

## 🖼️ Screenshots

|                    Login Screen                    |                      Dashboard Screen                      |                     Savings Products                     |
|:--------------------------------------------------:|:----------------------------------------------------------:|:--------------------------------------------------------:|
| ![Login Screen](docs/screenshots/login_screen.png) | ![Dashboard Screen](docs/screenshots/dashboard_screen.png) | ![Products Screen](docs/screenshots/products_screen.png) |

|                         Product Details                         |                            Create Savings                            |                     Profile Screen                     |
|:---------------------------------------------------------------:|:--------------------------------------------------------------------:|:------------------------------------------------------:|
| ![Product Details](docs/screenshots/product_details_screen.png) | ![Create Savings Screen](docs/screenshots/create_savings_screen.png) | ![Profile Screen](docs/screenshots/profile_screen.png) |

---

## 📱 Features

- **Authentication**:
    - Mock email & password authentication (`test@bank.com` / `Password123`).
    - Validation for required fields, email format, and password minimum length (8+ chars).
    - Secure session persistence in local storage with automatic route guards via `GoRouter`.
- **Savings Dashboard**:
    - Time-aware greeting (`Good Morning / Afternoon / Evening`) with user name.
    - Total Savings aggregate balance in Naira (`₦`).
    - Quick action shortcuts (*Create Savings*, *View Products*).
    - Recent savings plans with progress indicators.
    - Live **Money Insights** section powered by public API integrations.
- **Savings Products & Details**:
    - List of savings products (*Target Savings*, *Fixed Deposit*, *Education Savings*, *Vacation
      Savings*).
    - Search bar to dynamically filter products by name or description.
    - Detailed product page displaying interest rate, minimum deposit, duration, and descriptions.
- **Plan Creation & Offline-First Sync**:
    - Form validation for plan name, product type, target amount, monthly contribution, and
      duration.
    - **Offline-First Persistence**: Plans created offline land in Hive immediately and display on
      the dashboard with a "Pending sync" badge.
    - Automatic background sync outbox that POSTs queued plans as soon as connectivity is restored
      or on pull-to-refresh.
- **Profile & Account Management**:
    - Displays full name, email address, phone number, and account balance summary.
    - Logout workflow with confirmation dialog, clearing Hive sessions and redirecting to login.

---

## 🏛️ Architecture & Folder Structure

The project strictly follows **Clean Architecture** principles separated into distinct feature
layers:

```
lib/
├── core/                  # Application constants, theme, router, and utilities
│   ├── constants/         # Color palettes, typography, spacing, and icons
│   ├── router/            # GoRouter configuration & auth state guard notifier
│   ├── theme/             # Material 3 light theme definitions
│   └── utils/             # Formatters (currency, percent, date) and Validators
├── data/                  # Data layer: Models, Repositories, and Services
│   ├── models/            # Data models (UserModel, SavingsPlanModel, ProductModel, InsightModel)
│   ├── repositories/      # Auth, Savings, Product, and Insight repositories
│   └── services/          # Dio ApiService and Hive StorageService
├── providers/             # Riverpod providers for state management and DI
├── screens/               # Screen UIs organized by domain
│   ├── auth/              # LoginScreen
│   ├── dashboard/         # DashboardScreen
│   ├── navigation/        # MainNavigationWrapper (Bottom Navigation Shell)
│   ├── products/          # ProductsScreen & ProductDetailsScreen
│   ├── profile/           # ProfileScreen
│   └── savings/           # CreateSavingsScreen
├── widgets/               # Reusable UI components (buttons, text fields, cards, state views)
└── main.dart              # Application entry point & Hive initialization
```

### State Management & Storage

- **State Management**: **Flutter Riverpod** (`Notifier`, `AsyncNotifier`, `FutureProvider`,
  `Provider`). Riverpod enables compile-safe dependency injection, easy testing overrides, and clean
  reactive state updates.
- **Local Persistence**: **Hive (`hive_ce_flutter`)** with four isolated boxes:
    - `user_box`: Persists authenticated user session.
    - `savings_box`: Persists all savings plans locally.
    - `products_box`: Caches fetched product catalogue for offline access.
    - `pending_box`: Acts as an offline outbox queue for unsynced HTTP POST requests.

### Network Architecture & Endpoints

- **API Integration**: The app is connected to a public mock API to fetch external datasets (Money
  Insights via
  `dummyjson`, user profile/product data via GitHub Gists, Create Savings via HTTP POST via
  Beeceptor).
- **GET Requests (GitHub Gists)**: GitHub Gists were selected for retrieving static JSON payloads
  (user profile, savings product catalogue, initial savings plans) because Gists provide stable raw
  endpoints without rate limits, avoiding unexpected 429 errors during testing/review.
- **Money Insights API**: Integrates `https://dummyjson.com/posts` for dynamic financial tips.
- **POST Requests (Beeceptor)**:
  `https://koins-mfb-assessment.free.beeceptor.com/create-savings-plan` is used for creating a new
  savings plan using HTTP POST requests.

---

## 📦 Packages Used

| Package             | Version | Purpose                                                            |
|:--------------------|:--------|:-------------------------------------------------------------------|
| `flutter_riverpod`  | ^3.4.3  | Reactive state management & dependency injection                   |
| `go_router`         | ^18.1.1 | Declarative routing with auth guard redirection & shell navigation |
| `hive_ce_flutter`   | ^2.5.0  | High-performance, lightweight key-value local storage              |
| `dio`               | ^5.11.1 | HTTP client with timeout handling and error mapping                |
| `connectivity_plus` | ^7.3.2  | Network interface monitoring for triggering offline outbox sync    |
| `intl`              | ^0.20.3 | Currency formatting, numbers, and dates                            |
| `local_auth`        | ^3.0.2  | Biometric authentication support                                   |
| `mocktail`          | ^1.0.5  | Mocking library for unit testing                                   |

---

## 🛠️ Setup & Installation

### Prerequisites

- **Flutter SDK**: `^3.13.7` or any modern stable Flutter 3.x release.
- **Dart SDK**: `^3.1.0`
- **Android Studio / VS Code** with Flutter extensions installed.

### Steps to Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/koins_mfb_assessment.git
   cd koins_mfb_assessment
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

5. **Build APK**:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 💡 Assumptions & Design Decisions

1. **Mock Credentials**: As specified in the brief, credentials are fixed to `test@bank.com` and
   `Password123`. Credential validation occurs locally before fetching/restoring the user profile.
2. **Offline-First Savings Creation**: Creating a plan works seamlessly even when offline. If the
   network call fails, the plan is persisted locally in Hive and queued in `pending_box`. The user
   receives a clear warning SnackBar, and the plan shows on the dashboard. When internet connection
   returns, `syncProvider` automatically drains the outbox queue.
3. **Dropdown Pre-selection**: Arriving at *Create Savings* from a specific *Product Details* screen
   automatically pre-selects the product type and matching duration.

---

## 🔮 Improvements If Given More Time

1. **Full Biometric & PIN Unlock**: Wire `local_auth` directly to a PIN / FaceID / Fingerprint lock
   screen on app resume.
2. **Advanced Product Filtering**: Add category chips (e.g. *Flexible*, *Fixed*, *High Interest*) in
   addition to text search.
3. **Push Notifications**: Integrate local notifications (`flutter_local_notifications`) to alert
   users when contribution dates arrive or savings targets are reached.
4. **Golden & Screenshot Tests**: Add automated screenshot testing harnesses to generate visual
   diffs across screen sizes automatically.
