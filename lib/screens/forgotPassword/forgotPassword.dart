import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ForgotMyPassword extends StatefulWidget {
  const ForgotMyPassword({super.key});

  @override
  State<ForgotMyPassword> createState() => _ForgotMyPasswordState();
}

class _ForgotMyPasswordState extends State<ForgotMyPassword> {

  String email = '';
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        title: const Text('MegaNet App', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.white38,
      ),
      body: Column(
        children: [
          SizedBox(height: 100.h,),
          Center(
            child: Column(
              children: [
                Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 50.sp, color: Colors.white),),
                SizedBox(height: 50.h,),
                Text('Ingresa tu correo electronico', style: TextStyle(fontSize: 20.sp, color: Colors.white60),),
              ],
            ),
          ),
          SizedBox(height: 10.h,),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email';
                                }
                                return null;
                              },
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  focusColor: Colors.blueAccent,
                  hintText: 'Correo electronico',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h,),
          ElevatedButton(
            onPressed: (){
              if(_formKey.currentState!.validate()){
                setState(() {
                  email = emailController.text;
                });
                
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 20.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Enviar', style: TextStyle(fontSize: 20),),
          ),
        ],
      ),
    );
  }
}