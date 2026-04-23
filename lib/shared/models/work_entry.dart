import 'package:uuid/uuid.dart';

enum VehicleType { tractor, jcb, harvester }

enum WorkType {
  // Tractor
  rotor, ploughing, cultivation, seeding,
  // JCB
  digging, leveling, loading,
  // Harvester
  paddyCutting, wheatHarvesting,
}

enum PricingType { perHour, perAcre }

class WorkEntry {
  final String id;
  final String customerName;
  final VehicleType vehicleType;
  final WorkType workType;
  final DateTime startTime;
  final DateTime endTime;
  final double? acres;
  final double dieselUsed;
  final double dieselPricePerLiter;
  final double priceRate;
  final PricingType pricingType;
  final DateTime createdAt;

  WorkEntry({
    String? id,
    required this.customerName,
    required this.vehicleType,
    required this.workType,
    required this.startTime,
    required this.endTime,
    this.acres,
    required this.dieselUsed,
    required this.dieselPricePerLiter,
    required this.priceRate,
    required this.pricingType,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get workingHours => endTime.difference(startTime).inMinutes / 60.0;

  double get totalIncome {
    if (pricingType == PricingType.perHour) {
      return workingHours * priceRate;
    } else {
      return (acres ?? 0) * priceRate;
    }
  }

  double get dieselCost => dieselUsed * dieselPricePerLiter;

  double get profit => totalIncome - dieselCost;

  String get vehicleName {
    switch (vehicleType) {
      case VehicleType.tractor: return 'Tractor';
      case VehicleType.jcb: return 'JCB';
      case VehicleType.harvester: return 'Harvester';
    }
  }

  String get workTypeName {
    switch (workType) {
      case WorkType.rotor: return 'Rotor';
      case WorkType.ploughing: return 'Ploughing';
      case WorkType.cultivation: return 'Cultivation';
      case WorkType.seeding: return 'Seeding';
      case WorkType.digging: return 'Digging';
      case WorkType.leveling: return 'Leveling';
      case WorkType.loading: return 'Loading';
      case WorkType.paddyCutting: return 'Paddy Cutting';
      case WorkType.wheatHarvesting: return 'Wheat Harvesting';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'vehicleType': vehicleType.index,
        'workType': workType.index,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'acres': acres,
        'dieselUsed': dieselUsed,
        'dieselPricePerLiter': dieselPricePerLiter,
        'priceRate': priceRate,
        'pricingType': pricingType.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkEntry.fromJson(Map<String, dynamic> json) => WorkEntry(
        id: json['id'],
        customerName: json['customerName'],
        vehicleType: VehicleType.values[json['vehicleType']],
        workType: WorkType.values[json['workType']],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        acres: json['acres']?.toDouble(),
        dieselUsed: json['dieselUsed'].toDouble(),
        dieselPricePerLiter: json['dieselPricePerLiter'].toDouble(),
        priceRate: json['priceRate'].toDouble(),
        pricingType: PricingType.values[json['pricingType']],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class CustomerSummary {
  final String name;
  final List<WorkEntry> entries;

  CustomerSummary({required this.name, required this.entries});

  double get totalEarnings => entries.fold(0, (sum, e) => sum + e.totalIncome);
  double get totalProfit => entries.fold(0, (sum, e) => sum + e.profit);
  int get totalJobs => entries.length;
  DateTime? get lastWorkDate => entries.isEmpty ? null : entries.map((e) => e.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
}
