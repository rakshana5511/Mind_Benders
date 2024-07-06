import 'package:coral_reef/Authentication/Login.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _LoginState();
}

class _LoginState extends State<Register> {
  final username = TextEditingController();
  final email = TextEditingController();
  final contactNo = TextEditingController();
  String? selectedUserType;
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final formKey = GlobalKey<FormState>();

  signup() async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false
    );

    await conn.connect();

    var res = await conn.execute(
      "INSERT INTO users (id, user_name, email, contact_no, user_type, password) VALUES (:id, :user_name, :email, :contact_no, :user_type, :password)",
      {
        "id": null,
        "user_name": username.text,
        "email": email.text,
        "contact_no": contactNo.text,
        "user_type": selectedUserType ?? 'General Public',
        "password": password.text,
      },
    );

    print(res.affectedRows);
  }

  bool isVisible = false;

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
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ListTile(
                        title: Text(
                          "Register",
                          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: TextFormField(
                          controller: username,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "username is required";
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
                        margin: EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "email is required";
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
                      Container(
                        margin: EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: TextFormField(
                          controller: contactNo,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "contact no is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.phone),
                            border: InputBorder.none,
                            hintText: "Enter your contact no",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.8)
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedUserType,
                          hint: Text("User"),
                          items: ['General Public', 'Researcher']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedUserType = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please select a user type";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.work),
                            border: InputBorder.none,
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
                              return "password is required";
                            } else if (password.text != confirmPassword.text) {
                              return "Passwords don't match";
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
                              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off)
                            )
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
                          controller: confirmPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "password is required";
                            } else if (password.text != confirmPassword.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "Confirm Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off)
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.deepPurple
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              signup().whenComplete(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Registered Successfully")),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login())
                                );
                              });
                            }
                          },
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(color: Colors.white),
                          )
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Login())
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black),
                            ),
                          )
                        ],
                      )
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







// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';

// class Register extends StatefulWidget {
//   const Register({super.key});

//   @override
//   State<Register> createState() => _LoginState();
// }

// class _LoginState extends State<Register> {
    
//   final username = TextEditingController();
//   final email = TextEditingController();
//   final contactNo = TextEditingController();
//   final placeOfWork = TextEditingController();
//   final password = TextEditingController();
//   final confirmPassword = TextEditingController();

//   final formKey = GlobalKey<FormState>();
//   signup() async {
//     // var response = await db
//     //     .login(Users(username: username.text, password: password.text));
//     // if (response == true) {
//     //   //If login is correct
//     //   if (!mounted) return;
//       // Navigator.pushReplacement(
//       //     context, MaterialPageRoute(builder: (context) => const OptionalPanel()));
//     // } else {
//     //   //If not, true the bool value to show error message
//     //   setState(() {
//     //     isLoginTrue = true;
//     //   });
//     // }

//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       // host: "127.0.0.1",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db", // optional
//       secure: false
//     );

//     // actually connect to database
//     await conn.connect();

//     var res = await conn.execute(
//     "INSERT INTO users (id, user_name, email, contact_no, place_of_work, password) VALUES (:id, :user_name, :email, :contact_no, :place_of_work, :password)",
//     {
//       "id": null,
//       "user_name":username.text,
//       "email": email.text,
//       "contact_no": contactNo.text,
//       "place_of_work":placeOfWork.text,
//       "password": password.text,
//     },
//   );

//  print(res.affectedRows);
//   }

//   bool isVisible = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //SingleChildScrollView to have an scrol in the screen
//       body: Stack(
//         children: [
//           Positioned.fill(
//               child: Image.asset(
//                 'lib/assets/coral-bg.jpg', // Path to your image
//                 fit: BoxFit.cover, // Adjusts the image to cover the entire area
//               ),
//             ),
//           Center(
//             child: SingleChildScrollView(
//               child: Form(
//                 key: formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       //We will copy the previous textfield we designed to avoid time consuming
          
//                       const ListTile(
//                         title: Text(
//                           "Register",
//                           style:
//                               TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
//                         ),
//                       ),
          
//                       //As we assigned our controller to the textformfields
          
//                       Container(
//                         margin: EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: username,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "username is required";
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
          
//                       //Password field
//                       Container(
//                         margin: EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: email,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "email is required";
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             icon: Icon(Icons.email),
//                             border: InputBorder.none,
//                             hintText: "Enter your email",
//                           ),
//                         ),
//                       ),
          
//                       //Confirm Password field
//                       // Now we check whether password matches or not
//                       Container(
//                         margin: EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: contactNo,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "contact no is required";
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             icon: Icon(Icons.phone),
//                             border: InputBorder.none,
//                             hintText: "Enter your contact no",
//                           ),
//                         ),
//                       ),
          
//                       //Confirm Password field
//                       // Now we check whether password matches or not
//                       Container(
//                         margin: EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: placeOfWork,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "work place is required";
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             icon: Icon(Icons.work),
//                             border: InputBorder.none,
//                             hintText: "Enter your place of work",
//                           ),
//                         ),
//                       ),
          
//                       //Confirm Password field
//                       // Now we check whether password matches or not
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: password,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "password is required";
//                             } else if (password.text != confirmPassword.text) {
//                               return "Passwords don't match";
//                             }
//                             return null;
//                           },
//                           obscureText: !isVisible,
//                           decoration: InputDecoration(
//                               icon: const Icon(Icons.lock),
//                               border: InputBorder.none,
//                               hintText: "Password",
//                               suffixIcon: IconButton(
//                                   onPressed: () {
//                                     //In here we will create a click to show and hide the password a toggle button
//                                     setState(() {
//                                       //toggle button
//                                       isVisible = !isVisible;
//                                     });
//                                   },
//                                   icon: Icon(isVisible
//                                       ? Icons.visibility
//                                       : Icons.visibility_off))),
//                         ),
//                       ),
          
//                       //Confirm Password field
//                       // Now we check whether password matches or not
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         padding:
//                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.white.withOpacity(.8)),
//                         child: TextFormField(
//                           controller: confirmPassword,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "password is required";
//                             } else if (password.text != confirmPassword.text) {
//                               return "Passwords don't match";
//                             }
//                             return null;
//                           },
//                           obscureText: !isVisible,
//                           decoration: InputDecoration(
//                               icon: const Icon(Icons.lock),
//                               border: InputBorder.none,
//                               hintText: "Confirm Password",
//                               suffixIcon: IconButton(
//                                   onPressed: () {
//                                     //In here we will create a click to show and hide the password a toggle button
//                                     setState(() {
//                                       //toggle button
//                                       isVisible = !isVisible;
//                                     });
//                                   },
//                                   icon: Icon(isVisible
//                                       ? Icons.visibility
//                                       : Icons.visibility_off))),
//                         ),
//                       ),
          
//                       const SizedBox(height: 10),
//                       //Login button
//                       Container(
//                         height: 55,
//                         width: MediaQuery.of(context).size.width * .9,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.deepPurple),
//                         child: TextButton(
//                             onPressed: () {
//                         if (formKey.currentState!.validate()) {
//                             //Login method will be here


//                                 signup()
//                                 .whenComplete(() {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                    const SnackBar(
//                                       content: Text("Registered Successful")),
//                                  );
//                               //After success user creation go to login screen
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const Login()));
//                             });
//                           }
//                             } ,
//                             child: const Text(
//                               "REGISTER",
//                               style: TextStyle(color: Colors.white),
//                             )),
//                       ),
          
//                       //Sign up button
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Already have an account?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),),
//                           TextButton(
//                               onPressed: () {
//                                 //Navigate to sign up
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => const Login()));
//                               },
//                               child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black),),
//                               )
//                         ],
//                       )
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