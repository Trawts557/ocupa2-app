import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/payment.dart';
import 'package:ocupa2_app/services/payment_service.dart';

class MyPaymentsScreen extends StatefulWidget {
  final PaymentService paymentService;
  const MyPaymentsScreen({super.key, required this.paymentService});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  late Future<List<Payment>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.paymentService.getMyPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pagos')),
      body: FutureBuilder<List<Payment>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const Center(child: Text('Aún no tienes pagos registrados'));
          }
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, i) {
              final p = payments[i];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('\$${p.amount.toStringAsFixed(2)} — ${p.status}'),
                subtitle: Text(p.date.toString()),
              );
            },
          );
        },
      ),
    );
  }
}