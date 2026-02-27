import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../../core/app_translations.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  @override
  void initState() {
    super.initState();
    appProvider.addListener(_onChanged);
  }

  @override
  void dispose() {
    appProvider.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final current = appProvider.themeModeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Tr.get('display'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme Preview ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                      : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    isDark
                        ? Icons.dark_mode
                        : current == 'system'
                        ? Icons.brightness_auto
                        : Icons.light_mode,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    current == 'dark'
                        ? Tr.get('dark_mode')
                        : current == 'system'
                        ? Tr.get('system_mode')
                        : Tr.get('light_mode'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current == 'dark'
                        ? 'Easy on the eyes in low light'
                        : current == 'system'
                        ? 'Follows your device settings'
                        : 'Best for bright environments',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              Tr.get('choose_theme'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // ── Light Mode ──────────────────────────────────────────
            _ThemeOption(
              cardColor: cardColor,
              icon: Icons.light_mode,
              iconColor: Colors.amber,
              title: Tr.get('light_mode'),
              subtitle: 'Default bright appearance',
              isSelected: current == 'light',
              onTap: () => appProvider.setThemeMode('light'),
            ),

            const SizedBox(height: 10),

            // ── Dark Mode ───────────────────────────────────────────
            _ThemeOption(
              cardColor: cardColor,
              icon: Icons.dark_mode,
              iconColor: Colors.indigo,
              title: Tr.get('dark_mode'),
              subtitle: 'Reduces eye strain in low light',
              isSelected: current == 'dark',
              onTap: () => appProvider.setThemeMode('dark'),
            ),

            const SizedBox(height: 10),

            // ── System Mode ─────────────────────────────────────────
            _ThemeOption(
              cardColor: cardColor,
              icon: Icons.brightness_auto,
              iconColor: Colors.teal,
              title: Tr.get('system_mode'),
              subtitle: 'Automatically match device theme',
              isSelected: current == 'system',
              onTap: () => appProvider.setThemeMode('system'),
            ),

            const SizedBox(height: 24),

            // ── Auto brightness info ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1565C0),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can also enable auto dark/light mode based on ambient light in Settings → Sensors.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme Option Tile ────────────────────────────────────────────────────────
class _ThemeOption extends StatelessWidget {
  final Color cardColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.cardColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1565C0), size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
          ],
        ),
      ),
    );
  }
}
