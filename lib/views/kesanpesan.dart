import 'package:flutter/material.dart';
import 'package:projekakhirpam_124220134/JSON/users.dart';

class Kesanpesan extends StatefulWidget {
  final Users? profile;
  const Kesanpesan({super.key, this.profile});

  @override
  State<Kesanpesan> createState() => _KesanpesanState();
}

class _KesanpesanState extends State<Kesanpesan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,),
    );
  }
}