import 'package:coral_reef/pages/Optional.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CoralClassification extends StatefulWidget {
  final String userId;

  const CoralClassification({Key? key, required this.userId}) : super(key: key);

  @override
  _CoralClassificationState createState() => _CoralClassificationState();
}

class _CoralClassificationState extends State<CoralClassification> {
  bool _isLoading = true;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.asset('lib/assets/CoralClassification1.mp4');
    await _videoController.initialize();
    setState(() {
      _isVideoInitialized = true;
      _isLoading = false;
    });
    _videoController.play();
    _videoController.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coral Classification'),
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
          'Coral Classification in Progress...',
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
        if (_isVideoInitialized)
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
              } else {
                _videoController.play();
              }
            });
          },
          child: Icon(
            _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        const SizedBox(height: 20),
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
// import 'package:flutter/services.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'dart:async';
// import 'package:video_player/video_player.dart';
// import 'dart:io';

// class CoralClassification extends StatefulWidget {
//   final String userId;

//   const CoralClassification({Key? key, required this.userId}) : super(key: key);

//   @override
//   _CoralClassificationState createState() => _CoralClassificationState();
// }

// class _CoralClassificationState extends State<CoralClassification> {
//   bool _isLoading = true;
//   String _videoPath = '';
//   VideoPlayerController? _videoController;
//   bool _isVideoInitialized = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFromDatabase();
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchDataFromDatabase() async {
//     try {
//       final conn = await MySQLConnection.createConnection(
//         host: "10.0.2.2",
//         port: 3306,
//         userName: "rakshana",
//         password: "root",
//         databaseName: "coral_db",
//         secure: false,
//       );

//       await conn.connect();

//       var result = await conn.execute("SELECT video_path FROM coral_classification_results ORDER BY RAND() LIMIT 1");
      
//       await conn.close();

//       if (result.rows.isNotEmpty) {
//         setState(() {
//           _videoPath = result.rows.first.assoc()['video_path'] ?? '';
//         });

//         print("Video path from database: $_videoPath");

//         if (_videoPath.isNotEmpty) {
//           await _initializeVideoPlayer();
//         } else {
//           _setErrorMessage("Empty video path retrieved from database");
//         }
//       } else {
//         _setErrorMessage("No rows returned from database query");
//       }
//     } catch (e) {
//       _setErrorMessage('Error fetching data: $e');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       if (_videoPath.startsWith('lib/assets/')) {
//         // Asset file
//         _videoController = VideoPlayerController.asset(_videoPath);
//       } else {
//         // File on device
//         final file = File(_videoPath);
//         if (await file.exists()) {
//           _videoController = VideoPlayerController.file(file);
//         } else {
//           throw Exception('Video file does not exist: $_videoPath');
//         }
//       }

//       await _videoController!.initialize();
//       await _videoController!.setLooping(true);
//       setState(() {
//         _isVideoInitialized = true;
//       });
//       _videoController!.play();
//     } catch (e) {
//       _setErrorMessage('Error initializing video player: $e');
//     }
//   }

//   void _setErrorMessage(String message) {
//     print(message);  // Print to console for debugging
//     setState(() {
//       _errorMessage = message;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Coral Classification'),
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
//           'Coral Classification in Progress...',
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
//         if (_isVideoInitialized && _videoController != null)
//           AspectRatio(
//             aspectRatio: _videoController!.value.aspectRatio,
//             child: VideoPlayer(_videoController!),
//           )
//         else
//           Text(_errorMessage, style: TextStyle(color: Colors.white)),
//         const SizedBox(height: 20),
//         if (_isVideoInitialized && _videoController != null)
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 if (_videoController!.value.isPlaying) {
//                   _videoController!.pause();
//                 } else {
//                   _videoController!.play();
//                 }
//               });
//             },
//             child: Icon(
//               _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//             ),
//           ),
//         const SizedBox(height: 20),
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
// import 'package:flutter/services.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'dart:async';
// import 'package:video_player/video_player.dart';
// import 'dart:io';


// class CoralClassification extends StatefulWidget {
//   final String userId;

//   const CoralClassification({Key? key, required this.userId}) : super(key: key);

//   @override
//   _CoralClassificationState createState() => _CoralClassificationState();
// }

// class _CoralClassificationState extends State<CoralClassification> {
//   bool _isLoading = true;
//   String _videoPath = '';
//   VideoPlayerController? _videoController;
//   bool _isVideoInitialized = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFromDatabase();
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchDataFromDatabase() async {
//     try {
//       final conn = await MySQLConnection.createConnection(
//         host: "10.0.2.2",
//         port: 3306,
//         userName: "rakshana",
//         password: "root",
//         databaseName: "coral_db",
//         secure: false,
//       );

//       await conn.connect();

//       var result = await conn.execute("SELECT video_path FROM coral_classification_results ORDER BY RAND() LIMIT 1");
      
//       await conn.close();

//       if (result.rows.isNotEmpty) {
//         setState(() {
//           _videoPath = result.rows.first.assoc()['video_path'] ?? '';
//         });

//         print("Video path from database: $_videoPath");

//         if (_videoPath.isNotEmpty) {
//           await _initializeVideoPlayer();
//         } else {
//           _setErrorMessage("Empty video path retrieved from database");
//         }
//       } else {
//         _setErrorMessage("No rows returned from database query");
//       }
//     } catch (e) {
//       _setErrorMessage('Error fetching data: $e');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       if (_videoPath.startsWith('assets/')) {
//         // Asset file
//         _videoController = VideoPlayerController.asset(_videoPath);
//       } else {
//         // File on device
//         final file = File(_videoPath);
//         if (await file.exists()) {
//           _videoController = VideoPlayerController.file(file);
//         } else {
//           // Try to load as asset if file doesn't exist
//           _videoController = VideoPlayerController.asset(_videoPath);
//         }
//       }

//       await _videoController!.initialize();
//       await _videoController!.setLooping(true);
//       setState(() {
//         _isVideoInitialized = true;
//       });
//       _videoController!.play();
//     } catch (e) {
//       _setErrorMessage('Error initializing video player: $e');
//     }
//   }

//   void _setErrorMessage(String message) {
//     print(message);  // Print to console for debugging
//     setState(() {
//       _errorMessage = message;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Coral Classification'),
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
//           'Coral Classification in Progress...',
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
//         if (_isVideoInitialized && _videoController != null)
//           AspectRatio(
//             aspectRatio: _videoController!.value.aspectRatio,
//             child: VideoPlayer(_videoController!),
//           )
//         else
//           Text(_errorMessage, style: TextStyle(color: Colors.white)),
//         const SizedBox(height: 20),
//         if (_isVideoInitialized && _videoController != null)
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 if (_videoController!.value.isPlaying) {
//                   _videoController!.pause();
//                 } else {
//                   _videoController!.play();
//                 }
//               });
//             },
//             child: Icon(
//               _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//             ),
//           ),
//         const SizedBox(height: 20),
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

// class CoralClassification extends StatelessWidget {
//   final String userId;

//   const CoralClassification({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Coral Classification'),
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








