import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_item.dart';

class ShoppingListItemTile extends StatefulWidget {
  final ShoppingItem item;
  final Future<void> Function() onChanged;
  final Future<void> Function() onDelete;

  const ShoppingListItemTile({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<ShoppingListItemTile> createState() => _ShoppingListItemTileState();
}

class _ShoppingListItemTileState extends State<ShoppingListItemTile> {
  // Controllers --

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;

  // -- Controllers

  // Lifecycle --

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.item.name);

    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // -- Lifecycle

  // Item State --

  Future<void> toggleBought() async {
    setState(() {
      widget.item.isBought = !widget.item.isBought;
    });

    await widget.onChanged();
  }

  Future<void> updateName(String value) async {
    final name = value.trim();

    if (name.isEmpty) return;

    widget.item.name = name;

    await widget.onChanged();
  }

  // -- Item State

  // Quantity --

  Future<void> decreaseQuantity() async {
    if (widget.item.quantity <= 1) return;

    setState(() {
      widget.item.quantity--;
      _quantityController.text = widget.item.quantity.toString();
    });

    await widget.onChanged();
  }

  Future<void> increaseQuantity() async {
    setState(() {
      widget.item.quantity++;
      _quantityController.text = widget.item.quantity.toString();
    });

    await widget.onChanged();
  }

  Future<void> updateQuantity(String value) async {
    final quantity = int.tryParse(value);

    if (quantity == null || quantity < 1) {
      _quantityController.text = widget.item.quantity.toString();

      _quantityController.selection = TextSelection.collapsed(
        offset: _quantityController.text.length,
      );

      return;
    }

    setState(() {
      widget.item.quantity = quantity;
    });

    await widget.onChanged();
  }

  // -- Quantity

  // Edit --

  Future<void> editName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return _EditItemDialog(initialName: widget.item.name);
      },
    );

    if (result == null) return;

    await updateName(result);
  }

  // -- Edit

  // Delete --

  Future<void> confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove item?'),
          content: Text('Remove "${widget.item.name}" from this list?'),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await widget.onDelete();
    }
  }

  // -- Delete

  // UI --

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = widget.item.isBought
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;

    final textColor = widget.item.isBought
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return Dismissible(
      key: ValueKey(widget.item),
      direction: DismissDirection.endToStart,

      // Swipe Delete --
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),

      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Remove item?'),
              content: Text('Remove "${widget.item.name}" from this list?'),
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
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        );
      },

      onDismissed: (_) {
        widget.onDelete();
      },

      // -- Swipe Delete
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onDoubleTap: toggleBought,
            onLongPress: editName,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Item --

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          widget.item.isBought ? 'Bought' : 'Not bought',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -- Item

                  // Quantity --
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: decreaseQuantity,
                        icon: const Icon(Icons.remove),
                      ),

                      SizedBox(
                        width: 30,
                        child: TextField(
                          controller: _quantityController,
                          enabled: !widget.item.isBought,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSubmitted: updateQuantity,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: increaseQuantity,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  // -- Quantity

                  // More --
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          editName();
                          break;

                        case 'delete':
                          confirmDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ];
                    },
                  ),

                  // -- More
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- UI
}

// Edit Item Dialog --

class _EditItemDialog extends StatefulWidget {
  final String initialName;

  const _EditItemDialog({required this.initialName});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void save() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit item'),

      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) {
          save();
        },
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}

// -- Edit Item Dialog
