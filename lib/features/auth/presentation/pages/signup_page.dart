import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: isTablet ? 450 : double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                const AppTextField(
                  hint: 'Enter Your Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),

                const AppTextField(
                  hint: 'DOB (YYYY-MM-DD)',
                  icon: Icons.calendar_month,
                ),
                const SizedBox(height: 12),

                const AppTextField(hint: 'Gender', icon: Icons.people),
                const SizedBox(height: 12),

                const AppTextField(hint: 'Phone Number', icon: Icons.phone),
                const SizedBox(height: 12),

                const AppTextField(
                  hint: 'Enter Your Password',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 12),

                const AppTextField(
                  hint: 'Confirm Your Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 24),

                AppButton(title: 'Sign Up', onPressed: () {}),

                const SizedBox(height: 16),

                OutlinedButton(onPressed: () {}, child: const Text('Sign In')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
