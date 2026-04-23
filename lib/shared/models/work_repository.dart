import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';

class WorkRepository {
  static const String _key = 'work_entries';
  static const String _dieselPriceKey = 'diesel_price';
  static const String _languageKey = 'is_telugu';

  static WorkRepository? _instance;
  static WorkRepository get instance => _instance ??= WorkRepository._();
  WorkRepository._();

  Future<List<WorkEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => WorkEntry.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<WorkEntry>> getEntriesByVehicle(VehicleType type) async {
    final all = await getAllEntries();
    return all.where((e) => e.vehicleType == type).toList();
  }

  Future<void> saveEntry(WorkEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == id;
    });
    await prefs.setStringList(_key, raw);
  }

  Future<double> getDieselPrice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_dieselPriceKey) ?? 95.0;
  }

  Future<void> saveDieselPrice(double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_dieselPriceKey, price);
  }

  Future<bool> getIsTeluguLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageKey) ?? false;
  }

  Future<void> saveLanguage(bool isTelugu) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageKey, isTelugu);
  }

  // Seed demo data for first launch
  Future<void> seedDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('demo_seeded') == true) return;

    final now = DateTime.now();
    final entries = [
      WorkEntry(
        customerName: 'Raju Farmer',
        vehicleType: VehicleType.tractor,
        workType: WorkType.ploughing,
        startTime: now.subtract(const Duration(days: 1, hours: 6)),
        endTime: now.subtract(const Duration(days: 1, hours: 2)),
        acres: 3.5,
        dieselUsed: 12,
        dieselPricePerLiter: 95,
        priceRate: 500,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Suresh Reddy',
        vehicleType: VehicleType.tractor,
        workType: WorkType.rotor,
        startTime: now.subtract(const Duration(days: 2, hours: 5)),
        endTime: now.subtract(const Duration(days: 2, hours: 1)),
        acres: 2.0,
        dieselUsed: 10,
        dieselPricePerLiter: 95,
        priceRate: 600,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Lakshmi Devi',
        vehicleType: VehicleType.harvester,
        workType: WorkType.paddyCutting,
        startTime: now.subtract(const Duration(days: 3, hours: 7)),
        endTime: now.subtract(const Duration(days: 3, hours: 1)),
        acres: 5.0,
        dieselUsed: 20,
        dieselPricePerLiter: 95,
        priceRate: 1200,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Venkat Rao',
        vehicleType: VehicleType.jcb,
        workType: WorkType.digging,
        startTime: now.subtract(const Duration(days: 4, hours: 8)),
        endTime: now.subtract(const Duration(days: 4, hours: 2)),
        dieselUsed: 25,
        dieselPricePerLiter: 95,
        priceRate: 1800,
        pricingType: PricingType.perHour,
      ),
      WorkEntry(
        customerName: 'Raju Farmer',
        vehicleType: VehicleType.tractor,
        workType: WorkType.cultivation,
        startTime: now.subtract(const Duration(days: 5, hours: 5)),
        endTime: now.subtract(const Duration(days: 5, hours: 2)),
        acres: 2.5,
        dieselUsed: 9,
        dieselPricePerLiter: 95,
        priceRate: 500,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Nagaraju',
        vehicleType: VehicleType.tractor,
        workType: WorkType.seeding,
        startTime: now.subtract(const Duration(days: 6, hours: 4)),
        endTime: now.subtract(const Duration(days: 6, hours: 1)),
        acres: 1.5,
        dieselUsed: 7,
        dieselPricePerLiter: 95,
        priceRate: 400,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Suresh Reddy',
        vehicleType: VehicleType.harvester,
        workType: WorkType.wheatHarvesting,
        startTime: now.subtract(const Duration(days: 7, hours: 6)),
        endTime: now.subtract(const Duration(days: 7, hours: 2)),
        acres: 4.0,
        dieselUsed: 16,
        dieselPricePerLiter: 95,
        priceRate: 1100,
        pricingType: PricingType.perAcre,
      ),
      WorkEntry(
        customerName: 'Lakshmi Devi',
        vehicleType: VehicleType.jcb,
        workType: WorkType.leveling,
        startTime: now.subtract(const Duration(days: 8, hours: 5)),
        endTime: now.subtract(const Duration(days: 8, hours: 1)),
        dieselUsed: 18,
        dieselPricePerLiter: 95,
        priceRate: 1600,
        pricingType: PricingType.perHour,
      ),
    ];

    for (final entry in entries) {
      await saveEntry(entry);
    }
    await prefs.setBool('demo_seeded', true);
  }
}
