import 'package:coral_reef/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = localStorage.getString('user');

    print(user);
    if (user != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = const Home();
    } else {
      child = Home();
    }
    return Scaffold(
      body: child,
    );
  }
}









// import 'package:coral_reef/pages/Home.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Home(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(
//     //   appBar: AppBar(
//     //     title: Text(widget.title),
//     //   ),
//     //   body: const Center(
//     //     child: Text(
//     //       'Hello, Flutter!',
//     //       style: TextStyle(fontSize: 24),
//     //     ),
//     //   ),
//     // );
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Home(),
//     );
//   }
// }

// class CheckAuth extends StatefulWidget {
//   const CheckAuth({super.key});
//   @override
//   // ignore: library_private_types_in_public_api
//   _CheckAuthState createState() => _CheckAuthState();
// }

// class _CheckAuthState extends State<CheckAuth> {
//   bool isAuth = false;
//   @override
//   void initState() {
//     _checkIfLoggedIn();
//     super.initState();
//   }

//   void _checkIfLoggedIn() async{
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var user = localStorage.getString('user');

//     print(user);
//     if(user != null){
//       setState(() {
//         isAuth = true;
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     if (isAuth) {
//       child = const Home();
//     } else {
//       child = Home();
//     }
//     return Scaffold(
//       body: child,
// );
// }
// }