import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCard extends StatefulWidget {
  final String cardId;
  final String cursoId;

  UpdateCard({super.key, required this.cardId, required this.cursoId});

  @override
  _UpdateCardState createState() => _UpdateCardState();
}

class _UpdateCardState extends State<UpdateCard> {
  final _tituloController = TextEditingController();
  final _detalleController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  // Función para cargar los datos de la tarjeta
  Future<void> _fetchCardData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('cursos')
          .doc(widget.cursoId)
          .collection('cards')
          .doc(widget.cardId)
          .get();

      if (doc.exists) {
        setState(() {
          _tituloController.text = doc['titulo'];
          _detalleController.text = doc['detalle'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar los datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para actualizar los datos de la tarjeta
  Future<void> _updateCardData() async {
    try {
      await _firestore
          .collection('cursos')
          .doc(widget.cursoId)
          .collection('cards')
          .doc(widget.cardId)
          .update({
        'titulo': _tituloController.text,
        'detalle': _detalleController.text,
      });

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Tarjeta actualizada correctamente!')),
      );

      // Regresar a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      print('Error al actualizar la tarjeta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la tarjeta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425C5A),
        title: const Text('Actualizar Tarjeta', style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 4.0),
                    child: TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Título',
                        labelStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        enabledBorder: eneableBordT(),
                        focusedBorder: focusBordT(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 2.0),
                    child: TextField(
                      controller: _detalleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Detalle',
                        labelStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        enabledBorder: eneableBordT(),
                        focusedBorder: focusBordT(Colors.white),
                      ),
                      maxLines: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateCardData,
                    child: const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
    );
  }
}


  OutlineInputBorder focusBordT(Color colorBorder) {
    return OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: colorBorder),
            );
  }

  OutlineInputBorder eneableBordT() {
    return const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.white),
            );
  }