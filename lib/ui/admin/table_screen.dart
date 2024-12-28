import 'package:flutter/material.dart';
import '/services/api_service.dart';
import '/models/table.dart' as app_table;
import '../../util/admin/menu/add_table_screen.dart';
import '../../widgets/sidebar.dart';

class TableScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  TableScreen({required this.toggleTheme});
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  late Future<List<app_table.Table>> futureTables;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  void _fetchTables() {
    futureTables = ApiService().getTables();
  }

  Widget _buildTableTile(app_table.Table table) {
    if (table.tableQr == null || table.tableQr!.isEmpty) {
      return ListTile(
        title: Text('Table ${table.tableNumber}'),
        subtitle: Text('Invalid QR code data'),
      );
    }

    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Table ${table.tableNumber}',
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: 8), // Adjust as needed for spacing between text and image
          Image(
            image:
                AssetImage(table.tableQr!), // Use AssetImage for local assets
            fit: BoxFit
                .contain, // Ensure the image fits within the box without distortion
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text('Tables'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: FutureBuilder<List<app_table.Table>>(
        future: futureTables,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tables available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                app_table.Table table = snapshot.data![index];
                return _buildTableTile(table);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTableScreen()),
          ).then((value) {
            if (value == true) {
              setState(() {
                _fetchTables();
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
