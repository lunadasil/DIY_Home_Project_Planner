import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/project_repository.dart';
import '../services/storage.dart';

class PhotosCard extends StatelessWidget {
  final String projectId;
  final List<String> photoPaths;
  const PhotosCard({super.key, required this.projectId, required this.photoPaths});

  Future<void> _pickAndSave(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final saved = await StorageService.copyImageToAppDir(x.path);
    await context.read<ProjectStore>().addPhoto(projectId, saved.path);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                FilledButton.icon(
                  onPressed: () => _pickAndSave(context),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (photoPaths.isEmpty)
              Container(
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text('No photos yet.'),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(photoPaths[i]), fit: BoxFit.cover),
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
