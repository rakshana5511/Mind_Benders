import 'dart:io';
import 'dart:typed_data';

import 'package:coral_reef/pages/CoralClassification.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadVideo extends StatefulWidget {
  final String userId;

  const UploadVideo({super.key, required this.userId});

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  File? _video;
  Uint8List? _thumbnail;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _video = File(result.files.single.path!);
      });
      await _generateThumbnail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video selected')),
      );
    }
  }

  Future<void> _generateThumbnail() async {
    if (_video == null) return;

    try {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: _video!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );

      setState(() {
        _thumbnail = thumbnailBytes;
      });
    } catch (e) {
      print('Error generating thumbnail: $e');
    }
  }

  Future<void> _saveVideoToDeviceAndDatabase() async {
    if (_video == null) return;

    try {
      // Generate a unique filename for the video
      final fileName = 'video_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Save the video to the user's local gallery
      final directory = await getApplicationDocumentsDirectory();
      final userDirectory = Directory('${directory.path}/${widget.userId}');
      await userDirectory.create(recursive: true);
      final localVideo = File('${userDirectory.path}/$fileName');
      await _video!.copy(localVideo.path);

      print('Video saved locally to: ${localVideo.path}');

      // Connect to MySQL database
      final conn = await MySQLConnection.createConnection(
        host: "10.0.2.2",
        port: 3306,
        userName: "rakshana",
        password: "root",
        databaseName: "coral_db",
        secure: false,
      );

      await conn.connect();

      // Prepare the SQL query
      final query = "INSERT INTO videos (user_id, video_path, video_type, file_name) VALUES (:user_id, :video_path, :video_type, :file_name)";
      
      // Prepare the parameters
      final params = {
        "user_id": int.parse(widget.userId),  // Convert userId to int
        "video_path": localVideo.path,
        "video_type": "video/mp4",
        "file_name": fileName,
      };

      // Print debug information
      print("Executing query: $query");
      print("With parameters: $params");

      // Execute the query
      final res = await conn.execute(query, params);

      await conn.close();

      if (res.affectedRows.toInt() > 0) {
        print('Video metadata saved to database successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved successfully')),
        );

        // Navigate to the CoralClassification screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoralClassification(userId: widget.userId)),
        );
      } else {
        throw Exception('Failed to insert video metadata into database');
      }
    } catch (e, stackTrace) {
      print('Error saving video: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload underwater video'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _thumbnail != null
                    ? Image.memory(_thumbnail!, height: 150)
                    : Text('No video selected.'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: Text('Pick Video'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _video != null ? _saveVideoToDeviceAndDatabase : null,
                  child: Text('Save Video'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}












// // ignore_for_file: unused_local_variable

// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:coral_reef/pages/CoralClassification.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:mysql_client/mysql_client.dart';


// class UploadVideo extends StatefulWidget {
//   const UploadVideo({Key? key}) : super(key: key);

//   @override
//   State<UploadVideo> createState() => _UploadVideoState();
// }

// class _UploadVideoState extends State<UploadVideo> {
//   File? _video;
//   Uint8List? _thumbnail;

//   Future<void> _pickVideo() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.video,
//     );

//     if (result != null) {
//       setState(() {
//         _video = File(result.files.single.path!);
//       });
//       await _generateThumbnail();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No video selected')),
//       );
//     }
//   }

//   Future<void> _generateThumbnail() async {
//     if (_video == null) return;

//     final thumbnailBytes = await VideoThumbnail.thumbnailData(
//       video: _video!.path,
//       imageFormat: ImageFormat.JPEG,
//       maxWidth: 128,
//       quality: 25,
//     );

//     setState(() {
//       _thumbnail = thumbnailBytes;
//     });
//   }

//   Future<void> _saveVideoToDeviceAndDatabase() async {
//     if (_video == null) return;

//     try {
//       // Get the application directory
//       final directory = await getApplicationDocumentsDirectory();

//       // Create a unique file name
//       final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

//       // Copy the video file to the application directory
//       final savedVideo = await _video!.copy('${directory.path}/$fileName');

//       // Read the video file as bytes
//       final videoBytes = await savedVideo.readAsBytes();

//       // Convert video bytes to base64
//       final base64Video = base64Encode(videoBytes);

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

//       // Insert video into database
//       final res = await conn.execute(
//         "INSERT INTO videos (video_data, video_type, video_url) VALUES (:video_data, :video_type, :video_url)",
//         {
//           "video_data": base64Video,
//           "video_type": "mp4",
//           "video_url": savedVideo.path,
//         },
//       );

//       await conn.close();

//       // Display a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Video saved successfully')),
//       );

//       // Navigate to the Gallery screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => CoralClassification()),
//       );
//     } catch (e) {
//       print('Error saving video: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save video')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater video'),
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
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _thumbnail != null
//                     ? Image.memory(_thumbnail!, height: 150)
//                     : Text('No video selected.'),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickVideo,
//                   child: Text('Pick Video'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _saveVideoToDeviceAndDatabase,
//                   child: Text('Save Video'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:path/path.dart' as path;
// import 'package:video_thumbnail/video_thumbnail.dart';

// class UploadVideo extends StatefulWidget {
//   const UploadVideo({super.key});

//   @override
//   State<UploadVideo> createState() => _UploadVideoState();
// }

// class _UploadVideoState extends State<UploadVideo> {
//   File? _video;
//   Uint8List? _thumbnail;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _video = File(pickedFile.path);
//         _generateThumbnail();
//       });
//     }
//   }

//   Future<void> _generateThumbnail() async {
//     if (_video != null) {
//       final thumbnailBytes = await VideoThumbnail.thumbnailData(
//         video: _video!.path,
//         imageFormat: ImageFormat.JPEG,
//         maxWidth: 128,
//         quality: 25,
//       );
//       setState(() {
//         _thumbnail = thumbnailBytes;
//       });
//     }
//   }

// Future<void> _saveVideo() async {
//   if (_video == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select a video')),
//     );
//     return;
//   }

//   // Check file extension
//   final fileExtension = path.extension(_video!.path).toLowerCase();
//   if (fileExtension != '.mp4' && fileExtension != '.mkv' && fileExtension != '.mov') {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Invalid file type. Please select an MP4, MKV, or MOV video.')),
//     );
//     return;
//   }

//   // Check file size (500MB = 500 * 1024 * 1024 bytes)
//   final fileSize = await _video!.length();
//   if (fileSize > 500 * 1024 * 1024) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('File size exceeds 500MB. Please select a smaller video.')),
//     );
//     return;
//   }

//   // Encode video to base64
//   final bytes = await _video!.readAsBytes();
//   final base64Video = base64Encode(bytes);
//   final videoType = 'video/${fileExtension.substring(1)}';

//   // Generate a video URL (you may want to adjust this based on your actual storage setup)
//   final fileName = path.basename(_video!.path);
//   final videoUrl = 'https://your-video-storage-domain.com/videos/$fileName';

//   try {
//     // Connect to MySQL database
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     // Insert video into database
//     final res = await conn.execute(
//       "INSERT INTO videos (video_data, video_type, video_url) VALUES (:video_data, :video_type, :video_url)",
//       {
//         "video_data": base64Video,
//         "video_type": videoType,
//         "video_url": videoUrl,
//       },
//     );

//     await conn.close();

//     if (res.affectedRows.toInt() > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Video uploaded successfully')),
//       );
//       // Navigate to CoralClassification page
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const CoralClassification()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to upload video')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error uploading video: $e')),
//     );
//     print('Error uploading video: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater coral video'),
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
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _buildThumbnail(),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickVideo,
//                   child: const Text('Pick Video'),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _saveVideo,
//                   child: const Text('Upload Video'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildThumbnail() {
//     if (_thumbnail != null) {
//       return Image.memory(_thumbnail!, width: 128, height: 128, fit: BoxFit.cover);
//     } else {
//       return const SizedBox(
//         width: 128,
//         height: 128,
//         child: Center(child: Text('No video selected')),
//       );
//     }
//   }
// }

// // Placeholder for CoralClassification page
// class CoralClassification extends StatelessWidget {
//   const CoralClassification({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Coral Classification'),
//       ),
//       body: const Center(
//         child: Text('Coral Classification Page'),
//       ),
//     );
//   }
// }



// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';

// class UploadVideo extends StatefulWidget {
//   const UploadVideo({Key? key}) : super(key: key);

//   @override
//   State<UploadVideo> createState() => _UploadVideoState();
// }

// class _UploadVideoState extends State<UploadVideo> {
//   File? _video;

//   // Function to pick a video file using FilePicker
//   Future<void> _pickVideo() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.video, // Restricting to video files
//     );

//     if (result != null) {
//       setState(() {
//         _video = File(result.files.single.path!);
//       });
//     } else {
//       // User canceled the picker
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No video selected')),
//       );
//     }
//   }

//   // Function to save the selected video to device storage
//   Future<void> _saveVideoToDevice() async {
//     if (_video == null) return;

//     try {
//       // Get the application directory
//       final directory = await getApplicationDocumentsDirectory();

//       // Create a unique file name
//       final fileName = _video!.path.split('/').last;

//       // Copy the video file to the application directory
//       final savedVideo = await _video!.copy('${directory.path}/$fileName');

//       // Display a message with the saved video path
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Video saved to ${savedVideo.path}')),
//       );
//     } catch (e) {
//       print('Error saving video: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save video')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater video'),
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
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _video == null
//                     ? Text('No video selected.')
//                     : Text(_video!.path),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickVideo,
//                   child: Text('Pick Video'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _saveVideoToDevice,
//                   child: Text('Save Video to Device'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// class UploadVideo extends StatefulWidget {
//   const UploadVideo({super.key});

//   @override
//   State<UploadVideo> createState() => _UploadVideoState();
// }

// class _UploadVideoState extends State<UploadVideo> {

//   File? _video;

//   Future<void> _pickVideo() async {
//    FilePickerResult? result = await FilePicker.platform.pickFiles();

// if (result != null) {
//   File file = File(result.files.single.path!);
// } else {
//   // User canceled the picker
// }
//     // FilePickerResult? result = await FilePicker.platform.pickFiles(
//     //   type: FileType.video,
//     //   // allowedExtensions: ['mp4'],
//     // );

//     // if (result != null) {
//     //   setState(() {
//     //     _video = File(result.files.single.path!);
//     //   });
//     // }
//   }

//   Future<void> _saveVideoToDevice() async {
//     if (_video == null) return;

//     try {
//       // Get the application directory
//       final directory = await getApplicationDocumentsDirectory();

//       // Create a unique file name
//       final fileName = _video!.path.split('/').last;

//       // Copy the video file to the application directory
//       final savedVideo = await _video!.copy('${directory.path}/$fileName');

//       print('Video saved to ${savedVideo.path}');
//     } catch (e) {
//       print('Error saving video: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater video'),
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
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _video == null
//                 ? Text('No video selected.')
//                 : Text(_video!.path),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickVideo,
//               child: Text('Pick Video'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveVideoToDevice,
//               child: Text('Save Video to Device'),
//             ),
//           ],
//         ),
//       ),
//         ],
//       ),
//     );
//   }
// }