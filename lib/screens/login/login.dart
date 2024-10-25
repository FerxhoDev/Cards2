
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
 

  //Login con Correo y Contraseña
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fondo con el mensaje de bienvenida
          Container(
            height:
                MediaQuery.of(context).size.height * 0.4, // 40% de la pantalla
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
          // Espacio para el contenido: campos de texto y botones
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h), // Espacio superior
                    // Campo de texto para el correo
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h), // Espacio entre campos

                    // Campo de texto para la contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: true, // Oculta la contraseña
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Enlace de "Olvidaste tu contraseña"
                    GestureDetector(
                      onTap: () {
                        context.goNamed('ForgotPassword');
                      },
                      child: const Text(
                        'Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Botón de Iniciar Sesión
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 100.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Material(
                          color: const Color(0xFF425C5A),
                          child: InkWell(
                            onTap: () {
                              context.goNamed('HomePage');
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20.h,
                                horizontal: 10.w,
                              ),
                              child: Center(
                                child: Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Botón de Google
                    SignInButton(
                      Buttons.google,
                      text: 'Iniciar con Google',
                      onPressed: () {
                      },
                    ),
                    SizedBox(height: 30.h), // Espacio inferior

                    // Crear una cuenta
                    GestureDetector(
                      onTap: () {
                        context.goNamed('SignIn');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Crearme una cuenta',
                              style: TextStyle(color: Colors.grey)),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.grey, size: 20),
                        ],
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
