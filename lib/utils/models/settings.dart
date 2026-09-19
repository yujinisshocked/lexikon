import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings {
  // Shopping List
  @HiveField(0)
  final String activeShoppingId;

  Settings({
    required this.activeShoppingId,
  });
}