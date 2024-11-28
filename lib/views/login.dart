import 'package:flutter/material.dart';
import 'package:projekakhirpam_124220134/JSON/users.dart';
import 'package:projekakhirpam_124220134/componen/button.dart';
import 'package:projekakhirpam_124220134/componen/color.dart';
import 'package:projekakhirpam_124220134/componen/textfield.dart';
import 'package:projekakhirpam_124220134/views/Profile.dart';
import 'package:projekakhirpam_124220134/views/Signup.dart';
import 'package:projekakhirpam_124220134/views/beranda.dart';

import 'package:encrypt/encrypt.dart' as encrypt; // Import paket encrypt
import '../SQLite/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final usrName = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;

  final db = DatabaseHelper();

  // Fungsi untuk mendekripsi password
  String decryptPassword(String encryptedText) {
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final parts = encryptedText.split(':');
  if (parts.length != 2) throw Exception('Invalid encrypted format');

  final iv = encrypt.IV.fromBase64(parts[0]);
  final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  return encrypter.decrypt(encrypted, iv: iv);
}


  // Login Method
 login() async {
  Users? usrDetails = await db.getUser(usrName.text);

  if (usrDetails != null) {
    // Dekripsi password yang disimpan di database
    String decryptedPassword = decryptPassword(usrDetails.password);

    // Bandingkan dengan password input pengguna
    if (decryptedPassword == password.text) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CalendarScreen(profile: usrDetails)),
      );
    } else {
      setState(() {
        isLoginTrue = true; // Password tidak cocok
      });
    }
  } else {
    setState(() {
      isLoginTrue = true; // Username tidak ditemukan
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "LOGIN",
                  style: TextStyle(color: primaryColor, fontSize: 40),
                ),
                Image.asset("assets/upnLogo.png"),
                InputField(
                  hint: "Username",
                  icon: Icons.account_circle,
                  controller: usrName,
                ),
                InputField(
                  hint: "Password",
                  icon: Icons.lock,
                  controller: password,
                  passwordInvisible: true,
                ),
                Button(
                  label: "LOGIN",
                  press: () {
                    login();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text("SIGN UP"),
                    ),
                  ],
                ),
                // Pesan kesalahan jika login gagal
                isLoginTrue
                    ? Text(
                        "Username or password is incorrect",
                        style: TextStyle(color: Colors.red.shade900),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
