import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/models/menu.dart'; // Adjust import based on your actual file structure
import '/services/api_service.dart'; // Adjust import based on your actual file structure

class EditMenuScreen extends StatefulWidget {
  final Menu menu;

  EditMenuScreen({required this.menu});

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  Category? _selectedCategory; // Updated to Category type
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu.name);
    _priceController =
        TextEditingController(text: widget.menu.price.toString());
    _descriptionController =
        TextEditingController(text: widget.menu.description);
    _selectedCategory = widget.menu.category; // Assign the existing category
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateMenu() async {
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await ApiService().uploadImage(_image!);
      } else {
        imageUrl = widget.menu
            .image; // Ensure fallback to existing image URL if _image is null
      }

      await ApiService().updateMenu(
        widget.menu.id,
        _nameController.text,
        double.parse(_priceController.text),
        _descriptionController.text,
        _selectedCategory.toString().split('.').last, // Convert enum to string
        imageUrl, // Ensure imageUrl is not null here
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Navigate back after successful update
    } catch (e) {
      print('Error updating menu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update menu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
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
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Image.asset(widget.menu.image,
                        height: 150) // display the current image
                    : Image.file(_image!, height: 150),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateMenu,
                child: Text('Update Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
