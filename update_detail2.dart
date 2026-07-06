import 'dart:io';

void main() {
  final file = File('lib/screens/package_detail_screen.dart');
  String content = file.readAsStringSync();

  content = content.replaceAll(".state = ", ".set(");
  // Fix the .set( to have a closing parenthesis
  // Since we replaced ".state = x;" with ".set(x;" we need to fix it to ".set(x);"
  content = content.replaceAll(RegExp(r'\.set\((.*?);'), r'.set(\1);');

  content = content.replaceAll(".state--", ".decrement()");
  content = content.replaceAll(".state++", ".increment()");

  file.writeAsStringSync(content);
  print("Updated package_detail_screen.dart successfully");

  final file2 = File('lib/screens/welcome_screen.dart');
  String content2 = file2.readAsStringSync();

  content2 = content2.replaceAll(".state = ", ".set(");
  content2 = content2.replaceAll(RegExp(r'\.set\((.*?);'), r'.set(\1);');

  file2.writeAsStringSync(content2);
  print("Updated welcome_screen.dart successfully");
}
