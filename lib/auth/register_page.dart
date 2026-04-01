import "package:flutter/material.dart";
import "dart:convert";
import "package:android_id/android_id.dart";
import "package:qi_app_refact/config/endpoints.dart";
import "./login_page.dart";
import "../component/my_button.dart";
import "../component/my_textfield.dart";
import "package:flutter/services.dart";
import "../core/network/dio_client.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nrpController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final defPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  Future<String?> _getAndroidId() async {
    const androidIdPlugin = AndroidId();
    return await androidIdPlugin.getId();
  }

  Future<void> signUpUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final nrp = nrpController.text;
    final name = nameController.text;
    final password = passwordController.text;
    final defPassword = defPasswordController.text;
    final androidID = await _getAndroidId();

    final data = {
      "nrp": nrp,
      "name": name,
      "password": password,
      "def_password": defPassword,
      "androidID": androidID,
    };

    try {
      final dioClient = DioClient();
      final response = await dioClient.dio.post(Endpoint.register, data: data);

      final responseData = response.data;

      if (response.statusCode == 200) {
        if (responseData["status"] == "already_registered") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perangkat sudah terdaftar!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (responseData["status"] == "success") {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Registrasi berhasil!")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Registrasi gagal!")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("Register")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.person_add, size: 90),
                  const SizedBox(height: 30),

                  MyTextField(
                    controller: nrpController,
                    hintText: "NRP",
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.person,
                    validator: (val) =>
                        val == null || val.isEmpty ? "NRP wajib diisi" : null,
                  ),

                  MyTextField(
                    controller: nameController,
                    hintText: "Nama Lengkap",
                    prefixIcon: Icons.badge,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Nama wajib diisi" : null,
                  ),

                  MyTextField(
                    controller: defPasswordController,
                    hintText: "Default Password",
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val == null || val.isEmpty
                        ? "Default password wajib diisi"
                        : null,
                  ),

                  MyTextField(
                    controller: passwordController,
                    hintText: "Password Baru",
                    obscureText: !_isPasswordVisible,
                    prefixIcon: Icons.lock,
                    suffixIcon: _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    validator: (val) => val != null && val.length < 6
                        ? "Minimal 6 karakter"
                        : null,
                    onChanged: (_) {
                      setState(() {}); // Update UI jika perlu
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        label: Text(
                          _isPasswordVisible ? "Sembunyikan" : "Tampilkan",
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  MyButton(onTap: () => signUpUser(context), text: "Sign Up"),

                  const SizedBox(height: 20),

                  FutureBuilder<String?>(
                    future: _getAndroidId(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Gagal mendapatkan Android ID");
                      } else {
                        final id = snapshot.data ?? "Tidak tersedia";
                        return GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("ID disalin ke clipboard"),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Device ID: $id",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
