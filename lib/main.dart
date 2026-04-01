import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:qi_app_refact/screens/mainMenu.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib untuk init async di main
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "QI App",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const CardExample(), // Halaman utama
    );
  }
}
