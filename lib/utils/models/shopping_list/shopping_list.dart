import 'package:hive/hive.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 3)
class ShoppingList extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  bool isSelected;

  @HiveField(2)
  String name;

  @HiveField(3)
  List<ShoppingItem> items;

  @HiveField(4)
  int sortOrder;

  ShoppingList({
    required this.id,
    this.isSelected = false,
    required this.name, 
    required this.items,
    this.sortOrder = 0,
  });
}