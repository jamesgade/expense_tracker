import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory = Category.leisure;

  // var _expenseTitle = '';  //alt-1
  // void getTitleValue(String inputValue) {
  //   _expenseTitle = inputValue;
  // }

  void _displayDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showAlertDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (cupContext) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please enter a valid title, amount, date are entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(cupContext);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please enter a valid title, amount, date are entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    }
  }

  void _createNewExpense() {
    final enteredAmount = double.tryParse(_amountController
        .text); // tryParse('Hello') => null, tryParse('1.12') => 1.12
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      _showAlertDialog();
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory!,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose(); // cleanup controller from memory
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (lbCtx, constraints) {
      final width = constraints.maxHeight;
      final height = constraints.maxWidth;
      print('WIDTH');
      print(width);
      print('HEIGHT');
      print(height);

      return SizedBox(
        height: 900,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              children: [
                width <= 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              // onChanged: getTitleValue,    // alt-1
                              maxLength: 50,
                              decoration: const InputDecoration(
                                label: Text('Title'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                // prefixText: '\$',    // since dollar is reserved symbol in string
                                prefixText: '₹',
                                label: Text('Amount'),
                              ),
                            ),
                          ),
                        ],
                      )
                    : TextField(
                        controller: _titleController,
                        // onChanged: getTitleValue,    // alt-1
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                      ),
                width <= 600
                    ? Row(
                        children: [
                          DropdownButton(
                            value: _selectedCategory,
                            items: Category.values
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (_selectedCategory == null) {
                                return;
                              }
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'No Date Selected'
                                      : formatter.format(_selectedDate!),
                                ),
                                IconButton(
                                  onPressed: _displayDatePicker,
                                  icon: const Icon(
                                    Icons.calendar_month,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                // prefixText: '\$',    // since dollar is reserved symbol in string
                                prefixText: '₹',
                                label: Text('Amount'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'No Date Selected'
                                      : formatter.format(_selectedDate!),
                                ),
                                IconButton(
                                  onPressed: _displayDatePicker,
                                  icon: const Icon(
                                    Icons.calendar_month,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                const SizedBox(height: 16),
                if (width <= 600)
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _createNewExpense,
                        child: const Text('Save Expense'),
                      )
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton(
                        value: _selectedCategory,
                        items: Category.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (_selectedCategory == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _createNewExpense,
                        child: const Text('Save Expense'),
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
      );
    });
  }
}
