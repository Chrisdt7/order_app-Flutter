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

    return _buildMenuList(context, results);
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

    return _buildMenuList(context, suggestions);
  }

  // Reusable menu list builder
  Widget _buildMenuList(BuildContext context, List<Menu> menuList) {
    return ListView.builder(
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        Menu menu = menuList[index];
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          menu.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              width: 50, // Set desired width
              height: 50, // Set desired height
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  menu.image,
                  fit: BoxFit.cover,
                  key: Key(menu.image),
                ),
              ),
            ),
          ),
          title: Text(menu.name),
          subtitle:
              Text('${menu.price.toStringAsFixed(2)} \$ - ${menu.category}'),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: Icon(Icons.add_box_outlined),
                onPressed: () {
                  close(context, menu); // Return the selected menu item
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
