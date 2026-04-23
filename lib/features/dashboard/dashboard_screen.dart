import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../shared/models/work_entry.dart';
import '../../shared/models/work_repository.dart';
import '../../shared/widgets/common_widgets.dart';
import '../work_entry/work_entry_screen.dart';
import '../history/customer_history_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VehicleType vehicleType;
  const DashboardScreen({super.key, required this.vehicleType});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<WorkEntry> _allEntries = [];
  List<WorkEntry> _todayEntries = [];
  bool _loading = true;

  String get _vehicleEmoji => widget.vehicleType == VehicleType.tractor
      ? '🚜'
      : widget.vehicleType == VehicleType.jcb
          ? '🏗️'
          : '🌾';

  String get _vehicleName => widget.vehicleType == VehicleType.tractor
      ? AppStrings.tractor
      : widget.vehicleType == VehicleType.jcb
          ? AppStrings.jcb
          : AppStrings.harvester;

  Color get _vehicleColor => widget.vehicleType == VehicleType.tractor
      ? AppColors.primaryGreen
      : widget.vehicleType == VehicleType.jcb
          ? Colors.orange
          : Colors.amber[700]!;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final entries =
        await WorkRepository.instance.getEntriesByVehicle(widget.vehicleType);
    final today = DateTime.now();
    setState(() {
      _allEntries = entries;
      _todayEntries = entries.where((e) {
        return e.createdAt.year == today.year &&
            e.createdAt.month == today.month &&
            e.createdAt.day == today.day;
      }).toList();
      _loading = false;
    });
  }

  double get _totalEarnings => _allEntries.fold(0, (s, e) => s + e.totalIncome);
  double get _totalDieselCost =>
      _allEntries.fold(0, (s, e) => s + e.dieselCost);
  double get _totalProfit => _allEntries.fold(0, (s, e) => s + e.profit);
  double get _totalHours => _allEntries.fold(0, (s, e) => s + e.workingHours);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _vehicleColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_vehicleEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(_vehicleName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              AppStrings.setTelugu(!AppStrings.isTelugu);
              setState(() {});
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: _vehicleColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    SectionHeader(title: AppStrings.dashboard),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        SummaryCard(
                          title: AppStrings.totalEarnings,
                          value: '₹${_totalEarnings.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee,
                          color: AppColors.earnings,
                        ),
                        SummaryCard(
                          title: AppStrings.dieselCost,
                          value: '₹${_totalDieselCost.toStringAsFixed(0)}',
                          icon: Icons.local_gas_station,
                          color: AppColors.diesel,
                        ),
                        SummaryCard(
                          title: AppStrings.profit,
                          value: '₹${_totalProfit.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: _totalProfit >= 0
                              ? AppColors.profit
                              : AppColors.loss,
                        ),
                        SummaryCard(
                          title: AppStrings.workingTime,
                          value:
                              '${_totalHours.toStringAsFixed(1)} ${AppStrings.hours}',
                          icon: Icons.access_time_filled,
                          color: AppColors.time,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_circle_rounded,
                            label: AppStrings.startWork,
                            color: _vehicleColor,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkEntryScreen(
                                      vehicleType: widget.vehicleType),
                                ),
                              );
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.people_alt_rounded,
                            label: AppStrings.history,
                            color: Colors.blueGrey,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerHistoryScreen(
                                      vehicleType: widget.vehicleType),
                                ),
                              );
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.bar_chart_rounded,
                            label: AppStrings.reports,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReportsScreen(
                                    vehicleType: widget.vehicleType,
                                    entries: _allEntries,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Today's Work
                    SectionHeader(
                      title: AppStrings.todayWork,
                      trailing: Text(
                        '${_todayEntries.length} jobs',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_todayEntries.isEmpty)
                      _buildEmptyToday()
                    else
                      ..._todayEntries.map((e) => WorkEntryTile(entry: e)),

                    const SizedBox(height: 28),

                    // Recent Work
                    SectionHeader(
                      title: AppStrings.isTelugu ? 'ఇటీవలి పని' : 'Recent Work',
                      trailing: Text(
                        '${_allEntries.length} total',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_allEntries.isEmpty)
                      _buildEmptyState()
                    else
                      ..._allEntries
                          .take(5)
                          .map((e) => WorkEntryTile(entry: e)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    WorkEntryScreen(vehicleType: widget.vehicleType)),
          );
          _loadData();
        },
        backgroundColor: _vehicleColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppStrings.startWork,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyToday() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('⏳', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(AppStrings.noWorkToday,
              style: const TextStyle(color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            AppStrings.isTelugu
                ? 'పని నమోదులు లేవు'
                : 'No work entries yet.\nTap + to add your first entry!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
