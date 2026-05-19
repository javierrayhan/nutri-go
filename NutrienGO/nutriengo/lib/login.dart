import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State buat ngatur visibility password
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B9B82),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Senang\nmelihatmu lagi!',
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
                    const SizedBox(height: 20),
                    const Text(
                      'Email',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'example@email.com',
                        hintStyle: TextStyle(color: Colors.black26),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B9B82)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Password',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isPasswordHidden, // Pakai state di sini
                      decoration: InputDecoration(
                        hintText: 'admin#1234',
                        hintStyle: const TextStyle(color: Colors.black26),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B9B82)),
                        ),
                        // Ini icon buat hide/show password
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B9B82),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'MASUK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Belum punya akun? ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Daftar',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
