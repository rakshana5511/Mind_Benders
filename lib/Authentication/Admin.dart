import 'package:coral_reef/Authentication/Login.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isAuthenticated = false;
  bool isVisible = false;
  late TabController tabController;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void adminLogin() {
    if (formKey.currentState!.validate()) {
      if (usernameController.text == "admin" &&
          passwordController.text == "admin") {
        setState(() {
          isAuthenticated = true;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Invalid username or password';
        });
      }
    }
  }

  void navigateToUserLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<List<Map<String, dynamic>>> fetchAccounts() async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );

    await conn.connect();

    var res = await conn.execute("SELECT * FROM users");

    List<Map<String, dynamic>> accounts = [];

    for (final row in res.rows) {
      accounts.add(row.assoc());
    }

    await conn.close();

    return accounts;
  }

  Future<List<Map<String, dynamic>>> fetchDatasetRequests() async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );

    await conn.connect();

    var res = await conn.execute("SELECT * FROM request_dataset ORDER BY request_date DESC");

    List<Map<String, dynamic>> requests = [];

    for (final row in res.rows) {
      requests.add(row.assoc());
    }

    await conn.close();

    return requests;
  }

  Future<void> updateDatasetRequestStatus(int requestId, String status, String reason) async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );

    await conn.connect();

    await conn.execute(
      "UPDATE request_dataset SET status = :status, reason = :reason, notification = TRUE WHERE id = :id",
      {
        "status": status,
        "reason": reason,
        "id": requestId,
      },
    );

    String message;
    if (status == 'Approved') {
      message = 'Request approved successfully';
    } else if (status == 'Rejected') {
      message = 'Request declined successfully';
    } else {
      message = 'Request reset to pending';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    await conn.close();

    setState(() {});
  }

  Future<void> deleteUserAccount(int userId) async {
    final conn = await MySQLConnection.createConnection(
      host: "10.0.2.2",
      port: 3306,
      userName: "rakshana",
      password: "root",
      databaseName: "coral_db",
      secure: false,
    );

    await conn.connect();

    await conn.execute(
      "DELETE FROM users WHERE id = :id",
      {
        "id": userId,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted successfully')),
    );

    await conn.close();

    setState(() {});
  }

  void confirmDeleteAccount(int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              deleteUserAccount(userId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void logout() {
    setState(() {
      isAuthenticated = false;
      usernameController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/coral-bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          isAuthenticated
              ? buildAdminPanel()
              : buildLoginForm(),
        ],
      ),
    );
  }

  Widget buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/assets/Admin_logo.png",
                  width: 210,
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: TextFormField(
                    controller: usernameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Username is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person, color: Colors.blue),
                      hintText: "Admin Username",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !isVisible,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      icon: const Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: adminLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: navigateToUserLogin,
                  child: const Text(
                    "Login as a User",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAdminPanel() {
    return Column(
      children: [
        AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        TabBar(
          tabs: const [
            Tab(text: 'Manage Accounts'),
            Tab(text: 'Request Data Details'),
          ],
          controller: tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ManageAccountsTab(adminState: this),
              RequestDataDetailsTab(adminState: this),
            ],
          ),
        ),
      ],
    );
  }
}

class ManageAccountsTab extends StatelessWidget {
  final _AdminState adminState;

  const ManageAccountsTab({Key? key, required this.adminState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: adminState.fetchAccounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var accounts = snapshot.data!;
        return accounts.isEmpty
            ? const Center(child: Text('No user accounts'))
            : ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  var account = accounts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(account['user_name'][0].toUpperCase()),
                      ),
                      title: Text(account['user_name']),
                      subtitle: Text(account['email']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          adminState.confirmDeleteAccount(int.parse(account['id']));
                        },
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}

class RequestDataDetailsTab extends StatelessWidget {
  final _AdminState adminState;

  const RequestDataDetailsTab({Key? key, required this.adminState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: adminState.fetchDatasetRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var requests = snapshot.data!;
        return requests.isEmpty
            ? const Center(child: Text('No dataset requests'))
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  var request = requests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      title: Text(request['user_name']),
                      subtitle: Text('${request['purpose']} - ${request['status']}'),
                      children: [
                        ListTile(title: Text('Email: ${request['user_email']}')),
                        ListTile(title: Text('Data Type: ${request['data_type']}')),
                        ListTile(title: Text('Additional Info: ${request['additional_info']}')),
                        ListTile(title: Text('Request Date: ${request['request_date']}')),
                        if (request['reason'] != null && request['reason'].isNotEmpty)
                          ListTile(title: Text('Reason: ${request['reason']}')),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (request['status'] == 'Pending') ...[
                                ElevatedButton(
                                  child: const Text('Accept'),
                                  onPressed: () => _showReasonDialog(context, request, 'Approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Decline'),
                                  onPressed: () => _showReasonDialog(context, request, 'Rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  child: Text(request['status'] == 'Approved' ? 'Change to Decline' : 'Change to Accept'),
                                  onPressed: () {
                                    String newStatus = request['status'] == 'Approved' ? 'Rejected' : 'Approved';
                                    _showReasonDialog(context, request, newStatus);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: request['status'] == 'Approved' ? Colors.red : Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Reset Status'),
                                  onPressed: () => _showReasonDialog(context, request, 'Pending'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }

  void _showReasonDialog(BuildContext context, Map<String, dynamic> request, String newStatus) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Provide Reason'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(hintText: "Enter reason here"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              adminState.updateDatasetRequestStatus(
                int.parse(request['id']),
                newStatus,
                reasonController.text,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}









// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';

// class Admin extends StatefulWidget {
//   const Admin({Key? key}) : super(key: key);

//   @override
//   State<Admin> createState() => _AdminState();
// }

// class _AdminState extends State<Admin> with SingleTickerProviderStateMixin {
//   final formKey = GlobalKey<FormState>();
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool isAuthenticated = false;
//   bool isVisible = false;
//   late TabController tabController;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   void adminLogin() {
//     if (formKey.currentState!.validate()) {
//       if (usernameController.text == "admin" &&
//           passwordController.text == "admin") {
//         setState(() {
//           isAuthenticated = true;
//           errorMessage = '';
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Invalid username or password';
//         });
//       }
//     }
//   }

//   void navigateToUserLogin() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   Future<List<Map<String, dynamic>>> fetchAccounts() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     var res = await conn.execute("SELECT * FROM users");

//     List<Map<String, dynamic>> accounts = [];

//     for (final row in res.rows) {
//       accounts.add(row.assoc());
//     }

//     await conn.close();

//     return accounts;
//   }

//   Future<List<Map<String, dynamic>>> fetchDatasetRequests() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     var res = await conn.execute("SELECT * FROM request_dataset ORDER BY request_date DESC");

//     List<Map<String, dynamic>> requests = [];

//     for (final row in res.rows) {
//       requests.add(row.assoc());
//     }

//     await conn.close();

//     return requests;
//   }

//   Future<void> updateDatasetRequestStatus(int requestId, String status) async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     await conn.execute(
//       "UPDATE request_dataset SET status = :status, notification = TRUE WHERE id = :id",
//       {
//         "status": status,
//         "id": requestId,
//       },
//     );

//     String message;
//     if (status == 'Approved') {
//       message = 'Request approved successfully';
//     } else if (status == 'Rejected') {
//       message = 'Request declined successfully';
//     } else {
//       message = 'Request reset to pending';
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );

//     await conn.close();

//     setState(() {});
//   }

//   Future<void> deleteUserAccount(int userId) async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     await conn.execute(
//       "DELETE FROM users WHERE id = :id",
//       {
//         "id": userId,
//       },
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Account deleted successfully')),
//     );

//     await conn.close();

//     setState(() {});
//   }

//   void confirmDeleteAccount(int userId) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: const Text('Are you sure you want to delete this account?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               deleteUserAccount(userId);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void logout() {
//     setState(() {
//       isAuthenticated = false;
//       usernameController.clear();
//       passwordController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'lib/assets/coral-bg.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           isAuthenticated
//               ? buildAdminPanel()
//               : buildLoginForm(),
//         ],
//       ),
//     );
//   }

//   Widget buildLoginForm() {
//     return Center(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   "lib/assets/Admin_logo.png",
//                   width: 210,
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(29),
//                   ),
//                   child: TextFormField(
//                     controller: usernameController,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return "Username is required";
//                       }
//                       return null;
//                     },
//                     decoration: const InputDecoration(
//                       icon: Icon(Icons.person, color: Colors.blue),
//                       hintText: "Admin Username",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(29),
//                   ),
//                   child: TextFormField(
//                     controller: passwordController,
//                     obscureText: !isVisible,
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return "Password is required";
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Password",
//                       icon: const Icon(Icons.lock, color: Colors.blue),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           isVisible ? Icons.visibility : Icons.visibility_off,
//                           color: Colors.blue,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             isVisible = !isVisible;
//                           });
//                         },
//                       ),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: adminLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(29),
//                     ),
//                   ),
//                   child: const Text(
//                     "LOGIN",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ),
//                 if (errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Text(
//                       errorMessage,
//                       style: const TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 TextButton(
//                   onPressed: navigateToUserLogin,
//                   child: const Text(
//                     "Login as a User",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildAdminPanel() {
//     return Column(
//       children: [
//         AppBar(
//           title: const Text('Admin Panel'),
//           backgroundColor: Colors.blue,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: logout,
//             ),
//           ],
//         ),
//         TabBar(
//           tabs: const [
//             Tab(text: 'Manage Accounts'),
//             Tab(text: 'Request Data Details'),
//           ],
//           controller: tabController,
//           labelColor: Colors.blue,
//           unselectedLabelColor: Colors.grey,
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: tabController,
//             children: [
//               ManageAccountsTab(adminState: this),
//               RequestDataDetailsTab(adminState: this),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ManageAccountsTab extends StatelessWidget {
//   final _AdminState adminState;

//   const ManageAccountsTab({Key? key, required this.adminState}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: adminState.fetchAccounts(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         var accounts = snapshot.data!;
//         return accounts.isEmpty
//             ? const Center(child: Text('No user accounts'))
//             : ListView.builder(
//                 itemCount: accounts.length,
//                 itemBuilder: (context, index) {
//                   var account = accounts[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         child: Text(account['user_name'][0].toUpperCase()),
//                       ),
//                       title: Text(account['user_name']),
//                       subtitle: Text(account['email']),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           adminState.confirmDeleteAccount(int.parse(account['id']));
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               );
//       },
//     );
//   }
// }

// class RequestDataDetailsTab extends StatelessWidget {
//   final _AdminState adminState;

//   const RequestDataDetailsTab({Key? key, required this.adminState}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: adminState.fetchDatasetRequests(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         var requests = snapshot.data!;
//         return requests.isEmpty
//             ? const Center(child: Text('No dataset requests'))
//             : ListView.builder(
//                 itemCount: requests.length,
//                 itemBuilder: (context, index) {
//                   var request = requests[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     child: ExpansionTile(
//                       title: Text(request['user_name']),
//                       subtitle: Text('${request['purpose']} - ${request['status']}'),
//                       children: [
//                         ListTile(title: Text('Email: ${request['user_email']}')),
//                         ListTile(title: Text('Data Type: ${request['data_type']}')),
//                         ListTile(title: Text('Additional Info: ${request['additional_info']}')),
//                         ListTile(title: Text('Request Date: ${request['request_date']}')),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               if (request['status'] == 'Pending') ...[
//                                 ElevatedButton(
//                                   child: const Text('Accept'),
//                                   onPressed: () {
//                                     adminState.updateDatasetRequestStatus(
//                                       int.parse(request['id']), 
//                                       'Approved'
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green,
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   child: const Text('Decline'),
//                                   onPressed: () {
//                                     adminState.updateDatasetRequestStatus(
//                                       int.parse(request['id']), 
//                                       'Rejected'
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 ),
//                               ] else ...[
//                                 ElevatedButton(
//                                   child: Text(request['status'] == 'Approved' ? 'Change to Decline' : 'Change to Accept'),
//                                   onPressed: () {
//                                     String newStatus = request['status'] == 'Approved' ? 'Rejected' : 'Approved';
//                                     adminState.updateDatasetRequestStatus(
//                                       int.parse(request['id']), 
//                                       newStatus
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: request['status'] == 'Approved' ? Colors.red : Colors.green,
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   child: const Text('Reset Status'),
//                                   onPressed: () {
//                                     adminState.updateDatasetRequestStatus(
//                                       int.parse(request['id']), 
//                                       'Pending'
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.orange,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//       },
//     );
//   }
// }















// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:flutter/material.dart';
// import 'package:mysql_client/mysql_client.dart';



// class Admin extends StatefulWidget {
//   const Admin({super.key});

//   @override
//   State<Admin> createState() => _AdminState();
// }

// class _AdminState extends State<Admin> with SingleTickerProviderStateMixin {
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool isAuthenticated = false;
//   late TabController tabController;

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   void adminLogin() {
//     if (usernameController.text == "admin" &&
//         passwordController.text == "admin") {
//       setState(() {
//         isAuthenticated = true;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid username or password')),
//       );
//     }
//   }

//   void navigateToUserLogin() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   Future<List<Map<String, dynamic>>> fetchAccounts() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     var res = await conn.execute("SELECT * FROM users");

//     List<Map<String, dynamic>> accounts = [];

//     for (final row in res.rows) {
//       accounts.add(row.assoc());
//     }

//     await conn.close();

//     return accounts;
//   }

//   Future<List<Map<String, dynamic>>> fetchDatasetRequests() async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     var res = await conn.execute("SELECT * FROM request_dataset ORDER BY request_date DESC");

//     List<Map<String, dynamic>> requests = [];

//     for (final row in res.rows) {
//       requests.add(row.assoc());
//     }

//     await conn.close();

//     return requests;
//   }

//   Future<void> updateDatasetRequestStatus(int requestId, String status) async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     await conn.execute(
//       "UPDATE request_dataset SET status = :status, notification = TRUE WHERE id = :id",
//       {
//         "status": status,
//         "id": requestId,
//       },
//     );

//     String message;
//     if (status == 'Approved') {
//       message = 'Request approved successfully';
//     } else if (status == 'Rejected') {
//       message = 'Request declined successfully';
//     } else {
//       message = 'Request reset to pending';
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );

//     await conn.close();

//     setState(() {}); // Refresh the UI
//   }

//   Future<void> deleteUserAccount(int userId) async {
//     final conn = await MySQLConnection.createConnection(
//       host: "10.0.2.2",
//       port: 3306,
//       userName: "rakshana",
//       password: "root",
//       databaseName: "coral_db",
//       secure: false,
//     );

//     await conn.connect();

//     await conn.execute(
//       "DELETE FROM users WHERE id = :id",
//       {
//         "id": userId,
//       },
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Account deleted successfully')),
//     );

//     await conn.close();

//     setState(() {});
//   }

//   void confirmDeleteAccount(int userId) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: const Text('Are you sure you want to delete this account?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               deleteUserAccount(userId);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void logout() {
//     setState(() {
//       isAuthenticated = false;
//       usernameController.clear();
//       passwordController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Panel'),
//         backgroundColor: const Color.fromARGB(255, 36, 123, 163),
//         actions: isAuthenticated
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.logout),
//                   onPressed: logout,
//                 ),
//               ]
//             : null,
//       ),
//       body: isAuthenticated
//           ? Column(
//               children: [
//                 TabBar(
//                   tabs: [
//                     Tab(text: 'Manage Accounts'),
//                     Tab(text: 'Request Data Details'),
//                   ],
//                   controller: tabController,
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: tabController,
//                     children: [
//                       ManageAccountsTab(adminState: this),
//                       RequestDataDetailsTab(adminState: this),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextFormField(
//                       controller: usernameController,
//                       decoration: const InputDecoration(labelText: 'Username'),
//                     ),
//                     TextFormField(
//                       controller: passwordController,
//                       decoration: const InputDecoration(labelText: 'Password'),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: adminLogin,
//                       child: const Text('Login'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextButton(
//                       onPressed: navigateToUserLogin,
//                       child: const Text('Login as a User'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// class ManageAccountsTab extends StatelessWidget {
//   final _AdminState adminState;

//   const ManageAccountsTab({super.key, required this.adminState});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: adminState.fetchAccounts(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         var accounts = snapshot.data!;
//         return accounts.isEmpty
//             ? const Center(child: Text('No user accounts'))
//             : ListView.builder(
//                 itemCount: accounts.length,
//                 itemBuilder: (context, index) {
//                   var account = accounts[index];
//                   return ListTile(
//                     title: Text(account['user_name']),
//                     subtitle: Text(account['email']),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         adminState.confirmDeleteAccount(int.parse(account['id']));
//                       },
//                     ),
//                   );
//                 },
//               );
//       },
//     );
//   }
// }

// class RequestDataDetailsTab extends StatelessWidget {
//   final _AdminState adminState;

//   const RequestDataDetailsTab({super.key, required this.adminState});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: adminState.fetchDatasetRequests(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         var requests = snapshot.data!;
//         return requests.isEmpty
//             ? const Center(child: Text('No dataset requests'))
//             : ListView.builder(
//                 itemCount: requests.length,
//                 itemBuilder: (context, index) {
//                   var request = requests[index];
//                   return ExpansionTile(
//                     title: Text(request['user_name']),
//                     subtitle: Text('${request['purpose']} - ${request['status']}'),
//                     children: [
//                       ListTile(title: Text('Email: ${request['user_email']}')),
//                       ListTile(title: Text('Data Type: ${request['data_type']}')),
//                       ListTile(title: Text('Additional Info: ${request['additional_info']}')),
//                       ListTile(title: Text('Request Date: ${request['request_date']}')),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           if (request['status'] == 'Pending') ...[
//                             ElevatedButton(
//                               child: const Text('Accept'),
//                               onPressed: () {
//                                 adminState.updateDatasetRequestStatus(
//                                   int.parse(request['id']), 
//                                   'Approved'
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                               ),
//                             ),
//                             ElevatedButton(
//                               child: const Text('Decline'),
//                               onPressed: () {
//                                 adminState.updateDatasetRequestStatus(
//                                   int.parse(request['id']), 
//                                   'Rejected'
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                             ),
//                           ] else ...[
//                             ElevatedButton(
//                               child: Text(request['status'] == 'Approved' ? 'Change to Decline' : 'Change to Accept'),
//                               onPressed: () {
//                                 String newStatus = request['status'] == 'Approved' ? 'Rejected' : 'Approved';
//                                 adminState.updateDatasetRequestStatus(
//                                   int.parse(request['id']), 
//                                   newStatus
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: request['status'] == 'Approved' ? Colors.red : Colors.green,
//                               ),
//                             ),
//                             ElevatedButton(
//                               child: const Text('Reset Status'),
//                               onPressed: () {
//                                 adminState.updateDatasetRequestStatus(
//                                   int.parse(request['id']), 
//                                   'Pending'
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               );
//       },
//     );
//   }
// }







