import 'package:flutter/material.dart';
import '/models/menu.dart';

import 'package:order_app/widgets/CustomAppbar.dart';
import 'package:order_app/widgets/CustomBottomAppbar.dart';

class OrderPage extends StatelessWidget {
  final List<Menu> selectedItems;

  OrderPage({required this.selectedItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShapeAppBar(
        title: 'Order',
      ),
      body: ListView.builder(
        itemCount: selectedItems.length,
        itemBuilder: (context, index) {
          Menu menu = selectedItems[index];
          return ListTile(
            leading: Image.asset(menu.image),
            title: Text(menu.name),
            subtitle:
                Text('${menu.price.toStringAsFixed(2)} \$ - ${menu.category}'),
          );
        },
      ),
      bottomNavigationBar: CustomShapeBottomAppBar(height: 120, actions: [
        ElevatedButton(
          onPressed: () {
            // Handle order submission logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order Submitted')),
            );
          },
          child: Text('Submit Order'),
        ),
      ]),
    );
  }
}
