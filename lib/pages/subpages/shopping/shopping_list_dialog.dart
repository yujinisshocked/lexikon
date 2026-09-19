import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexikon/pages/subpages/shopping/shopping_list_tile_widget.dart';
import 'package:lexikon/utils/controllers/shopping_controller.dart';
import 'package:lexikon/utils/models/shopping_list/shopping_list.dart';

bool _isAdding = false;


class ShoppingListDialog extends ConsumerStatefulWidget {
  const ShoppingListDialog({super.key});

  @override
  ConsumerState<ShoppingListDialog> createState() => _ShoppingListDialogState();
}

class _ShoppingListDialogState extends ConsumerState<ShoppingListDialog> {

  @override
  Widget build(BuildContext context) {
    final shoppingLists = ref.watch(shoppingControllerProvider);

    final listCtrl = ref.read(shoppingControllerProvider.notifier);

    Future<void> removeList(String id) async {
      try {
        await listCtrl.removeList(id);
        debugPrint("Removed List: $id");
      } catch (e) {
        debugPrint("Remove List failed - $e");
      }
    }

    Future<void> loadList(String id) async {
      try {
        // Set the selected list
        await listCtrl.setSelectedList(id);

        if(!context.mounted) return;
        // Load the list
        if (id.isNotEmpty) Navigator.pop(context, id);
        

        debugPrint("List $id set!");
      } catch (e) {
        debugPrint("Load list failed! $e");
      }
    }

    return Dialog(
      child: shoppingLists.isEmpty ? _EmptyState() : Scaffold(
        floatingActionButton: IconButton(
          onPressed: () {
            showDialog(
              context: context, 
              builder: (context) {
                return _AddList();
              }
            );
          }, 
          icon: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: shoppingLists.length,
          itemBuilder: (BuildContext context, int index) {
            final shoppingList = shoppingLists[index];
            return ShoppingListTileWidget(
              shoppingList: shoppingList, 
              onTap: () {
                debugPrint("${shoppingList.id} tapped!");
                loadList(shoppingList.id);
              }, 
        
              onDelete: () {
                removeList(shoppingList.id);
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerStatefulWidget {
  const _EmptyState({super.key});

  @override
  ConsumerState<_EmptyState> createState() => __EmptyStateState();
}

class __EmptyStateState extends ConsumerState<_EmptyState> {


  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 14,
        children: [
          Text("No lists yet!"),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: (context) {
                  return _AddList();
                }
              );
            }, 
            child: Text("Create a new list"),
          ),
        ],
      ),      
    );
  }
}

class _AddList extends ConsumerStatefulWidget {
  const _AddList({super.key});

  @override
  ConsumerState<_AddList> createState() => __AddListState();
}

class __AddListState extends ConsumerState<_AddList> {

  final _controller = TextEditingController();

  Future<void> _createList() async{
    if (_isAdding) return;
    
    final ctrl = ref.read(shoppingControllerProvider.notifier);

    // Prepare the details
    final name = _controller.text;
    final id = "ShoppingList-${DateTime.now().millisecondsSinceEpoch}";
    // Create empty shoppingList
    final shoppingList = ShoppingList(
      id: id, 
      name: name, 
      items: []
    );

    try {
      await ctrl.addList(shoppingList);
      if (context.mounted) Navigator.pop(context);
      debugPrint("Create List Succeded");
    } catch (e) {
      debugPrint("Create List failed - $e");
    }
  }

  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 14,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: _controller,
              style: TextStyle(),
            ),
            ElevatedButton(
              onPressed: _createList, 
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}

