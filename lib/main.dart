import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_project/Profile.dart';
import 'package:my_project/auth.dart';
import 'package:my_project/firebase_options.dart';
import 'RoleSelection.dart';
import 'signupPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Auth _auth = Auth();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child:  Builder(
          builder: (BuildContext scaffoldContext) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80.0),
            Text(
              'ASU Carpool',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF73C2BE),
              ),
            ),
            SizedBox(height: 80.0),
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF73C2BE), width: 3),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              style: TextStyle(color: Colors.white),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF73C2BE), width: 3),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                var connectivityResult = await Connectivity().checkConnectivity();
                if (connectivityResult == ConnectivityResult.none) {
                  showOfflineDialog(context);
                }
                if (email.isEmpty || password.isEmpty){
                  // Display a SnackBar with the error message
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text('email and password cannot be empty'),
                        duration: Duration(seconds: 2), // Adjust the duration as needed
                      ));
                }else {
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // Navigate to the next screen or perform any other action on successful login
                    // For example:
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) =>
                        RoleSelectionScreen()));
                  } catch (e) {
                    // Display a SnackBar with the error message
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text('Incorrect username or password'),
                        duration: Duration(
                            seconds: 2), // Adjust the duration as needed
                      ),
                    );
                  }
                }
                },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF495159)
              ),
              child: Text('Do not have an account? Signup here!', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
      )
    );
  }
  void showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text('You are offline\n\nYou can view you profile',
            style: TextStyle(color: Color(0xFF495159)),),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));

                },
                child: Text('OK' , style: TextStyle(color: Colors.white,),)
            ),
          ],
        );
      },
    );
  }

  }

