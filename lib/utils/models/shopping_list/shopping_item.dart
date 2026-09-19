import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 4)
class ShoppingItem extends HiveObject{
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isBought;

  @HiveField(2)
  int quantity;

  ShoppingItem({
    required this.name, 
    this.isBought = false,
    required this.quantity,
  });
}