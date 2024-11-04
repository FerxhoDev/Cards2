import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCardMod extends StatefulWidget {
  final String categoryId;

  const AddCardMod({super.key, required this.categoryId});

  @override
  State<AddCardMod> createState() => _AddCardModState();
}

class _AddCardModState extends State<AddCardMod> {

  final TextEditingController _cardTitleController = TextEditingController();
  final TextEditingController _detalleTitleController = TextEditingController();

  var _counterTittle = "";
  var _counterDetalle = "";

  // Método para agregar una tarjeta a la subcolección de la categoría
  Future<void> _addCardToCategory() async {
    if (_cardTitleController.text.isEmpty || _detalleTitleController.text.isEmpty) {
      // Asegurarse de que los campos no estén vacíos
      print("Los campos no pueden estar vacíos");
      return;
    }

    try {
      // Agregar la tarjeta a la subcolección 'cards' de la categoría del usuario
      await FirebaseFirestore.instance
          .collection('cursos') // Subcolección de categorías
          .doc(widget.categoryId) // Documento de la categoría
          .collection('cards') // Subcolección de tarjetas
          .add({
        'titulo': _cardTitleController.text,
        'detalle': _detalleTitleController.text,
        'timestamp': FieldValue.serverTimestamp(), // Puede ser útil agregar la fecha de creación
      });

      // Cierra el modal después de agregar la tarjeta
      Navigator.pop(context);
      print('Tarjeta agregada con éxito');
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
        height: 670.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 29, 143, 131),
              Color.fromARGB(255, 74, 235, 219)
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(top: 40.h, left: 30.h, right: 30.h),
          child: Column(
            children: [
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
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
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
                      labelStyle: TextStyle(
                          color: Colors.teal[800], fontWeight: FontWeight.bold),
                      alignLabelWithHint: false,
                      floatingLabelBehavior:
                          FloatingLabelBehavior.values[2],
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
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _counterDetalle = (170 - value.length).toString();
                      });
                    },
                    maxLength: 170,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _detalleTitleController,
                    decoration: InputDecoration(
                      counterStyle: TextStyle(
                          color: Colors.teal[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      counterText: "$_counterDetalle/170",
                      labelText: 'Detalle',
                      labelStyle: TextStyle(
                          color: Colors.teal[800], fontWeight: FontWeight.bold),
                      alignLabelWithHint: false,
                      floatingLabelBehavior:
                          FloatingLabelBehavior.values[2],
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
                onPressed: _addCardToCategory,
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
            ],
          ),
        ),
      ),
    );
  }
}