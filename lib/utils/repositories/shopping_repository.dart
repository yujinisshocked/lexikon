import 'package:flutter/material.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class ShoppingRepository {
  List<ShoppingList> getShoppingLists() {
    return HiveServiceShoppingLists.getShoppingLists();
  }

  Future<void> addList(ShoppingList shoppingList) async {
    return HiveServiceShoppingLists.createShoppingList(shoppingList);
  }

  Future<void> removeList(String id) async {
    return HiveServiceShoppingLists.deleteShoppingList(id);
  }

  Future<void> setSelectedList(String id) async {
    return HiveServiceShoppingLists.setSelectedList(id);
  }

  Future<String> loadSelectedList() async {
    return HiveServiceShoppingLists.loadSelectedList();
  }

  Future<ShoppingList?> getShoppingListById(String id) async {
    return HiveServiceShoppingLists.getShoppingListById(id);
  }

  Future<void> updateShoppingList(ShoppingList shoppingList) async {
    await HiveServiceShoppingLists.updateShoppingList(shoppingList);
  }

  // Repositories for ShopppingItem
  Future<void> updateShoppingItem(ShoppingItem shoppingItem) async {
    return HiveServiceShoppingItems.updateShoppingItem(shoppingItem);
  }

  Future<void> addItem(String name) async {
    try {
      final item = ShoppingItem(
        name: name, 
        quantity: 0
      );

      return await HiveServiceShoppingItems.addShoppingItem(item);
    } catch (e) {
      debugPrint("Add Item Repo Failed - $e");
    }
  }

  Future<void> resetList(String id) async {
    await HiveServiceShoppingLists.resetListSession(id);
  }
}

