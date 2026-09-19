import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';
import 'package:lexikon/utils/repositories/shopping_repository.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository();
});

final shoppingControllerProvider = 
  StateNotifierProvider<ShoppingController, List<ShoppingList>>((ref) {
    return ShoppingController(
      ref.read(shoppingRepositoryProvider)
    );
  });

class ShoppingController extends StateNotifier<List<ShoppingList>>{
  final ShoppingRepository _repo;

  ShoppingController(this._repo) : super([]) {
    _loadShoppingLists();
  }

  void _loadShoppingLists() {
    final shoppingLists = _repo.getShoppingLists();

    shoppingLists.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder)
    );

    state = shoppingLists;
   
  }

  Future<void> setSelectedList(String id) async {
    return await _repo.setSelectedList(id);
  }

  Future<void> addList(ShoppingList shoppingList) async {
    await _repo.addList(shoppingList);
    _loadShoppingLists();
  }

  Future<void> removeList(String id) async {
    await _repo.removeList(id);
    _loadShoppingLists();
  }

  Future<String> loadSelectedList() async {
    return await _repo.loadSelectedList();
  }

  Future<ShoppingList?> getShoppingListDetails(String id) async {
    return await _repo.getShoppingListById(id);
  }

  Future<void> updateShoppingList(ShoppingList shoppingList) async {
    return await _repo.updateShoppingList(shoppingList);
  }

  // Controllers for ShoppingItem

  Future<void> updateShoppingItem(ShoppingItem shoppingItem) async{
    return await _repo.updateShoppingItem(shoppingItem);
  }

  Future<void> addItem(String name) async {
    return await _repo.addItem(name);
  }

  Future<void> resetList(String id) async {
    return await _repo.resetList(id);
  }
}