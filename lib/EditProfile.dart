import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'Profile.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Auth _auth = Auth();
  final DatabaseReference _userReference = FirebaseDatabase.instance.reference().child('Users');
  User? user = Auth().currentUser;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController profilePictureUrlController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController carTypeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Fetch user data and populate the controllers
    _userReference.child(user?.uid ?? '').once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>;
        nameController.text = userData['name'] ?? '';
        ageController.text = userData['age']?.toString() ?? '';
        gradeController.text = userData['grade'] ?? '';
        emailController.text = userData['email'] ?? '';
        addressController.text = userData['address'] ?? '';
        profilePictureUrlController.text = userData['profilePictureUrl'] ?? '';
        phoneNumberController.text = userData['phoneNumber'] ?? '';
        majorController.text = userData['major'] ?? '';
        carTypeController.text = userData['carType'] ?? '';
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        backgroundColor: Color(0xFF495159),
        title: Text('Edit Profile', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF73C2BE),
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.done, color: Color(0xFF73C2BE)),
            onPressed: () {
              // Update user data in the database
              _updateUserData();
              // Navigate back to the ProfilePage
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.0),
            Text('Name', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Age', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: ageController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            Text('Grade', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: gradeController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Email', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              enabled: false, // user can't edit email as he uses it to sign in
            ),
            SizedBox(height: 8.0),
            Text('Address', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: addressController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Profile Picture URL', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: profilePictureUrlController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Phone Number', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: phoneNumberController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Major', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: majorController,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.0),
            Text('Car Type', style: TextStyle(fontSize: 14, color: Colors.white)),
            TextFormField(
              controller: carTypeController,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    )
    );
  }

  // Function to update user data in the database
  Future<void> _updateUserData() async {
    await _userReference.child(user?.uid ?? '').update({
      'name': nameController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'grade': gradeController.text,
      'email': emailController.text,
      'address': addressController.text,
      'profilePictureUrl': profilePictureUrlController.text,
      'phoneNumber': phoneNumberController.text,
      'major': majorController.text,
      'carType': carTypeController.text,
    });
  }
}
