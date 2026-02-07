import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/formatters.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().loadOrders();
    });
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Төленді';
      case 'preparing':
        return 'Дайындалып жатыр';
      case 'delivering':
        return 'Жеткізуде';
      case 'completed':
        return 'Аяқталды';
      case 'cancelled':
        return 'Бас тартылды';
      default:
        return 'Қабылданды';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Тапсырыстар')),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().loadOrders(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.isLoading)
              const LinearProgressIndicator()
            else if (state.orders.isEmpty)
              const Center(child: Text('Әзірге тапсырыс жоқ'))
            else
              ...state.orders.map((order) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(order.restaurantName),
                      subtitle: Text(order.createdAt.toLocal().toString().split('.').first),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatCurrency(order.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_statusLabel(order.status), style: TextStyle(color: colors.primary)),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
