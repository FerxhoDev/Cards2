import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurdsoDetallePage extends StatefulWidget {
  final String cursoId;
  const CurdsoDetallePage({super.key, required this.cursoId});

  @override
  State<CurdsoDetallePage> createState() => _CurdsoDetallePageState();
}

class _CurdsoDetallePageState extends State<CurdsoDetallePage> {
  String? userRole; // Variable para almacenar el rol del usuario
  String cursoNombre = ''; // Variable para almacenar el nombre del curso
  
  Future<void> fetchUserDetails() async {
  final userDetails = await fetchUserNameAndRole();
    if (userDetails != null && mounted) {
      setState(() {
        userRole = userDetails['role'];
      });
    }
  }

  Future<Map<String, String>?> fetchUserNameAndRole() async {
    try {
      // Obtiene el correo del usuario actual logueado
      final String? userEmail = FirebaseAuth.instance.currentUser?.email;
      
      if (userEmail == null) {
        print('No hay un usuario logueado.');
        return null; // Retorna null si no hay un usuario logueado
      }

      // Realiza la consulta en la colección `usersperm` para obtener los campos `name` y `rol`
      final snapshot = await FirebaseFirestore.instance
          .collection('usersperm')
          .where('email', isEqualTo: userEmail)
          .limit(1) // Limita la consulta a 1 documento ya que el email es único
          .get();

      if (snapshot.docs.isEmpty) {
        print('Usuario no encontrado en la colección usersperm.');
        return null; // Retorna null si no se encuentra el documento
      }

      // Accede a los datos del primer documento encontrado
      final userDoc = snapshot.docs.first;
      final String name = userDoc['name'] as String;
      final String role = userDoc['rol'] as String;

      // Retorna el nombre y el rol como un mapa
      return {
        'name': name,
        'role': role,
      };
    } catch (e) {
      print('Error al obtener el nombre y rol del usuario: $e');
      return null; // Retorna null en caso de error
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchCursoNombre(); // Llama a la función para obtener el nombre del curso al iniciar
    fetchUserDetails(); // Llama a la función para obtener el rol del usuario al iniciar
  }

  Future<void> _fetchCursoNombre() async {
    try {
      DocumentSnapshot cursoDoc = await FirebaseFirestore.instance
          .collection('cursos')
          .doc(widget.cursoId)
          .get();

      if (cursoDoc.exists) {
        setState(() {
          cursoNombre = cursoDoc['namecurso'] ?? 'Sin nombre';
        });
      }
    } catch (e) {
      print('Error al obtener el nombre del curso: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Referencia a la colección de cursos
    final cursoRef = FirebaseFirestore.instance
        .collection('cursos')
        .doc(widget.cursoId);

    return Scaffold(
      appBar: AppBar(
        title: Text(cursoNombre.isNotEmpty ? cursoNombre : 'Cargando...'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cursoRef.collection('cards').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay tarjetas disponibles.'));
          }

          final cards = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final cardData = cards[index].data() as Map<String, dynamic>;
              final String titulo = cardData['titulo'] ?? 'Sin título';
              final String detalle = cardData['detalle'] ?? 'Sin detalle';
              final String cardId = cards[index].id; // ID de la tarjeta

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(titulo),
                  subtitle: Text(detalle),
                  onTap: () {
                    // Aquí puedes manejar la acción al tocar la tarjeta
                    // Por ejemplo, navegar a una página de edición
                    print('ID de la tarjeta: $cardId');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: userRole == 'profesor'
          ? FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 153, 118, 2),
              onPressed: () {
                null; // Aquí puedes manejar la acción al tocar el botón
              },
              icon: const Icon(Icons.add, color: Colors.white,),
              label: const Text('Crear Tarjeta', style: TextStyle(color: Colors.white),),
            )
          : null,
    );
    
  }
}
