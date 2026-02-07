import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: colors.primaryContainer,
                child: Icon(Icons.check_rounded, color: colors.onPrimaryContainer, size: 42),
              ),
              const SizedBox(height: 16),
              const Text(
                'Тапсырыс қабылданды',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('№ $orderId', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 16),
              const Text('Курьер жақында жолға шығады. Жағымды тәбет!'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Басты бетке оралу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
