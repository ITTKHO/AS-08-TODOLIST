import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/counter_model.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ห่อ MaterialApp ด้วย ChangeNotifierProvider -> กระจาย state ให้ทุกหน้า
    return ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Counter Provider',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        home: const HomePage(),
      ),
    );
  }
}
