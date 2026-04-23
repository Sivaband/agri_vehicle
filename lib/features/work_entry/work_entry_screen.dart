import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../shared/models/work_entry.dart';
import '../../shared/models/work_repository.dart';
import '../../shared/widgets/common_widgets.dart';

class WorkEntryScreen extends StatefulWidget {
  final VehicleType vehicleType;
  const WorkEntryScreen({super.key, required this.vehicleType});

  @override
  State<WorkEntryScreen> createState() => _WorkEntryScreenState();
}

class _WorkEntryScreenState extends State<WorkEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dieselController = TextEditingController();
  final _priceController = TextEditingController();
  final _dieselPriceController = TextEditingController(text: '95');

  WorkType? _selectedWorkType;
  PricingType _pricingType = PricingType.perAcre;
  
  // Tracking States
  bool _isTracking = false;
  bool _hasFinished = false;
  
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _duration = Duration.zero;

  // Speech
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  // GPS & Acres
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _path = [];
  double _calculatedAcres = 0;

  // Calculation results
  double _totalIncome = 0;
  double _dieselCost = 0;
  double _profit = 0;

  Color get _vehicleColor => widget.vehicleType == VehicleType.tractor
      ? AppColors.primaryGreen
      : widget.vehicleType == VehicleType.jcb
          ? Colors.orange
          : Colors.amber[700]!;

  List<WorkType> get _workTypes {
    switch (widget.vehicleType) {
      case VehicleType.tractor:
        return [
          WorkType.rotor,
          WorkType.ploughing,
          WorkType.cultivation,
          WorkType.seeding
        ];
      case VehicleType.jcb:
        return [WorkType.digging, WorkType.leveling, WorkType.loading];
      case VehicleType.harvester:
        return [WorkType.paddyCutting, WorkType.wheatHarvesting];
    }
  }

  Map<WorkType, double> get _defaultPrices => {
        WorkType.rotor: 600,
        WorkType.ploughing: 500,
        WorkType.cultivation: 450,
        WorkType.seeding: 400,
        WorkType.digging: 1800,
        WorkType.leveling: 1600,
        WorkType.loading: 1500,
        WorkType.paddyCutting: 1200,
        WorkType.wheatHarvesting: 1100,
      };

  Map<WorkType, PricingType> get _defaultPricingTypes => {
        WorkType.rotor: PricingType.perAcre,
        WorkType.ploughing: PricingType.perAcre,
        WorkType.cultivation: PricingType.perAcre,
        WorkType.seeding: PricingType.perAcre,
        WorkType.digging: PricingType.perHour,
        WorkType.leveling: PricingType.perHour,
        WorkType.loading: PricingType.perHour,
        WorkType.paddyCutting: PricingType.perAcre,
        WorkType.wheatHarvesting: PricingType.perAcre,
      };

  String _getWorkTypeName(WorkType t) {
    switch (t) {
      case WorkType.rotor: return AppStrings.rotor;
      case WorkType.ploughing: return AppStrings.ploughing;
      case WorkType.cultivation: return AppStrings.cultivation;
      case WorkType.seeding: return AppStrings.seeding;
      case WorkType.digging: return AppStrings.digging;
      case WorkType.leveling: return AppStrings.leveling;
      case WorkType.loading: return AppStrings.loading;
      case WorkType.paddyCutting: return AppStrings.paddyCutting;
      case WorkType.wheatHarvesting: return AppStrings.wheatHarvesting;
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _selectedWorkType = _workTypes.first;
    _pricingType = _defaultPricingTypes[_workTypes.first]!;
    _priceController.text = _defaultPrices[_workTypes.first]!.toStringAsFixed(0);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech not available')),
      );
      return;
    }
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _nameController.text = result.recognizedWords;
          if (result.finalResult) _isListening = false;
        });
      },
      localeId: AppStrings.isTelugu ? 'te_IN' : 'en_IN',
    );
  }

  Future<void> _startWork() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.isTelugu ? 'పని రకం ఎంచుకోండి' : 'Please select work type')),
      );
      return;
    }

    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _duration = Duration.zero;
      _path.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(_startTime!);
      });
    });

    if (widget.vehicleType != VehicleType.jcb) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          _positionStream = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
          ).listen((Position position) {
            _path.add(LatLng(position.latitude, position.longitude));
          });
        }
      }
    }
  }

  void _stopWork() {
    _timer?.cancel();
    _positionStream?.cancel();
    
    setState(() {
      _isTracking = false;
      _hasFinished = true;
      _endTime = DateTime.now();
    });

    if (widget.vehicleType != VehicleType.jcb && _path.length >= 3) {
      double areaSqMeters = SphericalUtil.computeArea(_path).toDouble();
      _calculatedAcres = areaSqMeters * 0.000247105;
    }
    
    _calculateProfit();
  }

  void _calculateProfit() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final diesel = double.tryParse(_dieselController.text) ?? 0;
    final dieselPrice = double.tryParse(_dieselPriceController.text) ?? 95;
    final hours = _duration.inMinutes / 60.0;
    
    setState(() {
      if (_pricingType == PricingType.perHour) {
        _totalIncome = hours * price;
      } else {
        _totalIncome = _calculatedAcres * price;
      }
      _dieselCost = diesel * dieselPrice;
      _profit = _totalIncome - _dieselCost;
    });
  }

  Future<void> _saveWork() async {
    final entry = WorkEntry(
      customerName: _nameController.text.trim(),
      vehicleType: widget.vehicleType,
      workType: _selectedWorkType!,
      startTime: _startTime ?? DateTime.now(),
      endTime: _endTime ?? DateTime.now(),
      acres: widget.vehicleType != VehicleType.jcb ? _calculatedAcres : null,
      dieselUsed: double.tryParse(_dieselController.text) ?? 0,
      dieselPricePerLiter: double.tryParse(_dieselPriceController.text) ?? 95,
      priceRate: double.tryParse(_priceController.text) ?? 0,
      pricingType: _pricingType,
    );

    await WorkRepository.instance.saveEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.isTelugu ? '✅ పని సేవ్ అయింది!' : '✅ Work saved successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _nameController.dispose();
    _dieselController.dispose();
    _priceController.dispose();
    _dieselPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _vehicleColor,
        title: Text(AppStrings.newWorkEntry),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isTracking && !_hasFinished) _buildSetupPhase(),
              if (_isTracking) _buildTrackingPhase(),
              if (_hasFinished) _buildSummaryPhase(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupPhase() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _SectionCard(
            title: AppStrings.customerName,
            icon: Icons.person,
            color: _vehicleColor,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterCustomerName,
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  color: _isListening ? Colors.red : _vehicleColor,
                  onPressed: _startListening,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: AppStrings.workType,
            icon: Icons.work_outline,
            color: _vehicleColor,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _workTypes.map((wt) {
                final selected = _selectedWorkType == wt;
                return ChoiceChip(
                  label: Text(_getWorkTypeName(wt)),
                  selected: selected,
                  selectedColor: _vehicleColor.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() {
                      _selectedWorkType = wt;
                      _pricingType = _defaultPricingTypes[wt]!;
                      _priceController.text = _defaultPrices[wt]!.toStringAsFixed(0);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Pricing Configuration',
            icon: Icons.currency_rupee,
            color: AppColors.earnings,
            child: Column(
              children: [
                SegmentedButton<PricingType>(
                  segments: const [
                    ButtonSegment(value: PricingType.perHour, label: Text('Per Hour')),
                    ButtonSegment(value: PricingType.perAcre, label: Text('Per Acre')),
                  ],
                  selected: {_pricingType},
                  onSelectionChanged: (set) => setState(() => _pricingType = set.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Rate'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _vehicleColor),
            onPressed: _startWork,
            child: const Text('START', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingPhase() {
    final hours = _duration.inHours.toString().padLeft(2, '0');
    final minutes = (_duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_duration.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.timer, size: 80, color: AppColors.time),
        const SizedBox(height: 20),
        Text(
          '$hours:$minutes:$seconds',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Text('Tracking ${widget.vehicleType != VehicleType.jcb ? "GPS & Time" : "Time"}...', style: const TextStyle(fontSize: 18, color: AppColors.textMedium)),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _stopWork,
          child: const Text('STOP', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _buildSummaryPhase() {
    return Column(
      children: [
        _SectionCard(
          title: 'Work Summary',
          icon: Icons.summarize,
          color: _vehicleColor,
          child: Column(
            children: [
              _SummaryRow(label: 'Duration:', value: '${(_duration.inMinutes / 60).toStringAsFixed(2)} hrs'),
              if (widget.vehicleType != VehicleType.jcb)
                _SummaryRow(label: 'Acres (Auto):', value: '${_calculatedAcres.toStringAsFixed(2)} ac'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: AppStrings.dieselUsed,
          icon: Icons.local_gas_station,
          color: AppColors.diesel,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dieselController,
                  decoration: InputDecoration(labelText: AppStrings.dieselUsed, suffixText: 'L'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateProfit(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _dieselPriceController,
                  decoration: const InputDecoration(labelText: 'Diesel ₹/L', prefixText: '₹ '),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateProfit(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Total Income:', value: '₹${_totalIncome.toStringAsFixed(0)}'),
              _SummaryRow(label: 'Diesel Cost:', value: '-₹${_dieselCost.toStringAsFixed(0)}'),
              const Divider(),
              _SummaryRow(label: 'Profit:', value: '₹${_profit.toStringAsFixed(0)}', bold: true),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _vehicleColor),
          onPressed: _saveWork,
          child: Text(AppStrings.saveWork, style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 16)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 16)),
        ],
      ),
    );
  }
}
