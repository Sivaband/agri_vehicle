import 'package:flutter/material.dart';
import '../../main.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../shared/models/work_entry.dart';
import '../../shared/models/auth_repository.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/login_screen.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthRepository.instance.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text('🌾', style: TextStyle(fontSize: 50)),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.selectVehicle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Vehicle Cards
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _VehicleCard(
                            emoji: '🚜',
                            name: AppStrings.tractor,
                            subtitle: AppStrings.isTelugu
                                ? 'రోటర్, దున్నడం, సేద్యం, విత్తనం'
                                : 'Rotor • Ploughing • Cultivation • Seeding',
                            color: AppColors.primaryGreen,
                            vehicleType: VehicleType.tractor,
                          ),
                          const SizedBox(height: 16),
                          _VehicleCard(
                            emoji: '🏗️',
                            name: AppStrings.jcb,
                            subtitle: AppStrings.isTelugu
                                ? 'తవ్వడం, సమం చేయడం, లోడింగ్'
                                : 'Digging • Leveling • Loading',
                            color: Colors.orange,
                            vehicleType: VehicleType.jcb,
                          ),
                          const SizedBox(height: 16),
                          _VehicleCard(
                            emoji: '🌾',
                            name: AppStrings.harvester,
                            subtitle: AppStrings.isTelugu
                                ? 'వరి కోత, గోధుమ కోత'
                                : 'Paddy Cutting • Wheat Harvesting',
                            color: Colors.amber[700]!,
                            vehicleType: VehicleType.harvester,
                          ),
                          const SizedBox(height: 32),
                          // Language Toggle
                          GestureDetector(
                            onTap: () {
                              AgriVehicleApp.of(context)?.toggleLanguage();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.primaryGreen
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language,
                                      color: AppColors.primaryGreen, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.switchLanguage,
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final Color color;
  final VehicleType vehicleType;

  const _VehicleCard({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.vehicleType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(vehicleType: vehicleType),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
