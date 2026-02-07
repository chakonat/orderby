import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../state/app_state.dart';
import '../widgets/formatters.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().loadMenu(widget.restaurant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;
    final menu = state.menuItems;

    final categories = menu.map((item) => item.category).toSet().toList();
    categories.sort();

    final filteredMenu = selectedCategory == null
        ? menu
        : menu.where((item) => item.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: colors.surfaceContainerHighest),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.restaurant.description,
                style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: widget.restaurant.deliveryTime),
                  _Badge(label: widget.restaurant.priceLevel),
                  _Badge(label: 'Мин. ${formatCurrency(widget.restaurant.minOrder)}'),
                  if (widget.restaurant.deliveryFee == 0)
                    const _Badge(label: 'Тегін жеткізу')
                  else
                    _Badge(label: 'Жеткізу ${formatCurrency(widget.restaurant.deliveryFee)}'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: const Text('Барлығы'),
                        selected: selectedCategory == null,
                        onSelected: (_) => setState(() => selectedCategory = null),
                      );
                    }

                    final category = categories[index - 1];
                    return ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) => setState(() => selectedCategory = category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (state.isMenuLoading)
                const LinearProgressIndicator()
              else if (state.errorMessage != null)
                _ErrorCard(message: state.errorMessage!)
              else
                ..._buildMenuSections(filteredMenu),
            ],
          ),
          if (state.cartItems.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Себетте ${state.cartItems.length} позиция',
                            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(state.total),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Себетке өту'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuSections(List<MenuItem> menu) {
    final grouped = <String, List<MenuItem>>{};
    for (final item in menu) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final widgets = <Widget>[];
    grouped.forEach((category, items) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          category,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ));

      widgets.addAll(items.map((item) => _MenuItemCard(item: item)).toList());
      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    final cartItem = state.cartItems.where((element) => element.item.id == item.id).firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 84,
                width: 84,
                child: Image.network(
                  item.imageUrl,
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
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.description, style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(formatCurrency(item.price), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      if (item.calories > 0)
                        Text('${item.calories} kcal', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (cartItem == null)
              IconButton(
                onPressed: () => context.read<AppState>().addToCart(item),
                icon: const Icon(Icons.add_circle_rounded),
                color: colors.primary,
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.read<AppState>().removeFromCart(item),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Text(cartItem.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => context.read<AppState>().addToCart(item),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
