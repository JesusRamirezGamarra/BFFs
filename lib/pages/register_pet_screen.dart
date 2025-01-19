import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPetScreen extends StatefulWidget {
  @override
  _RegisterPetScreenState createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  bool _isLoading = false;

  /// Selecciona una imagen de la galería
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al seleccionar la imagen: $e")),
      );
    }
  }

  /// Sube la imagen a Firebase Storage
  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('pets/$userId/$fileName');
      final uploadTask = await storageRef.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al subir la imagen: $e")),
      );
      return null;
    }
  }

  /// Guarda los datos de la mascota en Firestore
  Future<void> _savePetData(String userId, String imageUrl) async {
    try {
      final int edadYYYY = int.tryParse(_yearsController.text.trim()) ?? 0;
      final int edadMM = int.tryParse(_monthsController.text.trim()) ?? 0;

      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        await userRef.set({'initialized': true});
      }

      await userRef.collection('pets').add({
        'name': _nameController.text.trim(),
        'edad_YYYY': edadYYYY,
        'edad_MM': edadMM,
        'species': _speciesController.text.trim(),
        // 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota registrada exitosamente")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar los datos: $e")),
      );
    }
  }

  /// Registra la mascota
  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona una imagen")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Usuario no autenticado.");
      }

      // final imageUrl = await _uploadImage(_selectedImage!, userId);
      // if (imageUrl != null) {
       // await _savePetData(userId, imageUrl);
      // }

       await _savePetData(userId, '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Mascota")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa el nombre";
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Años"),
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return "Por favor ingresa un número válido";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _monthsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Meses"),
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null || int.parse(value) < 0 || int.parse(value) > 11) {
                            return "Por favor ingresa un valor entre 0 y 11";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(labelText: "Especie"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa la especie";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _registerPet,
                        child: const Text("Registrar Mascota"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
