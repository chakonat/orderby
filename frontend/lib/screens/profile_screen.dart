import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AppState>().currentUser;
      _nameController.text = user?.name ?? '';
      _emailController.text = user?.email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Аты-жөні'),
                  validator: (value) => (value == null || value.trim().length < 2) ? 'Толтырыңыз' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: state.currentUser?.phone ?? '',
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isProfileLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          await context.read<AppState>().updateProfile(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                              );
                        },
                  child: state.isProfileLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Сақтау'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('Мекенжайлар', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressFormScreen()),
                  );
                },
                child: const Text('Қосу'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.currentUser?.addresses.isEmpty ?? true)
            const Text('Мекенжай қосылмаған')
          else
            ...state.currentUser!.addresses.map((address) => _AddressCard(address: address)),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(address.label.isEmpty ? 'Мекенжай' : address.label),
        subtitle: Text('${address.city} ${address.street} ${address.building} ${address.apartment}'.trim()),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddressFormScreen(address: address)),
              );
            }
            if (value == 'delete') {
              state.deleteAddress(address.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Өзгерту')),
            PopupMenuItem(value: 'delete', child: Text('Жою')),
          ],
        ),
        leading: address.isDefault
            ? const Icon(Icons.star_rounded, color: Colors.orange)
            : const Icon(Icons.location_on_outlined),
      ),
    );
  }
}

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _city = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _apartment = TextEditingController();
  final _comment = TextEditingController();
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _label.text = address.label;
      _city.text = address.city;
      _street.text = address.street;
      _building.text = address.building;
      _apartment.text = address.apartment;
      _comment.text = address.comment;
      isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _city.dispose();
    _street.dispose();
    _building.dispose();
    _apartment.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.address == null ? 'Мекенжай қосу' : 'Мекенжай өзгерту')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _label,
                  decoration: const InputDecoration(labelText: 'Атауы (үй, жұмыс)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'Қала'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _street,
                  decoration: const InputDecoration(labelText: 'Көше'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Көше қажет' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _building,
                  decoration: const InputDecoration(labelText: 'Үй'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Үй қажет' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apartment,
                  decoration: const InputDecoration(labelText: 'Пәтер'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _comment,
                  decoration: const InputDecoration(labelText: 'Комментарий'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isDefault,
                  onChanged: (value) => setState(() => isDefault = value),
                  title: const Text('Негізгі мекенжай'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isProfileLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final payload = AddressPayload(
                            label: _label.text.trim(),
                            city: _city.text.trim(),
                            street: _street.text.trim(),
                            building: _building.text.trim(),
                            apartment: _apartment.text.trim(),
                            comment: _comment.text.trim(),
                            isDefault: isDefault,
                          );

                          if (widget.address == null) {
                            await context.read<AppState>().addAddress(payload);
                          } else {
                            await context.read<AppState>().updateAddress(widget.address!.id, payload);
                          }

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: state.isProfileLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Сақтау'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
