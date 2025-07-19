import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandahealthhospital/custom_widgets/drug_input_card.dart';
import 'package:pandahealthhospital/custom_widgets/interaction_result_card.dart';
import 'package:pandahealthhospital/custom_widgets/loading_overlay.dart';
import 'package:pandahealthhospital/custom_widgets/patient_info_card.dart';
import 'package:pandahealthhospital/models/drug_interaction_models.dart';
import 'package:pandahealthhospital/services/drug_interaction_service.dart';


class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen>
    with TickerProviderStateMixin {
  final DrugInteractionService _service = DrugInteractionService();
  final ScrollController _scrollController = ScrollController();
  
  final List<Drug> _drugs = [Drug(id: '1', name: '')];
  PatientInfo _patientInfo = PatientInfo(age: null, conditions: []);
  DrugInteractionResult? _result;
  bool _isLoading = false;
  String? _error;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addDrug() {
    setState(() {
      _drugs.add(Drug(id: DateTime.now().millisecondsSinceEpoch.toString(), name: ''));
    });
    HapticFeedback.lightImpact();
  }

  void _removeDrug(String id) {
    if (_drugs.length > 1) {
      setState(() {
        _drugs.removeWhere((drug) => drug.id == id);
      });
      HapticFeedback.lightImpact();
    }
  }

  void _updateDrugName(String id, String name) {
    setState(() {
      final index = _drugs.indexWhere((drug) => drug.id == id);
      if (index != -1) {
        _drugs[index] = Drug(
          id: id, 
          name: name, 
          imageFile: _drugs[index].imageFile,
          imagePath: _drugs[index].imagePath,
        );
      }
    });
  }

  void _updateDrugImage(String id, File? imageFile) {
    setState(() {
      final index = _drugs.indexWhere((drug) => drug.id == id);
      if (index != -1) {
        _drugs[index] = Drug(
          id: id, 
          name: _drugs[index].name, 
          imageFile: imageFile,
          imagePath: imageFile?.path,
        );
      }
    });
  }

  void _updatePatientAge(int? age) {
    setState(() {
      _patientInfo = PatientInfo(age: age, conditions: _patientInfo.conditions);
    });
  }

  void _addCondition(String condition) {
    if (condition.isNotEmpty && !_patientInfo.conditions.contains(condition)) {
      setState(() {
        _patientInfo = PatientInfo(
          age: _patientInfo.age,
          conditions: [..._patientInfo.conditions, condition],
        );
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removeCondition(String condition) {
    setState(() {
      _patientInfo = PatientInfo(
        age: _patientInfo.age,
        conditions: _patientInfo.conditions.where((c) => c != condition).toList(),
      );
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _checkInteractions() async {
    final validDrugs = _drugs.where((drug) => drug.isValid).toList();
    
    if (validDrugs.length < 2) {
      _showSnackBar('Please add at least 2 drugs (with names or images) to check interactions', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service.checkDrugInteractions(validDrugs, _patientInfo);
      setState(() {
        _result = result;
        _isLoading = false;
      });
      
      // Scroll to results
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      });
      
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showSnackBar('Failed to check interactions: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
          ? Theme.of(context).colorScheme.error 
          : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Drug Interaction Checker'),
        centerTitle: true,
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _shareResult(),
              tooltip: 'Share Results',
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrugInputCard(
                  drugs: _drugs,
                  onAddDrug: _addDrug,
                  onRemoveDrug: _removeDrug,
                  onUpdateDrugName: _updateDrugName,
                  onUpdateDrugImage: _updateDrugImage,
                ),
                const SizedBox(height: 24),
                PatientInfoCard(
                  patientInfo: _patientInfo,
                  onUpdateAge: _updatePatientAge,
                  onAddCondition: _addCondition,
                  onRemoveCondition: _removeCondition,
                ),
                const SizedBox(height: 32),
                if (_result != null) ...[
                  InteractionResultCard(
                    result: _result!,
                    drugs: _drugs,
                    patientInfo: _patientInfo,
                  ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ],
            ),
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _checkInteractions,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.search_rounded),
          label: const Text(
            'Check Interactions',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _shareResult() {
    if (_result != null) {
      final text = _service.formatResultForSharing(_result!);
      Clipboard.setData(ClipboardData(text: text));
      _showSnackBar('Results copied to clipboard');
    }
  }
}