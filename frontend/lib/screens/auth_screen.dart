import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isRegister = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email дұрыс емес';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Құпиясөз енгізіңіз';
    }
    final text = value.trim();
    if (text.length < 8) return 'Кемінде 8 таңба болуы керек';
    if (!RegExp(r'[A-Za-z]').hasMatch(text)) return 'Әріп болуы керек';
    if (!RegExp(r'[0-9]').hasMatch(text)) return 'Сан болуы керек';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRegister ? 'Тіркелу' : 'Кіру',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isRegister
                              ? 'Жаңа аккаунт жасаңыз'
                              : 'Аккаунтыңызға кіріңіз',
                          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 20),
                        if (isRegister) ...[
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'Аты-жөні',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                (value == null || value.trim().length < 2) ? 'Атыңызды енгізіңіз' : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Телефон (+7...)',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              (value == null || value.trim().length < 8) ? 'Телефон енгізіңіз' : null,
                        ),
                        const SizedBox(height: 12),
                        if (isRegister) ...[
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email (міндетті емес)',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            labelText: 'Құпиясөз',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => showPassword = !showPassword),
                            ),
                          ),
                          obscureText: !showPassword,
                          validator: _validatePassword,
                        ),
                        if (isRegister) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Құпиясөзді растау',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                              ),
                            ),
                            obscureText: !showConfirmPassword,
                            validator: (value) {
                              final pass = _password.text.trim();
                              if (value == null || value.trim().isEmpty) return 'Қайта енгізіңіз';
                              if (value.trim() != pass) return 'Құпиясөз сәйкес емес';
                              return null;
                            },
                          ),
                        ],
                        if (state.validationErrors.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: state.validationErrors
                                  .map((err) => Text('• $err', style: TextStyle(color: colors.error)))
                                  .toList(),
                            ),
                          )
                        else if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(state.errorMessage!, style: TextStyle(color: colors.error)),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: state.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    if (isRegister) {
                                      await context.read<AppState>().register(
                                            name: _name.text.trim(),
                                            phone: _phone.text.trim(),
                                            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
                                            password: _password.text.trim(),
                                          );
                                    } else {
                                      await context.read<AppState>().login(
                                            phone: _phone.text.trim(),
                                            password: _password.text.trim(),
                                          );
                                    }
                                  },
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(isRegister ? 'Тіркелу' : 'Кіру'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(isRegister ? 'Аккаунтыңыз бар ма?' : 'Аккаунтыңыз жоқ па?'),
                            TextButton(
                              onPressed: () {
                                context.read<AppState>().clearError();
                                setState(() => isRegister = !isRegister);
                              },
                              child: Text(isRegister ? 'Кіру' : 'Тіркелу'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
