import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/models/clerking_report.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/screens/hospital/view_ai_analysis.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pandahealthhospital/screens/hospital/select_doctor.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pandahealthhospital/models/appointment_request.dart';

class ClerkingField {
  final String type;
  final String label;
  dynamic value;
  final List<String>? options;

  ClerkingField({
    required this.type,
    required this.label,
    this.value,
    this.options,
  });

  factory ClerkingField.fromJson(Map<String, dynamic> json) {
    return ClerkingField(
      type: json['type'] as String,
      label: json['label'] as String,
      value: json['value'],
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'value': value,
      'options': options,
    };
  }
}

class HospitalClerkingPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedFiles;
  final AppointmentRequest? appointmentRequest;
  const HospitalClerkingPage({
    super.key,
    this.selectedFiles = const [],
    this.appointmentRequest,
  });

  @override
  _HospitalClerkingPageState createState() => _HospitalClerkingPageState();
}

class _HospitalClerkingPageState extends State<HospitalClerkingPage> {
  List fields = [];
  String notesText = "";
  bool loading = false;
  bool isLoadingTemplate = true;
  String? reportId;
  ClerkingReport? clerkingReport;
  List<Map<String, dynamic>> selectedFiles = [];
   List<String> uploadedImageUrls = []; 
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  late Hospital hospital;

  final FirebaseServices _firebaseServices = FirebaseServices();

  bool _hasUnsavedChanges = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _codeSent = false;

  DateTime? _startTime;
  Duration _formCompletionTime = Duration.zero;

  bool _hasObtainedConsent = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    selectedFiles = widget.selectedFiles;
    _firebaseServices.getClerkingTemplateSettings().then((val) {
      if (val != null) {
        setState(() {
          fields = val;
          isLoadingTemplate = false;
        });
      } else {
        setState(() {
          isLoadingTemplate = false;
        });
      }
    });

    hospital = Provider.of<UserStore>(context, listen: false).hospital!;
  }

  Duration _calculateFormCompletionTime() {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  void onSingleOptionSelect(dynamic e, int sectionIndex, int fieldIndex) {
    if (fieldIndex >= 0 && sectionIndex >= 0) {
      setState(() {
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                field['value'] = e;
              }
              return field;
            }).toList();
          }
          return section;
        }).toList();
      });
    } else {
      print('Invalid section index or field index');
    }
  }

  void onMultipleOptionSelect(
      dynamic e, bool add, int sectionIndex, int fieldIndex, int itemIndex) {
    if (fieldIndex >= 0 && itemIndex >= 0) {
      setState(() {
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                final currentValues = List.from(field['value']);
                if (!add) {
                  currentValues.remove(e);
                } else {
                  if (!currentValues.contains(e)) {
                    currentValues.add(e);
                  }
                }
                field['value'] = currentValues;
              }
              return field;
            }).toList();
          }
          return section;
        }).toList();
      });
    } else {
      print('Invalid section index or field index');
    }
  }

  void onDetailsUpdate(dynamic e, int sectionIndex, int fieldIndex) {
    if (fieldIndex >= 0 && sectionIndex >= 0) {
      setState(() {
        _hasUnsavedChanges = true;
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                field['value'] = e;
              }
              return field;
            }).toList();
          }
          return section;
        }).toList();
      });
    }
  }
/* I/flutter (12937): Generating AI analysis with fields: [{inputs: [{options: [], name: Patient ID(e.g 08031168021), type: text, value: Wert12}, {name: Sex, options: [Male, Female], type: soption, value: Male}, {options: [], name: Date of Birth, type: text, value: 2012-06-28T00:00:00.000}, {options: [], name: Contact(Phone e.g 08012345678), type: text, value: 07033033047}, {options: [], name: Contact(Email), type: text, value: }, {options: [], name: Referrer ID, type: text, value: }], title: Consultation Summary}, {inputs: [{options: [], name: RESP.RATE(Cycles per minute(c/m)), type: text, value: }, {options: [], name: TEMP(C), type: text, value: }, {options: [], name: SP02(%), type: text, value: }, {options: [], name: LMP, type: text, value: }, {options: [], name: Pulse, type: text, value: }, {options: [], name: BP, type: text, value: }, {options: [], name: Height(cm), type: text, value: }, {options: [], name: Weight(kg), type: text, value: }], title: Vitals}, {inputs: [{options: [], name: Chief Complaint/Duration of chief comp      
W/FirebaseContextProvider(12937): Error getting App Check token. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.

 */

  Future<bool> generateAiAnalysis() async {
    setState(() => loading = true);
    try {
      if (fields.isEmpty) {
        showCustomErrorToast("No fields available for AI analysis");
        return false;
      }
      debugPrint("Generating AI analysis with fields: $fields");
      debugPrint("Generating AI analysis with selectedFiles: $selectedFiles");
      // Generate AI analysis using the fields
      final analysis = await _firebaseServices.generateDiagnosisAssist(
  fields.toString(),
  selectedFiles: selectedFiles,
  imageFile: null,
);
debugPrint("AI analysis response: $analysis");
if (analysis != null) {
  debugPrint("Analysis object: $analysis");
  setState(() {
    if (analysis is String) {
      notesText = analysis;
    } else if (analysis is Map<String, dynamic>) {
      notesText = analysis['plainText'] ?? analysis['result'] ?? "No summary generated";
      uploadedImageUrls = List<String>.from(analysis['imageUrls'] ?? []);
    } else {
      notesText = "No summary generated";
    }
    loading = false;
  }); 
  return true;
} else {
  showCustomErrorToast("Couldn't generate AI report");
  debugPrint("AI analysis returned null or empty");
  return false;
}
    } catch (e) {
      debugPrint("Error generating AI analysis: $e");
      showCustomErrorToast("Couldn't generate AI report  $e");
      return false;
    } finally {
      setState(() => loading = false);
    }
  }

  void handleNoteChange(dynamic e) {
    setState(() {
      notesText = e;
    });
  }

  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.any);

    if (result != null) {
      setState(() {
        selectedFiles = result.files
            .map((val) => {'file': File(val.path!), 'name': val.name})
            .toList();
      });
    }
  }

  Future<bool> generateReport() async {
    debugPrint("Generating report with fields: $fields");
       debugPrint("Generating report with fields: $notesText");
    try {
      setState(() {
        loading = true;
      });

      if (notesText.isEmpty) {
        await generateAiAnalysis();
        setState(() {
          loading = true;
        });
      }

      if (notesText.isEmpty) return false;

      List<String> uploadedFiles = [];

      //Upload the documents if any
      if (selectedFiles.isNotEmpty) {
        uploadedFiles = await _firebaseServices
            .uploadFiles(selectedFiles.map((e) => e['file'] as File).toList());
      }

      _formCompletionTime = _calculateFormCompletionTime();

      // Include systemsSummary in the fields data if it exists
      if (widget.appointmentRequest?.systemsSummary != null) {
        fields.insert(0, {
          'title': 'Previous Systems Summary',
          'inputs': [
            {
              'type': 'text',
              'name': 'Systems Summary',
              'value': widget.appointmentRequest!.systemsSummary,
            }
          ]
        });
      }

      final val = await _firebaseServices.createClerkingReport(
          hospital.id,
          notesText,
          fields.toString(),
          uploadedFiles,
          _formCompletionTime.inSeconds,
          _codeSent ? _phoneController.text : null,
          widget.appointmentRequest?.id);

      if (val is String) {
        setState(() {
          reportId = val;
          loading = false;
        });
        return true;
      } else {
        showCustomErrorToast("Couldn't Share Report");
        setState(() {
          loading = false;
        });
        return false;
      }
    } catch (er) {
      print(er);
      showCustomErrorToast("Couldn't share report");
      return false;
    }
  }

  generateShareLink() async {
    setState(() {
      loading = true;
    });
    //Get the clerking details from the id
    if (reportId == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    clerkingReport = clerkingReport ??
        await _firebaseServices.getClerkingReportFromId(reportId!);

    showCustomToast("Generating share link...");
    setState(() {
      loading = false;
    });

    Share.share(
        "Tap the link to access the clerking details and collaborate on it. $clerkingTemplateBaseUrl/${clerkingReport?.id}. The passcode is ${clerkingReport?.passcode}");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomTitleBar(
          title: _getStepTitle(),
          showBackButton: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: backgroundDecoration(false),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: isLoadingTemplate
                      ? const Center(child: CircularProgressIndicator())
                      : PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildConsentForm(),
                            _buildClerkingForm(),
                            _buildAIAnalysis(),
                            _buildSharePage(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }

    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved data that will be lost if you leave this page. Are you sure you want to leave?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(
          _totalSteps,
          (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? lightGreen : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Patient Consent';
      case 1:
        return 'Patient Details';
      case 2:
        return 'AI Analysis';
      case 3:
        return 'Share Report';
      default:
        return '';
    }
  }

  Widget _buildClerkingForm() {
    return SafeArea(
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: lightGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Capturing as much information as possible improves the accuracy of results',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.appointmentRequest?.systemsSummary != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: lightGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.medical_information,
                                    color: lightGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Previous Systems Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.appointmentRequest!.systemsSummary!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildTestResultsSection(),
                    const SizedBox(height: 24),
                    _buildSections(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSections() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      itemBuilder: (context, sectionIndex) {
        final section = fields[sectionIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                (section['inputs'] as List).length,
                (fieldIndex) => _buildField(
                  section['inputs'][fieldIndex],
                  sectionIndex: sectionIndex,
                  fieldIndex: fieldIndex,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIAnalysis() {
    return SafeArea(
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Analysis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (loading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: darkBlue),
                          SizedBox(height: 16),
                          Text('Generating AI analysis...'),
                        ],
                      ),
                    )
                  else if (notesText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        notesText,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: _handleSaveAndExit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: darkBlue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Save and Exit',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildBottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isValid = _currentStep == 0
        ? _codeSent
            ? _otpController.text.length == 6
            : _phoneController.text.length >= 10
        : isFormValid();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: InkWell(
        onTap: !isValid || _isVerifying ? null : _handleButtonPress,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isValid && (!_isVerifying || !loading)
                ? darkBlue
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getButtonText(),
                style: TextStyle(
                  color: isValid && !_isVerifying
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isVerifying || loading) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Clerking Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Analysis Summary',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(notesText),
                  const SizedBox(height: 16),
                  if (selectedFiles.isNotEmpty) ...[
                    const Text(
                      'Attached Files',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...selectedFiles
                        .map((file) => Text(file['name'] as String)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test Results(Optional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                TextButton.icon(
                  onPressed: pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Files'),
                ),
              ],
            ),
            if (selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...selectedFiles.map((file) => ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(file['name'] as String),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedFiles.remove(file);
                        });
                      },
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(field, {int sectionIndex = -1, int fieldIndex = -1}) {
    switch (field['type']) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTextField(field, sectionIndex, fieldIndex),
        );
      case 'soption':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field['name'], style: const TextStyle(fontSize: 16)),
              if (field['name'].toString().toLowerCase() == 'sex')
                const Text('Required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (field['options'] as List)
                    .mapIndexed((optionIndex, option) {
                  return ChoiceChip(
                    label: Text(option.toString()),
                    selected: field['value'] == option,
                    onSelected: (selected) {
                      if (selected) {
                        onSingleOptionSelect(option, sectionIndex, fieldIndex);
                        isFormValid();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case 'moption':
        field['value'] = field['value'] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field['name'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (field['options'] as List)
                    .mapIndexed((optionIndex, option) {
                  return FilterChip(
                    label: Text(option.toString()),
                    selected: (field['value'] as List).contains(option),
                    onSelected: (selected) {
                      onMultipleOptionSelect(option, selected, sectionIndex,
                          fieldIndex, optionIndex);
                      isFormValid();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  bool isFormValid() {
    if (_currentStep == 0) {
      return _codeSent
          ? _otpController.text.length == 6
          : _phoneController.text.length >= 10;
    } else if (_currentStep == 1) {
      String? patientId;
      bool hasComplaint = false;
      bool isValid = true;

      for (var section in fields) {
        if (section['title']
            .toString()
            .toLowerCase()
            .contains('consultation')) {
          for (var field in section['inputs']) {
            if (field['name'].toString().toLowerCase().contains('patient id')) {
              patientId = field['value']?.toString();
              break;
            }
            if (field['name']
                .toString()
                .toLowerCase()
                .contains('contact(phone')) {
              isValid = false;
              break;
            }
            if (field['name'].toString().toLowerCase().contains('sex')) {
              final hasValue = field['value'] != null;
              if (!hasValue) {
                isValid = false;
                break;
              }
            }
          }
        }

        if (section['title'].toString().toLowerCase() == 'complaints') {
          for (var field in section['inputs']) {
            var value = field['value'];
            if (value != null) {
              if (value is String && value.isNotEmpty) {
                hasComplaint = true;
                break;
              } else if (value is List && value.isNotEmpty) {
                hasComplaint = true;
                break;
              }
            }
          }
        }
      }

      return patientId != null &&
          patientId.isNotEmpty &&
          hasComplaint &&
          isValid;
    } else if (_currentStep == 2) {
      return notesText.isNotEmpty;
    }
    return true; // Last step (sharing) is always valid
  }

  Widget _buildSharePage() {
    return SafeArea(
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _handleShareWithDoctor,
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: darkBlue),
                            SizedBox(width: 16),
                            Text(
                              'Share with Doctor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: generateShareLink,
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: darkBlue),
                            SizedBox(width: 16),
                            Text(
                              'Share as Link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(notesText),
                          if (selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Attached Files',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Add files list here
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (_currentStep == 0) {
      if (!_codeSent) return 'Send Code';
      return 'Verify';
    }
    switch (_currentStep) {
      case 1:
        return 'Continue';
      case 2:
        return 'Share';
      case 3:
        return 'Done';
      default:
        return '';
    }
  }

  void _handleButtonPress() async {
    if (_currentStep == 0) {
      if (!_codeSent) {
        await _sendVerificationCode();
      } else {
        final success = await _verifyCode();
        if (success) {
          setState(() => _currentStep++);
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      return;
    }

    if (_currentStep == 1) {
      if (isFormValid()) {
        // Show confirmation dialog before proceeding
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Proceed'),
            content: const Text(
              'Please note that this form cannot be edited after proceeding. Are you sure you want to continue?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Cancel button pressed'); // Debugging log
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  print('Proceed button pressed'); // Debugging log
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Proceed',
                  style: TextStyle(color: darkBlue, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        if (proceed == true) {
          print('User confirmed to proceed'); // Debugging log
          final success = await generateReport();
          if (success) {
            print('Report generated successfully'); // Debugging log
            setState(() => _currentStep++);
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            setState(() {
        loading = false;
      });
            debugPrint('Failed to generate report'); // Debugging log
          }
        }
      } else {
        showCustomErrorToast(
            'Please fill in Patient ID and at least one Complaint field');
      }
    } else if (_currentStep == 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 3) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleShareWithDoctor() async {
    if (reportId == null) {
      setState(() => loading = true);
      final success = await generateReport();
      setState(() => loading = false);

      if (!success) {
        showCustomErrorToast('Failed to generate report');
        return;
      }
    }
    final result  = await _firebaseServices.sendReportToDoctor(
        reportId: reportId!,
        doctorId: "tU0x5NG6U4bB8RZNl9g7CmezxqT2",
      );

   /*  final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDoctorScreen(
          reportId: reportId!,
        ),
      ),
    ); */

    if (result == true) {
      showCustomToast('Report shared successfully');
    }
  }

  Future<void> _selectDate(
      BuildContext context, int sectionIndex, int fieldIndex) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: lightGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDetailsUpdate(picked.toIso8601String(), sectionIndex, fieldIndex);
    }
  }

  Widget _buildTextField(field, int sectionIndex, int fieldIndex) {
    final bool isDateField =
        field['name'].toString().toLowerCase().contains('date');
    final bool isRequired = field['name']
            .toString()
            .toLowerCase()
            .contains('patient id') ||
        (field['name'].toString().contains('chief complaint') &&
                field['type'] == 'text' ||
            field['name'].toString().toLowerCase().contains('contact(phone') ||
            field['name'].toString().toLowerCase().contains('date of birth'));

    if (isDateField) {
      return InkWell(
        onTap: () => _selectDate(context, sectionIndex, fieldIndex),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: field['name'],
            suffix: isRequired
                ? const Text('*',
                    style: TextStyle(color: Colors.red, fontSize: 18))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            field['value'] != null && field['value'].toString().isNotEmpty
                ? DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(field['value']))
                : 'Select date',
            style: TextStyle(
              color:
                  field['value'] != null && field['value'].toString().isNotEmpty
                      ? Colors.black
                      : Colors.grey,
            ),
          ),
        ),
      );
    }

    final controller =
        TextEditingController(text: field['value']?.toString() ?? '');
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field['name'],
        suffix: isRequired
            ? const Text('*', style: TextStyle(color: Colors.red, fontSize: 18))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: isRequired ? 'Required' : null,
        helperStyle: const TextStyle(color: Colors.red),
      ),
      onChanged: (value) {
        onDetailsUpdate(value, sectionIndex, fieldIndex);
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );

        print(isFormValid());
      },
    );
  }

  Widget _buildConsentForm() {
    return SafeArea(
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Consent',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please enter the patient\'s phone number to obtain their consent.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'e.g 08034567890',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add checkbox for manual consent
                    CheckboxListTile(
                      value: _hasObtainedConsent,
                      onChanged: (value) {
                        setState(() {
                          _hasObtainedConsent = value ?? false;
                          if (_hasObtainedConsent) {
                            _codeSent = false;
                            // Move to next page when consent is obtained
                            _currentStep++;
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      },
                      title: const Text('I have already obtained consent'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 24),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        onChanged: (value) => setState(() {}),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          activeColor: lightGreen,
                          selectedColor: lightGreen,
                          inactiveColor: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Future<void> _sendVerificationCode() async {
    setState(() => _isVerifying = true);
    try {
      // Make your API call here to send verification code
      await _firebaseServices.sendVerificationCode(_phoneController.text);
      setState(() => _codeSent = true);
      showCustomToast('Verification code sent');
    } catch (e) {
      showCustomErrorToast('Failed to send verification code');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<bool> _verifyCode() async {
    setState(() => _isVerifying = true);
    try {
      // Make your API call here to verify the code
      final success = await _firebaseServices.verifyCode(
        _phoneController.text,
        _otpController.text,
      );
      if (success) {
        return true;
      }
      showCustomErrorToast('Invalid verification code');
      return false;
    } catch (e) {
      showCustomErrorToast('Failed to verify code');
      return false;
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  _handleSaveAndExit() async {
    Navigator.pop(context, true);
  }
}
