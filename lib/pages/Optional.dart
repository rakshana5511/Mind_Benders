import 'package:coral_reef/pages/Gallery.dart';
import 'package:coral_reef/pages/Profile.dart';
import 'package:coral_reef/pages/RequestData.dart';
import 'package:coral_reef/pages/UploadVideo.dart';
import 'package:coral_reef/pages/Uploadimage.dart';
import 'package:flutter/material.dart';

class OptionalPanel extends StatelessWidget {
  final String userId;

  const OptionalPanel({Key? key, required this.userId}) : super(key: key);

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, IconData icon, String text, VoidCallback onPressed, VoidCallback onIconPressed) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(icon, color: Colors.white),
                  onPressed: onIconPressed,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Option Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/coral-bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    Icons.image,
                    "Upload underwater coral image",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadImage(userId: userId))),
                    () => _showNotification(context, 'When you upload an image, we can calculate algae coverage in the coral reef.'),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    Icons.videocam,
                    "Upload underwater video",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadVideo(userId: userId))),
                    () => _showNotification(context, 'When you upload the video, you can classify the coral species.'),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    Icons.photo_library,
                    "View gallery",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(userId: userId))),
                    () => _showNotification(context, 'You can see your image and video collections.'),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    Icons.dataset,
                    "Request dataset",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestData())),
                    () => _showNotification(context, 'You can request for datasets.'),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    Icons.person,
                    "My Profile",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile())),
                    () => _showNotification(context, 'You can edit your profile and logout.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}









// import 'package:coral_reef/pages/Gallery.dart';
// import 'package:coral_reef/pages/Profile.dart';
// import 'package:coral_reef/pages/RequestData.dart';
// import 'package:coral_reef/pages/UploadVideo.dart';
// import 'package:coral_reef/pages/Uploadimage.dart';
// import 'package:flutter/material.dart';

// class OptionalPanel extends StatelessWidget {
//   final String userId; // Add this line to receive the user ID

//   const OptionalPanel({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Optional Panel'),
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
//                         color: Color.fromARGB(255, 5, 87, 125),
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => UploadImage(userId: userId)),
//                           );
//                         },
//                         child: const Text(
//                           "Upload underwater coral image",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => UploadVideo(userId: userId)),
//                           );
//                         },
//                         child: const Text(
//                           "Upload underwater video",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => Gallery(userId: userId)),
//                           );
//                         },
//                         child: const Text(
//                           "View gallery",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             // MaterialPageRoute(builder: (context) => const RequestData()),
//                             MaterialPageRoute(builder: (context) => RequestData()),
//                           );
//                         },
//                         child: const Text(
//                           "Request dataset",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const Profile()),
//                           );
//                         },
//                         child: const Text(
//                           "My Profile",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
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











// import 'package:coral_reef/pages/Gallery.dart';
// import 'package:coral_reef/pages/Profile.dart';
// import 'package:coral_reef/pages/RequestData.dart';
// import 'package:coral_reef/pages/UploadVideo.dart';
// import 'package:coral_reef/pages/Uploadimage.dart';
// import 'package:flutter/material.dart';

// class OptionalPanel extends StatelessWidget {
//   const OptionalPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Optional Panel'),
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
//                         color: Color.fromARGB(255, 5, 87, 125),
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const UploadImage()),
//                           );
//                         },
//                         child: const Text(
//                           "Upload underwater coral image",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const UploadVideo()),
//                           );
//                         },
//                         child: const Text(
//                           "Upload underwater video",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const Gallery()),
//                           );
//                         },
//                         child: const Text(
//                           "View gallery",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const RequestData()),
//                           );
//                         },
//                         child: const Text(
//                           "Request dataset",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
//                         ),
//                       ),
//                     ),
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
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const Profile()),
//                           );
//                         },
//                         child: const Text(
//                           "My Profile",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
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
