import 'package:esyria/pages/adding.dart';
import 'package:esyria/pages/search.dart';
import 'package:esyria/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const Esyria());
}

class Esyria extends StatelessWidget {
  const Esyria({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Syria (beta 0.1)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'E-Syria (beta 0.1)'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  void _exportDatabase(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await dbHelper.exportDatabase();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم تصدير قاعدة البيانات بنجاح')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('فشل التصدير: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'خدمات حاليه',
                style: TextStyle(color: Colors.green, fontSize: 24),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddRecordPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("أضافه سجل"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchRecordPage()),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("بحت عن سجل"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _exportDatabase(context),
                    icon: const Icon(Icons.import_export),
                    label: const Text("تصدير قاعدة البيانات"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
