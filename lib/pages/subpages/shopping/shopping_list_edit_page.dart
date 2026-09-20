import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_dialog.dart';
import 'package:lexikon/utils/controllers/shopping_controller.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';

class ShoppingListEditPage extends ConsumerStatefulWidget {
  const ShoppingListEditPage({super.key});

  @override
  ConsumerState<ShoppingListEditPage> createState() =>
      _ShoppingListEditPageState();
}

class _ShoppingListEditPageState
    extends ConsumerState<ShoppingListEditPage> {
  bool isAdding = false;

  String selectedId = '';
  ShoppingList? selectedList;

  final _itemController = TextEditingController();

  Future<ShoppingList?> getShoppingListDetails(String id) async {
    return await ref
        .read(shoppingControllerProvider.notifier)
        .getShoppingListDetails(id);
  }

  Future<void> loadSelectedList() async {
    final controller =
        ref.read(shoppingControllerProvider.notifier);

    final id = await controller.loadSelectedList();

    if (id.trim().isEmpty) {
      if (!mounted) return;

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

  Future<void> addItem(String name) async {
    if (selectedList == null) return;

    final item = ShoppingItem(
      name: name,
      quantity: 1,
    );

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

  Future<void> resetList(String id) async {
    try {
      await ref.read(shoppingControllerProvider.notifier).resetList(id);
      debugPrint("ResetList!");
    } catch(e) {
      debugPrint("Reset List Failed: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedList?.name ?? '',
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Are you sure you want to reset this list?"),
                      content: Text("(Check marks will be removed)"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          child: Text("Cancel")
                        ),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              resetList(selectedId);
                            });
                            if(context.mounted) Navigator.pop(context);
                          }, 
                          child: Text("Reset", style: TextStyle(color: Colors.red),)
                        )
                      ],
                    );
                  }
                );
              }, 
              child: Text("Reset")
            )
          ],
        ),
      ),

      floatingActionButton: IconButton(
        icon: const Icon(Icons.visibility),
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) => const ShoppingListDialog(),
          );

          if (result == null) return;

          await loadSelectedList();
        },
      ),

      body: selectedId.trim().isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: selectedList!.items.length + 1,
              itemBuilder: (context, index) {
                // Shopping items
                if (index < selectedList!.items.length) {
                  final item = selectedList!.items[index];

                  return _ShoppingItemWidget(
                    item: item,

                    onTap: () {},

                    onChanged: () async {
                      await updateList();

                      if (!mounted) return;

                      setState(() {});
                    },

                    onDelete: () async {
                      await deleteItem(item);
                    },
                  );
                }

                // Add item input
                if (isAdding) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Item name',
                          ),
                          onSubmitted: (value) async {
                            final name = value.trim();

                            if (name.isEmpty) return;

                            await addItem(name);

                            if (!mounted) return;

                            setState(() {
                              isAdding = false;
                              _itemController.clear();
                            });
                          },
                        ),
                      ),

                      // Cancel
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isAdding = false;
                            _itemController.clear();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),

                      // Save
                      IconButton(
                        onPressed: () async {
                          final name =
                              _itemController.text.trim();

                          if (name.isEmpty) return;

                          await addItem(name);

                          if (!mounted) return;

                          setState(() {
                            isAdding = false;
                            _itemController.clear();
                          });
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  );
                }

                // Add button
                return IconButton(
                  onPressed: () {
                    setState(() {
                      isAdding = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                );
              },
            ),
    );
  }
}

class _ShoppingItemWidget extends StatefulWidget {
  final ShoppingItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Future<void> Function() onChanged;

  const _ShoppingItemWidget({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_ShoppingItemWidget> createState() =>
      _ShoppingItemWidgetState();
}

class _ShoppingItemWidgetState
    extends State<_ShoppingItemWidget> {
  late final TextEditingController _controller;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.item.name,
    );

    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _updateIsBought(bool value) async {
    setState(() {
      widget.item.isBought = value;
    });

    await widget.onChanged();
  }

  Future<void> _updateName(String value) async {
    final name = value.trim();

    if (name.isEmpty) return;

    widget.item.name = name;

    await widget.onChanged();
  }

  Future<void> _updateQuantity(String value) async {
    final quantity = int.tryParse(value);

    if (quantity == null || quantity < 1) {
      setState(() {
        _qtyController.text =
            widget.item.quantity.toString();
        _qtyController.selection =
            TextSelection.collapsed(
          offset: _qtyController.text.length,
        );
      });

      return;
    }

    widget.item.quantity = quantity;

    await widget.onChanged();
  }

  Future<void> _reduceQuantity() async {
    final current =
        int.tryParse(_qtyController.text) ?? 1;

    if (current <= 1) return;

    final newValue = current - 1;

    setState(() {
      widget.item.quantity = newValue;
      _qtyController.text = newValue.toString();
    });

    await widget.onChanged();
  }

  Future<void> _addQuantity() async {
    final current =
        int.tryParse(_qtyController.text) ?? 1;

    final newValue = current + 1;

    setState(() {
      widget.item.quantity = newValue;
      _qtyController.text = newValue.toString();
    });

    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: widget.item.isBought,
            onChanged: (value) {
              if (value != null) {
                _updateIsBought(value);
              }
            },
          ),

          // Item name
          Expanded(
            flex: 75,
            child: TextField(
              controller: _controller,
              onSubmitted: _updateName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Quantity
          Expanded(
            flex: 20,
            child: quantityCounter(),
          ),

          // Delete
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget quantityCounter() {
    return Row(
      children: [
        // Reduce
        IconButton(
          onPressed: _reduceQuantity,
          icon: const Icon(Icons.remove),
        ),

        // Quantity
        Expanded(
          child: TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            onSubmitted: _updateQuantity,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),

        // Increase
        IconButton(
          onPressed: _addQuantity,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Load a list to continue',
      ),
    );
  }
}