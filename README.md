# New Lane

Production-ready Flutter project scaffold for `New Lane`, organized with a
feature-first Clean Architecture setup inspired by `korah_fe`, but without
business features.

## Architecture

```text
lib/
  app/
    app.dart
    bootstrap.dart
  core/
    config/
    constants/
    di/
    errors/
    network/
    router/
    storage/
    theme/
    usecases/
  features/
    architecture/
      data/
      domain/
      presentation/
    splash/
      presentation/
  shared/
    widgets/
config/
  env/
```

## Principles

- Feature-first modules with isolated `data`, `domain`, and `presentation`.
- Shared cross-cutting concerns inside `core`.
- Centralized app bootstrap for initialization and environment validation.
- Router-first navigation using `go_router`.
- BLoC/Cubit-ready presentation layer using `flutter_bloc`.
- Environment-driven configuration using `--dart-define-from-file`.

## Run

```bash
flutter run --dart-define-from-file=config/env/development.json
```

## Add a new feature

Create the feature under `lib/features/<feature_name>/` with:

- `data/datasources`
- `data/models`
- `data/repositories`
- `domain/entities`
- `domain/repositories`
- `domain/usecases`
- `presentation/cubit` or `presentation/bloc`
- `presentation/pages`
- `presentation/widgets`

Keep framework code in `presentation`, orchestration in `domain`, and external
I/O in `data`.
