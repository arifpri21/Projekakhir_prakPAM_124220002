import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekakhirpam_124220134/componen/buttonsignup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projekakhirpam_124220134/JSON/users.dart';
import 'package:projekakhirpam_124220134/componen/button.dart';
import 'package:projekakhirpam_124220134/componen/color.dart';
import 'package:projekakhirpam_124220134/views/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Profile extends StatefulWidget {
  final Users? profile;
  Profile({super.key, this.profile});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _selectedCurrency = 'USD';
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'JPY': 110.0,
    'IDR': 15000.0,
    'GBP': 0.75,
  };
  final double _basePrice = 10.0;

  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadProfileImage(); // Muat foto profil
    _loadPremiumStatus(); // Muat status premium
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'subscription_channel',
      'Subscription Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Subscription Successful',
      'You are now a Premium User! Enjoy exclusive content and features.',
      notificationDetails,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfileImage(pickedFile.path); // Simpan path foto ke SharedPreferences
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');

    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    setState(() {
      _isSubscribed = isPremium;
    });
  }

  double _convertPrice(String currency) {
    return _basePrice * (_currencyRates[currency] ?? 1.0);
  }

  Future<void> _showSubscriptionDialog() async {
    String selectedCurrency = _selectedCurrency;
    double convertedPrice = _convertPrice(selectedCurrency);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Subscription Plan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Access premium features and content by subscribing to our plan.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: _currencyRates.keys.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCurrency = value!;
                        convertedPrice = _convertPrice(selectedCurrency);
                      });
                    },
                  ),
                  Text(
                    "Price: ${convertedPrice.toStringAsFixed(2)} $selectedCurrency",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isSubscribed = true;
                    });
                    await _savePremiumStatus(true); // Simpan status premium
                    Navigator.of(context).pop();
                    _showNotification(); // Trigger notification
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Subscribed successfully! Enjoy premium access.")),
                    );
                  },
                  child: const Text("Subscribe Now"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile', style: TextStyle(color: primaryColor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 77,
                    child: CircleAvatar(
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage("assets/no_user.jpg") as ImageProvider,
                      radius: 75,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.profile?.usrName ?? "",
                  style: const TextStyle(fontSize: 28, color: primaryColor),
                ),
                Text(
                  widget.profile?.email ?? "",
                  style: const TextStyle(fontSize: 17, color: Colors.grey),
                ),

                // Subscription Button
                if (!_isSubscribed)
                  Button(
                    label: "Upgrade Premium",
                    press: _showSubscriptionDialog,
                  )
                else
                  const Text(
                    "Premium User",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                
                ListTile(
                  leading: const Icon(Icons.account_circle, size: 30),
                  subtitle: Text(widget.profile?.usrName ?? ""),
                  title: const Text("Username"),
                ),
                ListTile(
                  leading: const Icon(Icons.email, size: 30),
                  subtitle: Text(widget.profile?.email ?? ""),
                  title: const Text("Email"),
                ),
                const SizedBox(height: 20),

                SizedBox(height: 150),
                
                Button2(
                  label: "SIGN UP",
                  press: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
