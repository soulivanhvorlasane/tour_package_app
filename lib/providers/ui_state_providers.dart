import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCategoryIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}
final selectedCategoryIndexProvider = NotifierProvider<SelectedCategoryIndexNotifier, int>(SelectedCategoryIndexNotifier.new);

class CurrentCarouselIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}
final currentCarouselIndexProvider = NotifierProvider<CurrentCarouselIndexNotifier, int>(CurrentCarouselIndexNotifier.new);

class SelectedDateIndexNotifier extends Notifier<int> {
  @override
  int build() => -1;
  void set(int value) => state = value;
}
final selectedDateIndexProvider = NotifierProvider<SelectedDateIndexNotifier, int>(SelectedDateIndexNotifier.new);

class SeatsNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void set(int value) => state = value;
  void increment() => state++;
  void decrement() => state--;
}
final seatsProvider = NotifierProvider<SeatsNotifier, int>(SeatsNotifier.new);
