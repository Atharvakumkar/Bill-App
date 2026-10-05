import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

final StorageService storageService = StorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await storageService.init();
  runApp(const BillMakerApp());
}

class BillMakerApp extends StatelessWidget {
  const BillMakerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
