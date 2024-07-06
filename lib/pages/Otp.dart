import 'dart:convert'; // Importing the dart:convert library

import 'package:coral_reef/Authentication/Login.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late int generatedOtp;

  int OTP = 0;
  String email = '';
  late MySQLConnection conn;
  
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
  var user;
  void _getOtp() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // OTP =
    setState(() {
      OTP = localStorage.getInt('otp')!;
      email = localStorage.getString('email')!;
    });
    String? userJson = localStorage.getString('user');
    if (userJson != null) {
      setState(() {
        user = jsonDecode(userJson);
      });
    }
  }

  Future<int> updatePassword() async {
    // ignore: unused_local_variable
    var res = await conn.execute(
      "UPDATE users SET password = :password WHERE email = :email",
      {"password": newPasswordController.text, "email": email},
    );

    return 1;
  }

  @override
  void initState() {
    super.initState();
    _getOtp();
    connectToDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
                          controller: otpController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "OTP is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "Enter OTP",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(.8)),
                        child: TextFormField(
                          controller: newPasswordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "New password is required";
                            } else if (newPasswordController.text !=
                                confirmNewPasswordController.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "New Password",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(.8)),
                        child: TextFormField(
                          controller: confirmNewPasswordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Confirm new password is required";
                            } else if (newPasswordController.text !=
                                confirmNewPasswordController.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "Confirm New Password",
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
                              if (int.tryParse(otpController.text) == OTP) {
                                // SharedPreferences prefs =
                                //     await SharedPreferences.getInstance();

                                // prefs.getKeys().forEach((key) {
                                //   Map<String, dynamic> user = jsonDecode(prefs.getString(key)!);
                                //   if (user['email'] == widget.email) {
                                //     user['password'] = newPasswordController.text;
                                //     prefs.setString(key, jsonEncode(user));
                                //   }
                                // });
                                  updatePassword().whenComplete(() {
                                ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Password reset successful")),
      );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid OTP")),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "RESET PASSWORD",
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
