import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _setDefaultList() async {
    return await _repo.setDefaultList();
  }

  Future<void> addList(ShoppingList shoppingList) async {
    await _repo.addList(shoppingList);
    _loadShoppingLists;
  }
}