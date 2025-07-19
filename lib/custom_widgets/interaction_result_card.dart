import 'package:flutter/material.dart';
import 'package:pandahealthhospital/screens/drug_interaction/ai_chat_screen.dart';
import '../models/drug_interaction_models.dart';

class InteractionResultCard extends StatelessWidget {
  final DrugInteractionResult result;
  final List<Drug> drugs;
  final PatientInfo patientInfo;

  const InteractionResultCard({
    super.key,
    required this.result,
    required this.drugs,
    required this.patientInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.assessment_outlined,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drug Interaction Assessment',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overview
            InkWell(
              onTap: () => _openAiChat(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Drugs Checked',
                                result.drugsChecked.join(', '),
                                Icons.medication_outlined,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Patient Context',
                                result.patientContext,
                                Icons.person_outline,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap to chat with AI assistant',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Risk Profile - Featured
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result.riskProfile.severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: result.riskProfile.severityColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        result.riskProfile.severityIcon,
                        color: result.riskProfile.severityColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Risk Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: result.riskProfile.severityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem('Severity', result.riskProfile.severity),
                  const SizedBox(height: 8),
                  _buildDetailItem('Recommended Action', result.riskProfile.action),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Drug Profile
            _buildSection(
              '1. Drug Profile',
              result.drugProfile,
              Icons.info_outline,
              Theme.of(context).colorScheme.primary,
            ),
            
            const SizedBox(height: 20),
            
            // Adverse Effects
            _buildSection(
              '2. Adverse Effects',
              result.adverseEffects,
              Icons.warning_amber_outlined,
              Theme.of(context).colorScheme.error,
            ),
            
            const SizedBox(height: 20),
            
            // Mechanism of Action
            _buildSection(
              '3. Mechanism of Action',
              result.mechanismOfAction,
              Icons.science_outlined,
              Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 12),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _openAiChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiChatScreen(
          initialResult: result,
          drugs: drugs,
          patientInfo: patientInfo,
        ),
      ),
    );
  }
}