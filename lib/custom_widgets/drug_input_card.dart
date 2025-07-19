import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/drug_interaction_models.dart';

class DrugInputCard extends StatelessWidget {
  final List<Drug> drugs;
  final VoidCallback onAddDrug;
  final Function(String) onRemoveDrug;
  final Function(String, String) onUpdateDrugName;
  final Function(String, File?) onUpdateDrugImage;

  const DrugInputCard({
    super.key,
    required this.drugs,
    required this.onAddDrug,
    required this.onRemoveDrug,
    required this.onUpdateDrugName,
    required this.onUpdateDrugImage,
  });

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
                  Icons.medication_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Medications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add medications by typing the name or taking a photo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            ...drugs.asMap().entries.map((entry) {
              final index = entry.key;
              final drug = entry.value;
              return _DrugInputItem(
                key: ValueKey(drug.id),
                drug: drug,
                index: index,
                canRemove: drugs.length > 1,
                onRemove: () => onRemoveDrug(drug.id),
                onUpdateName: (name) => onUpdateDrugName(drug.id, name),
                onUpdateImage: (image) => onUpdateDrugImage(drug.id, image),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddDrug,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Drug'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugInputItem extends StatefulWidget {
  final Drug drug;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final Function(String) onUpdateName;
  final Function(File?) onUpdateImage;

  const _DrugInputItem({
    super.key,
    required this.drug,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onUpdateName,
    required this.onUpdateImage,
  });

  @override
  State<_DrugInputItem> createState() => _DrugInputItemState();
}

class _DrugInputItemState extends State<_DrugInputItem> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        widget.onUpdateImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Drug Image',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drug number and remove button
          Row(
            children: [
              Text(
                'Drug ${widget.index + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.canRemove)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove drug',
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Drug name input
          TextFormField(
            initialValue: widget.drug.name,
            decoration: InputDecoration(
              labelText: 'Drug name',
              hintText: 'Enter medication name',
              prefixIcon: Icon(
                Icons.local_pharmacy_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onChanged: widget.onUpdateName,
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 16),
          
          // Image section
          Row(
            children: [
              // Image preview or placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.drug.hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.drug.imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.medication,
                        size: 32,
                        color: Theme.of(context).colorScheme.outline,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Image actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.drug.hasImage) ...[
                      Text(
                        'Drug image added',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Change'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => widget.onUpdateImage(null),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Remove'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Add drug image (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Add Image'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}