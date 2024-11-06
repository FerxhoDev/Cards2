import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'Estudiante';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425C5A),
        title: const Text('Gestión de Usuarios', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 25.w, right: 25.w, bottom: 16.h),
        child: Column(
          children: [
            _buildUserForm(),
            _buildSearchBar(),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
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


  Widget _buildUserForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 10.h),
          TextFormField(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: eneableBordT(),
              focusedBorder: focusBordT(Colors.white),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un nombre';
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),
          TextFormField(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: eneableBordT(),
              focusedBorder: focusBordT(Colors.white),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un email';
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color.fromARGB(255, 78, 110, 108), // Cambia el color de fondo aquí
            ),
            child: DropdownButtonFormField<String>(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              value: _selectedRole,
              items: ['Estudiante', 'Profesor', 'Administrador']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 153, 118, 2),
            ),
            onPressed: _submitForm,
            label: const Text('Crear Usuario', style: TextStyle(color: Colors.white),),
            icon: const Icon(Icons.person_add, color: Colors.white,),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CupertinoSearchTextField(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      placeholder: 'Buscar usuarios',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    ),
  );
}

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usersperm').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        var users = snapshot.data!.docs;
        var filteredUsers = users.where((user) =>
            user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user['email'].toLowerCase().contains(_searchQuery.toLowerCase()));

        return ListView(
          children: filteredUsers.map((user) => _buildUserListItem(user)).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ListTile(
            title: Text(data['name']),
            subtitle: Text('${data['email']} - ${data['rol']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editUser(document),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteUser(document.id),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    String email = _emailController.text;

    // Consulta a Firestore para verificar si el correo ya existe
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('usersperm')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      // Si no hay documentos, el correo no existe y se puede agregar el usuario
      await FirebaseFirestore.instance.collection('usersperm').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'rol': _selectedRole,
      });

      // Limpiar los campos del formulario
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _selectedRole = 'Estudiante';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente')),
      );
    } else {
      // Si el correo ya existe, muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo ya está registrado')),
      );
    }
  }
}


  void _editUser(DocumentSnapshot document) {
    // Implement edit functionality
  }

  void _deleteUser(String documentId) {
    // confirmación de eliminación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('usersperm').doc(documentId).delete();
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}