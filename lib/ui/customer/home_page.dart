import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:order_app/widgets/CustomAppbar.dart';
import 'package:order_app/widgets/CustomBottomAppbar.dart';

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

class HomePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final AuthService _authService = AuthService();

  HomePage({required this.toggleTheme});

  Widget buildQuickAccessTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShapeAppBar(
        title: 'Home',
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Digi Restaurant!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                buildQuickAccessTile(
                  context,
                  icon: Icons.fastfood,
                  label: 'Menu',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/customer/menu'),
                ),
                buildQuickAccessTile(
                  context,
                  icon: Icons.camera,
                  label: 'Scan QR',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRViewExample()),
                  ),
                ),
                buildQuickAccessTile(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Orders',
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/customer/order'),
                ),
                buildQuickAccessTile(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/customer/profile'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.feedback),
              label: Text('Give Feedback'),
              onPressed: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),
          ),
        ],
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
