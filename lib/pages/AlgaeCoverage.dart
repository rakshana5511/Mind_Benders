// AlgaeCoverageDetection.dart

import 'package:coral_reef/pages/Optional.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:async';
import 'dart:io';

class AlgaeCoverageDetection extends StatefulWidget {
  final String userId;
  final String uploadedImagePath;

  const AlgaeCoverageDetection({
    Key? key,
    required this.userId,
    required this.uploadedImagePath,
  }) : super(key: key);

  @override
  _AlgaeCoverageDetectionState createState() => _AlgaeCoverageDetectionState();
}

class _AlgaeCoverageDetectionState extends State<AlgaeCoverageDetection> {
  bool _isLoading = true;
  String _databaseImagePath = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _fetchDataFromDatabase();
  }

  Future<void> _fetchDataFromDatabase() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: "10.0.2.2",
        port: 3306,
        userName: "rakshana",
        password: "root",
        databaseName: "coral_db",
        secure: false,
      );

      await conn.connect();

      var result = await conn.execute("SELECT * FROM algae_detection_results WHERE id IN (1, 2, 3) ORDER BY RAND() LIMIT 1");
      
      await conn.close();

      if (result.rows.isNotEmpty) {
        setState(() {
          _databaseImagePath = result.rows.first.assoc()['image_path'] ?? '';
          _description = result.rows.first.assoc()['description'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algae Coverage Detection'),
        backgroundColor: Color.fromARGB(255, 36, 123, 163),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading ? _buildLoadingWidget() : _buildResultWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          'Algae Coverage Detection in Progress...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Uploaded Image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Image.file(
          File(widget.uploadedImagePath),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 20),
        Text(
          'Processed Image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Image.asset(
          _databaseImagePath,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 5, 87, 125),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OptionalPanel(userId: widget.userId)),
              );
            },
            child: const Text(
              "Back to Options",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}




// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'dart:async';

// class AlgaeCoverageDetection extends StatefulWidget {
//   final String userId;

//   const AlgaeCoverageDetection({Key? key, required this.userId}) : super(key: key);

//   @override
//   _AlgaeCoverageDetectionState createState() => _AlgaeCoverageDetectionState();
// }

// class _AlgaeCoverageDetectionState extends State<AlgaeCoverageDetection> {
//   bool _isLoading = true;
//   String _imagePath = '';
//   String _description = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFromDatabase();
//   }

//   Future<void> _fetchDataFromDatabase() async {
//     try {
//       // Connect to MySQL database
//       final conn = await MySQLConnection.createConnection(
//         host: "10.0.2.2",
//         port: 3306,
//         userName: "rakshana",
//         password: "root",
//         databaseName: "coral_db",
//         secure: false,
//       );

//       await conn.connect();

//       // Fetch a random result from the database
//       // var result = await conn.execute("SELECT * FROM algae_detection_results ORDER BY RAND() LIMIT 1");
//       var result = await conn.execute("SELECT * FROM algae_detection_results WHERE id IN (1, 2, 3) ORDER BY RAND() LIMIT 1");
      
//       await conn.close();

//       if (result.rows.isNotEmpty) {
//         setState(() {
//           _imagePath = result.rows.first.assoc()['image_path'] ?? '';
//           _description = result.rows.first.assoc()['description'] ?? '';
//         });
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//       // Handle the error appropriately
//     }

//     // Simulate processing time
//     await Future.delayed(const Duration(seconds: 3));

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Algae Coverage Detection'),
//         backgroundColor: Color.fromARGB(255, 36, 123, 163),
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
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: _isLoading ? _buildLoadingWidget() : _buildResultWidget(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: const [
//         CircularProgressIndicator(),
//         SizedBox(height: 20),
//         Text(
//           'Algae Coverage Detection in Progress...',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildResultWidget() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(
//           _imagePath,
//           width: 200,
//           height: 200,
//           fit: BoxFit.cover,
//         ),
//         const SizedBox(height: 20),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             _description,
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(height: 30),
//         Container(
//           height: 55,
//           width: MediaQuery.of(context).size.width * 0.9,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: const Color.fromARGB(255, 5, 87, 125),
//           ),
//           child: TextButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => OptionalPanel(userId: widget.userId)),
//               );
//             },
//             child: const Text(
//               "Back to Options",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }













// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';

// class AlgaeCoverageDetection extends StatelessWidget {
//   final String userId;

//   const AlgaeCoverageDetection({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Algae Coverage Detection'),
//         backgroundColor: Color.fromARGB(255, 36, 123, 163),
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
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 50),
//                     Container(
//                       height: 55,
//                       width: MediaQuery.of(context).size.width * .9,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: const Color.fromARGB(255, 5, 87, 125),
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (context) => OptionalPanel(userId: userId)),
//                           );
//                         },
//                         child: const Text(
//                           "Back to Options",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
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
















