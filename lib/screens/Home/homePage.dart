import 'package:cartaspg/screens/curso/addCurso.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? userName;
  String? userRole;

  Future<void> fetchUserDetails() async {
  final userDetails = await fetchUserNameAndRole();
    if (userDetails != null && mounted) {
      setState(() {
        String name = userDetails['name']!;
        // Si el nombre tiene más de 15 caracteres, lo recortamos y añadimos '...'
        userName = name.length > 15 ? '${name.substring(0, 15)}...' : name;
        userRole = userDetails['role'];
      });
    }
  }


  void _checkCurrentUser() async {
  final User? user = _auth.currentUser;
  if (user != null) {
    // Usuario ya está autenticado, navega a HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goNamed('HomePage');
    });
  }
}
  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    _checkCurrentUser();
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

  Future<void> _logout(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay ningún usuario logueado.'),
          ),
        );
      }
      return; // Salir de la función si no hay usuario logueado
    }

    try {
      // Desconectar la cuenta de Google solo si el usuario está logueado con Google
      if (FirebaseAuth.instance.currentUser?.providerData.any((provider) => provider.providerId == 'google.com') ?? false) {
        await GoogleSignIn().disconnect();
      }
      
      // Cierra la sesión de Firebase
      await FirebaseAuth.instance.signOut();

      // Después de cerrar sesión, redirige al login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente.'),
          ),
        ); // Cambia 'Login' por el nombre de tu ruta de inicio de sesión
      }
    } catch (e) {
      // Manejo de errores
      if (mounted) {
        String errorMessage = e.toString(); // Convertir el error a cadena
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $errorMessage'),
          ),
        );
      }
    }
  }

  // Función para obtener los cursos en tiempo real desde Firestore
   Stream<List<Map<String, dynamic>>> fetchCoursesStream() {
    return FirebaseFirestore.instance
        .collection('cursos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final courseData = doc.data();
              courseData['id'] = doc.id; // Agregamos el ID del documento para referencia
              return courseData;
            }).toList());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text('Ined Corral Grande', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.sp),),
                SizedBox(width: 70.w,),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    _logout(context);
                    context.goNamed('login'); // Cambia 'login' por el nombre de tu ruta de inicio de sesión
                  },
                ),
              ],
            ),
            // Saludo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    '¡Hola, ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userName != null)
                  Text(
                    '$userName 👋',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text('Cargando...'),
                ],
              ),
            ),
            const SizedBox(height: 16),
        
            // Barra de búsqueda
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSearchTextField(),
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
                      top: 40, right: 14, left: 14),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: fetchCoursesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay cursos disponibles.'));
                      }

                      final courses = snapshot.data!;
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return CourseCard(courseName: course['namecurso'], idCourse: course['id'],);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: userRole == 'Administrador'
          ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                  heroTag: 'Usuarios',
                  backgroundColor: const Color.fromARGB(255, 153, 118, 2),
                  onPressed: () {
                    context.go('/homePage/users');
                  },
                  icon: const Icon(Icons.group_add_outlined, color: Colors.white,),
                  label: const Text('Usuario', style: TextStyle(color: Colors.white),),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton.extended(
                  heroTag: 'Cursos',
                  backgroundColor: const Color.fromARGB(255, 153, 118, 2),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => const AddCurso(),
                      isScrollControlled: true,
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white,),
                  label: const Text('Crear Curso', style: TextStyle(color: Colors.white),),
                ),
            ],
          )
          : userRole == 'Profesor'
              ? FloatingActionButton.extended(
                  heroTag: 'CrearCurso',
                  backgroundColor: const Color.fromARGB(255, 153, 118, 2),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => const AddCurso(),
                      isScrollControlled: true,
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white,),
                  label: const Text('Crear Curso', style: TextStyle(color: Colors.white),),
                )
          : null,
    );
  }
}

class CourseCard extends StatelessWidget {
    final String courseName;
    final String idCourse;
  const CourseCard({Key? key, required this.courseName, required this.idCourse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/homePage/detalleCurso/$idCourse') ,
      child: Card(
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
      ),
    );
  }
}
