import 'package:flutter/material.dart';
import '/models/menu.dart';
import '/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddMenuScreen extends StatefulWidget {
  @override
  _AddMenuScreenState createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  Category? _selectedCategory;
  File? _image;
  String? _imageUrl;

  final ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploading image...')),
        );

        // Upload the image
        String imageUrl = await apiService.uploadImage(_image!);

        setState(() {
          _imageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to upload image')));
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _imageUrl != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adding menu...')),
        );

        // Create the menu
        await apiService.createMenu(
          _nameController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          _selectedCategory.toString().split('.').last,
          _imageUrl!,
        );

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        // Handle error
        print('Error adding menu: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add menu')));
      }
    } else {
      // Validate form and show errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please complete the form and upload an image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Menu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Menu Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the menu name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: Category.values.map((Category category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
