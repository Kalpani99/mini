import 'dart:io';
import 'package:track_bus/phone.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  File? imageX; // Holds the selected image
  bool isLoading = false;

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        imageX = File(pickedImage.path);
      });
    }
  }

  // Upload image to Firebase Storage and return the download URL
  Future<String?> _uploadImage(File imageX) async {
    try {
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child(uniqueFileName);
      final uploadTask = storageRef.putFile(imageX);

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully. Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Save user profile to Firestore
  Future<void> _saveUserProfile() async {
    final name = nameController.text;
    final homeAddress = homeController.text;
    final phoneNumber = phoneNoController.text;
    final email = emailController.text;

    print("DEBUG: Submit pressed with values:");
    print(
        "Name: $name, Address: $homeAddress, Phone: $phoneNumber, Email: $email");
    print("Image selected: ${imageX != null}");

    if (!_validatePhoneNumber(phoneNumber)) {
      showSnackBar('Invalid phone number');
      return;
    }

    if (email.isEmpty) {
      showSnackBar('Email cannot be empty');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? downloadURL;
      if (imageX != null) {
        print("DEBUG: Uploading image...");
        downloadURL = await _uploadImage(imageX!);
        print("DEBUG: Image uploaded. URL: $downloadURL");
      }

      final FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      print("DEBUG: Current user ID: ${user?.uid}");

      if (user != null) {
        final userProfileData = {
          'name': name,
          'homeAddress': homeAddress,
          'phoneNumber': phoneNumber,
          'email': email,
          'profileImageURL': downloadURL ?? '',
        };

        print("DEBUG: Saving data to Firestore...");
        await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(user.uid)
            .set(userProfileData, SetOptions(merge: true));
        print("DEBUG: Profile saved successfully.");

        // Navigate to 2FA screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TwoFactorAuthScreen(),
          ),
        );
      } else {
        print("DEBUG: No user is logged in.");
        showSnackBar('User not authenticated');
      }
    } catch (e) {
      print('DEBUG: Error saving user profile: $e');
      showSnackBar('Failed to save profile');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _validatePhoneNumber(String value) {
    if (value.isEmpty) return false;
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(value);
  }

  // Show a SnackBar with a message
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Passenger Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Pick from Gallery'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take a Photo'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF808080),
                          ),
                          child: Center(
                            child: imageX != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      imageX!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: homeController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText: 'Enter your home address',
                        prefixIcon: Icon(
                          Icons.home_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: phoneNoController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Phone No',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(
                          Icons.phone_android_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText: 'Enter your home email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ButtonWidget(
                        title: "Submit",
                        onPress: () async {
                          final phoneNumber = phoneNoController.text;
                          final email = emailController.text;
                          if (_validatePhoneNumber(phoneNumber)) {
                            await _saveUserProfile();
                          } else {
                            showSnackBar('Invalid phone number');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
