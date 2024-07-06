import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coral_reef/Authentication/Login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = '';
  final _formKey = GlobalKey<FormState>();
  late MySQLConnection _conn;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _initializeConnection().then((_) => _fetchProfileData());
  }

  @override
  void dispose() {
    _conn.close();
    super.dispose();
  }

  Future<void> _initializeConnection() async {
    _conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );
    await _conn.connect();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? userJson = localStorage.getString('user');
    if (userJson != null) {
      setState(() => _user = jsonDecode(userJson));
    }

    try {
      var result = await _conn.execute(
        "SELECT * FROM users WHERE id = :id",
        {"id": _user?['id']},
      );

      if (result.rows.isNotEmpty) {
        var row = result.rows.first;
        setState(() {
          _nameController.text = row.colByName('user_name') ?? '';
          _emailController.text = row.colByName('email') ?? '';
          _contactController.text = row.colByName('contact_no') ?? '';
          _userType = row.colByName('user_type') ?? '';
          _passwordController.text = row.colByName('password') ?? '';
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching profile data: $e');
    }
  }

  Future<void> _updateProfileData() async {
    try {
      await _conn.execute(
        "UPDATE users SET user_name = :user_name, contact_no = :contact_no, password = :password WHERE id = :id",
        {
          "user_name": _nameController.text,
          "contact_no": _contactController.text,
          "password": _passwordController.text,
          "id": _user?['id'],
        },
      );
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating profile data: $e');
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.remove('user');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/coral-bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 10),
        Text(
          _nameController.text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          _userType,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController, Icons.person),
              _buildTextField('Email', _emailController, Icons.email, enabled: false),
              _buildTextField('Contact Number', _contactController, Icons.phone),
              _buildUserTypeField(),
              _buildTextField('Password', _passwordController, Icons.lock, obscureText: true),
              const SizedBox(height: 20),
            //  _buildButton('Save', _updateProfileData, Colors.blue),
            _buildButton('Save', _updateProfileData, Color.fromARGB(255, 132, 103, 201)),
              const SizedBox(height: 10),
              _buildButton('Logout', () => _logout(context), Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool enabled = true, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildUserTypeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'User Type',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(_userType, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}












// import 'dart:convert';

// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Profile extends StatefulWidget {
//   const Profile({Key? key}) : super(key: key);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   String _userType = ''; // New variable to store user type
//   final TextEditingController _passwordController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   late MySQLConnection _conn;

//   Future<void> _initializeConnection() async {
//     _conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );
//     await _conn.connect();
//   }

//   var user;
//   Future<void> _fetchProfileData() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     String? userJson = localStorage.getString('user');
//     if (userJson != null) {
//       setState(() {
//         user = jsonDecode(userJson);
//       });
//     }
//     try {
//       var result = await _conn.execute(
//         "SELECT * FROM users WHERE id = :id",
//         {"id": user['id']},
//       );

//       if (result.rows.isNotEmpty) {
//         var row = result.rows.first;
//         setState(() {
//           _nameController.text = row.colByName('user_name') ?? '';
//           _emailController.text = row.colByName('email') ?? '';
//           _contactController.text = row.colByName('contact_no') ?? '';
//           _userType = row.colByName('user_type') ?? ''; // Fetch user type
//           _passwordController.text = row.colByName('password') ?? '';
//         });
//       }
//     } catch (e) {
//       print('Error fetching profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile data: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfileData() async {
//     try {
//       await _conn.execute(
//         "UPDATE users SET user_name = :user_name, contact_no = :contact_no, password = :password WHERE id = :id",
//         {
//           "user_name": _nameController.text,
//           "contact_no": _contactController.text,
//           "password": _passwordController.text,
//           "id": user['id'],
//         },
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//     } catch (e) {
//       print('Error updating profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile data: $e')),
//       );
//     }
//   }

//   void _logout(BuildContext context) async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     localStorage.remove('user');
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeConnection().then((_) {
//       _fetchProfileData();
//     });
//   }

//   @override
//   void dispose() {
//     _conn.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//       ),
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
//               child: Form(
//                 key: formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 50),
//                       Container(
//                         padding: const EdgeInsets.all(20.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Name:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _nameController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your name',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Name is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Email:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _emailController,
//                               enabled: false,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Your email',
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Contact Number:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _contactController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your contact number',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Contact number is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'User Type:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 _userType,
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Password:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _passwordController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your password',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Password is required";
//                                 }
//                                 return null;
//                               },
//                               obscureText: true,
//                             ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   if (formKey.currentState!.validate()) {
//                                     await _updateProfileData();
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(255, 5, 87, 125),
//                                 ),
//                                 child: const Text(
//                                   'Save',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   _logout(context);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                 ),
//                                 child: const Text(
//                                   'Logout',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
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







// import 'dart:convert'; // Importing the dart:convert library

// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Profile extends StatefulWidget {
//   const Profile({Key? key}) : super(key: key);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   // Controllers for the TextFormFields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _workplaceController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   // Connection to MySQL database
//   late MySQLConnection _conn;

//   // Method to initialize and connect to MySQL
//   Future<void> _initializeConnection() async {
//     _conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false, // SSL disabled
//     );
//     await _conn.connect();
//   }

//   // Method to fetch profile data from MySQL
//   var user;
//   Future<void> _fetchProfileData() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     String? userJson = localStorage.getString('user');
//     if (userJson != null) {
//       setState(() {
//         user = jsonDecode(userJson);
//       });
//     }
//     try {
//       var result = await _conn.execute(
//         "SELECT * FROM users WHERE id = :id",
//         {"id": user['id']}, // Replace with actual user ID or fetch dynamically
//       );

//       if (result.rows.isNotEmpty) {
//         var row = result.rows.first;
//         setState(() {
//           _nameController.text = row.colByName('user_name') ?? '';
//           _emailController.text = row.colByName('email') ?? '';
//           _contactController.text = row.colByName('contact_no') ?? '';
//           _workplaceController.text = row.colByName('place_of_work') ?? '';
//           _passwordController.text = row.colByName('password') ?? '';
//         });
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile data: $e')),
//       );
//     }
//   }

//   // Method to update profile data in MySQL
//   Future<void> _updateProfileData() async {
//     try {
//       await _conn.execute(
//         "UPDATE users SET user_name = :user_name, contact_no = :contact_no, place_of_work = :place_of_work, password = :password WHERE id = :id",
//         {
//           "user_name": _nameController.text,
//           "contact_no": _contactController.text,
//           "place_of_work": _workplaceController.text,
//           "password": _passwordController.text,
//           "id": user['id'], // Replace with actual user ID
//         },
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//     } catch (e) {
//       // Handle error
//       print('Error updating profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile data: $e')),
//       );
//     }
//   }

//   // Method to handle logout
//   void _logout(BuildContext context) async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     localStorage.remove('user');
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeConnection().then((_) {
//       _fetchProfileData();
//     });
//   }

//   @override
//   void dispose() {
//     _conn.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//       ),
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
//               child: Form(
//                 key: formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 50),
//                       Container(
//                         padding: const EdgeInsets.all(20.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Name:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _nameController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your name',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Name is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Email:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _emailController,
//                               enabled: false, // Make email field non-editable
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Your email',
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Contact Number:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _contactController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your contact number',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Contact number is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Place of Work:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _workplaceController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your place of work',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Place of work is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Password:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _passwordController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your password',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Password is required";
//                                 }
//                                 return null;
//                               },
//                               obscureText: true,
//                             ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   if (formKey.currentState!.validate()) {
//                                     await _updateProfileData();
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(255, 5, 87, 125),
//                                 ),
//                                 child: const Text(
//                                   'Save',
//                                   style: TextStyle(color: Colors.white), // Change text color
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   _logout(context);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                 ),
//                                 child: const Text(
//                                   'Logout',
//                                   style: TextStyle(color: Colors.white), // Change text color
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
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



// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert'; // Importing the dart:convert library

// class Profile extends StatefulWidget {
//   const Profile({Key? key}) : super(key: key);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   // Controllers for the TextFormFields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _workplaceController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   // Connection to MySQL database
//   late MySQLConnection _conn;

//   // Method to initialize and connect to MySQL
//   Future<void> _initializeConnection() async {
//     _conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false, // SSL disabled
//     );
//     await _conn.connect();
//   }

//   // Method to fetch profile data from MySQL
  
//   var user;
//   Future<void> _fetchProfileData() async {
//      SharedPreferences localStorage = await SharedPreferences.getInstance();
//      String? userJson = localStorage.getString('user');
//       if (userJson != null) {
//         setState(() {
//           user = jsonDecode(userJson);
//         });
//       }
//     try {
//       var result = await _conn.execute(
//         "SELECT * FROM users WHERE id = :id",
//         {"id": user['id']}, // Replace with actual user ID or fetch dynamically
//       );

//       if (result.rows.isNotEmpty) {
//         var row = result.rows.first;
//         setState(() {
//           _nameController.text = row.colByName('user_name') ?? '';
//           _emailController.text = row.colByName('email') ?? '';
//           _contactController.text = row.colByName('contact_no') ?? '';
//           _workplaceController.text = row.colByName('place_of_work') ?? '';
//           _passwordController.text = row.colByName('password') ?? '';
//         });
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile data: $e')),
//       );
//     }
//   }

//   // Method to update profile data in MySQL
//   Future<void> _updateProfileData() async {
//     try {
//       await _conn.execute(
//         "UPDATE users SET user_name = :user_name, contact_no = :contact_no, place_of_work = :place_of_work, password = :password WHERE id = :id",
//         {
//           "user_name": _nameController.text,
//           "contact_no": _contactController.text,
//           "place_of_work": _workplaceController.text,
//           "password": _passwordController.text,
//           "id": user['id'], // Replace with actual user ID
//         },
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//     } catch (e) {
//       // Handle error
//       print('Error updating profile data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile data: $e')),
//       );
//     }
//   }

//   // Method to handle logout
//   void _logout(BuildContext context) async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//        localStorage.remove('user');
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeConnection().then((_) {
//       _fetchProfileData();
//     });
//   }

//   @override
//   void dispose() {
//     _conn.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//       ),
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
//               child: Form(
//                 key: formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 50),
//                       Container(
//                         padding: const EdgeInsets.all(20.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Name:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _nameController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your name',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Name is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Email:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _emailController,
//                               enabled: false, // Make email field non-editable
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Your email',
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Contact Number:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _contactController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your contact number',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Contact number is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Place of Work:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _workplaceController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your place of work',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Place of work is required";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Password:',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 10),
//                             TextFormField(
//                               controller: _passwordController,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 hintText: 'Enter your password',
//                               ),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return "Password is required";
//                                 }
//                                 return null;
//                               },
//                               obscureText: true,
//                             ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   if (formKey.currentState!.validate()) {
//                                     await _updateProfileData();
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(255, 5, 87, 125),
//                                 ),
//                                 child: const Text('Save'),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   _logout(context);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                 ),
//                                 child: const Text('Logout'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
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
