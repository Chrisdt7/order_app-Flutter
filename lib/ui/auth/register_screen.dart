import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController(text: 'customer');
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ApiService apiService = ApiService();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/etc/DigiBackgroundLogin.png'), // Your image path
            fit: BoxFit.cover, // Adjusts how the image fits the screen
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'Unknown Creature',
                          hintStyle: TextStyle(color: Colors.white38),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelStyle: TextStyle(
                              color:
                                  Colors.green), // Set the floating label color
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'Unknown12',
                          hintStyle: TextStyle(color: Colors.white38),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelStyle: TextStyle(
                              color:
                                  Colors.green), // Set the floating label color
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'Unknown123@hotmail.com',
                          hintStyle: TextStyle(color: Colors.white38),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelStyle: TextStyle(
                              color:
                                  Colors.green), // Set the floating label color
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.white38),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        floatingLabelStyle: TextStyle(
                            color:
                                Colors.green), // Set the floating label color
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off, // Toggle the icon
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible; // Toggle visibility
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _roleController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: TextStyle(color: Colors.green),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your role';
                        }
                        return null;
                      },
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: '081234567890',
                          hintStyle: TextStyle(color: Colors.white38),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelStyle: TextStyle(
                              color:
                                  Colors.green), // Set the floating label color
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText:
                              'Cikarang Square, Jl. Cibarusah Raya No.168, Jawa Barat 17550',
                          hintStyle: TextStyle(color: Colors.white38),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelStyle: TextStyle(
                              color:
                                  Colors.green), // Set the floating label color
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          User newUser = User(
                            name: _nameController.text,
                            username: _usernameController.text,
                            email: _emailController.text,
                            role: _roleController.text,
                            phone: _phoneController.text,
                            address: _addressController.text,
                            password: _passwordController.text,
                          );

                          apiService.register(newUser).then((User? user) {
                            if (user != null) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Register Success'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              ;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Username already exist'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to register: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          // Set the shape
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
