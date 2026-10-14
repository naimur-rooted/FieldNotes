import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loginMode = true;
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Notes')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.note_alt_outlined, size: 64),
                  const SizedBox(height: 8),
                  Text(loginMode ? 'Log in' : 'Create account',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  const Text('Online login required first — then work offline',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (!loginMode)
                    TextField(controller: nameC,
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                  if (!loginMode) const SizedBox(height: 12),
                  TextField(controller: emailC, keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: passC, obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: state.loading
                        ? null
                        : () {
                            final email = emailC.text.trim();
                            final pass = passC.text;
                            if (loginMode) {
                              context.read<AuthBloc>().add(AuthLogin(email, pass));
                            } else {
                              context.read<AuthBloc>().add(AuthRegister(nameC.text.trim(), email, pass));
                            }
                          },
                    child: state.loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(loginMode ? 'Login' : 'Register'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => loginMode = !loginMode),
                    child: Text(loginMode ? 'No account? Register' : 'Have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
