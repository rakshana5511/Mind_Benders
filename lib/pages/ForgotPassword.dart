import 'dart:convert'; // Importing the dart:convert library
import 'dart:io';
import 'dart:math';

import 'package:coral_reef/pages/Otp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';  
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic>? user;
 

  int _randomNumber = 0;

  void _generateRandomNumber() {
    setState(() {
      _randomNumber = generateRandomSixDigitNumber();
    });
  }

  int generateRandomSixDigitNumber() {
    Random random = Random();
    int min = 100000;
    int max = 999999;
    return min + random.nextInt(max - min + 1);
  }

  // final String apiKey = 'bf29b5de04281285916e747fc84d656c';
  // final String apiSecret = '2bb1cc9ba197247fc62d010e6f6befab';

  Future<void> sendEmail() async {
     final url = Uri.parse('https://api.mailgun.net/v3/sandbox845020b3886849ec8f61edc48a041ab9.mailgun.org/messages');
     final username = 'api';
     final password = 'fb65dc3d09cf778cd6a1b8ad1e95f21e-51356527-80ee7cb7';
 
     final response = await http.post(
       url,
       headers: {
         HttpHeaders.authorizationHeader:
             'Basic ' + base64Encode(utf8.encode('$username:$password')),
       },
       body: {
         'from': 'Coral DB <coral@sandbox685f44c0f7624b54bd8ca7e9af69b6b8.mailgun.org>',
         'to': emailController.text,
         'subject': 'Password Reset',
         'text': 'Here\'s Your OTP ' + _randomNumber.toString(),
       },
     );
 
     if (response.statusCode == 200) {
       print('Email sent successfully!');
     } else {
       print('Failed to send email: ${json.decode(response.body)}');
}
}

  late MySQLConnection conn;

  @override
  void initState() {
    super.initState();
    connectToDatabase();
    _loadUser();
    _generateRandomNumber();
  }

  Future<void> connectToDatabase() async {
    conn = await MySQLConnection.createConnection(
        host: "10.0.2.2",
        // host: "127.0.0.1",
        port: 3306,
        userName: "rakshana",
        password: "root",
        databaseName: "coral_db", // optional
        secure: false);

    // actually connect to database
    await conn.connect();
  }

  void saveOTP() async {
    // var res = await conn.execute(
    //   "UPDATE users SET otp = :otp WHERE email = :email",
    //   {"otp": _randomNumber, "email": emailController.text},
    // );

    var res = await conn.execute(
      "SELECT * FROM users WHERE email = :email",
      {"email": emailController.text},
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('otp', _randomNumber);
    await prefs.setString('email', emailController.text);

     if (res.numOfRows > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("OTP sent")),
      );
      sendEmail();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(email: emailController.text),
        ),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Email not registered")),
      );
    }
  }

  Future<void> _loadUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? userJson = localStorage.getString('user');
    if (userJson != null) {
      setState(() {
        user = jsonDecode(userJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color.fromARGB(255, 36, 123, 163),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/coral-bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(.8)),
                        child: TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            border: InputBorder.none,
                            hintText: "Enter your email",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.deepPurple),
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              // sendEmail(
                              //     'afrijweb@gmail.com',
                              //     'afrij',
                              //     'jifratech@gmail.com',
                              //     'test',
                              //     'test',
                              //     'test',
                              //     'test');
                              // print(_randomNumber);
                              saveOTP();
                              print(emailController.text);

                              // SharedPreferences prefs =
                              //     await SharedPreferences.getInstance();
                              // bool emailExists = false;

                              // prefs.getKeys().forEach((key) {
                              //   Map<String, dynamic> user =
                              //       jsonDecode(prefs.getString(key)!);
                              //   if (user['email'] == emailController.text) {
                              //     emailExists = true;
                              //   }
                              // });

                              // if (emailExists) {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         OtpPage(email: emailController.text),
                              //   ),
                              // );
                              // } else {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(
                              //         content: Text("Email not registered")),
                              //   );
                              // }
                            }
                          },
                          child: const Text(
                            "SEND OTP",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
