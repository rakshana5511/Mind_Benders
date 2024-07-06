import 'package:coral_reef/Authentication/Admin.dart';
import 'package:coral_reef/Authentication/Login.dart';
import 'package:coral_reef/Authentication/Register.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Coral Reef',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Explore the underwater world',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    children: [
                      _buildButton(context, 'Register', Register(), Icons.person_add, Colors.blue[300]!),
                      SizedBox(height: 20),
                      _buildButton(context, 'Login', Login(), Icons.login, Colors.blue[500]!),
                      SizedBox(height: 20),
                      _buildButton(context, 'Admin', Admin(), Icons.admin_panel_settings, Colors.blue[700]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget destination, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    SizedBox(width: 15),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









// import 'package:coral_reef/Authentication/Admin.dart';
// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:coral_reef/Authentication/Register.dart';
// import 'package:flutter/material.dart';

// class Home extends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'lib/assets/home.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     Text('Welcome', style: TextStyle(color: Colors.white ,fontSize: 50, fontWeight: FontWeight.bold),),
//                     const SizedBox(height: 50),
//                     Container(
//                       height: 55,
//                       width: MediaQuery.of(context).size.width * .9,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color.fromARGB(255, 79, 176, 221)),
//                       child: TextButton(
//                           onPressed: () {
//                              Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => const Register()));
//                           },
//                           child: const Text(
//                             "REGISTER",
//                             style: TextStyle(color: Colors.white),
//                           )),
//                     ),
//                     const SizedBox(height: 50),
//                     //Login button
//                     Container(
//                       height: 55,
//                       width: MediaQuery.of(context).size.width * .9,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color.fromARGB(255, 79, 176, 221)),
//                       child: TextButton(
//                           onPressed: () {
//                              Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => const Login()));
//                           },
//                           child: const Text(
//                             "LOGIN",
//                             style: TextStyle(color: Colors.white),
//                           )),
//                     ),
//                     const SizedBox(height: 50),
//                     //Admin button
//                     Container(
//                       height: 55,
//                       width: MediaQuery.of(context).size.width * .9,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color.fromARGB(255, 79, 176, 221)),
//                       child: TextButton(
//                           onPressed: () {
//                              Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => const Admin()));
//                           },
//                           child: const Text(
//                             "ADMIN",
//                             style: TextStyle(color: Colors.white),
//                           )),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
