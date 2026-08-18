import 'package:flutter/material.dart';
import 'views/home/main_navigation_view.dart' as mainMenu;
import 'core/theme/app_theme.dart';
import 'services/session_service.dart';
import 'views/auth/login_view.dart';

class Ocupa2App extends StatelessWidget {
  const Ocupa2App({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionService sessionService = SessionService();

    return MaterialApp(
      title: 'Ocupa2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: sessionService.hasToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return const mainMenu.ProfileView();
          }

          return const LoginView();
        },
      ),
    );
  }
}