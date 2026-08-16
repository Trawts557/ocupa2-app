import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/views/publish/demo_home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ApiClient apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocupa2',
      debugShowCheckedModeBanner: false,
      home: DemoHomeScreen(apiClient: apiClient),
    );
  }
}