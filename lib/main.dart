import 'package:flutter/material.dart';
import 'package:myapp/views/product/add.dart';
import 'package:myapp/views/product/list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 8, 136, 106)),
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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 7, 91, 68),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_business),
              title: Text('Produk Masuk'),
              onTap: () {
                Navigator.pop(context); // Menutup drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.seventeen_mp_outlined),
              title: Text('Produk Sortir/Expired'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(''),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ProductListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
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
