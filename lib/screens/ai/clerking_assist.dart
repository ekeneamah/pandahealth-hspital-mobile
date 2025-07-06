import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:collection/collection.dart';

// NOTE: If you see an error about 'package:image_picker/image_picker.dart', run 'flutter pub add image_picker' in your project root.

class ClerkingTemplate extends StatefulWidget {
  const ClerkingTemplate({super.key});

  @override
  _ClerkingTemplateState createState() => _ClerkingTemplateState();
}

class _ClerkingTemplateState extends State<ClerkingTemplate> {
  List<dynamic> fields = [];
  String notesText = "";
  bool loading = false;
  File? _selectedImage;
  String imageAnalysisResult = "";
  final ImagePicker _picker = ImagePicker();

  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
    _firebaseServices.getClerkingTemplateSettings().then((val) {
      if (val != null) {
        setState(() {
          fields = val;
        });
      }
    });
  }

  void onSingleOptionSelect(dynamic e, int sectionIndex, int fieldIndex) {
    if (fieldIndex >= 0 && sectionIndex >= 0) {
      // Added null check here
      setState(() {
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            print("Section");
            print(section);
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                print("Field");
                print(field);

                field['value'] = e;
              }

              return field;
            }).toList();
          }
          print("Modified section");
          print(section);
          return section;
        }).toList();
      });
    } else {
      print('Invalid section index or field index');
      print('$e, $sectionIndex $fieldIndex');
    }
  }

  void onMultipleOptionSelect(
      dynamic e, bool add, int sectionIndex, int fieldIndex, int itemIndex) {
    print(sectionIndex);
    print(fieldIndex);
    print(itemIndex);

    if (fieldIndex >= 0 && itemIndex >= 0) {
      // Added null check here
      setState(() {
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            print("Section");
            print(section);
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                print("Field");
                print(field);
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
          print("Modified section");
          print(section);
          return section;
        }).toList();
      });
    } else {
      print('Invalid section index, field index, or field index is null');
      print("$e, $sectionIndex $fieldIndex");
    }
  }

  void onDetailsUpdate(dynamic e, int sectionIndex, int fieldIndex) {
    if (fieldIndex >= 0 && sectionIndex >= 0) {
      // Added null check here
      setState(() {
        fields = fields.mapIndexed((ind, section) {
          if (ind == sectionIndex) {
            print("Section");
            print(section);
            List sectionInput = section['inputs'];
            section['inputs'] = sectionInput.mapIndexed((fieldInd, field) {
              if (fieldInd == fieldIndex) {
                field['value'] = e;
              }

              return field;
            }).toList();
          }
          print("Modified section");
          print(section);
          return section;
        }).toList();
      });
    }
  }

  void generateReport() async {
    showCustomToast("Generating report...");
    setState(() {
      loading = true;
    });

    // Always call generateDiagnosisAssist, pass image if present
    final aiResult = await _firebaseServices.generateDiagnosisAssist(
      fields.toString(),
      selectedFiles: [], // Pass empty list if no files are selected
      imageFile: _selectedImage,
    );

    setState(() {
      loading = false;
    });
    if (aiResult != null) {
      setState(() {
        notesText = aiResult['result'] ?? "No summary generated";
      });
    } else {
      showCustomErrorToast("Couldn't generate ai report");
    }
  }

  void handleNoteChange(dynamic e) {
    setState(() {
      notesText = e;
    });
  }

  Future<void> pickImageAndAnalyze() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        imageAnalysisResult = "";
      });
     // await analyzeImage(_selectedImage!);
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        title: "Clerking Template",
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
            vertical: defaultVerticalPadding,
            horizontal: defaultHorizontalPadding),
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: fields.length,
                      itemBuilder: (context, sectionIndex) {
                        var section = fields[sectionIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (section['inputs'] as List<dynamic>)
                                  .mapIndexed<Widget>((fieldIndex, field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      field['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    if (field['type'] == 'text')
                                      TextField(
                                        onChanged: (value) {
                                          onDetailsUpdate(
                                              value, sectionIndex, fieldIndex);
                                        },
                                      ),
                                    if (field['type'] == 'moption')
                                      Wrap(
                                        spacing: 10.0,
                                        children:
                                            (field['options'] as List<dynamic>)
                                                .map<Widget>((option) {
                                          bool selected =
                                              (field['value'] as List)
                                                  .contains(option);
                                          return GestureDetector(
                                            onTap: () {
                                              print(field);
                                              onMultipleOptionSelect(
                                                  option,
                                                  !selected,
                                                  sectionIndex,
                                                  fieldIndex, // Added null check here
                                                  field['options']
                                                      .indexOf(option));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    if (field['type'] == 'soption')
                                      Column(
                                        children:
                                            (field['options'] as List<dynamic>)
                                                .map<Widget>((option) {
                                          bool selected = field['value'] ==
                                              option.toString();
                                          return GestureDetector(
                                            onTap: () {
                                              print(field);
                                              onSingleOptionSelect(
                                                  option,
                                                  sectionIndex,
                                                  fieldIndex); // Added null check here
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10.0),
                                                margin: const EdgeInsets.only(
                                                    right: 10.0),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  /* ElevatedButton.icon(
                    onPressed: pickImageAndAnalyze,
                    icon: const Icon(Icons.image_search),
                    label: const Text("Add Image with AI"),
                  ),
                  if (_selectedImage != null)
                    Column(
                      children: [
                        Image.file(_selectedImage!, height: 150),
                        if (imageAnalysisResult.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              imageAnalysisResult,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ), */
                  const SizedBox(height: 20.0),
                  AppPrimaryButton(
                    onPressed: () {
                      generateReport();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('AI Diagnosis Assist'),
                        const SizedBox(width: 10.0),
                        loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Icon(Icons.android),
                      ],
                    ),
                  ),
                 
                  
                     if (notesText.isNotEmpty)
                    TextField(
                      controller: TextEditingController(text: notesText),
                      onChanged: (value) {
                        handleNoteChange(value);
                      },
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
