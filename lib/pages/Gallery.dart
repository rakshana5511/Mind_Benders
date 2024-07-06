import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class Gallery extends StatefulWidget {
  final String userId;

  const Gallery({super.key, required this.userId});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<File> _savedImages = [];
  List<File> _savedVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedMedia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedMedia() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userDirectory = Directory('${directory.path}/${widget.userId}');
      
      if (await userDirectory.exists()) {
        final files = userDirectory.listSync();
        
        setState(() {
          _savedImages = files.where((file) =>
            (file.path.endsWith('.jpg') || file.path.endsWith('.png'))
          ).map((file) => File(file.path)).toList();
          
          _savedVideos = files.where((file) =>
            file.path.endsWith('.mp4')
          ).map((file) => File(file.path)).toList();
        });
      } else {
        await userDirectory.create(recursive: true);
        setState(() {
          _savedImages = [];
          _savedVideos = [];
        });
      }
    } catch (e) {
      print('Error loading media: $e');
    }
  }

  Future<void> _deleteMedia(File file, bool isVideo) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this ${isVideo ? 'video' : 'image'}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await file.delete();
        setState(() {
          if (isVideo) {
            _savedVideos.remove(file);
          } else {
            _savedImages.remove(file);
          }
        });
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        backgroundColor: Color.fromARGB(255, 36, 123, 163),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.video_collection), text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaGrid(_savedImages, isVideo: false),
          _buildMediaGrid(_savedVideos, isVideo: true),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<File> mediaFiles, {required bool isVideo}) {
    return mediaFiles.isEmpty
        ? Center(child: Text('No saved ${isVideo ? 'videos' : 'images'}.'))
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: mediaFiles.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  isVideo
                      ? _buildVideoThumbnail(mediaFiles[index])
                      : Image.file(mediaFiles[index], fit: BoxFit.cover),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMedia(mediaFiles[index], isVideo),
                    ),
                  ),
                ],
              );
            },
          );
  }

  Widget _buildVideoThumbnail(File videoFile) {
    return FutureBuilder(
      future: _initializeVideoPlayer(videoFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: snapshot.data!.value.aspectRatio,
            child: VideoPlayer(snapshot.data!),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoPlayer(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();
    return controller;
  }

  Future<void> saveImageForUser(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory('${directory.path}/${widget.userId}');
    
    if (!await userDirectory.exists()) {
      await userDirectory.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${userDirectory.path}/$fileName');
    
    setState(() {
      _savedImages.add(savedImage);
    });
  }

  Future<void> saveVideoForUser(File videoFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory('${directory.path}/${widget.userId}');
    
    if (!await userDirectory.exists()) {
      await userDirectory.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedVideo = await videoFile.copy('${userDirectory.path}/$fileName');
    
    setState(() {
      _savedVideos.add(savedVideo);
    });
  }
}











// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';

// class Gallery extends StatefulWidget {
//   final String userId;

//   const Gallery({super.key, required this.userId});

//   @override
//   State<Gallery> createState() => _GalleryState();
// }

// class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<File> _savedImages = [];
//   List<File> _savedVideos = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadSavedMedia();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadSavedMedia() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final userDirectory = Directory('${directory.path}/${widget.userId}');
      
//       if (await userDirectory.exists()) {
//         final files = userDirectory.listSync();
        
//         setState(() {
//           _savedImages = files.where((file) =>
//             (file.path.endsWith('.jpg') || file.path.endsWith('.png'))
//           ).map((file) => File(file.path)).toList();
          
//           _savedVideos = files.where((file) =>
//             file.path.endsWith('.mp4')
//           ).map((file) => File(file.path)).toList();
//         });
//       } else {
//         // If the user directory doesn't exist, create it
//         await userDirectory.create(recursive: true);
//         setState(() {
//           _savedImages = [];
//           _savedVideos = [];
//         });
//       }
//     } catch (e) {
//       print('Error loading media: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Gallery'),
//         backgroundColor: Color.fromARGB(255, 36, 123, 163),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(icon: Icon(Icons.photo), text: 'Photos'),
//             Tab(icon: Icon(Icons.video_collection), text: 'Videos'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildMediaGrid(_savedImages, isVideo: false),
//           _buildMediaGrid(_savedVideos, isVideo: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildMediaGrid(List<File> mediaFiles, {required bool isVideo}) {
//     return mediaFiles.isEmpty
//         ? Center(child: Text('No saved ${isVideo ? 'videos' : 'images'}.'))
//         : GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 4.0,
//               mainAxisSpacing: 4.0,
//             ),
//             itemCount: mediaFiles.length,
//             itemBuilder: (context, index) {
//               return isVideo
//                   ? _buildVideoThumbnail(mediaFiles[index])
//                   : Image.file(mediaFiles[index], fit: BoxFit.cover);
//             },
//           );
//   }

//   Widget _buildVideoThumbnail(File videoFile) {
//     return FutureBuilder(
//       future: _initializeVideoPlayer(videoFile),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return AspectRatio(
//             aspectRatio: snapshot.data!.value.aspectRatio,
//             child: VideoPlayer(snapshot.data!),
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }

//   Future<VideoPlayerController> _initializeVideoPlayer(File videoFile) async {
//     final controller = VideoPlayerController.file(videoFile);
//     await controller.initialize();
//     await controller.setLooping(true);
//     await controller.play();
//     return controller;
//   }

//   // Helper method to save an image for the current user
//   Future<void> saveImageForUser(File imageFile) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final userDirectory = Directory('${directory.path}/${widget.userId}');
    
//     if (!await userDirectory.exists()) {
//       await userDirectory.create(recursive: true);
//     }
    
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final savedImage = await imageFile.copy('${userDirectory.path}/$fileName');
    
//     setState(() {
//       _savedImages.add(savedImage);
//     });
//   }

//   // Helper method to save a video for the current user
//   Future<void> saveVideoForUser(File videoFile) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final userDirectory = Directory('${directory.path}/${widget.userId}');
    
//     if (!await userDirectory.exists()) {
//       await userDirectory.create(recursive: true);
//     }
    
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
//     final savedVideo = await videoFile.copy('${userDirectory.path}/$fileName');
    
//     setState(() {
//       _savedVideos.add(savedVideo);
//     });
//   }
// }








// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class Gallery extends StatefulWidget {
//   const Gallery({super.key});

//   @override
//   State<Gallery> createState() => _GalleryState();
// }

// class _GalleryState extends State<Gallery> {
//   // ignore: unused_field
//   File? _image;
//   List<File> _savedImages = [];

// @override
//   void initState() {
//     super.initState();
//     _loadSavedImages();
//   }


//   Future<void> _loadSavedImages() async {
//     try {
//       // Get the application directory
//       final directory = await getApplicationDocumentsDirectory();
//       final directoryPath = directory.path;

//       // List all files in the directory
//       final files = Directory(directoryPath).listSync();

//       // Filter the list to include only image files
//       final imageFiles = files
//           .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
//           .map((file) => File(file.path))
//           .toList();

//       setState(() {
//         _savedImages = imageFiles;
//       });
//     } catch (e) {
//       print('Error loading images: $e');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Gallery'),
//         backgroundColor: Color.fromARGB(255, 36, 123, 163),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             SizedBox(height: 20),
//             Expanded(
//               child: _savedImages.isEmpty
//                   ? const Text('No saved images.')
//                   : GridView.builder(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 4.0,
//                         mainAxisSpacing: 4.0,
//                       ),
//                       itemCount: _savedImages.length,
//                       itemBuilder: (context, index) {
//                         return Image.file(_savedImages[index]);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





