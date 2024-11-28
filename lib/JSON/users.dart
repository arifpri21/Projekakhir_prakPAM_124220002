

import 'package:meta/meta.dart';
import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
    final int? usrId;
    final String? fullname;
    final String? email;
    final String usrName;
    final String password;

    Users({
        this.usrId,
        this.fullname,
        this.email,
        required this.usrName,
        required this.password,
    });

    factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        fullname: json["fullname"],
        email: json["email"],
        usrName: json["usrName"],
        password: json["usrPassword"],
    );

    Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "fullname": fullname,
        "email": email,
        "usrName": usrName,
        "usrPassword": password,
    };
}
