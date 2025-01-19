import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Crear usuario en Firebase Authentication
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userId = userCredential.user?.uid;

        // Crear documento en Firestore bajo la colección 'users'
        if (userId != null) {
          await _firestore.collection('users').doc(userId).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'point': 0, // Campo point inicializado en 0
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado con éxito')),
        );

        // Redirige al inicio de sesión después del registro
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black, // Establece el color de fondo aquí
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo de la aplicación
              Center(
                child: Image.asset(
                  'assets/images/LogoBBFs.png',
                  width: 350, // Ajusta el ancho del logo
                  height: 250, // Ajusta la altura del logo
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombres '),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Registrar Usuario'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: Size(
                      MediaQuery.of(context).size.width * 0.9, 50), // Botón grande
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   Future<void> _registerUser() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Crear usuario en Firebase Authentication
//         await _auth.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Usuario registrado con éxito')),
//         );

//         // Redirige al inicio de sesión después del registro
//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Registro de Usuario'),
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.black, // Establece el color de fondo aquí        
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//                           // Logo de la aplicación
//             Center(
//               child: Image.asset(
//                 'assets/images/LogoBBFs.png',
//                 width: 350, // Ajusta el ancho del logo
//                 height: 250, // Ajusta la altura del logo
//               ),
//             ),
//             const SizedBox(height: 20),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Nombre'),
//                 style: TextStyle(color: Colors.white), // Color del texto que se escribe
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Por favor, ingrese su nombre';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Correo Electrónico'),
//                 style: TextStyle(color: Colors.white), // Color del texto que se escribe
//                 validator: (value) {
//                   if (value == null || !value.contains('@')) {
//                     return 'Ingrese un correo válido';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'Contraseña'),
//                 style: TextStyle(color: Colors.white), // Color del texto que se escribe
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.length < 6) {
//                     return 'La contraseña debe tener al menos 6 caracteres';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 50),
//               ElevatedButton(
//                 onPressed: _registerUser,
//                 child: Text('Registrar Usuario'),
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8), // Ajusta el redondeo aquí (menor valor = menos redondeo)
//                   ),
//                   fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 50), // 80% del ancho y 50px de altura
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
