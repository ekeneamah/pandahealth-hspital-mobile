import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:path/path.dart' as path;

class FileUploadPreview extends StatelessWidget {
  final File? file;
  final String label;
  final VoidCallback onPickFile;
  final bool isRequired;
  final List<String> imageExtensions = ['jpg', 'jpeg', 'png'];

  FileUploadPreview({
    super.key,
    required this.file,
    required this.label,
    required this.onPickFile,
    this.isRequired = true,
  });

  bool get isImage {
    if (file == null) return false;
    final extension =
        path.extension(file!.path).toLowerCase().replaceAll('.', '');
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (file != null) ...[
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.file_present,
                              size: 48,
                              color: lightGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              path.basename(file!.path),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onPickFile,
                      color: lightGreen,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            CustomButton(
              onPressed: onPickFile,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload, size: 20),
                  const SizedBox(width: 8),
                  Text('Upload $label'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
