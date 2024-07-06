import 'dart:io';

import 'package:coral_reef/pages/AlgaeCoverage.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UploadImage extends StatefulWidget {
  final String userId;

  const UploadImage({super.key, required this.userId});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_image == null) return;

    // Check file extension
    final fileExtension = path.extension(_image!.path).toLowerCase();
    if (fileExtension != '.jpg' && fileExtension != '.png') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file type. Please select a JPG or PNG image')),
      );
      return;
    }

    // Check file size (50MB = 50 * 1024 * 1024 bytes)
    final fileSize = await _image!.length();
    if (fileSize > 50 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size exceeds 50MB. Please select a smaller image.')),
      );
      return;
    }

    try {
      // Read image file as bytes
      final bytes = await _image!.readAsBytes();

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

      // Generate a unique filename for the image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Insert image data into database
      final res = await conn.execute(
        "INSERT INTO images (image_data, image_type, file_name, user_id) VALUES (:image_data, :image_type, :file_name, :user_id)",
        {
          "image_data": bytes,
          "image_type": fileExtension == '.jpg' ? 'image/jpeg' : 'image/png',
          "file_name": fileName,
          "user_id": widget.userId,
        },
      );

      await conn.close();

      if (res.affectedRows.toInt() > 0) {
        // Save the image to the user's local gallery
        final directory = await getApplicationDocumentsDirectory();
        final userDirectory = Directory('${directory.path}/${widget.userId}');
        await userDirectory.create(recursive: true);
        final localImage = File('${userDirectory.path}/$fileName');
        await localImage.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
        // Navigate to AlgaeCoverageDetection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AlgaeCoverageDetection(
              userId: widget.userId,
              uploadedImagePath: localImage.path,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload underwater coral image'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? const Text('No image selected.')
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.file(_image!),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 20),
                _image == null
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: _saveImage,
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}









// import 'dart:io';

// import 'package:coral_reef/pages/AlgaeCoverage.dart'; // Ensure this import is correct
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';

// class UploadImage extends StatefulWidget {
//   final String userId;

//   const UploadImage({super.key, required this.userId});

//   @override
//   State<UploadImage> createState() => _UploadImageState();
// }

// class _UploadImageState extends State<UploadImage> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _saveImage() async {
//     if (_image == null) return;

//     // Check file extension
//     final fileExtension = path.extension(_image!.path).toLowerCase();
//     if (fileExtension != '.jpg' && fileExtension != '.png') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid file type. Please select a JPG or PNG image')),
//       );
//       return;
//     }

//     // Check file size (50MB = 50 * 1024 * 1024 bytes)
//     final fileSize = await _image!.length();
//     if (fileSize > 50 * 1024 * 1024) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('File size exceeds 50MB. Please select a smaller image.')),
//       );
//       return;
//     }

//     try {
//       // Read image file as bytes
//       final bytes = await _image!.readAsBytes();

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

//       // Generate a unique filename for the image
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

//       // Insert image data into database
//       final res = await conn.execute(
//         "INSERT INTO images (image_data, image_type, file_name, user_id) VALUES (:image_data, :image_type, :file_name, :user_id)",
//         {
//           "image_data": bytes,
//           "image_type": fileExtension == '.jpg' ? 'image/jpeg' : 'image/png',
//           "file_name": fileName,
//           "user_id": widget.userId,
//         },
//       );

//       await conn.close();

//       if (res.affectedRows.toInt() > 0) {
//         // Save the image to the user's local gallery
//         final directory = await getApplicationDocumentsDirectory();
//         final userDirectory = Directory('${directory.path}/${widget.userId}');
//         await userDirectory.create(recursive: true);
//         final localImage = File('${userDirectory.path}/$fileName');
//         await localImage.writeAsBytes(bytes);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Image uploaded successfully')),
//         );
//         // Navigate to AlgaeCoverageDetection
//         Navigator.pushReplacement(
//           context,
//           // MaterialPageRoute(builder: (context) => const AlgaeCoverageDetection()),
//           MaterialPageRoute(builder: (context) => AlgaeCoverageDetection(userId: widget.userId)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload image')),
//         );
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error uploading image')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater coral image'),
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
//                 _image == null
//                     ? const Text('No image selected.')
//                     : Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Image.file(_image!),
//                       ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickImage,
//                   child: const Text('Pick Image'),
//                 ),
//                 const SizedBox(height: 20),
//                 _image == null
//                     ? const SizedBox.shrink()
//                     : ElevatedButton(
//                         onPressed: _saveImage,
//                         child: const Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












// import 'dart:io';

// import 'package:coral_reef/pages/AlgaeCoverage.dart'; // Ensure this import is correct
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:path/path.dart' as path;

// class UploadImage extends StatefulWidget {
//   const UploadImage({super.key});

//   @override
//   State<UploadImage> createState() => _UploadImageState();
// }

// class _UploadImageState extends State<UploadImage> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _saveImage() async {
//   if (_image == null) return;

//   // Check file extension
//   final fileExtension = path.extension(_image!.path).toLowerCase();
//   if (fileExtension != '.jpg' && fileExtension != '.png') {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Invalid file type. Please select a JPG or PNG image')),
//     );
//     return;
//   }

//   // Check file size (50MB = 50 * 1024 * 1024 bytes)
//   final fileSize = await _image!.length();
//   if (fileSize > 50 * 1024 * 1024) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('File size exceeds 50MB. Please select a smaller image.')),
//     );
//     return;
//   }

//   try {
//     // Read image file as bytes
//     final bytes = await _image!.readAsBytes();

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

//     // Generate a unique filename for the image
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    
//     // Assuming you have a base URL for your image storage
//     final baseUrl = 'http://your-image-storage-url.com/';
//     final imageUrl = '$baseUrl$fileName';

//     // Insert image data into database
//     final res = await conn.execute(
//       "INSERT INTO images (image_data, image_type, image_url) VALUES (:image_data, :image_type, :image_url)",
//       {
//         "image_data": bytes,
//         "image_type": fileExtension == '.jpg' ? 'image/jpeg' : 'image/png',
//         "image_url": imageUrl,
//       },
//     );

//     if (res.affectedRows.toInt() > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Image uploaded successfully')),
//       );
//       // Navigate to AlgaeCoverageDetection
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const AlgaeCoverageDetection()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to upload image')),
//       );
//     }

//     await conn.close();
//   } catch (e) {
//     print('Error uploading image: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error uploading image')),
//     );
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater coral image'),
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
//                 _image == null
//                     ? const Text('No image selected.')
//                     : Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Image.file(_image!),
//                       ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickImage,
//                   child: const Text('Pick Image'),
//                 ),
//                 const SizedBox(height: 20),
//                 _image == null
//                     ? const SizedBox.shrink()
//                     : ElevatedButton(
//                         onPressed: _saveImage,
//                         child: const Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }









// import 'package:coral_reef/pages/AlgaeCoverage.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class UploadImage extends StatefulWidget {
//   const UploadImage({super.key});

//   @override
//   State<UploadImage> createState() => _UploadImageState();
// }

// class _UploadImageState extends State<UploadImage> {
//   File? _image;

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _saveImage() async {
//     if (_image == null) return;

//  // Check file extension
//     final fileExtension = path.extension(_image!.path).toLowerCase();
//     if (fileExtension != '.jpg' && fileExtension != '.png') {
//        ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: const Text('Invalid file type. Please select a JPG or PNG image')),
//       );

//       return;
//     }

//     // Check file size (50MB = 50 * 1024 * 1024 bytes)
//     final fileSize = await _image!.length();
//     if (fileSize > 50 * 1024 * 1024) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('File size exceeds 50MB. Please select a smaller image.')),
//       );

//       return;
//     }
//     try {
//       // Get the application directory
//       final directory = await getApplicationDocumentsDirectory();

//       // Create a unique file name
//       final fileName = path.basename(_image!.path);
//       final savedImage = await _image!.copy('${directory.path}/$fileName');

//       print('Image saved to ${savedImage.path}');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const AlgaeCoverageDetection()),
//       );
//     } catch (e) {
//       print('Error saving image: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload underwater coral image'),
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
//                 _image == null
//                     ? Text('No image selected.')
//                     : Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Image.file(_image!),
//                       ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _pickImage,
//                   child: Text('Pick Image'),
//                 ),
//                 SizedBox(height: 20),
//                 _image == null
//                     ? SizedBox.shrink()
//                     : ElevatedButton(
//                         onPressed: _saveImage,
//                         child: Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                       )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }