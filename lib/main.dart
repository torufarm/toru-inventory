import 'package:flutter/material.dart';
import 'package:toruerp/views/inventory/product/add.dart';
import 'package:toruerp/views/inventory/product/list.dart';
import 'package:toruerp/views/inventory/product/stock/stock_in.dart';

void main() {
  runApp(const toruerp());
}

class toruerp extends StatelessWidget {
  const toruerp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 8, 136, 106)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Torufarm Inventory'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 7, 91, 68),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Torufarm Inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Purchase'),
              children: [
                ListTile(
                  leading: const Icon(Icons.add_shopping_cart),
                  title: const Text('Create Invoice'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Invoice List'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              children: [
                ListTile(
                  leading: const Icon(Icons.add_business),
                  title: const Text('Stock In'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StockInScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Stock Opname'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Produk Sortir/Expired'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: ProductListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah produk
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
    );
  }
}
