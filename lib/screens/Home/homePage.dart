import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '¡Hola, Bienvenido!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const CupertinoSearchTextField(),
          ),
          const SizedBox(height: 16),

          // Título de cursos
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Cursos Disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contenedor para las tarjetas
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF425C5A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 40, right: 14, left: 14), // Padding para el contenedor
                child: GridView.count(
                  crossAxisCount: 2, // Número de columnas
                  crossAxisSpacing: 16.0, // Espaciado horizontal
                  mainAxisSpacing: 16.0, // Espaciado vertical
                  children: const [
                    CourseCard(courseName: 'Curso de Flutter'),
                    CourseCard(courseName: 'Curso de Dart'),
                    CourseCard(courseName: 'Curso de Firebase'),
                    CourseCard(courseName: 'Curso de Diseño UI'),
                    CourseCard(courseName: 'Curso de Matemáticas'),
                    CourseCard(courseName: 'Curso de Inglés'),
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

class CourseCard extends StatelessWidget {
  final String courseName;

  const CourseCard({Key? key, required this.courseName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              courseName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
