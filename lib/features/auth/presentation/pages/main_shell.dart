import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
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

  // ── App bar titles per tab ─────────────────────────────────────────────────
  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Booking History';
      default:
        return 'Bus Booking';
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    Navigator.pop(context); // close drawer first

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  // ── Change Password bottom sheet ───────────────────────────────────────────
  void _showChangePassword() {
    Navigator.pop(context); // close drawer
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
                  const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _pwField(
                    ctrl: currentCtrl,
                    label: 'Current Password',
                    icon: Icons.lock_outline,
                    obscure: obscureCurrent,
                    toggle: () =>
                        setSheet(() => obscureCurrent = !obscureCurrent),
                    validator: (v) =>
                        v!.isEmpty ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    ctrl: newCtrl,
                    label: 'New Password',
                    icon: Icons.lock_open_outlined,
                    obscure: obscureNew,
                    toggle: () => setSheet(() => obscureNew = !obscureNew),
                    validator: (v) =>
                        v!.length < 6 ? 'Minimum 6 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  _pwField(
                    ctrl: confirmCtrl,
                    label: 'Confirm New Password',
                    icon: Icons.lock_person_outlined,
                    obscure: obscureConfirm,
                    toggle: () =>
                        setSheet(() => obscureConfirm = !obscureConfirm),
                    validator: (v) =>
                        v != newCtrl.text ? 'Passwords do not match' : null,
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
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Update Password',
                        style: TextStyle(
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

  // ── Settings bottom sheet ──────────────────────────────────────────────────
  void _showSettings() {
    Navigator.pop(context); // close drawer
    bool notifications = true;
    bool smsAlerts = false;
    bool darkMode = false;

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
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _toggleTile(
                icon: Icons.notifications_outlined,
                color: Colors.orange,
                title: 'Push Notifications',
                subtitle: 'Get booking updates & alerts',
                value: notifications,
                onChanged: (v) => setSheet(() => notifications = v),
              ),
              _toggleTile(
                icon: Icons.sms_outlined,
                color: Colors.green,
                title: 'SMS Alerts',
                subtitle: 'Receive booking confirmation via SMS',
                value: smsAlerts,
                onChanged: (v) => setSheet(() => smsAlerts = v),
              ),
              _toggleTile(
                icon: Icons.dark_mode_outlined,
                color: Colors.indigo,
                title: 'Dark Mode',
                subtitle: 'Switch app appearance',
                value: darkMode,
                onChanged: (v) => setSheet(() => darkMode = v),
              ),
              const Divider(),
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
                title: const Text('Language'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('English', style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
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
                title: const Text('Privacy Policy'),
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
                title: const Text('About App'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
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

  // ── Drawer item helper ─────────────────────────────────────────────────────
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
          color: titleColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pages for IndexedStack — NO Scaffold inside these widgets
    final List<Widget> pages = [
      const HomeContent(), // Tab 0
      const BookingHistoryScreen(), // Tab 1
    ];

    return Scaffold(
      // ── AppBar lives HERE in MainShell only ────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
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
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
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

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF1565C0),
                      title: 'View Profile',
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
                      title: 'Edit Profile',
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
                      title: 'Change Password',
                      onTap: _showChangePassword,
                    ),
                    _drawerItem(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.indigo,
                      title: 'Settings',
                      onTap: _showSettings,
                    ),
                    _drawerItem(
                      icon: Icons.receipt_long_outlined,
                      iconColor: Colors.purple,
                      title: 'Booking History',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.help_outline,
                      iconColor: Colors.green,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _drawerItem(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Sign Out',
                      titleColor: Colors.red,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bus Booking v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────
      body: IndexedStack(index: _currentIndex, children: pages),

      // ── Bottom Nav Bar ─────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
