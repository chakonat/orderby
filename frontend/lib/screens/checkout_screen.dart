import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/formatters.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();

  String paymentMethod = 'kaspi';
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      final user = state.currentUser;
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phone ?? '';
      if (state.defaultAddress != null) {
        selectedAddressId = state.defaultAddress!.id;
        _addressController.text = _formatAddress(state.defaultAddress!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  String _formatAddress(dynamic address) {
    return '${address.city} ${address.street} ${address.building} ${address.apartment}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final restaurant = state.selectedRestaurant;
    final colors = Theme.of(context).colorScheme;
    final addresses = state.currentUser?.addresses ?? [];

    if (restaurant == null) {
      return const Scaffold(body: Center(child: Text('Мейрамхана таңдалмаған')));
    }

    final minOrderReached = state.subtotal >= restaurant.minOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Төлем және жеткізу')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
          children: [
            _SectionHeader(title: 'Жеткізу мәліметі'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Аты-жөні'),
              validator: (value) => (value == null || value.isEmpty) ? 'Толтырыңыз' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Телефон'),
              validator: (value) => (value == null || value.isEmpty) ? 'Толтырыңыз' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Мекенжай'),
              validator: (value) => (value == null || value.isEmpty) ? 'Толтырыңыз' : null,
            ),
            if (addresses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Сақталған мекенжайлар', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: addresses.map((address) {
                  return ChoiceChip(
                    label: Text(address.label.isEmpty ? address.street : address.label),
                    selected: selectedAddressId == address.id,
                    onSelected: (_) {
                      setState(() {
                        selectedAddressId = address.id;
                        _addressController.text = _formatAddress(address);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            _SectionHeader(title: 'Купон'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _couponController,
              decoration: const InputDecoration(labelText: 'Код купона'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Төлем әдісі'),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: paymentMethod,
              onChanged: (value) => setState(() => paymentMethod = value ?? paymentMethod),
              child: Column(
                children: paymentMethods
                    .map((method) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: RadioListTile<String>(
                            value: method.value,
                            title: Text(method.label),
                            secondary: Icon(method.icon, color: colors.primary),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Қорытынды'),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Сома', value: formatCurrency(state.subtotal)),
            _SummaryRow(label: 'Жеткізу', value: formatCurrency(restaurant.deliveryFee)),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(state.errorMessage!, style: TextStyle(color: colors.error)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: FilledButton(
            onPressed: (!minOrderReached || state.isLoading)
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    final order = await context.read<AppState>().placeOrder(
                          paymentMethod: paymentMethod,
                          customerName: _nameController.text,
                          customerPhone: _phoneController.text,
                          customerAddress: _addressController.text,
                          couponCode: _couponController.text.trim().isEmpty
                              ? null
                              : _couponController.text.trim(),
                        );

                    if (order != null && context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => OrderSuccessScreen(orderId: order['_id'] as String),
                        ),
                      );
                    }
                  },
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Төлеу ${formatCurrency(state.total)}'),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

class PaymentMethod {
  const PaymentMethod({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

const paymentMethods = [
  PaymentMethod(label: 'Kaspi', value: 'kaspi', icon: Icons.account_balance_wallet_outlined),
  PaymentMethod(label: 'Банк картасы', value: 'card', icon: Icons.credit_card_rounded),
  PaymentMethod(label: 'Apple Pay', value: 'apple_pay', icon: Icons.phone_iphone_rounded),
  PaymentMethod(label: 'Google Pay', value: 'google_pay', icon: Icons.phone_android_rounded),
  PaymentMethod(label: 'Қолма-қол', value: 'cash', icon: Icons.payments_outlined),
];
