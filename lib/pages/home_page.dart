import 'package:appvotacionesg10/pages/login_screen.dart';
import 'package:appvotacionesg10/pages/pets_list_screen.dart';
import 'package:appvotacionesg10/pages/register_pet_screen.dart';
import 'package:appvotacionesg10/pages/vaccination_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final CollectionReference bbfRef =
      FirebaseFirestore.instance.collection('Donacion');

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Cargando...");
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Puntos GUF: 0");
            }

            final int points = snapshot.data!['point'] ?? 0;
            return Text("Puntos GUF: $points");
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'Usuario',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendario de Vacunación'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VaccinationCalendar()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Registrar Mascota'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPetScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista de Mascotas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetsListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: bbfRef.orderBy('point', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay documentos disponibles."));
          }

          final bbfDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bbfDocs.length,
            itemBuilder: (context, index) {
              final bbf = bbfDocs[index];
              return BBFCard(
                bbf: bbf,
                userId: userId,
              );
            },
          );
        },
      ),
    );
  }
}

class BBFCard extends StatefulWidget {
  final QueryDocumentSnapshot bbf;
  final String? userId;

  BBFCard({required this.bbf, required this.userId});

  @override
  _BBFCardState createState() => _BBFCardState();
}

class _BBFCardState extends State<BBFCard> {
  int assignedPoints = 0;

  Future<void> _assignPoint() async {
    try {
      if (widget.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario no autenticado.")),
        );
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId);
        final selectedDocRef = widget.bbf.reference;

        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("Usuario no encontrado.");
        }

        final userPoints = userSnapshot['point'] ?? 0;
        if (userPoints <= 0) {
          throw Exception("No tienes suficientes puntos.");
        }

        final selectedDocSnapshot = await transaction.get(selectedDocRef);
        final selectedDocPoints = selectedDocSnapshot['point'] ?? 0;

        transaction.update(userRef, {'point': userPoints - 1});
        transaction.update(selectedDocRef, {'point': selectedDocPoints + 1});

        setState(() {
          assignedPoints++;
        });

        if (assignedPoints % 10 == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "¡Has asignado $assignedPoints puntos en total a este documento!"),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int edadYYYY = widget.bbf['edad_YYYY'] ?? 0;
    final int edadMM = widget.bbf['edad_MM'] ?? 0;
    final String descripcion =
        widget.bbf['descripcion'] ?? 'Descripción no disponible';
    final String nombre = widget.bbf['nombre'] ?? 'Nombre no disponible';
    final String imageUrl = widget.bbf['url'] ?? 'https://via.placeholder.com/50';
    final int point = widget.bbf['point'] ?? 0;

    String edadTexto = '';
    if (edadYYYY > 0) {
      edadTexto += '$edadYYYY años';
    }
    if (edadMM > 0) {
      if (edadTexto.isNotEmpty) {
        edadTexto += ' ';
      }
      edadTexto += '$edadMM meses';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image,
                    size: 140, color: Colors.grey);
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descripcion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                edadTexto.isNotEmpty ? edadTexto : 'Sin información',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: _assignPoint,
              ),
              Text(
                "$point",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

            




// import 'package:appvotacionesg10/pages/login_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   // Referencia a la colección Donacion
//   final CollectionReference bbfRef =
//       FirebaseFirestore.instance.collection('Donacion');

//   @override
//   Widget build(BuildContext context) {
//     // Obtiene el UID del usuario actual
//     final String? userId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('users') // Cambia según tu estructura
//               .doc(userId)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Text("Cargando...");
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Text("Puntos GUF: 0");
//             }

//             final int points = snapshot.data!['point'] ?? 0;
//             return Text("Puntos GUF: $points");
//           },
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.person,
//                       size: 50,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     FirebaseAuth.instance.currentUser?.email ?? 'Usuario',
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Inicio'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Cerrar Sesión'),
//               onTap: () async {
//                 await FirebaseAuth.instance.signOut();
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.black,
//       body: StreamBuilder<QuerySnapshot>(
//         stream: bbfRef.orderBy('point', descending: true).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No hay documentos disponibles."));
//           }

//           final bbfDocs = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: bbfDocs.length,
//             itemBuilder: (context, index) {
//               final bbf = bbfDocs[index];
//               final int edadYYYY = bbf['edad_YYYY'] ?? 0; // Obtén el campo edad_YYYY
//               final int edadMM = bbf['edad_MM'] ?? 0; // Obtén el campo edad_MM
//               final String descripcion =
//                   bbf['descripcion'] ?? 'Descripción no disponible';
//               final String nombre =
//                   bbf['nombre'] ?? 'Nombre no disponible';
//               final String imageUrl = bbf['url'] ??
//                   'https://via.placeholder.com/50';
//               final int point = bbf['point'] ?? 0;

//               // Construir el texto de edad según los valores
//               String edadTexto = '';
//               if (edadYYYY > 0) {
//                 edadTexto += '$edadYYYY años';
//               }
//               if (edadMM > 0) {
//                 if (edadTexto.isNotEmpty) {
//                   edadTexto += ' ';
//                 }
//                 edadTexto += '$edadMM meses';
//               }

//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         imageUrl,
//                         width: 150,
//                         height: 150,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(Icons.broken_image,
//                               size: 150, color: Colors.grey);
//                         },
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Mostrar descripción encima del nombre
//                         Text(
//                           descripcion,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.brown,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           nombre,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           edadTexto.isNotEmpty ? edadTexto : 'Sin información',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontStyle: FontStyle.italic,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_upward),
//                           onPressed: () {
//                             bbf.reference.update({'point': point + 1});
//                           },
//                         ),
//                         Text(
//                           "$point",
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

