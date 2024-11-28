import 'package:flutter/material.dart';
import 'package:projekakhirpam_124220134/JSON/users.dart';
import 'package:projekakhirpam_124220134/componen/button.dart';
import 'package:projekakhirpam_124220134/componen/color.dart';
import 'package:projekakhirpam_124220134/componen/textfield.dart';
import 'package:projekakhirpam_124220134/views/login.dart';

import 'package:encrypt/encrypt.dart' as encrypt; // Import paket encrypt
import '../SQLite/database_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final fullname = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final db = DatabaseHelper();

  // Fungsi untuk mengenkripsi password
 String encryptPassword(String plainText) {
  try {
    // Kunci AES 32 karakter
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    
    // Buat IV baru untuk setiap proses enkripsi
    final iv = encrypt.IV.fromLength(16); 
    
    // Buat encrypter AES
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    // Enkripsi teks
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Gabungkan IV dan teks terenkripsi dalam format "iv_base64:encrypted_base64"
    return "${iv.base64}:${encrypted.base64}";
  } catch (e) {
    print("Encryption failed: $e");
    return ""; // Return string kosong jika ada error
  }
}


 signUp() async {
  if (password.text != confirmPassword.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  // Enkripsi password
  String encryptedPassword = encryptPassword(password.text);

  // Simpan data pengguna
  var res = await db.createUser(
    Users(
      fullname: fullname.text,
      email: email.text,
      usrName: usrName.text,
      password: encryptedPassword, // Simpan password terenkripsi
    ),
  );

  if (res > 0) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Register New Account",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputField(hint: "Full name", icon: Icons.person, controller: fullname),
                InputField(hint: "Email", icon: Icons.email, controller: email),
                InputField(hint: "Username", icon: Icons.account_circle, controller: usrName),
                InputField(
                  hint: "Password",
                  icon: Icons.lock,
                  controller: password,
                  passwordInvisible: true,
                ),
                InputField(
                  hint: "Re-enter password",
                  icon: Icons.lock,
                  controller: confirmPassword,
                  passwordInvisible: true,
                ),
                const SizedBox(height: 10),
                Button(
                  label: "SIGN UP",
                  press: () {
                    signUp();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text("LOGIN"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
