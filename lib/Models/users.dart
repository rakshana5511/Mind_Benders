//In here first we create the users json model
// To parse this JSON data, do
//

class Users {
  int? id;
  String username;
  String? email;
  String? contactNo;
  String? placeOfWork;
  String password;

  Users({
    this.id,
    required this.username,
    this.email,
    this.contactNo,
    this.placeOfWork,
    required this.password,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        contactNo: json["contactNo"],
        placeOfWork: json["placeOfWork"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "email": email,
        "contactNo": contactNo,
        "placeOfWork": placeOfWork,
        "password": password,
      };
}
