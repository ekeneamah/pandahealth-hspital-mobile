import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';

class ImageUploadPreview extends StatelessWidget {
  final File? imageFile;
  final String label;
  final VoidCallback onPickImage;
  final bool isRequired;

  const ImageUploadPreview({
    super.key,
    required this.imageFile,
    required this.label,
    required this.onPickImage,
    this.isRequired = true,
  });

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
          if (imageFile != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    imageFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onPickImage,
                      color: lightGreen,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            CustomButton(
              onPressed: onPickImage,
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
