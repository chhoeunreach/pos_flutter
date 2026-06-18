import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckConnectionEvent());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) context.go('/');
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store,
                          size: 80, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 16),
                      Text('POS Login',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Sign in to your account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isServerConnected == true
                                ? Icons.check_circle
                                : state.isServerConnected == false
                                    ? Icons.error_outline
                                    : Icons.sync,
                            size: 16,
                            color: state.isServerConnected == true
                                ? Colors.green
                                : state.isServerConnected == false
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isServerConnected == true
                                ? 'Server connected'
                                : state.isServerConnected == false
                                    ? 'Server unreachable'
                                    : 'Checking server...',
                            style: TextStyle(
                              fontSize: 12,
                              color: state.isServerConnected == true
                                  ? Colors.green
                                  : state.isServerConnected == false
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter password' : null,
                        onFieldSubmitted: (_) => _login(context),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isLoading ||
                                  state.isServerConnected == false
                              ? null
                              : () => _login(context),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Sign In',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      if (state.isServerConnected == false) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => context
                                .read<AuthBloc>()
                                .add(CheckConnectionEvent()),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry Connection'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/connect'),
                        child: const Text('Change Server'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _login(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginEvent(
          _usernameController.text.trim(), _passwordController.text));
    }
  }
}
