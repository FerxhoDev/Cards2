import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _selectedRole;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn(BuildContext context) async {
  try {
    // Cerrar sesión previa para permitir seleccionar otra cuenta
    await _googleSignIn.signOut();
    
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // Verificar si el correo está en la colección usersperm
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('usersperm')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // Verifica si el widget sigue montado antes de navegar
        if (!mounted) return;
        // El correo está permitido, navegar a la página de inicio
        context.goNamed('HomePage');
      } else {
        // El correo no está permitido
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este correo no está autorizado para iniciar sesión.'),
            backgroundColor: Colors.red,
          ),
        );
        // Cerrar sesión del usuario no autorizado
        await _auth.signOut();
      }
    }
  } catch (e) {
    print('Error durante el inicio de sesión: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocurrió un error durante el inicio de sesión.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.52,
            decoration: const BoxDecoration(
              color: Color(0xFF425C5A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 50.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'De nuevo!',
                    style: TextStyle(
                      fontSize: 40.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Text('Quien eres?',
                        style: TextStyle(
                            fontSize: 35.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: DropdownButton<String>(
                        hint: const Text('Selecciona tu rol'),
                        value: _selectedRole,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: <String>[
                          'Estudiante',
                          'Profesor',
                          'Administrador'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 100.h),
                    SignInButton(
                      Buttons.google,
                      text: 'Iniciar con Google',
                      onPressed: () => _handleSignIn(context),
                    ),
                    SizedBox(height: 30.h),
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