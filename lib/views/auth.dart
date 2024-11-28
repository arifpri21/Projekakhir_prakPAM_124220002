import 'package:flutter/material.dart';
import 'package:projekakhirpam_124220134/componen/color.dart';
import 'package:projekakhirpam_124220134/views/login.dart';
import 'package:projekakhirpam_124220134/views/Signup.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ONE-CAL",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              const Text(
                "Ingatkan Semua Orang Dengan 1 Sentuhan",
                style: TextStyle(color: Colors.grey),
              ),
              Expanded(child: Image.asset("assets/upnLogo.png")),

              //LOGIN BUTTON
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                child: Text("LOGIN",
                style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primaryColor)
                ),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
                  },
                 ),),
                 SizedBox(height: 10,),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                child: Text("REGISTER",
                style: TextStyle(color: Colors.black),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white60)
                ),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignupScreen()));
                  },
                 ),),
              
            ],
          ),
        ),
      )),
    );
  }
}