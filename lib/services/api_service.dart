import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu.dart';
import '../models/user.dart';
import '../models/table.dart' as app_table;
import '../models/order.dart';
import '../models/order_detail.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String _baseUrl = 'http://10.0.2.2:3000';
  static const String _baseUrl = 'http://192.168.110.189:3000';

  // ---------- Login ----------
  Future<void> _storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('Stored Token: $token'); // Log the stored token
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Retrieved Token: $token'); // Log the retrieved token
    return token;
  }

  Future<void> _storeUserDetails(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name ?? '');
    await prefs.setString('email', user.email ?? '');
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

  Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('Login successful: $responseData');

      final String token = responseData['token'];
      await _storeToken(token);
      print('Stored Token: $token');

      final User user = User.fromJson(responseData['user']);
      await _storeUserDetails(user);
      print('Stored User Details: $user');

      return User.fromJson(responseData['user']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      print('Login failed: ${errorData['message']}');
      return null;
    }
  }

  Future<User?> fetchUserDetails(String token) async {
    print('Token being sent: $token'); // Log the token being sent
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('User details response status: ${response.statusCode}');
    print('User details response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('User details fetched: $responseData');
      return User.fromJson(responseData);
    } else {
      print('Failed to fetch user details');
      return null;
    }
  }
  // ---------- End Login ----------

  // ---------- Register ----------
  Future<User?> register(User user) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('Registration successful: $responseData');
      return User.fromJson(responseData);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      print('Registration failed: ${errorData['message']}');
      return null;
    }
  }
  // ---------- End Register ----------

  // ---------- Table ----------
  Future<List<app_table.Table>> getTables() async {
    final response = await http.get(Uri.parse('$_baseUrl/tables'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<app_table.Table> tables =
          body.map((dynamic item) => app_table.Table.fromJson(item)).toList();
      return tables;
    } else {
      throw Exception('Failed to load tables');
    }
  }

  Future<void> addTables(int numberOfTables) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tables'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'number_of_tables': numberOfTables,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add tables');
    }
  }

  Future<bool> checkQRValidity(String qrCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/checkqr/$qrCode'));
      if (response.statusCode == 200) {
        return true; // QR code is valid in the database
      } else {
        return false; // QR code is not valid in the database
      }
    } catch (e) {
      print('Error checking QR code validity: $e');
      throw Exception('Failed to check QR code validity');
    }
  }

  Future<void> deleteTable(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tables/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete table');
    }
  }
  // ---------- End Table ----------

  // ---------- Menu ----------
  Future<String> uploadImage(File image) async {
    try {
      if (image == null) {
        throw Exception('Image file is null or not selected.');
      }

      var uri = Uri.parse('$_baseUrl/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file', // Make sure the key matches the one expected by the server
            image.path,
            contentType: MediaType(
              lookupMimeType(image.path)!.split('/')[0],
              lookupMimeType(image.path)!.split('/')[1],
            ),
          ),
        );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Upload image response status: ${response.statusCode}');
      print('Upload image response body: $responseBody');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        return responseData['filename']; // Return the filename
      } else {
        throw Exception('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<List<Menu>> getMenus() async {
    final response = await http.get(Uri.parse('$_baseUrl/menus'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Menu> menus = body.map((dynamic item) {
        try {
          return Menu.fromJson(item); // Parse Menu from JSON
        } catch (e) {
          print('Error parsing menu: $e');
          throw Exception('Failed to parse menu');
        }
      }).toList();
      return menus;
    } else {
      throw Exception('Failed to load menus');
    }
  }

  Future<void> createMenu(String name, double price, String description,
      String category, String image) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/menus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Menu created successfully');
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      print('Failed to create menu: ${errorData['message']}');
      throw Exception('Failed to create menu: ${errorData['message']}');
    }
  }

  Future<void> updateMenu(
    int id,
    String name,
    double price,
    String description,
    String category, // Changed to accept string
    String image,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/menus/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
        'description': description,
        'category': category, // Pass category as string
        'image': image,
      }),
    );

    if (response.statusCode != 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update menu');
    }
  }

  Future<void> deleteMenu(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/menus/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete menu');
    }
  }
  // ---------- End Menu ----------

  // ---------- Order ----------
  Future<Order?> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return Order.fromJson(responseData);
    } else {
      print('Failed to create order: ${response.body}');
      return null;
    }
  }

  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse('$_baseUrl/orders'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Order> orders =
          body.map((dynamic item) => Order.fromJson(item)).toList();
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Order?> getOrder(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/orders/$id'));

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to fetch order: ${response.body}');
      return null;
    }
  }

  Future<void> updateOrder(Order order) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/${order.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    }
  }

  Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/orders/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete order');
    }
  }
  // ---------- End Order ----------

  // ---------- Order Detail ----------
  Future<OrderDetail?> createOrderDetail(OrderDetail orderDetail) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orderdetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderDetail.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderDetail.fromJson(responseData);
    } else {
      print('Failed to create order detail: ${response.body}');
      return null;
    }
  }

  Future<List<OrderDetail>> getOrderDetails(int orderId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/orders/$orderId/details'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<OrderDetail> orderDetails =
          body.map((dynamic item) => OrderDetail.fromJson(item)).toList();
      return orderDetails;
    } else {
      throw Exception('Failed to load order details');
    }
  }

  Future<void> updateOrderDetail(OrderDetail orderDetail) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orderdetails/${orderDetail.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderDetail.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order detail');
    }
  }

  Future<void> deleteOrderDetail(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/orderdetails/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete order detail');
    }
  }
  // ---------- End Order Detail ----------
}
