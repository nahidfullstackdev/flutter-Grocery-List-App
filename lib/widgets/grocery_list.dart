import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_groceries/data/categories.dart';

import 'package:flutter_groceries/models/grocery_item.dart';
import 'package:flutter_groceries/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

//.. fetching data from backened ..
  void _loadData() async {
    final url = Uri.https(
        'grocery-app-f4a5d-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to Fetch data. Please try again later';
      });
    }

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedList = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;

      loadedList.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          category: category,
          quantity: item.value['quantity'],
        ),
      );
    }
    setState(() {
      _groceryItems = loadedList;
      _isLoading = false;
    });
  }

  //adding new item...
  void _addItem() async {
    final newItems =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (ctx) => const Newitem(),
    ));

    if (newItems == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItems);
      _isLoading = false;
    });
  }

//..removing items....
  void _removeItem(GroceryItem item) async {
    final itemIndex = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('grocery-app-f4a5d-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Items deleted'),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _groceryItems.insert(itemIndex, item);
              });
            }),
      ),
    );

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(itemIndex, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet...'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
