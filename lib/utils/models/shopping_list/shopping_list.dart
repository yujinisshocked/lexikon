import 'package:hive/hive.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 2)
class ShoppingList extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ShoppingItem> items;

  @HiveField(3)
  bool isSelected;

  @HiveField(4)
  int sortOrder;

  ShoppingList({
    required this.id,
    required this.name, 
    required this.items,
    this.isSelected = false,
    this.sortOrder = 0,
  });
}