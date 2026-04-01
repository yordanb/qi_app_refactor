import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:android_id/android_id.dart";

import "../component/my_button.dart";
import "../component/my_textfield.dart";
import "auth_service.dart";
import "register_page.dart";
import "../screens/mainMenu.dart"; // Halaman utama

class LoginPage extends StatefulWidget {
  final bool isAlreadyRegistered;
  const LoginPage({super.key, this.isAlreadyRegistered = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nrpController = TextEditingController();
  final passwordController = TextEditingController();

  String androidID = "";
  String? fcmToken = "";
  String buttonText = "Login";
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // DBService init tidak diperlukan lagi (migrated to SecureStorage)
    if (!widget.isAlreadyRegistered) {
      await _getAndroidID();
    }
  }

  // Ambil Android ID dan cek registrasi
  Future<void> _getAndroidID() async {
    const androidIdPlugin = AndroidId();
    final id = await androidIdPlugin.getId();
    setState(() => androidID = id ?? "");

    if (id == null) return;

    bool isRegistered = await AuthService().checkAndroidID(id);
    if (!isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CardExample()),
      );
    }
  }

  // Fungsi login
  Future<void> signUserIn(
    BuildContext context, {
    required bool stateLoginAs,
  }) async {
    final nrp = nrpController.text;
    final password = passwordController.text;

    try {
      await AuthService().loginWithNRP(
        nrp: nrp,
        password: password,
        androidId: androidID,
        loginAs: stateLoginAs,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CardExample()),
      );
    } catch (_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Failed"),
          content: const Text("Invalid NRP or password."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Tombol long-press handler
  void onLongPress() {
    setState(() => buttonText = "Login as");
  }

  void onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      buttonText = "Login";
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/Aira.png",
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.85,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 50),
                Text(
                  "Welcome back Innovator,\n you've been missed!",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: nrpController,
                  hintText: "NRP",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                /// Tombol Login (normal dan login-as jika long press)
                GestureDetector(
                  onLongPress: () {
                    Future.delayed(const Duration(seconds: 5), () {
                      if (isPressed) onLongPress();
                    });
                  },
                  onLongPressStart: (_) => setState(() => isPressed = true),
                  onLongPressEnd: onLongPressEnd,
                  child: MyButton(
                    onTap: () {
                      final isLoginAs = buttonText == "Login as";
                      signUserIn(context, stateLoginAs: isLoginAs);
                    },
                    text: buttonText,
                  ),
                ),

                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Device ID: ${androidID.isNotEmpty ? androidID : "Memuat..."}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 120),
                const Text(
                  "Supported by QI Agent Plant 2 KIDE",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
