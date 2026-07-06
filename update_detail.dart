import 'dart:io';

void main() {
  final file = File('lib/screens/package_detail_screen.dart');
  String content = file.readAsStringSync();

  content = content.replaceFirst(
      "import '../providers/package_provider.dart';",
      "import '../providers/package_provider.dart';\nimport '../providers/ui_state_providers.dart';");

  content = content.replaceFirst(
      "class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {\n  int _selectedDateIndex = 0;\n  int _seats = 1;\n  int _currentCarouselIndex = 0;",
      "class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {");

  content = content.replaceFirst(
      "final displayPackage = detailAsyncValue.value ?? widget.package;",
      "final displayPackage = detailAsyncValue.value ?? widget.package;\n    final selectedDateIndex = ref.watch(selectedDateIndexProvider);\n    final seats = ref.watch(seatsProvider);\n    final currentCarouselIndex = ref.watch(currentCarouselIndexProvider);");

  content = content.replaceFirst(
      "double totalPrice = displayPackage.price * _seats;",
      "double totalPrice = displayPackage.price * seats;");

  content = content.replaceFirst(
      "setState(() {\n                                _currentCarouselIndex = index;\n                              });",
      "ref.read(currentCarouselIndexProvider.notifier).state = index;");

  content = content.replaceFirst(
      "_currentCarouselIndex == entry.key", "currentCarouselIndex == entry.key");

  content = content.replaceFirst(
      "bool isSelected = _selectedDateIndex == idx;",
      "bool isSelected = selectedDateIndex == idx;");

  content = content.replaceFirst(
      "setState(() {\n                                  _selectedDateIndex = idx;\n                                  if (_seats > calendar.remainingSeats) _seats = calendar.remainingSeats;\n                                });",
      "ref.read(selectedDateIndexProvider.notifier).state = idx;\n                                if (ref.read(seatsProvider) > calendar.remainingSeats) {\n                                  ref.read(seatsProvider.notifier).state = calendar.remainingSeats;\n                                }");

  content = content.replaceAll(
      "_selectedDateIndex", "selectedDateIndex");

  content = content.replaceFirst(
      "if (_seats > 1) setState(() => _seats--);",
      "if (ref.read(seatsProvider) > 1) ref.read(seatsProvider.notifier).state--;");

  content = content.replaceFirst(
      "Text('\$_seats',",
      "Text('\$seats',");

  content = content.replaceFirst(
      "if (_seats < displayPackage.calendars[selectedDateIndex].remainingSeats) {\n                                              setState(() => _seats++);\n                                            }",
      "if (ref.read(seatsProvider) < displayPackage.calendars[selectedDateIndex].remainingSeats) {\n                                              ref.read(seatsProvider.notifier).state++;\n                                            }");

  file.writeAsStringSync(content);
  print("Updated successfully");
}
