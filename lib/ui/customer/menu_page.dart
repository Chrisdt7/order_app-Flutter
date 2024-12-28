import 'package:flutter/material.dart';
import '/models/menu.dart';
import '/models/order.dart';
import '/models/order_detail.dart';
import '/services/api_service.dart';
import '../../util/customer/menu/search_menu_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:order_app/widgets/CustomAppbar.dart';
import 'package:order_app/widgets/CustomBottomAppbar.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  MenuPage({required this.toggleTheme});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<Menu>> futureMenus;
  List<Menu> menus = [];
  List<OrderDetail> orderDetails = [];

  @override
  void initState() {
    super.initState();
    futureMenus = ApiService().getMenus();
  }

  void refreshMenus() {
    setState(() {
      futureMenus = ApiService().getMenus();
    });
  }

  void onSearch(String value) {
    setState(() {
      menus = value.isEmpty
          ? []
          : menus
              .where((menu) =>
                  menu.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
    });
  }

  void _addToOrder(Menu menu) {
    setState(() {
      final existingOrderDetail = orderDetails.firstWhere(
        (detail) => detail.id_menus == menu.id,
        orElse: () => OrderDetail(
          id: 0,
          id_orders: 0,
          id_menus: menu.id,
          quantity: 0,
          subtotal: 0.0,
        ),
      );

      if (existingOrderDetail.id != 0) {
        existingOrderDetail.quantity++;
        existingOrderDetail.subtotal += menu.price;
      } else {
        orderDetails.add(OrderDetail(
          id: 0,
          id_orders: 0,
          id_menus: menu.id,
          quantity: 1,
          subtotal: menu.price,
        ));
      }
    });
  }

  void _submitOrder() async {
    if (orderDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your order is empty')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id_users');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final order = Order(
      id: 0,
      id_tables: 1,
      id_users: int.parse(userId),
      total: orderDetails.fold(0, (sum, item) => sum + item.subtotal),
      status: Status.Pending,
      payment: Payment.Cash,
    );

    final createdOrder = await ApiService().createOrder(order);

    if (createdOrder != null) {
      for (var detail in orderDetails) {
        detail.id_orders = createdOrder.id;
        await ApiService().createOrderDetail(detail);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted successfully')),
      );

      setState(() {
        orderDetails.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShapeAppBar(
        title: 'Menu',
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MenuSearchDelegate(
                  menus: menus,
                  onSearch: onSearch,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Menu>>(
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
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true, // Important to make it fit the Column
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling inside ListView
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      Menu menu = menus[index];
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
                                      Navigator.pop(
                                          context); // Close the dialog
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
                              borderRadius: BorderRadius.circular(
                                  8), // Optional: to make the image rounded
                              child: Image.asset(
                                menu.image,
                                fit: BoxFit
                                    .cover, // Ensures the image fits within the box
                                key: Key(menu.image),
                              ),
                            ),
                          ),
                        ),
                        title: Text(menu.name),
                        subtitle: Text(
                            '${menu.price.toStringAsFixed(2)} \$ - ${menu.category}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_box_outlined),
                              onPressed: () => _addToOrder(menu),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _submitOrder,
        mini: true,
        child: Icon(Icons.shopping_cart),
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
