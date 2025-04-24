import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:track_bus/phone.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:track_bus/bus_operator/bus_shedule.dart';

class BusOperatorProfileScreen extends StatefulWidget {
  const BusOperatorProfileScreen({Key? key}) : super(key: key);

  @override
  State<BusOperatorProfileScreen> createState() =>
      _BusOperatorProfileScreenState();
}

class _BusOperatorProfileScreenState extends State<BusOperatorProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController routeController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController busnoController = TextEditingController();
  TextEditingController busNameController = TextEditingController();

  File? image;
  bool isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('bus_operator_profile_images')
          .child(fileName);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  Future<void> _saveUserProfile() async {
    final name = nameController.text.trim();
    final route = routeController.text.trim();
    final phone = phoneNoController.text.trim();
    final email = emailController.text.trim();
    final busNo = busnoController.text.trim();
    final busName = busNameController.text.trim();

    if (!_validatePhoneNumber(phone)) {
      showSnackBar('Invalid phone number');
      return;
    }

    if (!_validateEmail(email)) {
      showSnackBar('Invalid email address');
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImage(image!);
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('busOperatorProfiles')
            .doc(uid)
            .set({
          'name': name,
          'route': route,
          'phoneNumber': phone,
          'email': email,
          'busNo': busNo,
          'busName': busName,
          'profileImageURL': imageUrl,
        });

        // Clear
        nameController.clear();
        routeController.clear();
        phoneNoController.clear();
        emailController.clear();
        busnoController.clear();
        busNameController.clear();
        image = null;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusScheduleScreen()),
        );
      }
    } catch (e) {
      print('Save error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validatePhoneNumber(String value) =>
      RegExp(r'^[0-9]{10}$').hasMatch(value);

  bool _validateEmail(String value) =>
      RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    routeController.dispose();
    phoneNoController.dispose();
    emailController.dispose();
    busnoController.dispose();
    busNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Bus Operator Profile',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Camera'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: image != null ? FileImage(image!) : null,
                  child: image == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person),
              _buildTextField(
                  controller: busNameController,
                  label: 'Bus Name',
                  icon: Icons.directions_bus),
              _buildTextField(
                  controller: routeController,
                  label: 'Bus Route',
                  icon: Icons.route),
              _buildTextField(
                  controller: busnoController,
                  label: 'Bus No',
                  icon: Icons.confirmation_number),
              _buildTextField(
                  controller: phoneNoController,
                  label: 'Phone No',
                  icon: Icons.phone,
                  isNumber: true),
              _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  isEmail: true),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ButtonWidget(
                  title: isLoading ? 'Saving...' : 'Submit',
                  onPress: isLoading ? null : _saveUserProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
