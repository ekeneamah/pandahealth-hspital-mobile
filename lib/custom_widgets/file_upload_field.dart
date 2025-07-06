import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class FileUploadField extends StatelessWidget {
  final String label;
  final Function(File) onPicked;

  const FileUploadField({
    super.key,
    required this.label,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: () async {
        final file = await pickFile();
        if (file != null) {
          onPicked(file);
        }
      },
      child: Text(label),
    );
  }
}
