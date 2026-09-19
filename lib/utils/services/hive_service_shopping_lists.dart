part of 'hive_service.dart';

extension HiveServiceShoppingLists on HiveService {
  static String get _boxName => 'LEXIKON_SHOPPING';

  // Helper to fetch the shopping box safely
  static Box<ShoppingList> get _shoppingBox => 
      HiveService.getBox<ShoppingList>(_boxName);

  // 1. Create / Add List
  static Future<void> createShoppingList(ShoppingList shoppingList) async {
    await _shoppingBox.put(shoppingList.id, shoppingList);
  }

  // 2. Get All Lists
  static List<ShoppingList> getShoppingLists() {
    return _shoppingBox.values.toList();
  }

  // 3. Get Single List by ID
  static ShoppingList? getShoppingListById(String id) {
    return _shoppingBox.get(id);
  }

  // 6. Reset Checkout State (Unchecks items & clears selected list)
  static Future<void> resetListSession(String listId) async {
    final list = getShoppingListById(listId);

    if (list != null) {
      for (final item in list.items) {
        item.isBought = false;
      }

      // list.isSelected = false;

      await list.save();
      debugPrint("Item reset! - List: ${list.name}");
    }
  }

  // 7. Toggle an Item's Purchased Status
  static Future<void> toggleItemBought(String listId, int itemIndex) async {
    final list = getShoppingListById(listId);
    if (list != null && itemIndex < list.items.length) {
      list.items[itemIndex].isBought = !list.items[itemIndex].isBought;
      await list.save();
    }
  }

  // 8. Update List Details
  static Future<void> updateShoppingList(ShoppingList shoppingList) async {
    await shoppingList.save();
  }

  // 9. Delete List
  static Future<void> deleteShoppingList(String id) async {
    await _shoppingBox.delete(id);
  }

  // 10. Set a selected list
  static Future<void> setSelectedList(String id) async {
    for (final list in _shoppingBox.values) {
      final selected = list.id == id;

      if (list.isSelected != selected) {
        list.isSelected = selected;
        await list.save();
      }
    }
  }

  static Future<String> loadSelectedList() async {
    for (final list in _shoppingBox.values) {
      if (list.isSelected) return list.id;
    }
    return '';
  }

}