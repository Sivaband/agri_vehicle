import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../shared/models/work_entry.dart';
import '../../shared/models/work_repository.dart';
import '../../shared/widgets/common_widgets.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final VehicleType vehicleType;
  const CustomerHistoryScreen({super.key, required this.vehicleType});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<WorkEntry> _entries = [];
  bool _loading = true;

  Map<String, List<WorkEntry>> get _customerMap {
    final map = <String, List<WorkEntry>>{};
    for (final e in _entries) {
      map.putIfAbsent(e.customerName, () => []).add(e);
    }
    // Sort by total earnings descending
    final sorted = map.entries.toList()
      ..sort((a, b) {
        final aTot = a.value.fold(0.0, (s, e) => s + e.totalIncome);
        final bTot = b.value.fold(0.0, (s, e) => s + e.totalIncome);
        return bTot.compareTo(aTot);
      });
    return Map.fromEntries(sorted);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final entries = await WorkRepository.instance.getEntriesByVehicle(widget.vehicleType);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Color get _vehicleColor => widget.vehicleType == VehicleType.tractor
      ? AppColors.primaryGreen
      : widget.vehicleType == VehicleType.jcb
          ? Colors.orange
          : Colors.amber[700]!;

  @override
  Widget build(BuildContext context) {
    final customerMap = _customerMap;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _vehicleColor,
        title: Text(AppStrings.customerHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : customerMap.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: customerMap.length,
                  itemBuilder: (ctx, i) {
                    final name = customerMap.keys.elementAt(i);
                    final entries = customerMap[name]!;
                    final summary = CustomerSummary(name: name, entries: entries);
                    return _CustomerCard(
                      summary: summary,
                      vehicleColor: _vehicleColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _CustomerDetailScreen(summary: summary, vehicleColor: _vehicleColor),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            AppStrings.isTelugu ? 'కస్టమర్లు లేరు' : 'No customers yet',
            style: const TextStyle(fontSize: 18, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerSummary summary;
  final Color vehicleColor;
  final VoidCallback onTap;

  const _CustomerCard({required this.summary, required this.vehicleColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: vehicleColor.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: vehicleColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  summary.name.isNotEmpty ? summary.name[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: vehicleColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Chip(
                          label: '${summary.totalJobs} ${AppStrings.isTelugu ? "పనులు" : "jobs"}',
                          color: vehicleColor),
                      const SizedBox(width: 6),
                      if (summary.lastWorkDate != null)
                        _Chip(label: _formatDate(summary.lastWorkDate!), color: Colors.blueGrey),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${summary.totalEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.earnings),
                ),
                Text(
                  AppStrings.isTelugu ? 'మొత్తం ఆదాయం' : 'Total',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// Customer Detail Screen
class _CustomerDetailScreen extends StatelessWidget {
  final CustomerSummary summary;
  final Color vehicleColor;

  const _CustomerDetailScreen({required this.summary, required this.vehicleColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: vehicleColor,
        title: Text(summary.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Row
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: AppStrings.totalEarnings,
                    value: '₹${summary.totalEarnings.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                    color: AppColors.earnings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: AppStrings.totalJobs,
                    value: summary.totalJobs.toString(),
                    icon: Icons.work_outline,
                    color: vehicleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              title: AppStrings.profit,
              value: '₹${summary.totalProfit.toStringAsFixed(0)}',
              icon: Icons.trending_up,
              color: summary.totalProfit >= 0 ? AppColors.profit : AppColors.loss,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: AppStrings.isTelugu ? 'పని చరిత్ర' : 'Work History'),
            const SizedBox(height: 12),
            ...summary.entries.map((e) => WorkEntryTile(entry: e)),
          ],
        ),
      ),
    );
  }
}
