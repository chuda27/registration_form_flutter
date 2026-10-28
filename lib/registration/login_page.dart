import 'package:flutter/material.dart';
import '../helpers/shared_prefs_service.dart';
import '../constant.dart' as constant;
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();
  bool _isPasswordVisible = true;

  void _showURLDialog(BuildContext context) {
    TextEditingController basedIPController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // User harus menekan tombol untuk menutup
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Base URL'),
          content: TextField(
            controller: basedIPController,
            decoration: const InputDecoration(
              hintText: "Masukkan IP baru di sini...",
              border: OutlineInputBorder(),
            ),
            autofocus: true, // Langsung memunculkan keyboard saat dialog buka
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                // Bersihkan controller
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () async {
                String basedURLInput = basedIPController.text.trim();

                if (basedURLInput.isNotEmpty) {
                  await SharedPrefsService.setString(
                    constant.Constant.KEY_IP_PREFERENCE,
                    basedURLInput,
                  );
                } // Bersihkan controller
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (() => _showURLDialog(context)),
            iconSize: 20,
            padding: const EdgeInsets.only(right: 10),
            icon: Icon(Icons.settings, color: Colors.blueGrey),
          ),
        ],
        centerTitle: true,
        title: Text(widget.title),
        titleTextStyle: TextStyle(
          color: Colors.blue[600],
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white60,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formLoginKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Masukkan Email',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors
                        .grey[50], // Memberikan warna latar belakang halus
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),

                    // Border saat dalam kondisi normal
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),

                    // Border saat kolom sedang ditekan/aktif
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),

                    // Border saat terjadi kesalahan validasi
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Masukkan Password',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors
                        .grey[50], // Memberikan warna latar belakang halus
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),

                    // Border saat dalam kondisi normal
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),

                    // Border saat kolom sedang ditekan/aktif
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),

                    // Border saat terjadi kesalahan validasi
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF97316), // Jingga Terang (Orange 500)
                      Color(0xFFC2410C), // Merah Bata / Jingga Tua (Orange 700)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFF97316,
                      ).withOpacity(0.35), // Bayangan mengikuti warna jingga
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    // Implement login logic here
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Jika belum daftar, ',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(title: 'Halaman Registrasi'),
                        ),
                      );
                    },
                    child: const Text(
                      'Signup!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
