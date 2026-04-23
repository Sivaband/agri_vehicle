import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_strings.dart';
import 'shared/models/work_repository.dart';
import 'features/vehicle_selection/vehicle_selection_screen.dart';
import 'features/auth/login_screen.dart';
import 'shared/models/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load language preference
  final prefs = await SharedPreferences.getInstance();
  final isTelugu = prefs.getBool('is_telugu') ?? false;
  AppStrings.setTelugu(isTelugu);

  // Seed demo data
  await WorkRepository.instance.seedDemoData();

  runApp(const AgriVehicleApp());
}

class AgriVehicleApp extends StatefulWidget {
  const AgriVehicleApp({super.key});

  static _AgriVehicleAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AgriVehicleAppState>();

  @override
  State<AgriVehicleApp> createState() => _AgriVehicleAppState();
}

class _AgriVehicleAppState extends State<AgriVehicleApp> {
  bool _isTelugu = AppStrings.isTelugu;
  late Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = AuthRepository.instance.isLoggedIn();
  }

  void toggleLanguage() async {
    setState(() {
      _isTelugu = !_isTelugu;
      AppStrings.setTelugu(_isTelugu);
    });
    await WorkRepository.instance.saveLanguage(_isTelugu);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FutureBuilder<bool>(
        future: _authFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn
              ? VehicleSelectionScreen(key: ValueKey(_isTelugu))
              : LoginScreen(key: ValueKey(_isTelugu));
        },
      ),
    );
  }
}
