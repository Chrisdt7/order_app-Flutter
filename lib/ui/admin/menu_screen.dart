import 'package:flutter/material.dart';
import '../../models/menu.dart';
import '../../services/api_service.dart';
import '../../util/admin/menu/add_menu_screen.dart';
import '../../util/admin/menu/edit_menu_screen.dart';
import '../../util/admin/menu/search_menu_screen.dart';
import '../../widgets/sidebar.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  MenuScreen({required this.toggleTheme});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Menu>> futureMenus;
  List<Menu> menus = [];
  Map<String, List<Menu>> menuCategories = {};
  final List<String> categoryOrder = [
    'Foods',
    'Drinks',
    'Dessert',
    'Others'
  ]; // Desired order

  @override
  void initState() {
    super.initState();
    futureMenus = ApiService().getMenus();
    futureMenus.then((menus) {
      this.menus = menus;
      _groupMenusByCategory();
      for (var menu in menus) {
        precacheImage(AssetImage(menu.image), context);
      }
    }).catchError((error) {
      print('Error precaching images: $error');
    });
  }

  void _groupMenusByCategory() {
    menuCategories.clear();
    for (var menu in menus) {
      String categoryString = menu.category
          .toString()
          .split('.')
          .last; // Convert Category to String
      if (!menuCategories.containsKey(categoryString)) {
        menuCategories[categoryString] = [];
      }
      menuCategories[categoryString]!.add(menu);
    }
  }

  void refreshMenus() {
    setState(() {
      futureMenus = ApiService().getMenus();
    });

    futureMenus.then((menus) {
      this.menus = menus;
      _groupMenusByCategory();
      for (var menu in menus) {
        precacheImage(AssetImage(menu.image), context);
      }
    }).catchError((error) {
      print('Error precaching images: $error');
    });
  }

  Future<void> deleteMenu(int menuId) async {
    try {
      Menu menuToDelete = menus.firstWhere((menu) => menu.id == menuId);
      await ApiService().deleteMenu(menuId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      precacheImage(AssetImage(menuToDelete.image), context);
      refreshMenus(); // Refresh menus after deletion
    } catch (e) {
      print('Error deleting menu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete menu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onSearch(String value) {
    setState(() {
      // Handle search functionality here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text('Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MenuSearchDelegate(
                  menus: menus, // Pass the list of menus here
                  onSearch: onSearch,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: FutureBuilder<List<Menu>>(
        future: futureMenus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No menu items found'));
          } else {
            menus = snapshot.data!;
            _groupMenusByCategory();
            return ListView(
              children: categoryOrder.map((category) {
                if (menuCategories.containsKey(category)) {
                  return ExpansionTile(
                    title: Text(category),
                    children: menuCategories[category]!.map((menu) {
                      return ListTile(
                        leading: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset(
                            menu.image,
                            key: Key(menu.image),
                          ),
                        ),
                        title: Text(menu.name),
                        subtitle: Text(
                            '${menu.price.toStringAsFixed(2)} \$ - ${menu.category.toString().split('.').last}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final updatedMenu = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditMenuScreen(menu: menu),
                                  ),
                                );
                                if (updatedMenu != null) {
                                  // Update the menu in the list with the new values
                                  setState(() {
                                    menu = updatedMenu;
                                  });
                                  refreshMenus(); // Refresh menus after editing
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteMenu(menu.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 7.0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMenuScreen()),
          ).then((_) {
            refreshMenus();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
