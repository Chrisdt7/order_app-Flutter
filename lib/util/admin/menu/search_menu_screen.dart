import 'package:flutter/material.dart';
import '/models/menu.dart';

class MenuSearchDelegate extends SearchDelegate<Menu?> {
  final List<Menu> menus;
  final ValueChanged<String> onSearch;

  MenuSearchDelegate({
    required this.menus,
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Ensure to handle null return properly
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Menu> results = query.isEmpty
        ? []
        : menus
            .where((menu) =>
                menu.name.toLowerCase().contains(query.toLowerCase()) ||
                menu.category
                    .toString()
                    .split('.')
                    .last
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        Menu menu = results[index];
        return ListTile(
          title: Text(menu.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: \$${menu.price.toStringAsFixed(2)}'),
              Text('Description: ${menu.description}'),
              Text('Category: ${menu.category.toString().split('.').last}'),
            ],
          ),
          onTap: () {
            close(context, menu); // Return the selected menu item
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Menu> suggestions = query.isEmpty
        ? []
        : menus
            .where((menu) =>
                menu.name.toLowerCase().contains(query.toLowerCase()) ||
                menu.category
                    .toString()
                    .split('.')
                    .last
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        Menu menu = suggestions[index];
        return ListTile(
          title: Text(menu.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: \$${menu.price.toStringAsFixed(2)}'),
              Text('Category: ${menu.category.toString().split('.').last}'),
            ],
          ),
          onTap: () {
            query = menu.name; // or any other field you want to use
            onSearch(query);
          },
        );
      },
    );
  }
}
