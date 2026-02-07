import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;

    if (state.selectedRestaurant == null) {
      return const Scaffold(
        body: Center(child: Text('Мейрамхана таңдаңыз')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Себет')),
      body: state.cartItems.isEmpty
          ? const Center(child: Text('Себет бос'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              children: [
                ...state.cartItems.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 64,
                                width: 64,
                                child: Image.network(
                                  item.item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: colors.surfaceContainerHighest),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(formatCurrency(item.item.price)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => context.read<AppState>().removeFromCart(item.item),
                                    icon: const Icon(Icons.remove_rounded),
                                  ),
                                  Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  IconButton(
                                    onPressed: () => context.read<AppState>().addToCart(item.item),
                                    icon: const Icon(Icons.add_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
      bottomNavigationBar: state.cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Сома',
                            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                        Text(formatCurrency(state.subtotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Жеткізу',
                            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                        Text(formatCurrency(state.selectedRestaurant?.deliveryFee ?? 0)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Барлығы',
                            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                        Text(formatCurrency(state.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      child: const Text('Төлеу және рәсімдеу'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
