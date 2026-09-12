import 'package:hive/hive.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 2)
class ShoppingList {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> items;

  @HiveField(2)
  bool isSelected;

  ShoppingList({
    required this.name, 
    required this.items,
    this.isSelected = false,
  });
}