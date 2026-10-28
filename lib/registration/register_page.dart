import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:registration_flutter/api/user_request.dart';
import '../models/user.dart';
import 'package:registration_flutter/constant.dart' as constant;
import 'package:http/http.dart' as http;
import 'package:registration_flutter/helpers/shared_prefs_service.dart';

enum DialogType { error, warning, success }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bdateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formRegistration = GlobalKey<FormState>();
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;
  String _selectedGender = '';
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() {
        bdateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  //custom dialog
  void showCustomAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    required DialogType type,
    VoidCallback? onConfirm,
  }) {
    // 2. Tentukan warna berdasarkan 3 tipe
    Color primaryColor;
    IconData dialogIcon;

    switch (type) {
      case DialogType.error:
        primaryColor = Colors.red.shade700; // Merah untuk Error
        dialogIcon = Icons.error_outline;
        break;
      case DialogType.warning:
        primaryColor = Colors.orange.shade800; // Jingga untuk Peringatan
        dialogIcon = Icons.warning_amber_rounded;
        break;
      case DialogType.success:
        primaryColor = Colors.green.shade700; // Hijau untuk Sukses
        dialogIcon = Icons.check_circle_outline;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: primaryColor, width: 2),
          ),
          title: Row(
            children: [
              Icon(dialogIcon, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(content, style: const TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  //dialog setting URL Flutter
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
                  print('Data berhasil disimpan: $basedURLInput');
                } // Bersihkan controller
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<UserRequest> registerUser(User user) async {
    String baseIP = SharedPrefsService.getString(
      constant.Constant.KEY_IP_PREFERENCE,
    );
    if (baseIP.isEmpty) {
      showCustomAlertDialog(
        context: context,
        title: 'IP Kosong',
        content: 'IP tidak ditemukan. Silakan atur IP server terlebih dahulu!',
        type: DialogType.error,
        onConfirm: () {
          print('User menekan OK pada dialog Error');
        },
      );

      return Future.error(
        'IP server tidak ditemukan. Silakan atur IP server terlebih dahulu.',
      );
    } else {
      String baseURL = 'http://' + baseIP + constant.Constant.WS_PROJECT_NAME;
      final url = Uri.parse(baseURL + constant.Constant.USER_REGISTRATION);
      try {
        final response = await http.post(
          url,
          body: user.toJson(),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        );
        if (response.statusCode == 200) {
          return UserRequest.fromJson(response.body);
        } else {
          throw Exception('Failed to register user');
        }
      } catch (e) {
        throw Exception('Error occurred while registering user: $e');
      }
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    bdateController.dispose();
    genderController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
          key: _formRegistration,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: TextFormField(
                      controller: fullnameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintText: 'Masukkan nama lengkap sesuai KTP',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
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
                          return 'Nama Lengkap tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
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
                      controller: bdateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Lahir',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintText: 'Masukkan Tanggal Lahir',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
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
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal Lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender.isNotEmpty
                          ? _selectedGender
                          : null,
                      items: _genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue ?? '';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintText: 'Pilih Jenis Kelamin',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.male_outlined,
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
                          return 'Jenis Kelamin tidak boleh kosong';
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintText: 'Masukkan konfirmasi password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.password_outlined,
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
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi Password tidak boleh kosong';
                        }
                        if (value != passwordController.text) {
                          return 'Konfirmasi Password tidak sesuai';
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
                          Color(
                            0xFFC2410C,
                          ), // Merah Bata / Jingga Tua (Orange 700)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(
                            0.35,
                          ), // Bayangan mengikuti warna jingga
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
                        if (_formRegistration.currentState!.validate()) {
                          // Lakukan proses registrasi di sini
                          User user = User(
                            user_fullname: fullnameController.text,
                            user_email: emailController.text,
                            user_birthdate: bdateController.text,
                            user_gender: _selectedGender,
                            user_password: passwordController.text,
                          );
                          UserRequest submitUser = await registerUser(user);
                          if (submitUser.code == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selamat datang, ${user.user_fullname}, ${submitUser.status}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(
                                  0xFF10B981,
                                ), // Warna Merah Bata
                                behavior: SnackBarBehavior
                                    .floating, // Tetap melayang agar modern
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Lekukan sudut yang minimalis
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                duration: const Duration(
                                  seconds: 2,
                                ), // Tampil singkat saja (2 detik)
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Registrasi gagal. Silakan coba lagi.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(
                                  0xFFEF4444,
                                ), // Warna Merah
                                behavior: SnackBarBehavior
                                    .floating, // Tetap melayang agar modern
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Lekukan sudut yang minimalis
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                duration: const Duration(
                                  seconds: 2,
                                ), // Tampil singkat saja (2 detik)
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
