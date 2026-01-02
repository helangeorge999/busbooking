import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: isTablet ? 420 : double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Log In',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                const AppTextField(
                  hint: 'Email or Phone Number',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                const AppTextField(
                  hint: 'Password',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 24),

                AppButton(title: 'Login', onPressed: () {}),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
