import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class AddCurso extends StatefulWidget {
  const AddCurso({super.key});

  @override
  State<AddCurso> createState() => _AddCatmodState();
}

class _AddCatmodState extends State<AddCurso> {
  bool _isCategoryCreated = false;
  String? _categoryId;
  
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cardTitleController = TextEditingController();
  final TextEditingController _detalleTitleController = TextEditingController();

  var _counterTittle = "";
  var _counterDetalle = "";
  var _counterCategory = "";
  
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para crear una categoría en Firebase y obtener su ID
Future<void> _createCurso() async {
  if (_categoryController.text.isEmpty || user == null) return;

  try {
    // Crear la categoría en la subcolección 'categories' y obtener la referencia del documento
    DocumentReference docRef = await _firestore.collection('cursos').add({
      'namecurso': _categoryController.text,
      'timestamp': FieldValue.serverTimestamp(),
      // Otros campos que desees agregar
    });

    // Mostrar mensaje de que se creó la categoría
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Curso creado con éxito'),
      ),
    );

    setState(() {
      _isCategoryCreated = true;
      _categoryId = docRef.id; // Almacena el ID de la categoría creada
    });
  } catch (e) {
    print('Error al crear la categoría: $e');
  }
}


// Método para agregar una tarjeta a la subcolección de la categoría
  Future<void> _addCardToCurso() async {
  if (_cardTitleController.text.isEmpty ||
      _detalleTitleController.text.isEmpty ||
      _categoryId == null) return;

  try {
    // Agregar la tarjeta a la subcolección 'cards' de la categoría del usuario
    await FirebaseFirestore.instance 
        .collection('cursos') // Ir a la subcolección de categorías
        .doc(_categoryId) // Usar el ID de la categoría creada
        .collection('cards')
        .add({
      'titulo': _cardTitleController.text,
      'detalle': _detalleTitleController.text,
      'timestamp': FieldValue.serverTimestamp(),// Otros campos para la tarjeta
    });

    Navigator.pop(context);
    print('Tarjeta agregada con éxito'); // Cierra el modal después de agregar la tarjeta
  } catch (e) {
    print('Error al agregar la tarjeta: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 650.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
               Color(0xFF425C5A),
               Color(0xFF425C5A),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: 40.h, left: 30.h, right: 30.h),
            child: Column(
              children: [
                //Espacio para validar si la categoría fue creada
                if (!_isCategoryCreated) ...[
                  Text('Agregar Curso',
                      style: TextStyle(
                          fontSize: 35.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 50.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding( 
                      padding: const EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _counterCategory = (18 - value.length).toString();
                          });
                        },
                        maxLength: 18,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Curso',
                          labelStyle: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
                          alignLabelWithHint: false,
                          floatingLabelBehavior: FloatingLabelBehavior.values[2],
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80.h),
                  ElevatedButton(
                    onPressed: () {
                      _createCurso();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 20.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Agregar',
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  Text('Agregar Tarjeta',
                      style: TextStyle(
                          fontSize: 35.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _counterTittle = (15 - value.length).toString();
                      });
                    },
                    maxLength: 15,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _cardTitleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      labelStyle: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
                      alignLabelWithHint: false,
                      floatingLabelBehavior: FloatingLabelBehavior.values[2],
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),

                    ),
                  ),
                ),
              ),
                  SizedBox(height: 25.h),
                  Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _counterDetalle = (500 - value.length).toString();
                      });
                    },
                    maxLength: 500,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _detalleTitleController,
                    decoration: InputDecoration(
                      counterStyle: TextStyle(color: Colors.teal[800], fontSize: 12, fontWeight: FontWeight.bold),
                      counterText: "$_counterDetalle/500",
                      labelText: 'Título',
                      labelStyle: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
                      alignLabelWithHint: false,
                      floatingLabelBehavior: FloatingLabelBehavior.values[2],
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
                  SizedBox(height: 25.h),
                  ElevatedButton(
                    onPressed: () {
                      _addCardToCurso();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 20.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Agregar Tarjeta',
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            ),
          ),
        ));
  }
}
