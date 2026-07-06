---
name: using-riverpod-state-management
description: A comprehensive, zero-to-hero guide on implementing Riverpod state management in Flutter, including Notifiers, AsyncValue, and best practices.
---

# Using Riverpod State Management (Zero to Hero)

This skill provides a complete guide to mastering Riverpod state management in Flutter, taking you from basic setup to advanced architectural patterns.

## 1. Setup & Installation

To use Riverpod, add it to your `pubspec.yaml` and wrap your app in a `ProviderScope`.

**pubspec.yaml**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0 # Or the latest version
```

**main.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // ProviderScope is REQUIRED at the root of the app
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## 2. Choosing the Right Provider

Riverpod offers several types of providers. Always use the modern `Notifier` and `AsyncNotifier` classes over the older `StateProvider` and `StateNotifier`.

- **Provider**: For exposing static values, configurations, or classes that don't change (e.g., a repository).
- **FutureProvider**: For asynchronous operations that return a value once (e.g., fetching a user profile on load).
- **NotifierProvider**: For complex synchronous state that changes over time (replaces `StateNotifier`).
- **AsyncNotifierProvider**: For complex asynchronous state that changes over time.

## 3. Creating Providers

### A. Simple Values (Provider)
```dart
final greetingProvider = Provider<String>((ref) {
  return 'Hello, World!';
});
```

### B. Asynchronous Data (FutureProvider)
```dart
final userProfileProvider = FutureProvider.autoDispose<User>((ref) async {
  // .autoDispose ensures the state is destroyed when no longer listened to
  final api = ref.read(apiClientProvider);
  return api.fetchUserProfile();
});
```

### C. Synchronous Mutable State (NotifierProvider)
Use this for UI state like counters, selected indices, or form inputs.
```dart
class CounterNotifier extends Notifier<int> {
  @override
  int build() {
    // Initial state
    return 0;
  }

  // Define methods to mutate the state
  void increment() {
    state++; // 'state' is a protected variable exposed by Notifier
  }
  
  void set(int value) {
    state = value;
  }
}

final counterProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);
```

## 4. Consuming Providers in the UI

To read providers, your widgets need access to a `WidgetRef`.

### Method 1: ConsumerWidget (For Stateless Widgets)
```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.watch to rebuild the widget when the value changes
    final count = ref.watch(counterProvider);

    return Scaffold(
      body: Center(child: Text('Count: $count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use ref.read inside callbacks/events to read without rebuilding
          ref.read(counterProvider.notifier).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Method 2: ConsumerStatefulWidget (For Stateful Widgets)
```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // 'ref' is available natively anywhere inside a ConsumerState!
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

## 5. Handling Async Data (AsyncValue)

When you watch a `FutureProvider` or `AsyncNotifier`, you receive an `AsyncValue` which elegantly handles loading and error states.

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final userAsyncValue = ref.watch(userProfileProvider);

  return userAsyncValue.when(
    data: (user) => Text('Welcome, ${user.name}'),
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

## 6. Best Practices & Rules of Thumb

1. **Avoid `ref.read` in the `build` method**: Always use `ref.watch` inside `build()`. Only use `ref.read` in callbacks like `onPressed` or `initState`.
2. **Use `autoDispose` by default**: When creating a provider, default to `.autoDispose` (e.g., `NotifierProvider.autoDispose`) unless you explicitly need the state to survive globally forever. This prevents memory leaks.
3. **Prefer `Notifier` over `StateProvider`**: In modern Riverpod architectures, exposing explicit methods (like `.increment()`) via a `Notifier` is preferred over allowing external widgets to blindly overwrite state.
4. **Keep UI dumb**: Your widgets should only display data and dispatch events. Put all complex business logic, API calls, and calculations inside your Notifiers.
