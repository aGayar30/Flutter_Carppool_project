import 'package:flutter/material.dart';
import 'package:my_project/auth.dart';
import 'main.dart';




class SignupPage extends StatelessWidget {
  final Auth _auth = Auth();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF495159),
        appBar: AppBar(
          backgroundColor: Color(0xFF495159),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child:  Builder(
            builder: (BuildContext scaffoldContext) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80.0),
                Text(
                  'Signup',
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

                    // Define a regular expression for the desired format
                    RegExp regex = RegExp(r'^\d{2}p\d{4}@eng\.asu\.edu\.eg$');

                    // Use the regular expression to check the format
                    if (regex.hasMatch(email)){
                        if(password.length >= 6) {
                          try {
                            await _auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            showSucessDialog(context, 'Signedup Succesfully!');
                          } catch (e) {
                            // Display a SnackBar with the error message
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text('${e}'),
                                duration: Duration(
                                    seconds: 2), // Adjust the duration as needed
                              ),
                            );
                          }
                        }else {
                          showAlertDialog(context, 'Password must be at least 6 characters');
                        }
                    }else {
                      showAlertDialog(context, 'You have to singup with your ASU email \n (xxpxxxx@eng.asu.edu.eg)');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF73C2BE),
                  ),
                  child: Text('Signup'),
                ),
              ],
            ),
          ),
        )
    );
  }
  void showSucessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text('${message}',
            style: TextStyle(color: Color(0xFF495159)),),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));

                },
                child: Text('OK' , style: TextStyle(color: Colors.white,),)
            ),
          ],
        );
      },
    );
  }
  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Error', style: TextStyle(color: Colors.white)),
          content: Text('${message}',
            style: TextStyle(color: Color(0xFF495159)),),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK' , style: TextStyle(color: Colors.white,),)
            ),
          ],
        );
      },
    );
  }
}

