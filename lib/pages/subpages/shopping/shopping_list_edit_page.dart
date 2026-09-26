import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_dialog.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_tile_widget.dart';
import 'package:lexikon/utils/controllers/shopping_controller.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';

class ShoppingListEditPage extends ConsumerStatefulWidget {
  const ShoppingListEditPage({super.key});

  @override
  ConsumerState<ShoppingListEditPage> createState() =>
      _ShoppingListEditPageState();
}

class _ShoppingListEditPageState extends ConsumerState<ShoppingListEditPage> {
  // State --

  bool isAdding = false;

  String selectedId = '';
  ShoppingList? selectedList;

  final _itemController = TextEditingController();

  // -- State

  // Shopping List --

  Future<ShoppingList?> getShoppingListDetails(String id) async {
    return ref
        .read(shoppingControllerProvider.notifier)
        .getShoppingListDetails(id);
  }

  Future<void> loadSelectedList() async {
    final controller = ref.read(shoppingControllerProvider.notifier);

    final id = await controller.loadSelectedList();

    if (!mounted) return;

    if (id.trim().isEmpty) {
      setState(() {
        selectedId = '';
        selectedList = null;
      });

      return;
    }

    final list = await getShoppingListDetails(id);

    if (!mounted) return;

    setState(() {
      selectedId = id;
      selectedList = list;
    });
  }

  Future<void> updateList() async {
    if (selectedList == null) return;

    await ref
        .read(shoppingControllerProvider.notifier)
        .updateShoppingList(selectedList!);
  }

  // -- Shopping List

  // Items --

  Future<void> addItem(String name) async {
    if (selectedList == null) return;

    final item = ShoppingItem(name: name, quantity: 1);

    selectedList!.items.add(item);

    await updateList();
    await loadSelectedList();
  }

  Future<void> deleteItem(ShoppingItem item) async {
    if (selectedList == null) return;

    selectedList!.items.remove(item);

    await updateList();
    await loadSelectedList();
  }

  Future<void> updateItem(ShoppingItem item) async {
    await updateList();
    await loadSelectedList();
  }

  // -- Items

  // Reset --

  Future<void> resetList(String id) async {
    try {
      await ref.read(shoppingControllerProvider.notifier).resetList(id);

      await loadSelectedList();
    } catch (e) {
      debugPrint('Reset list failed: $e');
    }
  }

  // -- Reset

  // Add Item Input --

  Future<void> submitNewItem() async {
    final name = _itemController.text.trim();

    if (name.isEmpty) return;

    await addItem(name);

    if (!mounted) return;

    setState(() {
      isAdding = false;
      _itemController.clear();
    });
  }

  void cancelAdding() {
    setState(() {
      isAdding = false;
      _itemController.clear();
    });
  }

  // -- Add Item Input

  // Lifecycle --

  @override
  void initState() {
    super.initState();
    loadSelectedList();
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  // -- Lifecycle

  // UI --

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedList?.name ?? ''),
        actions: [
          // Reset --

          if (selectedList != null)
            IconButton(
              tooltip: 'Reset',
              icon: const Icon(Icons.restart_alt),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Reset this list?'),
                      content: const Text(
                        'All checked items will be unchecked.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            await resetList(selectedId);

                            if (!context.mounted) return;

                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

          // -- Reset
        ],
      ),

      body: selectedList == null
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              children: [
                // Items --

                for (final item in selectedList!.items)
                  ShoppingListItemTile(
                    key: ValueKey(item),
                    item: item,
                    onChanged: () async {
                      await updateItem(item);
                    },
                    onDelete: () async {
                      await deleteItem(item);
                    },
                  ),

                // -- Items

                // Add Item --
                if (isAdding)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Item name',
                            ),
                            onSubmitted: (_) {
                              submitNewItem();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: cancelAdding,
                          icon: const Icon(Icons.close),
                        ),
                        IconButton(
                          onPressed: submitNewItem,
                          icon: const Icon(Icons.check),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isAdding = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                    ),
                  ),

                // -- Add Item
              ],
            ),

      // List Selector --
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Shopping lists',
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return const ShoppingListDialog();
            },
          );

          if (result == null) return;

          await loadSelectedList();
        },
        child: const Icon(Icons.list),
      ),

      // -- List Selector
    );
  }

  // -- UI
}

// Empty State --

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Load a list to continue',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

// -- Empty State
