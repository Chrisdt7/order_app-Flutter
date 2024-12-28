import 'package:flutter/material.dart';
import '/services/api_service.dart';

class AddTableScreen extends StatefulWidget {
  @override
  _AddTableScreenState createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfTablesController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _addTables() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService()
            .addTables(int.parse(_numberOfTablesController.text));
        Navigator.pop(context, true); // Pass true to indicate success
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add tables: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tables'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numberOfTablesController,
                decoration: InputDecoration(labelText: 'Number of Tables'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of tables';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addTables,
                      child: Text('Add Tables'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
