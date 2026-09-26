import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/utils/controllers/shopping_controller.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';

class ShoppingListDialog extends ConsumerStatefulWidget {
  const ShoppingListDialog({super.key});

  @override
  ConsumerState<ShoppingListDialog> createState() => _ShoppingListDialogState();
}

class _ShoppingListDialogState extends ConsumerState<ShoppingListDialog> {
  // List Actions --

  Future<void> loadList(String id) async {
    final controller = ref.read(shoppingControllerProvider.notifier);

    await controller.setSelectedList(id);

    if (!mounted) return;

    Navigator.pop(context, id);
  }

  Future<void> removeList(String id) async {
    final controller = ref.read(shoppingControllerProvider.notifier);

    await controller.removeList(id);
  }

  // -- List Actions

  // Create List --

  Future<void> createList() async {
    await showDialog(
      context: context,
      builder: (context) {
        return const _AddList();
      },
    );
  }

  // -- Create List

  // Delete Confirmation --

  Future<bool> confirmDelete(ShoppingList shoppingList) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete list?'),
          content: Text('Delete "${shoppingList.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // -- Delete Confirmation

  // UI --

  @override
  Widget build(BuildContext context) {
    final shoppingLists = ref.watch(shoppingControllerProvider);

    return Dialog(
      child: SafeArea(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header --

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        'Shopping Lists',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: createList,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                // -- Header
                const SizedBox(height: 8),

                // Lists --
                Flexible(
                  child: shoppingLists.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No shopping lists yet.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: shoppingLists.length,
                          itemBuilder: (context, index) {
                            final shoppingList = shoppingLists[index];

                            return Dismissible(
                              key: ValueKey(shoppingList.id),
                              direction: DismissDirection.endToStart,

                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.only(right: 20),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                              ),

                              confirmDismiss: (_) {
                                return confirmDelete(shoppingList);
                              },

                              onDismissed: (_) {
                                removeList(shoppingList.id);
                              },

                              child: _ShoppingListRow(
                                shoppingList: shoppingList,
                                onTap: () {
                                  loadList(shoppingList.id);
                                },
                              ),
                            );
                          },
                        ),
                ),

                // -- Lists
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- UI
}

// Shopping List Row --

class _ShoppingListRow extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;

  const _ShoppingListRow({required this.shoppingList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final boughtItems = shoppingList.items
        .where((item) => item.isBought)
        .length;

    final totalItems = shoppingList.items.length;

    final backgroundColor = shoppingList.isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shoppingList.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '$boughtItems / $totalItems items bought',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                if (shoppingList.isSelected)
                  Icon(Icons.check, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Shopping List Row

// Add List --

class _AddList extends ConsumerStatefulWidget {
  const _AddList();

  @override
  ConsumerState<_AddList> createState() => _AddListState();
}

class _AddListState extends ConsumerState<_AddList> {
  final _controller = TextEditingController();

  bool _isCreating = false;

  Future<void> createList() async {
    if (_isCreating) return;

    final name = _controller.text.trim();

    if (name.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    final controller = ref.read(shoppingControllerProvider.notifier);

    final shoppingList = ShoppingList(
      id: 'ShoppingList-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      items: [],
    );

    try {
      await controller.addList(shoppingList);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Create list failed: $e');

      if (!mounted) return;

      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create new list'),

      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'E.g. Groceries'),
        onSubmitted: (_) {
          createList();
        },
      ),

      actions: [
        TextButton(
          onPressed: _isCreating
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: _isCreating ? null : createList,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// -- Add List
