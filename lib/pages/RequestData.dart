import 'dart:convert';
import 'package:coral_reef/pages/Optional.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestData extends StatefulWidget {
  const RequestData({Key? key}) : super(key: key);

  @override
  _RequestDataState createState() => _RequestDataState();
}

class _RequestDataState extends State<RequestData> {
  String userName = '';
  String userEmail = '';
  String? selectedPurpose;
  String? selectedDataType;
  String? selectedSceneryType;
  String? selectedSampleRange;
  String? selectedResearchSampleRange;
  String? selectedStudySampleRange;

  final formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'duration': TextEditingController(),
    'objective': TextEditingController(),
    'workPlace': TextEditingController(),
    'academicBackground': TextEditingController(),
    'studyObjective': TextEditingController(),
    'currentlyStudyingPlace': TextEditingController(),
    'publicationName': TextEditingController(),
    'researchArea': TextEditingController(),
  };

  final Map<String, List<String>> dropdownOptions = {
    'purposes': ['Study Purpose', 'Publication Purpose', 'Research Purpose'],
    'dataTypes': ['Images', 'Videos'],
    'sceneryTypes': ['Brain coral', 'Coral with pollution', 'Other coral', 'Coral with bleach'],
    'sampleRanges': ['5 to 10', '10 to 15', '15 to 20'],
    'researchSampleRanges': ['150 to 250', '250 to 350', '350 to 500'],
    'studySampleRanges': ['50 to 100', '100 to 150', '150 to 200'],
  };

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> user = jsonDecode(userJson);
      setState(() {
        userName = user['user_name'] ?? '';
        userEmail = user['email'] ?? '';
      });
    }
  }

  Future<void> requestData() async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false
    );

    await conn.connect();

    String query = "INSERT INTO request_dataset (user_name, user_email, purpose, data_type, additional_info, status) VALUES (:user_name, :user_email, :purpose, :data_type, :additional_info, :status)";
    Map<String, dynamic> params = {
      "user_name": userName,
      "user_email": userEmail,
      "purpose": selectedPurpose,
      "data_type": selectedDataType,
      "additional_info": getAdditionalInfo(),
      "status": "Pending",
    };

    try {
      await conn.execute(query, params);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Successful")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OptionalPanel(userId: '',)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      await conn.close();
    }
  }

  String getAdditionalInfo() {
    switch (selectedPurpose) {
      case 'Research Purpose':
        return "Duration: ${controllers['duration']!.text}, Objective: ${controllers['objective']!.text}, Datasets: $selectedResearchSampleRange, Workplace: ${controllers['workPlace']!.text}";
      case 'Study Purpose':
        return "Academic Background: ${controllers['academicBackground']!.text}, Objective: ${controllers['studyObjective']!.text}, Datasets: $selectedStudySampleRange, Studying Place: ${controllers['currentlyStudyingPlace']!.text}";
      case 'Publication Purpose':
        return "Publication Name: ${controllers['publicationName']!.text}, Research Area: ${controllers['researchArea']!.text}, Scenery Type: $selectedSceneryType, Sample Range: $selectedSampleRange";
      default:
        return "";
    }
  }

  void showNotifications() async {
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
      "SELECT * FROM request_dataset WHERE user_email = :email ORDER BY request_date DESC",
      {"email": userEmail}
    );

    List<Map<String, String>> notifications = [];
    for (final row in res.rows) {
      Map<String, String> notification = {};
      row.assoc().forEach((key, value) {
        notification[key] = value ?? '';
      });
      notifications.add(notification);
    }

    await conn.close();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: SingleChildScrollView(
          child: notifications.isEmpty
              ? Text('No Notifications')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: notifications.map((notification) => 
                    ListTile(
                      title: Text('Request for ${notification['data_type']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${notification['status']}'),
                          Text('Purpose: ${notification['purpose']}'),
                          Text('Date: ${notification['request_date']}'),
                          if (notification['reason'] != null && notification['reason']!.isNotEmpty)
                            Text('Reason: ${notification['reason']}'),
                        ],
                      ),
                    )
                  ).toList(),
                ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Data'),
        backgroundColor: const Color.fromARGB(255, 36, 123, 163),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: showNotifications,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/coral-bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Name: $userName",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Email: $userEmail",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        buildDropdownField("Purpose", (String? newValue) {
                          setState(() {
                            selectedPurpose = newValue;
                          });
                        }, dropdownOptions['purposes']!),
                        buildDropdownField("Data Type", (String? newValue) {
                          setState(() {
                            selectedDataType = newValue;
                          });
                        }, dropdownOptions['dataTypes']!),
                        if (selectedPurpose == 'Research Purpose') ...[
                          buildTextField("Duration", controllers['duration']!, "Duration is required"),
                          buildTextField("Objective", controllers['objective']!, "Objective is required"),
                          buildDropdownField("How many samples do you want?", (String? newValue) {
                            setState(() {
                              selectedResearchSampleRange = newValue;
                            });
                          }, dropdownOptions['researchSampleRanges']!),
                          buildTextField("Work Place", controllers['workPlace']!, "Work place is required"),
                        ] else if (selectedPurpose == 'Study Purpose') ...[
                          buildTextField("Academic Background", controllers['academicBackground']!, "Academic background is required"),
                          buildTextField("Objective", controllers['studyObjective']!, "Objective is required"),
                          buildDropdownField("How many samples do you want?", (String? newValue) {
                            setState(() {
                              selectedStudySampleRange = newValue;
                            });
                          }, dropdownOptions['studySampleRanges']!),
                          buildTextField("Currently Studying Place", controllers['currentlyStudyingPlace']!, "Studying place is required"),
                        ] else if (selectedPurpose == 'Publication Purpose') ...[
                          buildTextField("Name of Publication", controllers['publicationName']!, "Publication name is required"),
                          buildTextField("Research Area", controllers['researchArea']!, "Research area is required"),
                          buildDropdownField("What type of scenery do you want to get?", (String? newValue) {
                            setState(() {
                              selectedSceneryType = newValue;
                            });
                          }, dropdownOptions['sceneryTypes']!),
                          buildDropdownField("How many samples do you want?", (String? newValue) {
                            setState(() {
                              selectedSampleRange = newValue;
                            });
                          }, dropdownOptions['sampleRanges']!),
                        ],
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromARGB(255, 5, 87, 125),
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              requestData();
                            }
                          },
                          child: Text("Request"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdownField(String label, void Function(String?) onChanged, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        value: label == "Purpose" ? selectedPurpose : 
               label == "Data Type" ? selectedDataType : 
               label == "What type of scenery do you want to get?" ? selectedSceneryType :
               label == "How many samples do you want?" && selectedPurpose == "Research Purpose" ? selectedResearchSampleRange :
               label == "How many samples do you want?" && selectedPurpose == "Study Purpose" ? selectedStudySampleRange :
               label == "How many samples do you want?" && selectedPurpose == "Publication Purpose" ? selectedSampleRange : null,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }
}











// import 'dart:convert';
// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RequestData extends StatefulWidget {
//   const RequestData({Key? key}) : super(key: key);

//   @override
//   _RequestDataState createState() => _RequestDataState();
// }

// class _RequestDataState extends State<RequestData> {
//   String userName = '';
//   String userEmail = '';
//   String? selectedPurpose;
//   String? selectedDataType;
//   String? selectedSceneryType;
//   String? selectedSampleRange;
//   String? selectedResearchSampleRange;
//   String? selectedStudySampleRange;

//   final formKey = GlobalKey<FormState>();

//   final Map<String, TextEditingController> controllers = {
//     'duration': TextEditingController(),
//     'objective': TextEditingController(),
//     'workPlace': TextEditingController(),
//     'academicBackground': TextEditingController(),
//     'studyObjective': TextEditingController(),
//     'currentlyStudyingPlace': TextEditingController(),
//     'publicationName': TextEditingController(),
//     'researchArea': TextEditingController(),
//   };

//   final Map<String, List<String>> dropdownOptions = {
//     'purposes': ['Study Purpose', 'Publication Purpose', 'Research Purpose'],
//     'dataTypes': ['Images', 'Videos'],
//     'sceneryTypes': ['Brain coral', 'Coral with pollution', 'Other coral', 'Coral with bleach'],
//     'sampleRanges': ['5 to 10', '10 to 15', '15 to 20'],
//     'researchSampleRanges': ['150 to 250', '250 to 350', '350 to 500'],
//     'studySampleRanges': ['50 to 100', '100 to 150', '150 to 200'],
//   };

//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }

//   Future<void> fetchUserDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? userJson = prefs.getString('user');
//     if (userJson != null) {
//       Map<String, dynamic> user = jsonDecode(userJson);
//       setState(() {
//         userName = user['user_name'] ?? '';
//         userEmail = user['email'] ?? '';
//       });
//     }
//   }

//   Future<void> requestData() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     String query = "INSERT INTO request_dataset (user_name, user_email, purpose, data_type, additional_info, status) VALUES (:user_name, :user_email, :purpose, :data_type, :additional_info, :status)";
//     Map<String, dynamic> params = {
//       "user_name": userName,
//       "user_email": userEmail,
//       "purpose": selectedPurpose,
//       "data_type": selectedDataType,
//       "additional_info": getAdditionalInfo(),
//       "status": "Pending",
//     };

//     try {
//       await conn.execute(query, params);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Request Successful")),
//       );
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const OptionalPanel(userId: '',)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       await conn.close();
//     }
//   }

//   String getAdditionalInfo() {
//     switch (selectedPurpose) {
//       case 'Research Purpose':
//         return "Duration: ${controllers['duration']!.text}, Objective: ${controllers['objective']!.text}, Datasets: $selectedResearchSampleRange, Workplace: ${controllers['workPlace']!.text}";
//       case 'Study Purpose':
//         return "Academic Background: ${controllers['academicBackground']!.text}, Objective: ${controllers['studyObjective']!.text}, Datasets: $selectedStudySampleRange, Studying Place: ${controllers['currentlyStudyingPlace']!.text}";
//       case 'Publication Purpose':
//         return "Publication Name: ${controllers['publicationName']!.text}, Research Area: ${controllers['researchArea']!.text}, Scenery Type: $selectedSceneryType, Sample Range: $selectedSampleRange";
//       default:
//         return "";
//     }
//   }

//   void showNotifications() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     var res = await conn.execute(
//       "SELECT * FROM request_dataset WHERE user_email = :email ORDER BY request_date DESC",
//       {"email": userEmail}
//     );

//     List<Map<String, String>> notifications = [];
//     for (final row in res.rows) {
//       Map<String, String> notification = {};
//       row.assoc().forEach((key, value) {
//         notification[key] = value ?? '';
//       });
//       notifications.add(notification);
//     }

//     await conn.close();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Notifications'),
//         content: SingleChildScrollView(
//           child: notifications.isEmpty
//               ? Text('No Notifications')
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: notifications.map((notification) => 
//                     ListTile(
//                       title: Text('Request for ${notification['data_type']}'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Status: ${notification['status']}'),
//                           Text('Purpose: ${notification['purpose']}'),
//                           Text('Date: ${notification['request_date']}'),
//                         ],
//                       ),
//                     )
//                   ).toList(),
//                 ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Close'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Request Data'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: showNotifications,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('lib/assets/coral-bg.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   color: Colors.white.withOpacity(0.9),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Name: $userName",
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           "Email: $userEmail",
//                           style: TextStyle(fontSize: 18),
//                         ),
//                         SizedBox(height: 20),
//                         buildDropdownField("Purpose", (String? newValue) {
//                           setState(() {
//                             selectedPurpose = newValue;
//                           });
//                         }, dropdownOptions['purposes']!),
//                         buildDropdownField("Data Type", (String? newValue) {
//                           setState(() {
//                             selectedDataType = newValue;
//                           });
//                         }, dropdownOptions['dataTypes']!),
//                         if (selectedPurpose == 'Research Purpose') ...[
//                           buildTextField("Duration", controllers['duration']!, "Duration is required"),
//                           buildTextField("Objective", controllers['objective']!, "Objective is required"),
//                           buildDropdownField("How many samples do you want?", (String? newValue) {
//                             setState(() {
//                               selectedResearchSampleRange = newValue;
//                             });
//                           }, dropdownOptions['researchSampleRanges']!),
//                           buildTextField("Work Place", controllers['workPlace']!, "Work place is required"),
//                         ] else if (selectedPurpose == 'Study Purpose') ...[
//                           buildTextField("Academic Background", controllers['academicBackground']!, "Academic background is required"),
//                           buildTextField("Objective", controllers['studyObjective']!, "Objective is required"),
//                           buildDropdownField("How many samples do you want?", (String? newValue) {
//                             setState(() {
//                               selectedStudySampleRange = newValue;
//                             });
//                           }, dropdownOptions['studySampleRanges']!),
//                           buildTextField("Currently Studying Place", controllers['currentlyStudyingPlace']!, "Studying place is required"),
//                         ] else if (selectedPurpose == 'Publication Purpose') ...[
//                           buildTextField("Name of Publication", controllers['publicationName']!, "Publication name is required"),
//                           buildTextField("Research Area", controllers['researchArea']!, "Research area is required"),
//                           buildDropdownField("What type of scenery do you want to get?", (String? newValue) {
//                             setState(() {
//                               selectedSceneryType = newValue;
//                             });
//                           }, dropdownOptions['sceneryTypes']!),
//                           buildDropdownField("How many samples do you want?", (String? newValue) {
//                             setState(() {
//                               selectedSampleRange = newValue;
//                             });
//                           }, dropdownOptions['sampleRanges']!),
//                         ],
//                         SizedBox(height: 30),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 5, 87, 125),
//                               padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                               textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               elevation: 5,
//                             ),
//                             onPressed: () {
//                               if (formKey.currentState!.validate()) {
//                                 requestData();
//                               }
//                             },
//                             child: Text("Request"),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String label, TextEditingController controller, String validationMessage) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//         validator: (value) {
//           if (value!.isEmpty) {
//             return validationMessage;
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget buildDropdownField(String label, void Function(String?) onChanged, List<String> items) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//         value: label == "Purpose" ? selectedPurpose : 
//                label == "Data Type" ? selectedDataType : 
//                label == "What type of scenery do you want to get?" ? selectedSceneryType :
//                label == "How many samples do you want?" && selectedPurpose == "Research Purpose" ? selectedResearchSampleRange :
//                label == "How many samples do you want?" && selectedPurpose == "Study Purpose" ? selectedStudySampleRange :
//                label == "How many samples do you want?" && selectedPurpose == "Publication Purpose" ? selectedSampleRange : null,
//         onChanged: onChanged,
//         items: items.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please select a ${label.toLowerCase()}';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }









// import 'dart:convert';

// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RequestData extends StatefulWidget {
//   const RequestData({Key? key}) : super(key: key);

//   @override
//   _RequestDataState createState() => _RequestDataState();
// }

// class _RequestDataState extends State<RequestData> {
//   String userName = '';
//   String userEmail = '';
//   String? selectedPurpose;
//   String? selectedDataType;
//   String? selectedSceneryType;
//   String? selectedSampleRange;
//   String? selectedResearchSampleRange;
//   String? selectedStudySampleRange;

//   // Controllers for Research Purpose
//   final durationController = TextEditingController();
//   final objectiveController = TextEditingController();
//   final workPlaceController = TextEditingController();

//   // Controllers for Study Purpose
//   final academicBackgroundController = TextEditingController();
//   final studyObjectiveController = TextEditingController();
//   final currentlyStudyingPlaceController = TextEditingController();

//   // Controllers for Publication Purpose
//   final publicationNameController = TextEditingController();
//   final researchAreaController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   List<String> purposes = ['Study Purpose', 'Publication Purpose', 'Research Purpose'];
//   List<String> dataTypes = ['Images', 'Videos'];
//   List<String> sceneryTypes = ['Brain coral', 'Coral with pollution', 'Other coral', 'Coral with bleach'];
//   List<String> sampleRanges = ['5 to 10', '10 to 15', '15 to 20'];
//   List<String> researchSampleRanges = ['150 to 250', '250 to 350', '350 to 500'];
//   List<String> studySampleRanges = ['50 to 100', '100 to 150', '150 to 200'];

//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }

//   Future<void> fetchUserDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? userJson = prefs.getString('user');
//     print("User JSON: $userJson"); // Debug print
//     if (userJson != null) {
//       Map<String, dynamic> user = jsonDecode(userJson);
//       setState(() {
//         userName = user['user_name'] ?? '';
//         userEmail = user['email'] ?? '';
//       });
//       print("User Name: $userName"); // Debug print
//       print("User Email: $userEmail"); // Debug print
//     } else {
//       print("No user data found in SharedPreferences"); // Debug print
//     }
//   }

//   Future<void> requestData() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     String query = "INSERT INTO request_dataset (user_name, user_email, purpose, data_type, additional_info, status) VALUES (:user_name, :user_email, :purpose, :data_type, :additional_info, :status)";
//     Map<String, dynamic> params = {
//       "user_name": userName,
//       "user_email": userEmail,
//       "purpose": selectedPurpose,
//       "data_type": selectedDataType,
//       "additional_info": getAdditionalInfo(),
//       "status": "Pending",
//     };

//     print("SQL Query: $query"); // Debug print
//     print("Parameters: $params"); // Debug print

//     try {
//       var res = await conn.execute(query, params);
//       print("Affected rows: ${res.affectedRows}"); // Debug print
//     } catch (e) {
//       print("Error executing query: $e"); // Debug print
//     } finally {
//       await conn.close();
//     }
//   }

//   String getAdditionalInfo() {
//     switch (selectedPurpose) {
//       case 'Research Purpose':
//         return "Duration: ${durationController.text}, Objective: ${objectiveController.text}, Datasets: $selectedResearchSampleRange, Workplace: ${workPlaceController.text}";
//       case 'Study Purpose':
//         return "Academic Background: ${academicBackgroundController.text}, Objective: ${studyObjectiveController.text}, Datasets: $selectedStudySampleRange, Studying Place: ${currentlyStudyingPlaceController.text}";
//       case 'Publication Purpose':
//         return "Publication Name: ${publicationNameController.text}, Research Area: ${researchAreaController.text}, Scenery Type: $selectedSceneryType, Sample Range: $selectedSampleRange";
//       default:
//         return "";
//     }
//   }

//   void showNotifications() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     var res = await conn.execute(
//       "SELECT * FROM request_dataset WHERE user_email = :email ORDER BY request_date DESC",
//       {"email": userEmail}
//     );

//     List<Map<String, String>> notifications = [];
//     for (final row in res.rows) {
//       Map<String, String> notification = {};
//       row.assoc().forEach((key, value) {
//         notification[key] = value ?? '';
//       });
//       notifications.add(notification);
//     }

//     await conn.close();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Notifications'),
//         content: SingleChildScrollView(
//           child: notifications.isEmpty
//               ? Text('No Notifications')
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: notifications.map((notification) => 
//                     ListTile(
//                       title: Text('Request for ${notification['data_type']}'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Status: ${notification['status']}'),
//                           Text('Purpose: ${notification['purpose']}'),
//                           Text('Date: ${notification['request_date']}'),
//                         ],
//                       ),
//                     )
//                   ).toList(),
//                 ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Close'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Request Data'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               showNotifications();
//             },
//           ),
//         ],
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
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Name: $userName",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "Email: $userEmail",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       SizedBox(height: 20),
//                       buildDropdownField("Purpose", (String? newValue) {
//                         setState(() {
//                           selectedPurpose = newValue;
//                         });
//                       }, purposes),
//                       buildDropdownField("Data Type", (String? newValue) {
//                         setState(() {
//                           selectedDataType = newValue;
//                         });
//                       }, dataTypes),
//                       if (selectedPurpose == 'Research Purpose') ...[
//                         buildTextField("Duration", durationController, "Duration is required"),
//                         buildTextField("Objective", objectiveController, "Objective is required"),
//                         buildDropdownField("How many samples do you want?", (String? newValue) {
//                           setState(() {
//                             selectedResearchSampleRange = newValue;
//                           });
//                         }, researchSampleRanges),
//                         buildTextField("Work Place", workPlaceController, "Work place is required"),
//                       ] else if (selectedPurpose == 'Study Purpose') ...[
//                         buildTextField("Academic Background", academicBackgroundController, "Academic background is required"),
//                         buildTextField("Objective", studyObjectiveController, "Objective is required"),
//                         buildDropdownField("How many samples do you want?", (String? newValue) {
//                           setState(() {
//                             selectedStudySampleRange = newValue;
//                           });
//                         }, studySampleRanges),
//                         buildTextField("Currently Studying Place", currentlyStudyingPlaceController, "Studying place is required"),
//                       ] else if (selectedPurpose == 'Publication Purpose') ...[
//                         buildTextField("Name of Publication", publicationNameController, "Publication name is required"),
//                         buildTextField("Research Area", researchAreaController, "Research area is required"),
//                         buildDropdownField("What type of scenery do you want to get?", (String? newValue) {
//                           setState(() {
//                             selectedSceneryType = newValue;
//                           });
//                         }, sceneryTypes),
//                         buildDropdownField("How many samples do you want?", (String? newValue) {
//                           setState(() {
//                             selectedSampleRange = newValue;
//                           });
//                         }, sampleRanges),
//                       ],
//                       const SizedBox(height: 10),
//                       Container(
//                         height: 55,
//                         width: MediaQuery.of(context).size.width * .9,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color.fromARGB(255, 5, 87, 125),
//                         ),
//                         child: TextButton(
//                           onPressed: () {
//                             if (formKey.currentState!.validate()) {
//                               requestData().whenComplete(() {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text("Request Successful")),
//                                 );
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const OptionalPanel(userId: '',)),
//                                 );
//                               });
//                             }
//                           },
//                           child: const Text(
//                             "Request",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16.0,
//                               color: Colors.white,
//                             ),
//                           ),
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

//   Widget buildTextField(String label, TextEditingController controller, String validationMessage) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.0,
//             color: Colors.white,
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white.withOpacity(.8),
//           ),
//           child: TextFormField(
//             controller: controller,
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return validationMessage;
//               }
//               return null;
//             },
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildDropdownField(String label, void Function(String?) onChanged, List<String> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.0,
//             color: Colors.white,
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white.withOpacity(.8),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: label == "Purpose" ? selectedPurpose : 
//                    label == "Data Type" ? selectedDataType : 
//                    label == "What type of scenery do you want to get?" ? selectedSceneryType :
//                    label == "How many samples do you want?" && selectedPurpose == "Research Purpose" ? selectedResearchSampleRange :
//                    label == "How many samples do you want?" && selectedPurpose == "Study Purpose" ? selectedStudySampleRange :
//                    label == "How many samples do you want?" && selectedPurpose == "Publication Purpose" ? selectedSampleRange : null,
//             onChanged: onChanged,
//             items: items.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a ${label.toLowerCase()}';
//               }
//               return null;
//             },
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


















// import 'dart:convert';

// import 'package:coral_reef/pages/Optional.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RequestData extends StatefulWidget {
//   const RequestData({Key? key}) : super(key: key);

//   @override
//   _RequestDataState createState() => _RequestDataState();
// }

// class _RequestDataState extends State<RequestData> {
//   String userName = '';
//   String userEmail = '';
//   String? selectedPurpose;
//   String? selectedDataType;

//   // Controllers for Research Purpose
//   final durationController = TextEditingController();
//   final objectiveController = TextEditingController();
//   final datasetsCountController = TextEditingController();
//   final workPlaceController = TextEditingController();

//   // Controllers for Study Purpose
//   final academicBackgroundController = TextEditingController();
//   final studyObjectiveController = TextEditingController();
//   final studyDatasetsCountController = TextEditingController();
//   final currentlyStudyingPlaceController = TextEditingController();

//   // Controllers for Publication Purpose
//   final publicationNameController = TextEditingController();
//   final researchAreaController = TextEditingController();
//   final publicationDatasetsCountController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   List<String> purposes = ['Study Purpose', 'Publication Purpose', 'Research Purpose'];
//   List<String> dataTypes = ['Images', 'Videos'];

//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }

//   Future<void> fetchUserDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? userJson = prefs.getString('user');
//     print("User JSON: $userJson"); // Debug print
//     if (userJson != null) {
//       Map<String, dynamic> user = jsonDecode(userJson);
//       setState(() {
//         userName = user['user_name'] ?? '';
//         userEmail = user['email'] ?? '';
//       });
//       print("User Name: $userName"); // Debug print
//       print("User Email: $userEmail"); // Debug print
//     } else {
//       print("No user data found in SharedPreferences"); // Debug print
//     }
//   }

//   Future<void> requestData() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     String query = "INSERT INTO request_dataset (user_name, user_email, purpose, data_type, additional_info, status) VALUES (:user_name, :user_email, :purpose, :data_type, :additional_info, :status)";
//     Map<String, dynamic> params = {
//       "user_name": userName,
//       "user_email": userEmail,
//       "purpose": selectedPurpose,
//       "data_type": selectedDataType,
//       "additional_info": getAdditionalInfo(),
//       "status": "Pending",
//     };

//     print("SQL Query: $query"); // Debug print
//     print("Parameters: $params"); // Debug print

//     try {
//       var res = await conn.execute(query, params);
//       print("Affected rows: ${res.affectedRows}"); // Debug print
//     } catch (e) {
//       print("Error executing query: $e"); // Debug print
//     } finally {
//       await conn.close();
//     }
//   }

//   String getAdditionalInfo() {
//     switch (selectedPurpose) {
//       case 'Research Purpose':
//         return "Duration: ${durationController.text}, Objective: ${objectiveController.text}, Datasets: ${datasetsCountController.text}, Workplace: ${workPlaceController.text}";
//       case 'Study Purpose':
//         return "Academic Background: ${academicBackgroundController.text}, Objective: ${studyObjectiveController.text}, Datasets: ${studyDatasetsCountController.text}, Studying Place: ${currentlyStudyingPlaceController.text}";
//       case 'Publication Purpose':
//         return "Publication Name: ${publicationNameController.text}, Research Area: ${researchAreaController.text}, Datasets: ${publicationDatasetsCountController.text}";
//       default:
//         return "";
//     }
//   }

//   void showNotifications() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false
//     );

//     await conn.connect();

//     var res = await conn.execute(
//       "SELECT * FROM request_dataset WHERE user_email = :email ORDER BY request_date DESC",
//       {"email": userEmail}
//     );

//     List<Map<String, String>> notifications = [];
//     for (final row in res.rows) {
//       Map<String, String> notification = {};
//       row.assoc().forEach((key, value) {
//         notification[key] = value ?? '';
//       });
//       notifications.add(notification);
//     }

//     await conn.close();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Notifications'),
//         content: SingleChildScrollView(
//           child: notifications.isEmpty
//               ? Text('No Notifications')
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: notifications.map((notification) => 
//                     ListTile(
//                       title: Text('Request for ${notification['data_type']}'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Status: ${notification['status']}'),
//                           Text('Purpose: ${notification['purpose']}'),
//                           Text('Date: ${notification['request_date']}'),
//                         ],
//                       ),
//                     )
//                   ).toList(),
//                 ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Close'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Request Data'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               showNotifications();
//             },
//           ),
//         ],
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
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Name: $userName",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "Email: $userEmail",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       SizedBox(height: 20),
//                       buildDropdownField("Purpose", (String? newValue) {
//                         setState(() {
//                           selectedPurpose = newValue;
//                         });
//                       }, purposes),
//                       buildDropdownField("Data Type", (String? newValue) {
//                         setState(() {
//                           selectedDataType = newValue;
//                         });
//                       }, dataTypes),
//                       if (selectedPurpose == 'Research Purpose') ...[
//                         buildTextField("Duration", durationController, "Duration is required"),
//                         buildTextField("Objective", objectiveController, "Objective is required"),
//                         buildTextField("Number of Datasets", datasetsCountController, "Number of datasets is required"),
//                         buildTextField("Work Place", workPlaceController, "Work place is required"),
//                       ] else if (selectedPurpose == 'Study Purpose') ...[
//                         buildTextField("Academic Background", academicBackgroundController, "Academic background is required"),
//                         buildTextField("Objective", studyObjectiveController, "Objective is required"),
//                         buildTextField("Number of Datasets", studyDatasetsCountController, "Number of datasets is required"),
//                         buildTextField("Currently Studying Place", currentlyStudyingPlaceController, "Studying place is required"),
//                       ] else if (selectedPurpose == 'Publication Purpose') ...[
//                         buildTextField("Name of Publication", publicationNameController, "Publication name is required"),
//                         buildTextField("Research Area", researchAreaController, "Research area is required"),
//                         buildTextField("Number of Datasets", publicationDatasetsCountController, "Number of datasets is required"),
//                       ],
//                       const SizedBox(height: 10),
//                       Container(
//                         height: 55,
//                         width: MediaQuery.of(context).size.width * .9,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: const Color.fromARGB(255, 5, 87, 125),
//                         ),
//                         child: TextButton(
//                           onPressed: () {
//                             if (formKey.currentState!.validate()) {
//                               requestData().whenComplete(() {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text("Request Successful")),
//                                 );
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const OptionalPanel(userId: '',)),
//                                 );
//                               });
//                             }
//                           },
//                           child: const Text(
//                             "Request",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16.0,
//                               color: Colors.white,
//                             ),
//                           ),
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

//   Widget buildTextField(String label, TextEditingController controller, String validationMessage) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.0,
//             color: Colors.white,
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white.withOpacity(.8),
//           ),
//           child: TextFormField(
//             controller: controller,
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return validationMessage;
//               }
//               return null;
//             },
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildDropdownField(String label, void Function(String?) onChanged, List<String> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.0,
//             color: Colors.white,
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white.withOpacity(.8),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: label == "Purpose" ? selectedPurpose : selectedDataType,
//             onChanged: onChanged,
//             items: items.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a ${label.toLowerCase()}';
//               }
//               return null;
//             },
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }







