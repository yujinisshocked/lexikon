import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';
import 'package:lexikon/utils/services/hive_service.dart';

class ShoppingRepository {
  List<ShoppingList> getShoppingLists() {
    return HiveServiceShoppingLists.getShoppingLists();
  }

  Future<void> addList(ShoppingList shoppingList) async {
    return HiveServiceShoppingLists.createShoppingList(shoppingList);
  }

  Future<void> setDefaultList() async {
  }
}

