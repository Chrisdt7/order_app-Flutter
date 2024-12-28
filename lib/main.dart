import 'package:flutter/material.dart';
import 'ui/admin/menu_screen.dart';
import 'ui/admin/table_screen.dart';
import 'ui/customer/home_page.dart';
import 'ui/admin/dashboard_screen.dart';
import 'ui/customer/menu_page.dart';
import 'ui/customer/order_page.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/register_screen.dart';
import 'ui/customer/profile_page.dart';

void main() {
  runApp(MyApp());
}

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    color: Colors.blue,
    centerTitle: true,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.blue,
  ),
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    color: Colors.black,
    centerTitle: true,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.black,
  ),
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        // Admin
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/table': (context) => TableScreen(toggleTheme: _toggleTheme),
        '/menu': (context) => MenuScreen(toggleTheme: _toggleTheme),
        '/home': (context) => HomePage(toggleTheme: _toggleTheme),
        '/dashboard': (context) => DashboardScreen(toggleTheme: _toggleTheme),
        '/sidebar': (context) => DashboardScreen(toggleTheme: _toggleTheme),

        // Customer
        '/customer/profile': (context) =>
            ProfilePage(toggleTheme: _toggleTheme),
        '/customer/menu': (context) => MenuPage(toggleTheme: _toggleTheme),
        '/customer/order': (context) => OrderPage(
              selectedItems: [],
            ),
      },
    );
  }
}
