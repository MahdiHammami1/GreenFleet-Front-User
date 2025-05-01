import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'screens/opening_screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserModel(),
      child: DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Sharing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OpeningScreen(), // Set to OpeningScreen
      useInheritedMediaQuery: true, // Recommended when using DevicePreview
    );
  }
}
