import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:order_app/models/user.dart';
import 'package:order_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:order_app/widgets/CustomAppbar.dart';
import 'package:order_app/widgets/CustomBottomAppbar.dart';
import '../../util/customer/profile/profile_field.dart';

class AuthService {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout Successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final VoidCallback toggleTheme;

  ProfilePage({required this.toggleTheme});

  Future<User?> _fetchUserData() async {
    final ApiService apiService = ApiService();
    try {
      final token = await apiService.getToken();
      if (token != null) {
        return await apiService.fetchUserDetails(token);
      }
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShapeAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Error loading profile data',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileField(title: 'Name', value: user.name ?? 'N/A'),
                      ProfileField(title: 'Email', value: user.email ?? 'N/A'),
                      ProfileField(
                          title: 'Username', value: user.username ?? 'N/A'),
                      ProfileField(title: 'Role', value: user.role ?? 'N/A'),
                      ProfileField(title: 'Phone', value: user.phone ?? 'N/A'),
                      ProfileField(
                          title: 'Address', value: user.address ?? 'N/A'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomShapeBottomAppBar(
        height: 120,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          IconButton(
            icon: Icon(Icons.fastfood),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/customer/menu');
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_enhance),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRViewExample()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_basket),
            onPressed: () {
              Navigator.pushNamed(context, '/customer/order');
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/customer/profile');
            },
          ),
        ],
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShapeAppBar(
        title: 'Scan QR Code',
      ),
      body: MobileScanner(
        key: qrKey,
        controller: cameraController,
        onDetect: (BarcodeCapture barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              handleQRCodeScanResult(code);
              break; // Exit after handling the first valid QR code.
            }
          }
        },
      ),
    );
  }

  void handleQRCodeScanResult(String qrCode) async {
    try {
      final isValid = await ApiService().checkQRValidity(qrCode);
      if (isValid) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid QR Code')),
        );
      }
    } catch (e) {
      print('Error checking QR code validity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking QR Code validity')),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
