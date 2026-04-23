import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../shared/models/work_entry.dart';
import '../../shared/widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  final VehicleType vehicleType;
  final List<WorkEntry> entries;

  const ReportsScreen({super.key, required this.vehicleType, required this.entries});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  Color get _vehicleColor => widget.vehicleType == VehicleType.tractor
      ? AppColors.primaryGreen
      : widget.vehicleType == VehicleType.jcb
          ? Colors.orange
          : Colors.amber[700]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() => _selectedTab = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<WorkEntry> get _filteredEntries {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0: // Daily
        return widget.entries.where((e) =>
            e.createdAt.year == now.year && e.createdAt.month == now.month && e.createdAt.day == now.day).toList();
      case 1: // Weekly
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.entries.where((e) => e.createdAt.isAfter(weekAgo)).toList();
      case 2: // Monthly
        return widget.entries.where((e) => e.createdAt.year == now.year && e.createdAt.month == now.month).toList();
      default:
        return widget.entries;
    }
  }

  // Group entries by day for chart
  Map<int, double> get _dailyEarnings {
    final map = <int, double>{};
    final days = _selectedTab == 0 ? 1 : _selectedTab == 1 ? 7 : 30;
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayEntries = widget.entries.where((e) =>
          e.createdAt.year == day.year && e.createdAt.month == day.month && e.createdAt.day == day.day);
      map[days - 1 - i] = dayEntries.fold(0, (s, e) => s + e.totalIncome);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;
    final totalEarnings = filtered.fold(0.0, (s, e) => s + e.totalIncome);
    final totalDiesel = filtered.fold(0.0, (s, e) => s + e.dieselCost);
    final totalProfit = filtered.fold(0.0, (s, e) => s + e.profit);
    final totalHours = filtered.fold(0.0, (s, e) => s + e.workingHours);
    final dailyData = _dailyEarnings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _vehicleColor,
        title: Text(AppStrings.reports),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: AppStrings.daily),
            Tab(text: AppStrings.weekly),
            Tab(text: AppStrings.monthly),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
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
                  value: '₹${totalEarnings.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee,
                  color: AppColors.earnings,
                ),
                SummaryCard(
                  title: AppStrings.dieselCost,
                  value: '₹${totalDiesel.toStringAsFixed(0)}',
                  icon: Icons.local_gas_station,
                  color: AppColors.diesel,
                ),
                SummaryCard(
                  title: AppStrings.profit,
                  value: '₹${totalProfit.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: totalProfit >= 0 ? AppColors.profit : AppColors.loss,
                ),
                SummaryCard(
                  title: AppStrings.workingTime,
                  value: '${totalHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time,
                  color: AppColors.time,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Earnings Chart
            SectionHeader(title: AppStrings.earningsChart),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: _vehicleColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: dailyData.isEmpty || dailyData.values.every((v) => v == 0)
                  ? Center(
                      child: Text(
                        AppStrings.isTelugu ? 'డేటా లేదు' : 'No data for this period',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: dailyData.values.reduce((a, b) => a > b ? a : b) * 1.3 + 100,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (val, _) => Text('₹${val.toInt()}',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) {
                                final days = _selectedTab == 0 ? 1 : _selectedTab == 1 ? 7 : 30;
                                final now = DateTime.now();
                                final day = now.subtract(Duration(days: days - 1 - val.toInt()));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('${day.day}/${day.month}',
                                      style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: dailyData.entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: _vehicleColor,
                                width: _selectedTab == 2 ? 6 : 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Pie Chart - Earnings vs Diesel
            if (totalEarnings > 0) ...[
              SectionHeader(title: AppStrings.isTelugu ? 'ఆదాయం వర్సెస్ ఖర్చు' : 'Earnings vs Cost Breakdown'),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _vehicleColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: totalProfit > 0 ? totalProfit : 0,
                              color: AppColors.profit,
                              title: '${((totalProfit / totalEarnings) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: totalDiesel,
                              color: AppColors.diesel,
                              title: '${((totalDiesel / totalEarnings) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Legend(color: AppColors.profit, label: AppStrings.profit),
                        const SizedBox(height: 10),
                        _Legend(color: AppColors.diesel, label: AppStrings.dieselCost),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Work entries list
            if (filtered.isNotEmpty) ...[
              SectionHeader(
                title: AppStrings.isTelugu ? 'పని జాబితా' : 'Work List',
                trailing: Text('${filtered.length} entries', style: const TextStyle(color: AppColors.textLight)),
              ),
              const SizedBox(height: 12),
              ...filtered.map((e) => WorkEntryTile(entry: e)),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
      ],
    );
  }
}
