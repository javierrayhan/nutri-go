import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    // Pro-tip: ALWAYS dispose your controllers to prevent memory leaks!
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B9B82), // Sage Green Header
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Biarkan kami\nmengenalmu!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 40),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    _buildTextField("Fullname", "John Doe", _nameController),
                    const SizedBox(height: 24),
                    _buildTextField(
                      "Email",
                      "example@email.com",
                      _emailController,
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    _buildPasswordField(
                      "Password",
                      "Use unique character, letters and number",
                      _passwordController,
                      _isPasswordHidden,
                      () {
                        setState(() => _isPasswordHidden = !_isPasswordHidden);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Confirm Password Field
                    _buildPasswordField(
                      "Confirm Password",
                      "Must be same with password",
                      _confirmPasswordController,
                      _isConfirmHidden,
                      () {
                        setState(() => _isConfirmHidden = !_isConfirmHidden);
                      },
                    ),

                    const SizedBox(height: 60),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                // --- VALIDATION GATEKEEPER ---
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final pass = _passwordController.text;
                                final confirm = _confirmPasswordController.text;

                                if (name.isEmpty ||
                                    email.isEmpty ||
                                    pass.isEmpty ||
                                    confirm.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Hold up! Tolong isi semua data dulu ya bestie.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                if (pass != confirm) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Oops, password dan konfirmasi nggak match!',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                // --- SUCCESS PIPELINE (TEMBAK API) ---
                                setState(() {
                                  _isLoading = true;
                                });

                                AuthService authService = AuthService();
                                bool isSuccess = await authService.register(
                                  name,
                                  email,
                                  pass,
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (isSuccess) {
                                  // --- OPERASI PENYEGELAN BRANKAS ---
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                    'is_profile_completed',
                                    false,
                                  ); // Segel Dikunci
                                  await prefs.setString(
                                    'user_fullname',
                                    name,
                                  ); // Simpan nama untuk Prioritas 4
                                  // ----------------------------------

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pendaftaran Berhasil! Mari isi profil fisikmu.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/assessment',
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gagal Mendaftar. Email mungkin sudah terpakai.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B9B82),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'DAFTAR SEKARANG!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Masuk',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget buat Input Biasa
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B9B82)),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget buat Password
  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller,
    bool isHidden,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        TextField(
          controller: controller,
          obscureText: isHidden,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            suffixIcon: IconButton(
              icon: Icon(
                isHidden ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggle,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B9B82)),
            ),
          ),
        ),
      ],
    );
  }
}
