part of 'hive_service.dart';

class HiveServiceShoppingItems {
  static String get _boxName => "LEXIKON_SHOPPING_ITEM";

  static Box<ShoppingItem> get _box =>
      HiveService.getBox<ShoppingItem>(_boxName);

  // Create
  static Future<void> addShoppingItem(
    ShoppingItem shoppingItem,
  ) async {
    await _box.add(shoppingItem);
  }

  // Read all
  static List<ShoppingItem> getShoppingItems() {
    return _box.values.toList();
  }

  // Update
  static Future<void> updateShoppingItem(
    ShoppingItem shoppingItem,
  ) async {
    await shoppingItem.save();
  }

  // Delete
  static Future<void> deleteShoppingItem(
    ShoppingItem shoppingItem,
  ) async {
    await shoppingItem.delete();
  }

  // Delete all
  static Future<void> clearShoppingItems() async {
    await _box.clear();
  }
}