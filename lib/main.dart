import 'package:flutter/material.dart';
import 'core/app_provider.dart';
import 'core/app_translations.dart';
import 'core/api_config.dart';
import 'core/hive_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';

final AppProvider appProvider = AppProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await appProvider.init();
  await ApiConfig.init();
  Tr.setLanguage(appProvider.language);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    appProvider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    appProvider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    Tr.setLanguage(appProvider.language);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Booking',
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
      ),
      home: const SplashPage(),
    );
  }
}
