# 📓 Notebook

A clean and minimal note-taking app built with Flutter, designed around a modern MVVM architecture.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/notebook.git

# Navigate to the project directory
cd notebook

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 🏛 Architecture

This project follows the **MVVM (Model-View-ViewModel)** pattern.

```
lib/
├── core/
│   ├── database/        # Drift database setup & DAOs
│   ├── extensions/      # Dart extensions
│   ├── router/          # GoRouter configuration
│   ├── services/        # Notification service
│   └── widgets/         # Shared widgets (LoadingOverlay, etc.)
├── model/               # Data models (Note, Draft)
├── pages/               # UI screens
├── utils/
│   └── constants/       # App colors, sizes
├── viewmodel/           # ViewModels per page
└── main.dart
```

### How it works

- **Model** — Plain Dart classes and Drift table definitions representing the data layer.
- **ViewModel** — Extends `ChangeNotifier`, holds state, business logic, controllers, and interacts with the database. Receives a `Ref` for accessing other providers.
- **View** — `ConsumerWidget` that watches the ViewModel and rebuilds on state changes. Contains no business logic.

---

## 🛠 Tech Stack

| Technology                                                                          | Purpose                 |
| ----------------------------------------------------------------------------------- | ----------------------- |
| [Flutter](https://flutter.dev)                                                      | UI framework            |
| [Riverpod](https://riverpod.dev)                                                    | State management        |
| [Drift](https://drift.simonbinder.eu)                                               | Local database (SQLite) |
| [GoRouter](https://pub.dev/packages/go_router)                                      | Navigation              |
| [intl](https://pub.dev/packages/intl)                                               | Date & time formatting  |
| [BotToast](https://pub.dev/packages/bot_toast)                                      | Toast notifications     |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Push notifications      |

---

## 📄 License

This project is licensed under the MIT License.
