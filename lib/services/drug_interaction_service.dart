import '../models/drug_interaction_models.dart';

class DrugInteractionService {
  // Simulated API call - replace with actual API integration
  Future<DrugInteractionResult> checkDrugInteractions(
    List<Drug> drugs, 
    PatientInfo patientInfo
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Extract drug names (for drugs with images, you would use OCR or image recognition)
    final drugNames = drugs.map((d) => d.hasName ? d.name : 'Drug from image').toList();
    
    // Simulate different responses based on drug combinations
    if (drugNames.any((name) => name.toLowerCase().contains('lisinopril')) && 
        drugNames.any((name) => name.toLowerCase().contains('ibuprofen'))) {
      return _createLisinoprilIbuprofenResult(drugNames, patientInfo);
    } else if (drugNames.any((name) => name.toLowerCase().contains('warfarin'))) {
      return _createWarfarinResult(drugNames, patientInfo);
    } else {
      return _createGenericResult(drugNames, patientInfo);
    }
  }

  DrugInteractionResult _createLisinoprilIbuprofenResult(
    List<String> drugs, 
    PatientInfo patientInfo
  ) {
    return DrugInteractionResult(
      drugsChecked: drugs,
      patientContext: _formatPatientContext(patientInfo),
      drugProfile: [
        'Lisinopril: ACE inhibitor used to treat hypertension and protect kidneys.',
        'Ibuprofen: NSAID for pain and inflammation relief.',
      ],
      adverseEffects: [
        'Lisinopril: Hyperkalemia, dizziness, dry cough. Risky in pregnancy or renal issues.',
        'Ibuprofen: GI irritation, elevated blood pressure, renal stress. Risky in hypertensive or renal patients.',
      ],
      mechanismOfAction: [
        'Lisinopril blocks angiotensin-converting enzyme, reducing blood pressure.',
        'Ibuprofen inhibits prostaglandins, reducing pain but lowering kidney perfusion.',
        'Combined use can impair kidney function and reduce antihypertensive efficacy.',
      ],
      riskProfile: RiskProfile(
        severity: 'Moderate to Severe',
        action: 'Consider paracetamol instead of ibuprofen. Consult doctor before dispensing.',
      ),
    );
  }

  DrugInteractionResult _createWarfarinResult(
    List<String> drugs, 
    PatientInfo patientInfo
  ) {
    return DrugInteractionResult(
      drugsChecked: drugs,
      patientContext: _formatPatientContext(patientInfo),
      drugProfile: [
        'Warfarin: Anticoagulant used to prevent blood clots.',
        ...drugs.where((d) => !d.toLowerCase().contains('warfarin')).map((d) => '$d: Consult drug database for specific profile.'),
      ],
      adverseEffects: [
        'Warfarin: Bleeding risk, requires regular INR monitoring.',
        'Drug interactions with warfarin can significantly increase bleeding risk.',
      ],
      mechanismOfAction: [
        'Warfarin inhibits vitamin K-dependent clotting factors.',
        'Many drugs can potentiate or antagonize warfarin effects.',
      ],
      riskProfile: RiskProfile(
        severity: 'High',
        action: 'Monitor INR closely. Consult prescriber before dispensing any new medications with warfarin.',
      ),
    );
  }

  DrugInteractionResult _createGenericResult(
    List<String> drugs, 
    PatientInfo patientInfo
  ) {
    return DrugInteractionResult(
      drugsChecked: drugs,
      patientContext: _formatPatientContext(patientInfo),
      drugProfile: drugs.map((drug) => '$drug: Consult drug database for detailed profile.').toList(),
      adverseEffects: [
        'Review individual drug monographs for specific adverse effects.',
        'Consider patient-specific risk factors and contraindications.',
      ],
      mechanismOfAction: [
        'Each drug has a specific mechanism of action.',
        'Potential interactions depend on metabolic pathways and receptor targets.',
      ],
      riskProfile: RiskProfile(
        severity: 'Low to Moderate',
        action: 'No major interactions found. Standard monitoring recommended.',
      ),
    );
  }

  String _formatPatientContext(PatientInfo patientInfo) {
    final age = patientInfo.age != null ? '${patientInfo.age}-year-old' : 'Adult';
    final conditions = patientInfo.conditions.isNotEmpty 
      ? patientInfo.conditions.join(', ') 
      : 'No known conditions';
    return '$age patient, $conditions';
  }

  String formatResultForSharing(DrugInteractionResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('Drug Interaction Assessment');
    buffer.writeln('');
    buffer.writeln('Drugs Checked: ${result.drugsChecked.join(', ')}');
    buffer.writeln('Patient Context: ${result.patientContext}');
    buffer.writeln('');
    
    buffer.writeln('1. Drug Profile');
    for (final profile in result.drugProfile) {
      buffer.writeln('- $profile');
    }
    buffer.writeln('');
    
    buffer.writeln('2. Adverse Effects of Drug');
    for (final effect in result.adverseEffects) {
      buffer.writeln('- $effect');
    }
    buffer.writeln('');
    
    buffer.writeln('3. Mechanism of Action');
    for (final mechanism in result.mechanismOfAction) {
      buffer.writeln('- $mechanism');
    }
    buffer.writeln('');
    
    buffer.writeln('4. Risk Profile');
    buffer.writeln('- Severity: ${result.riskProfile.severity}');
    buffer.writeln('- Action: ${result.riskProfile.action}');
    
    return buffer.toString();
  }

  // New method for follow-up questions in AI chat
  Future<String> askFollowUpQuestion(
    String question,
    List<Drug> drugs,
    PatientInfo patientInfo,
    DrugInteractionResult previousResult,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    // Extract drug names
    final drugNames = drugs.map((d) => d.hasName ? d.name : 'Drug from image').toList();
    
    // Simulate AI responses based on common questions
    if (question.toLowerCase().contains('alternative') || 
        question.toLowerCase().contains('substitute')) {
      return _generateAlternativeResponse(drugNames, patientInfo);
    } else if (question.toLowerCase().contains('dosage') || 
               question.toLowerCase().contains('dose')) {
      return _generateDosageResponse(drugNames, patientInfo);
    } else if (question.toLowerCase().contains('side effect') || 
               question.toLowerCase().contains('adverse')) {
      return _generateSideEffectResponse(drugNames, patientInfo);
    } else if (question.toLowerCase().contains('food') || 
               question.toLowerCase().contains('diet')) {
      return _generateFoodInteractionResponse(drugNames);
    } else if (question.toLowerCase().contains('timing') || 
               question.toLowerCase().contains('when')) {
      return _generateTimingResponse(drugNames);
    } else {
      return _generateGenericResponse(question, drugNames, patientInfo);
    }
  }

  String _generateAlternativeResponse(List<String> drugs, PatientInfo patientInfo) {
    final age = patientInfo.age != null ? '${patientInfo.age}-year-old' : 'adult';
    return '''Based on the current medications and patient profile ($age patient), here are some alternative options:

**For pain management:**
• Paracetamol (acetaminophen) - safer for kidney function
• Topical NSAIDs - reduced systemic exposure
• Physical therapy and non-pharmacological approaches

**For hypertension:**
• Consider ARBs (like losartan) if ACE inhibitors cause cough
• Calcium channel blockers for additional blood pressure control
• Lifestyle modifications (diet, exercise, stress management)

**Important:** Any medication changes should be discussed with the prescribing physician. Consider patient's complete medical history, allergies, and current response to therapy.''';
  }

  String _generateDosageResponse(List<String> drugs, PatientInfo patientInfo) {
    return '''**Dosage Considerations:**

**General Guidelines:**
• Start with lowest effective dose, especially in elderly patients
• Adjust based on kidney and liver function
• Monitor for therapeutic response and side effects

**Patient-Specific Factors:**
• Age: ${patientInfo.age ?? 'Not specified'}
• Conditions: ${patientInfo.conditions.isNotEmpty ? patientInfo.conditions.join(', ') : 'None specified'}

**Monitoring:**
• Regular blood pressure checks for antihypertensives
• Kidney function tests if using ACE inhibitors with NSAIDs
• Watch for signs of drug accumulation

**Note:** Exact dosing must be determined by the prescribing physician based on individual patient factors and clinical response.''';
  }

  String _generateSideEffectResponse(List<String> drugs, PatientInfo patientInfo) {
    return '''**Common Side Effects to Monitor:**

**ACE Inhibitors (like Lisinopril):**
• Dry cough (10-15% of patients)
• Dizziness, especially when standing
• Elevated potassium levels
• Rare: Angioedema (swelling of face/throat)

**NSAIDs (like Ibuprofen):**
• Stomach upset, heartburn
• Increased blood pressure
• Kidney function changes
• Fluid retention

**Red Flags - Seek immediate medical attention:**
• Difficulty breathing or swallowing
• Severe stomach pain
• Significant swelling
• Unusual fatigue or weakness

**Patient Education:**
• Take medications as prescribed
• Report any concerning symptoms promptly
• Regular follow-up appointments are important''';
  }

  String _generateFoodInteractionResponse(List<String> drugs) {
    return '''**Food and Drug Interactions:**

**ACE Inhibitors:**
• Avoid excessive potassium-rich foods (bananas, oranges, potatoes)
• Limit salt substitutes containing potassium
• Maintain consistent diet

**NSAIDs:**
• Take with food to reduce stomach irritation
• Avoid alcohol (increases GI bleeding risk)
• Stay well hydrated

**General Recommendations:**
• Maintain consistent meal timing with medications
• Avoid grapefruit juice with many medications
• Limit caffeine if taking blood pressure medications
• Discuss any dietary supplements with pharmacist

**Timing:**
• Some medications work better on empty stomach
• Others need food to prevent irritation
• Follow specific instructions for each medication''';
  }

  String _generateTimingResponse(List<String> drugs) {
    return '''**Optimal Timing for Medications:**

**ACE Inhibitors:**
• Usually once daily, preferably at bedtime
• Helps minimize dizziness during daily activities
• Consistent timing improves effectiveness

**NSAIDs:**
• With meals to reduce stomach irritation
• Avoid late evening doses (may affect sleep)
• Short-term use recommended

**General Timing Tips:**
• Space medications appropriately if taking multiple drugs
• Use pill organizers or medication apps for reminders
• Don't skip doses - maintain consistent blood levels
• If you miss a dose, take it as soon as remembered (unless close to next dose)

**Special Considerations:**
• Some medications interact if taken too close together
• Blood pressure medications often work better at specific times
• Always follow pharmacist's specific instructions''';
  }

  String _generateGenericResponse(String question, List<String> drugs, PatientInfo patientInfo) {
    return '''Thank you for your question about "${question}".

**Current Medication Context:**
• Drugs: ${drugs.join(', ')}
• Patient: ${_formatPatientContext(patientInfo)}

**General Guidance:**
I can help with questions about drug interactions, side effects, timing, alternatives, and general medication guidance. For specific medical advice or dosing changes, please consult with the prescribing physician or clinical pharmacist.

**Common Topics I Can Help With:**
• Drug interaction explanations
• Side effect information
• Timing and administration
• Food and drug interactions
• Alternative medication options
• Patient education points

Feel free to ask more specific questions about any of these topics!''';
  }
}