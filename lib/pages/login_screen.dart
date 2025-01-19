// import 'package:appvotacionesg10/pages/home_page.dart';
// import 'package:appvotacionesg10/pages/register_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   Future<void> _loginUser() async {
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Inicio de sesión exitoso')));
//         // Redirige al HomePage
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Inicio de Sesión')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Correo Electrónico'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Contraseña'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loginUser,
//               child: Text('Iniciar Sesión'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => RegisterScreen()),
//                 );
//               },
//               child: Text('¿No tienes una cuenta? Regístrate'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:appvotacionesg10/pages/home_page.dart';
import 'package:appvotacionesg10/pages/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

Future<void> _loginUser() async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inicio de sesión exitoso')),
    );

    // Redirige al HomePage después de un inicio de sesión exitoso
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  } on FirebaseAuthException catch (e) {
    // Manejo de errores de Firebase Authentication
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No se encontró una cuenta con este correo electrónico.';
        break;
      case 'wrong-password':
        errorMessage = 'La contraseña es incorrecta. Inténtalo nuevamente.';
        break;
      case 'invalid-email':
        errorMessage = 'El correo electrónico ingresado no es válido.';
        break;
      case 'user-disabled':
        errorMessage =
            'Esta cuenta ha sido deshabilitada. Contacta al soporte técnico.';
        break;
      case 'too-many-requests':
        errorMessage =
            'Demasiados intentos fallidos. Por favor, inténtalo más tarde.';
        break;
      case 'operation-not-allowed':
        errorMessage =
            'El inicio de sesión con correo y contraseña no está habilitado.';
        break;
      case 'network-request-failed':
        errorMessage =
            'Error de red. Verifica tu conexión a internet e inténtalo nuevamente.';
        break;
      default:
        errorMessage = 'Ha ocurrido un error desconocido. Inténtalo más tarde.';
    }

    // Muestra el mensaje personalizado al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    // Manejo de errores generales (no relacionados con Firebase)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error inesperado: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
        centerTitle: true,
        ),
      backgroundColor: Colors.black, // Establece el color de fondo aquí        
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            // Campo de correo electrónico
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
              style: TextStyle(color: Colors.white), // Color del texto que se escribe
            ),
            // Campo de contraseña
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              style: TextStyle(color: Colors.white), // Color del texto que se escribe
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Botón de iniciar sesión
            ElevatedButton(
              onPressed: _loginUser,
              child: Text('Iniciar Sesión'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Ajusta el redondeo aquí (menor valor = menos redondeo)
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 50), // 80% del ancho y 50px de altura
                ),              
            ),
            // Botón para registrar una cuenta
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('¿No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
