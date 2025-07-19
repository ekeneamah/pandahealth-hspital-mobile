import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/drug_interaction_models.dart';

class PatientInfoCard extends StatefulWidget {
  final PatientInfo patientInfo;
  final Function(int?) onUpdateAge;
  final Function(String) onAddCondition;
  final Function(String) onRemoveCondition;

  const PatientInfoCard({
    super.key,
    required this.patientInfo,
    required this.onUpdateAge,
    required this.onAddCondition,
    required this.onRemoveCondition,
  });

  @override
  State<PatientInfoCard> createState() => _PatientInfoCardState();
}

class _PatientInfoCardState extends State<PatientInfoCard> {
  final TextEditingController _conditionController = TextEditingController();
  final List<String> _commonConditions = [
    'Hypertension',
    'Diabetes Type 1',
    'Diabetes Type 2',
    'Renal impairment',
    'Heart disease',
    'Liver disease',
    'Pregnancy',
    'Breastfeeding',
    'Asthma',
    'COPD',
    'Epilepsy',
    'Depression',
    'Anxiety',
    'Arthritis',
    'High cholesterol',
    'Thyroid disorder',
    'Osteoporosis',
    'Glaucoma',
    'Migraine',
    'Allergies',
  ];

  List<String> _filteredConditions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _filteredConditions = _commonConditions;
  }

  @override
  void dispose() {
    _conditionController.dispose();
    super.dispose();
  }

  void _filterConditions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConditions = _commonConditions;
        _showSuggestions = false;
      } else {
        _filteredConditions = _commonConditions
            .where((condition) =>
                condition.toLowerCase().contains(query.toLowerCase()) &&
                !widget.patientInfo.conditions.contains(condition))
            .toList();
        _showSuggestions = _filteredConditions.isNotEmpty;
      }
    });
  }

  void _addCondition(String condition) {
    if (condition.trim().isNotEmpty && 
        !widget.patientInfo.conditions.contains(condition.trim())) {
      widget.onAddCondition(condition.trim());
      _conditionController.clear();
      setState(() {
        _showSuggestions = false;
        _filteredConditions = _commonConditions;
      });
    }
  }

  void _addCustomCondition() {
    final condition = _conditionController.text.trim();
    if (condition.isNotEmpty) {
      _addCondition(condition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Patient Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Provide patient context for more accurate interaction analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            
            // Age Input
            TextFormField(
              initialValue: widget.patientInfo.age?.toString(),
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Enter patient age',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                suffixText: 'years',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (value) {
                final age = int.tryParse(value);
                widget.onUpdateAge(age);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Conditions Section
            Text(
              'Medical Conditions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Add Condition Input with Suggestions
            Column(
              children: [
                TextFormField(
                  controller: _conditionController,
                  decoration: InputDecoration(
                    labelText: 'Add medical condition',
                    hintText: 'Type to search or add custom condition',
                    prefixIcon: const Icon(Icons.health_and_safety_outlined),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_conditionController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _conditionController.clear();
                              setState(() {
                                _showSuggestions = false;
                                _filteredConditions = _commonConditions;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _addCustomCondition,
                          tooltip: 'Add condition',
                        ),
                      ],
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: _filterConditions,
                  onFieldSubmitted: (_) => _addCustomCondition(),
                ),
                
                // Suggestions dropdown
                if (_showSuggestions && _filteredConditions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredConditions.length,
                      itemBuilder: (context, index) {
                        final condition = _filteredConditions[index];
                        return ListTile(
                          dense: true,
                          title: Text(condition),
                          leading: Icon(
                            Icons.medical_information_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onTap: () => _addCondition(condition),
                        );
                      },
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Common Conditions Quick Add
            if (!_showSuggestions) ...[
              Text(
                'Quick Add Common Conditions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonConditions
                    .where((condition) => !widget.patientInfo.conditions.contains(condition))
                    .take(6)
                    .map((condition) {
                  return ActionChip(
                    label: Text(
                      condition,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _addCondition(condition),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            
            // Selected Conditions
            if (widget.patientInfo.conditions.isNotEmpty) ...[
              Text(
                'Selected Conditions (${widget.patientInfo.conditions.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.patientInfo.conditions.map((condition) {
                  return Chip(
                    label: Text(condition),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => widget.onRemoveCondition(condition),
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    deleteIconColor: Theme.of(context).colorScheme.secondary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No medical conditions added yet. Add conditions for more accurate drug interaction analysis.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}