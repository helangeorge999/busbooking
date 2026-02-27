import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: request OTP ───────────────────────────────────────────────────
  Future<void> _sendCode() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _snack('Please enter your email', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.authUrl}/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': _emailCtrl.text.trim()}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && data['success'] == true) {
        final otp = data['otp'] as String;
        setState(() => _codeSent = true);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Reset Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Use this code to reset your password:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      otp,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Expires in 10 minutes',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Got it',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        _snack(data['message'] ?? 'Email not found', Colors.red);
      }
    } catch (_) {
      _snack('Server error. Make sure backend is running.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2: submit new password ───────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (_otpCtrl.text.trim().isEmpty ||
        _newPassCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      _snack('Please fill all fields', Colors.red);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _snack('Passwords do not match', Colors.red);
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      _snack('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.authUrl}/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailCtrl.text.trim(),
              'otp': _otpCtrl.text.trim(),
              'newPassword': _newPassCtrl.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && data['success'] == true) {
        _snack('Password reset successfully!', Colors.green);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _snack(data['message'] ?? 'Failed to reset password', Colors.red);
      }
    } catch (_) {
      _snack('Server error. Make sure backend is running.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ── Shared input decoration ───────────────────────────────────────────────
  InputDecoration _inputDec(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.green.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1565C0),
      ),
      body: Center(
        child: SizedBox(
          width: isTablet ? 420 : double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Icon(
                  Icons.lock_reset,
                  size: 48,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code and your new password.'
                      : 'Enter your email address to receive a reset code.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 28),

                // ── Step indicator ─────────────────────────────────────────
                Row(
                  children: [
                    _stepDot(1, active: true),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: _codeSent
                            ? const Color(0xFF1565C0)
                            : Colors.grey[300],
                      ),
                    ),
                    _stepDot(2, active: _codeSent),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Email field (always visible, disabled after step 1) ────
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_codeSent,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor:
                        _codeSent ? Colors.grey.shade100 : Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF1565C0),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // ── Step 1 button ──────────────────────────────────────────
                if (!_codeSent) ...[
                  const SizedBox(height: 20),
                  _primaryButton('Send Reset Code', _sendCode),
                ],

                // ── Step 2 fields ──────────────────────────────────────────
                if (_codeSent) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: _inputDec(
                      'Enter 6-digit code',
                      Icons.lock_clock_outlined,
                    ).copyWith(counterText: ''),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _newPassCtrl,
                    obscureText: _obscureNew,
                    decoration: _inputDec(
                      'New password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmPassCtrl,
                    obscureText: _obscureConfirm,
                    decoration: _inputDec(
                      'Confirm new password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _primaryButton('Reset Password', _resetPassword),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _codeSent = false;
                                _otpCtrl.clear();
                                _newPassCtrl.clear();
                                _confirmPassCtrl.clear();
                              }),
                      child: const Text(
                        'Resend code',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : onTap,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _stepDot(int step, {required bool active}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF1565C0) : Colors.grey[300],
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
