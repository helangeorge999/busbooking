import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';
import '../../../../core/app_translations.dart';
import '../../../../core/api_config.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import 'sensor_screen.dart';
import 'display_settings_screen.dart';
import '../../../dashboard/presentation/pages/booking_history_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String userName = '';
  String userEmail = '';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    appProvider.addListener(_onAppChange);
  }

  @override
  void dispose() {
    appProvider.removeListener(_onAppChange);
    super.dispose();
  }

  void _onAppChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
      userEmail = prefs.getString('user_email') ?? '';
      photoUrl = prefs.getString('photoUrl');
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return Tr.get('home');
      case 1:
        return Tr.get('booking_history');
      default:
        return Tr.get('app_name');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    Navigator.pop(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(Tr.get('sign_out')),
        content: Text(Tr.get('sign_out_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Tr.get('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              Tr.get('sign_out'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      // Save dark mode and language preferences before clearing
      final isDark = prefs.getBool('dark_mode') ?? false;
      final lang = prefs.getString('language') ?? 'en';
      await prefs.clear();
      await prefs.setBool('dark_mode', isDark);
      await prefs.setString('language', lang);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  // ── Change Password ────────────────────────────────────────────────────────
  void _showChangePassword() {
    Navigator.pop(context);
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Tr.get('change_password'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _pwField(
                    ctrl: currentCtrl,
                    label: Tr.get('current_password'),
                    icon: Icons.lock_outline,
                    obscure: obscureCurrent,
                    toggle: () =>
                        setSheet(() => obscureCurrent = !obscureCurrent),
                    validator: (v) =>
                        v!.isEmpty ? Tr.get('enter_current') : null,
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    ctrl: newCtrl,
                    label: Tr.get('new_password'),
                    icon: Icons.lock_open_outlined,
                    obscure: obscureNew,
                    toggle: () => setSheet(() => obscureNew = !obscureNew),
                    validator: (v) =>
                        v!.length < 6 ? Tr.get('min_6_chars') : null,
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    ctrl: confirmCtrl,
                    label: Tr.get('confirm_password'),
                    icon: Icons.lock_person_outlined,
                    obscure: obscureConfirm,
                    toggle: () =>
                        setSheet(() => obscureConfirm = !obscureConfirm),
                    validator: (v) =>
                        v != newCtrl.text ? Tr.get('passwords_mismatch') : null,
                  ),
                  const SizedBox(height: 24),
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
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token') ?? '';

                            final response = await http.post(
                              Uri.parse('${ApiConfig.userUrl}/change-password'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer $token',
                              },
                              body: jsonEncode({
                                'currentPassword': currentCtrl.text,
                                'newPassword': newCtrl.text,
                              }),
                            );

                            final data = jsonDecode(response.body);
                            Navigator.pop(ctx);

                            if (response.statusCode == 200 &&
                                data['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(Tr.get('password_changed')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    data['message'] ??
                                        'Failed to change password',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(Tr.get('network_error')),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        Tr.get('update_password'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pwField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  void _showSettings() {
    Navigator.pop(context);
    bool notifications = true;
    bool smsAlerts = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Tr.get('settings'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _toggleTile(
                icon: Icons.notifications_outlined,
                color: Colors.orange,
                title: Tr.get('push_notifications'),
                subtitle: Tr.get('notif_subtitle'),
                value: notifications,
                onChanged: (v) => setSheet(() => notifications = v),
              ),
              _toggleTile(
                icon: Icons.sms_outlined,
                color: Colors.green,
                title: Tr.get('sms_alerts'),
                subtitle: Tr.get('sms_subtitle'),
                value: smsAlerts,
                onChanged: (v) => setSheet(() => smsAlerts = v),
              ),
              const Divider(),
              // ── Display Submenu ────────────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                title: Text(Tr.get('display')),
                subtitle: Text(
                  appProvider.themeModeName == 'dark'
                      ? Tr.get('dark_mode')
                      : appProvider.themeModeName == 'system'
                      ? Tr.get('system_mode')
                      : Tr.get('light_mode'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DisplaySettingsScreen(),
                    ),
                  );
                },
              ),
              // ── Sensor Submenu ─────────────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Icons.sensors,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                title: Text(Tr.get('sensors')),
                subtitle: const Text(
                  'Accelerometer, Gyroscope, Light',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SensorScreen()),
                  );
                },
              ),
              const Divider(),
              // ── Language Selector ──────────────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    Icons.language,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(Tr.get('language')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appProvider.language == 'ne'
                          ? Tr.get('nepali')
                          : Tr.get('english'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showLanguagePicker();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                title: Text(Tr.get('privacy_policy')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                title: Text(Tr.get('about_app')),
                subtitle: Text(Tr.get('version')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Language Picker ────────────────────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                Tr.get('select_language'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _languageOption(ctx, 'English', 'en', '🇺🇸'),
              _languageOption(ctx, 'नेपाली', 'ne', '🇳🇵'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageOption(
    BuildContext ctx,
    String label,
    String code,
    String flag,
  ) {
    final isSelected = appProvider.language == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1565C0) : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF1565C0))
          : null,
      onTap: () {
        appProvider.setLanguage(code);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1565C0),
      ),
    );
  }

  // ── Drawer item ────────────────────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color:
              titleColor ??
              (appProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeContent(),
      const BookingHistoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.directions_bus,
              color: Color(0xFF1565C0),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              _appBarTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),

      // ── Drawer ────────────────────────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      backgroundImage:
                          (photoUrl != null &&
                              photoUrl!.isNotEmpty &&
                              photoUrl!.startsWith('http'))
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (userEmail.isNotEmpty)
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF1565C0),
                      title: Tr.get('view_profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        ).then((_) => _loadUserData());
                      },
                    ),
                    _drawerItem(
                      icon: Icons.edit_outlined,
                      iconColor: Colors.teal,
                      title: Tr.get('edit_profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ).then((_) => _loadUserData());
                      },
                    ),
                    _drawerItem(
                      icon: Icons.lock_outline,
                      iconColor: Colors.orange,
                      title: Tr.get('change_password'),
                      onTap: _showChangePassword,
                    ),
                    _drawerItem(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.indigo,
                      title: Tr.get('settings'),
                      onTap: _showSettings,
                    ),
                    _drawerItem(
                      icon: Icons.receipt_long_outlined,
                      iconColor: Colors.purple,
                      title: Tr.get('booking_history'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.help_outline,
                      iconColor: Colors.green,
                      title: Tr.get('help_support'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(Tr.get('coming_soon'))),
                        );
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _drawerItem(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: Tr.get('sign_out'),
                      titleColor: Colors.red,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${Tr.get('app_name')} v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: Tr.get('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: Tr.get('bookings'),
          ),
        ],
      ),
    );
  }
}
