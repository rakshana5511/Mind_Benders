import 'dart:convert';

import 'package:coral_reef/Authentication/Admin.dart';
import 'package:coral_reef/Authentication/Register.dart';
import 'package:coral_reef/pages/ForgotPassword.dart';
import 'package:coral_reef/pages/Optional.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isVisible = false;
  bool isLoginTrue = false;
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  late MySQLConnection conn;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    connectToDatabase();
  }

  Future<void> connectToDatabase() async {
    conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );

    await conn.connect();
  }

  void login() async {
    var result = await conn.execute(
      'SELECT * FROM users WHERE user_name = :username and password = :password',
      {"username": username.text, "password": password.text},
    );
    var resultList = result.rows;
    if (resultList.isNotEmpty) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var userData = resultList.first.assoc();
      localStorage.setString('user', jsonEncode(userData));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OptionalPanel(userId: userData['id'] as String)),
      );
    } else {
      setState(() {
        errorMessage = "Username or password is incorrect";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        "lib/assets/login.png",
                        width: 210,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: TextFormField(
                          controller: username,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Username is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            border: InputBorder.none,
                            hintText: "Username",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: TextFormField(
                          controller: password,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromARGB(255, 3, 39, 56)
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              errorMessage = '';
                            });
                            if (formKey.currentState!.validate()) {
                              login();
                            }
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forget Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10), // Add some spacing
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Admin(), // Replace with your Admin page
                            ),
                          );
                        },
                        child: const Text(
                          "Login as Admin",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
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









// import 'dart:convert';

// import 'package:coral_reef/Authentication/Register.dart';
// import 'package:coral_reef/pages/ForgotPassword.dart';
// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   bool isVisible = false;
//   bool isLoginTrue = false;
//   final formKey = GlobalKey<FormState>();
//   final username = TextEditingController();
//   final password = TextEditingController();
//   late MySQLConnection conn;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     connectToDatabase();
//   }

//   Future<void> connectToDatabase() async {
//     conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();
//   }

//   void login() async {
//     var result = await conn.execute(
//       'SELECT * FROM users WHERE user_name = :username and password = :password',
//       {"username": username.text, "password": password.text},
//     );
//     var resultList = result.rows;
//     if (resultList.isNotEmpty) {
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       var userData = resultList.first.assoc();
//       localStorage.setString('user', jsonEncode(userData));
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => OptionalPanel(userId: userData['id'] as String)),
//       );
//     } else {
//       setState(() {
//         errorMessage = "Username or password is incorrect";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'lib/assets/coral-bg.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         "lib/assets/login.png",
//                         width: 210,
//                       ),
//                       const SizedBox(height: 15),
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.white.withOpacity(.8)
//                         ),
//                         child: TextFormField(
//                           controller: username,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Username is required";
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             icon: Icon(Icons.person),
//                             border: InputBorder.none,
//                             hintText: "Username",
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.white.withOpacity(.8)
//                         ),
//                         child: TextFormField(
//                           controller: password,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Password is required";
//                             }
//                             return null;
//                           },
//                           obscureText: !isVisible,
//                           decoration: InputDecoration(
//                             icon: const Icon(Icons.lock),
//                             border: InputBorder.none,
//                             hintText: "Password",
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   isVisible = !isVisible;
//                                 });
//                               },
//                               icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         height: 55,
//                         width: MediaQuery.of(context).size.width * .9,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color.fromARGB(255, 3, 39, 56)
//                         ),
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               errorMessage = '';
//                             });
//                             if (formKey.currentState!.validate()) {
//                               login();
//                             }
//                           },
//                           child: const Text(
//                             "LOGIN",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ForgotPassword(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Forget Password?",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16.0,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Don't have an account?",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16.0,
//                               color: Colors.white,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const Register(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Register",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16.0,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (errorMessage.isNotEmpty)
//                         Text(
//                           errorMessage,
//                           style: TextStyle(color: Colors.red),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



