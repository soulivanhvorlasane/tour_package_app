---
name: Create Flutter Project (Zero to Hero)
description: A comprehensive guide to initialize, structure, and configure a production-ready Flutter app with best practices.
---

# Create Flutter Project (Zero to Hero)

When the user asks you to create a new Flutter project, follow this "Zero to Hero" comprehensive process.

## 1. Project Initialization
- Run `flutter create <project_name> --org <com.yourdomain>`.
- Use `--empty` flag if you want a clean slate without the counter app, or just clean up `main.dart` yourself.

## 2. Dependencies Setup
Add the following essential dependencies using `flutter pub add`:
- **State Management**: `flutter_riverpod`, `riverpod_annotation`
- **Routing**: `go_router`
- **Networking/API**: `http` or `dio`
- **Local Storage**: `shared_preferences`
- **UI/Styling**: `google_fonts`, `cached_network_image`
- **Dev Dependencies**: `build_runner`, `riverpod_generator`, `flutter_lints`

## 3. Directory Structure
Create a scalable architecture in the `lib` folder:
```text
lib/
 ┣ core/
 ┃ ┣ constants/      (colors, dimensions, text styles)
 ┃ ┣ theme/          (app_theme.dart)
 ┃ ┗ utils/          (helpers, extensions)
 ┣ models/           (data classes, freezeds)
 ┣ providers/        (Riverpod state providers)
 ┣ repositories/     (API calls, database queries)
 ┣ router/           (go_router configuration)
 ┣ screens/          (main page layouts)
 ┣ widgets/          (reusable UI components)
 ┗ main.dart         (entry point, ProviderScope)
```

## 4. Main Setup (main.dart)
- Wrap `MyApp` with `ProviderScope`.
- Initialize `GoRouter`.
- Apply a beautiful default theme using Google Fonts and custom color schemes.

## 5. UI/UX Aesthetics
- Use rich aesthetics: vibrant colors, modern typography (Inter, Poppins), and glassmorphism.
- Avoid plain colors. Use smooth gradients and soft shadows.
- Micro-animations: Add `AnimatedContainer` or `Hero` transitions to make the app feel alive.

## 6. Implementation Workflow
- **Plan**: Understand requirements, define models.
- **Foundation**: Set up `app_theme.dart`, routing, and basic layout structure.
- **State & Logic**: Build out repositories and Riverpod providers.
- **UI**: Construct reusable widgets and assemble screens.
- **Polish**: Test responsivenes and add interactive hover/tap effects.
