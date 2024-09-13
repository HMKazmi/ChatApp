import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({required this.onPickImage, super.key});
  final Function(File imageArg) onPickImage;
  @override
  State<UserImagePicker> createState() => UserImagePickerState();
}

class UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _pickedImage = File(pickedFile.path);
    });
    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          label: Text(
            "Pick Image",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          icon: const Icon(Icons.camera_alt),
        )
      ],
    );
  }
}
