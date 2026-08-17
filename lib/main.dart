import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/views/publish/demo_home_screen.dart';
// Asegúrate de importar tu pantalla de pago y tu MainNavigationView si la usas:
// import 'package:ocupa2_app/views/payments/card_payment_screen.dart';
// import 'package:ocupa2_app/views/home/main_navigation_view.dart';

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
      // Usamos initialRoute en lugar de 'home' para que el sistema de rutas funcione
      initialRoute: '/',
      routes: {
        '/': (context) => DemoHomeScreen(apiClient: apiClient),
        // Registra aquí la ruta de la pasarela de pago para que funcione el botón:
        // '/card-payment': (context) => const CardPaymentScreen(),
        
        // Si también quieres tener lista la ruta de navegación principal:
        // '/main': (context) => const MainNavigationView(),
      },
    );
  }
}