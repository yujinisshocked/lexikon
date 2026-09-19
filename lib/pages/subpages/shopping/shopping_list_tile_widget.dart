import 'package:flutter/material.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';

class ShoppingListTileWidget extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ShoppingListTileWidget({
    super.key,
    required this.shoppingList,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final boughtItems = shoppingList.items
        .where((item) => item.isBought)
        .length;

    final totalItems = shoppingList.items.length;

    return Dismissible(
      key: ValueKey(shoppingList.id),

      direction: DismissDirection.endToStart,

      // -----------------------------------------------------------------------
      // Swipe left → Delete
      // -----------------------------------------------------------------------

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        padding: const EdgeInsets.only(
          right: 20,
        ),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      onDismissed: (_) {
        onDelete();
      },

      // -----------------------------------------------------------------------
      // Shopping list card
      // -----------------------------------------------------------------------

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // Selected indicator
              // ----------------------------------------------------------------

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                width: shoppingList.isSelected ? 4 : 0,
                height: 72,
                color: shoppingList.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),

              // ----------------------------------------------------------------
              // Shopping list content
              // ----------------------------------------------------------------

              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),

                  title: Row(
                    children: [
                      if (shoppingList.isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(width: 6),
                      ],

                      Expanded(
                        child: Text(
                          shoppingList.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      '$boughtItems / $totalItems items bought',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),

              // ----------------------------------------------------------------
              // Drag handle
              // ----------------------------------------------------------------

              const Padding(
                padding: EdgeInsets.only(
                  right: 8,
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}