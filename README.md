# Wattodo — iBusinessFormula Technical Assessment

A Flutter task manager app built for the Mobile App Developer assessment. It started as a straightforward CRUD app and grew into something a bit more complete — local notifications with due date reminders, a daily morning briefing, SQLite persistence, remote seeding, and a clean architecture that makes the whole thing easy to navigate.

---

## Getting Started

**You'll need:**
- Flutter SDK `>= 3.41.x` (stable channel)
- Dart SDK `>= 3.11.x`
- Android Studio or Xcode (for a device or emulator)

```bash
git clone <repo-url>
cd wattodo
flutter pub get
flutter run
```

Run on a specific platform:
```bash
flutter run -d android
flutter run -d ios
```

Build a release APK:
```bash
flutter build apk --release
```

> **Android note:** The app uses `flutter_local_notifications` for scheduled reminders, which requires core library desugaring. This is already configured in `android/app/build.gradle.kts` — no extra setup needed.

---

## What It Does

When you first open the app it fetches 5 sample tasks from `jsonplaceholder.typicode.com/todos` and seeds them into a local SQLite database. After that, everything works offline — the remote call only happens once.

From there you can:

- **Add tasks** with a title, optional notes, and an optional due date and time
- **Get reminded** 1 hour before a task is due (local notification, no internet required)
- **Complete tasks** by tapping the circle — the app congratulates you when you clear the whole list
- **Delete tasks** by swiping left or long-pressing — there's a 3-second undo window if you change your mind
- **Filter** between All, Active, and Done views
- **See progress** in the ring counter in the header
- **Get a morning briefing** at 8am with how many tasks are waiting — it reschedules itself whenever your pending count changes

The due date shows up directly on the task card. It turns amber when you're within 2 hours of the deadline and red if the task is overdue.

---

## Architecture

Feature-first clean architecture. Each layer has a single job and the data only flows one way.

```
lib/
├── core/
│   ├── constant/          # AppColors, AppConstants
│   ├── di/                # CoreModule — Dio, DatabaseHelper, NotificationService
│   ├── network/           # BaseUrls
│   ├── services/          # NotificationService
│   └── util/              # Resource<T>, DatabaseHelper, ExceptionUtil
│
└── features/
    └── task_manager/
        ├── data/
        │   ├── datasources/
        │   │   ├── api/       # TaskApi (Dio)
        │   │   ├── dto/       # TodoResponseDto (JSON serializable)
        │   │   └── local/     # TaskLocalDatasource (sqflite)
        │   └── repository/    # TaskRepositoryImpl
        ├── domain/
        │   ├── business/      # One class per use case
        │   ├── model/         # TaskDataModel, AddTaskReqModel
        │   ├── repository/    # TaskRepository (abstract)
        │   └── usecase/       # TaskUseCases (bundles all business classes)
        ├── di/                # TaskModule
        └── presentation/
            ├── controller/    # TaskController (GetxController)
            └── ui/
                ├── screens/   # TaskListScreen, AddTaskSheet
                └── widgets/   # TaskTileWidget, EmptyTaskWidget
```

The repository is registered against its abstract interface, so swapping the implementation is a one-line change in `TaskModule`. The controller takes `TaskUseCases` as a single dependency instead of six, which keeps the constructor readable.

---

## State Management

**GetX** (`get: ^4.7.x`)

The controller holds the task list as an `RxList`. Widgets wrapped in `Obx()` rebuild only when the specific observable they reference changes — not the entire screen. Toggle, delete, and undo all use optimistic updates: the UI flips immediately and reverts if the database write fails.

`Get.lazyPut` with `fenix: true` means the controller is only created when first accessed and gets recreated automatically if it's ever garbage collected.

---

## Local Notifications

Three notification types, all local (no push infrastructure required):

| Type | Trigger | Channel |
|---|---|---|
| **Due soon** | 1 hour before `dueDate`, exact alarm | `wattodo_tasks` |
| **Daily briefing** | 8am every morning, repeating | `wattodo_daily` |
| **All done** | When every task is completed | `wattodo_tasks` |

Reminders are automatically cancelled when you complete or delete a task, and rescheduled if you undo a delete. The daily briefing cancels itself when your pending count hits zero and re-creates itself when you add new tasks.

Android 12+ requires the `SCHEDULE_EXACT_ALARM` permission for precise reminder timing. The app requests it on first launch. If it's denied, the reminder silently falls back to an inexact alarm rather than crashing.

---

## Local Persistence

SQLite via `sqflite`. Two tables:

**`tasks`**
```
id TEXT PRIMARY KEY
title TEXT NOT NULL
description TEXT NOT NULL DEFAULT ''
is_completed INTEGER NOT NULL DEFAULT 0
created_at TEXT NOT NULL
due_date TEXT          -- nullable, ISO 8601
```

**`meta`**
```
key TEXT PRIMARY KEY
value TEXT NOT NULL
```

The `meta` table stores a `seeded` flag so the app only hits the remote API once. `DatabaseHelper` is a singleton — one instance shared across the app prevents "database is locked" errors on concurrent writes.

The schema is on version 2. Existing installs on version 1 get the `due_date` column added automatically via `onUpgrade`.

---

## Error Handling

API failures come back as typed `Resource.error` objects, never raw exceptions. The controller shows a snackbar and continues with local data — the app stays usable even with no network connection. Database errors bubble up through the same `Resource<T>` wrapper.

---

## App Icon

Generated with `flutter_launcher_icons`. The source is `assets/icons/app_icon.png` — a purple gradient background matching the app's color scheme with a white card and checkmark. Adaptive icon support is included for Android 8.0+.

To regenerate after changing the source image:
```bash
dart run flutter_launcher_icons
```

---

## Tech Stack

| Concern | Package |
|---|---|
| State management & DI | `get` 4.7.x (GetX) |
| Service locator | `get_it` 8.x |
| HTTP | `dio` 5.9.x |
| Local storage | `sqflite` 2.3.x |
| Local notifications | `flutter_local_notifications` 18.x |
| Timezone scheduling | `timezone` 0.9.x |
| ID generation | `uuid` 4.x |
| Icon generation | `flutter_launcher_icons` 0.14.x (dev) |

---

## Known Limitations

- No edit screen — tasks can be added or deleted but not modified after creation
- API seeding only retries on the next cold start if it fails on first launch
- No pagination — all tasks are loaded into memory at once
- Notification reminders don't survive a device reboot (no boot receiver registered)
