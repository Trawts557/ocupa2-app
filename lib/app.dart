import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class Ocupa2App extends StatelessWidget {
  const Ocupa2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocupa2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Ocupa2'),
        ),
      ),
    );
  }
}