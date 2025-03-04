import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/Login.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = "Electronics"; // Default category
  final List<String> _categories = ["Electronics", "Clothing", "Furniture", "Books", "Toys","Mobile"];
  String? base64Image;
  bool _isUploading = false;  // For loading indicator
  bool _isSuccess = false;    // For success animation
  void initState() {
    super.initState();
    _initializePreferences();
  }
  void _initializePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

  }
  // Pick Image from Gallery or Camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        base64Image = base64String;
      });
    }
  }

  // Upload Data to Firebase Realtime Database
  Future<void> _uploadData() async {
    if (_nameController.text.isEmpty ||
        _descController.text.isEmpty ||
        _priceController.text.isEmpty ||

        base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields & select an image")),
      );
      return;
    }

    setState(() {
      _isUploading = true; // Show loading animation
    });

    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("products");
    String productId = dbRef.push().key!;

    await dbRef.child(productId).set({
      "name": _nameController.text,
      "description": _descController.text,
      "price": _priceController.text,
      "image": base64Image,
      "catagory": _selectedCategory,
    });

    setState(() {
      _isUploading = false; // Hide loading animation
      _isSuccess = true;    // Show success animation
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isSuccess = false;
      });
    });

    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    setState(() {
      base64Image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Product Added Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [Padding(padding:EdgeInsets.only(right: 20),child: IconButton(
        onPressed: () async {
          bool shouldLogout = await Get.defaultDialog(
            title: "Confirm Logout",
            middleText: "Are you sure you want to logout?",
            actions: [ElevatedButton(onPressed: (){Get.back(result: true);}, child: Text("Confirm",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),),ElevatedButton(onPressed: (){Get.back(result: true);}, child: Text("Cancel",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: Colors.green),)],


          );

          if (shouldLogout == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            await prefs.setBool('isLandingPageFirstTime', true);

            Get.offAll(() => const LoginScreen());  // Clears previous routes and navigates to login
          }
        }
      , icon: Icon(Icons.logout,color: Colors.white,)))],automaticallyImplyLeading: false,
        title: Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: "Product Name"),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _descController,
                          maxLines: 4,  // Makes it a rectangle textbox
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(  // Gives a rectangle shape
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Price",
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12.0), // Adjust padding for better alignment
                              child: Text(
                                "₹",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ), SizedBox(height: 10),InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Category Selection",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("Product Image",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        base64Image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(base64Decode(base64Image!),
                              height: 150, width: 150, fit: BoxFit.cover),
                        )
                            : Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: Icon(Icons.image,color: Colors.white,),
                              label: Text("Gallery",style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: Icon(Icons.camera,color: Colors.white,),
                              label: Text("Camera",style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadData,
                  child: Text("Upload Product",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Show the loading indicator when uploading
          if (_isUploading)
            Center(
              child: CircularProgressIndicator()
            ),

          // Show success animation when upload is complete
          if (_isSuccess)
            Center(
              child: Container(
                child: Lottie.asset(
                  'assets/animation/success_tick_mark.json',
                  width: 100,
                  height: 100,
                  repeat: false,
                ),color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
