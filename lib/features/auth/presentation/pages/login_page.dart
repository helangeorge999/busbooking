import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/app_colors.dart';
import 'main_shell.dart';
import 'signup_page.dart';

// ── LoginPage ─────────────────────────────────────────────────────────────────
// User login  → POST /api/auth/login    (AuthController.login)
//               Response: { success, token, user: { id, name, email, phone, gender, dob, photoUrl, role } }
//
// Admin login → POST /api/admin/auth/login  (AdminAuthController.login)
//               Response: { success, token, user: { id, name, email, role: "admin" } }
//
// Both save the JWT token to SharedPreferences under key 'token'
// The token is then sent as Bearer token in all protected API calls
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _isAdmin = false;

  // Endpoints from index.ts route mounting
  static const String _userLoginUrl = 'http://10.0.2.2:5050/api/auth/login';
  static const String _adminLoginUrl =
      'http://10.0.2.2:5050/api/admin/auth/login';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _snack('Please enter email and password', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = _isAdmin ? _adminLoginUrl : _userLoginUrl;

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailCtrl.text.trim(),
              'password': _passwordCtrl.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['user'] as Map<String, dynamic>;
        final token = data['token'] as String;

        final prefs = await SharedPreferences.getInstance();

        // Save JWT — used as Bearer token for all protected endpoints
        await prefs.setString('token', token);

        // Save user fields from response
        // User: id, name, email, phone, gender, dob, photoUrl, role
        // Admin: id, name, email, role:"admin"
        await prefs.setString(
          'userId',
          user['id']?.toString() ?? user['_id']?.toString() ?? '',
        );
        await prefs.setString('user_name', user['name'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_phone', user['phone'] ?? '');
        await prefs.setString('user_gender', user['gender'] ?? '');
        await prefs.setString('user_dob', user['dob'] ?? '');
        await prefs.setString('photoUrl', user['photoUrl'] ?? '');
        await prefs.setString('role', user['role'] ?? 'user');
        await prefs.setBool('isAdmin', _isAdmin);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        _snack(data['message'] ?? 'Invalid email or password', Colors.red);
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: isTablet ? 420 : double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // ── Logo ───────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Color(0xFF1565C0),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bus Booking',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isAdmin ? 'Admin Portal' : 'Welcome back!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                // ── User / Admin Toggle ─────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _toggleBtn(
                        label: 'User',
                        icon: Icons.person_outline,
                        active: !_isAdmin,
                        onTap: () => setState(() => _isAdmin = false),
                      ),
                      _toggleBtn(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        active: _isAdmin,
                        onTap: () => setState(() => _isAdmin = true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Email ───────────────────────────────────────────────
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.green.shade50,
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

                const SizedBox(height: 14),

                // ── Password ────────────────────────────────────────────
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: Colors.green.shade50,
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

                if (!_isAdmin) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(height: 16),

                // ── Login Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
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
                            _isAdmin ? 'Admin Sign In' : 'Sign In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Create account — users only ─────────────────────────
                if (!_isAdmin) ...[
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Admin warning note ──────────────────────────────────
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Admin access only. Unauthorized login attempts are logged.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
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

  Widget _toggleBtn({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1565C0) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
