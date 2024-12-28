import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout Succesfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

Future<Map<String, String>> _getUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? name = prefs.getString('name');
  String? email = prefs.getString('email');
  return {
    'name': name ?? '',
    'email': email ?? '',
  };
}

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return FutureBuilder<Map<String, String>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading user details'));
        } else {
          final userDetails = snapshot.data!;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userDetails['name']!),
                  accountEmail: Text(userDetails['email']!),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Dashboard"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text("Menu"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text("Tables"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/table');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit_note),
                  title: Text("Orders"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/order');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text("Reservation"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/reservation');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text("User Management"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/user');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text("Log Out"),
                  onTap: () async {
                    await _authService.logout(context);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
