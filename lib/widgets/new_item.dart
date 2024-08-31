import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_groceries/data/categories.dart';
import 'package:flutter_groceries/models/category.dart';
import 'package:flutter_groceries/models/grocery_item.dart';

import 'package:http/http.dart' as http;

class Newitem extends StatefulWidget {
  const Newitem({super.key});

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  //.. to validate the form data and access it
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _isSending = true;

//..POST request by http..
      final url = Uri.https('grocery-app-f4a5d-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredName,
            'category': _selectedCategory.title,
            'quantity': _enteredQuantity,
          },
        ),
      );

      if (!context.mounted) {
        return;
      }

      final Map<String, dynamic> resData = json.decode(response.body);

      Navigator.of(context).pop(
        GroceryItem(
            id: resData['name'],
            name: _enteredName,
            category: _selectedCategory,
            quantity: _enteredQuantity),
      );

//..storing in a variable and memory but not local device.../
      // Navigator.of(context).pop(
      //   GroceryItem(
      //       id: DateTime.now().toString(),
      //       name: _enteredName,
      //       category: _selectedCategory,
      //       quantity: _enteredQuantity),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),

                  //..error message showing by validation..
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Please put a valid info & try again';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value)! <= 0 ||
                              int.tryParse(value) == null) {
                            return 'Must be a valid & positive number';
                          }
                          return null;
                        },
                        initialValue: _enteredQuantity.toString(),
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(category.value.title),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //.. Reset the form..
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),

                    //.. Adding new item..
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveData,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
