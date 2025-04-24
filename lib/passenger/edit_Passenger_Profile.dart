import 'package:track_bus/model/passenger.dart';
import 'package:track_bus/passenger/view_Passenger_Profile.dart';
import 'package:flutter/material.dart';
import 'package:track_bus/services/getuserauth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:track_bus/passenger/view_Passenger_Profile.dart';

class PassengerProfileEditScreen extends StatefulWidget {
  const PassengerProfileEditScreen({Key? key}) : super(key: key);

  @override
  _PassengerProfileEditScreenState createState() =>
      _PassengerProfileEditScreenState();
}

class _PassengerProfileEditScreenState
    extends State<PassengerProfileEditScreen> {
  late Future<UserDetailsP> futureData;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  UserDetailsP? data;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    futureData = AuthService().getUserProfile();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (data == null) return;

    String? uploadedImageUrl = data!.profileImageURL;

    // Upload image if selected
    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'user_profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = await storageRef.putFile(_selectedImage!);
        uploadedImageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed")),
        );
        return;
      }
    }

    // Update the profile with the new image URL (if any)
    await AuthService().updatePassengerProfile(
      UserDetailsP(
        profileImageURL: uploadedImageUrl,
        name: _nameController.text,
        homeAddress: _addressController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
      ),
    );

    // Navigate to view profile screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProfileTypeScreenP(),
      ),
    );
  }

  void _navigateToProfileScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProfileTypeScreenP(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<UserDetailsP>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Text('No data available');
          } else {
            data = snapshot.data;
            _nameController.text = data!.name!;
            _addressController.text = data!.homeAddress!;
            _phoneController.text = data!.phoneNumber!;
            _emailController.text = data!.email!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _selectedImage == null
                          ? NetworkImage(data!.profileImageURL ?? '')
                          : FileImage(_selectedImage!) as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
