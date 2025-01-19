import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PetsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener el ID del usuario actual
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Mascotas")),
      body: userId == null
          ? const Center(child: Text("Usuario no autenticado."))
          : StreamBuilder<QuerySnapshot>(
              // Consulta para obtener las mascotas de este usuario
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('pets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay mascotas registradas."));
                }

                final pets = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return ListTile(
                      // leading: CircleAvatar(
                      //   backgroundImage: NetworkImage(pet['imageUrl']),
                      // ),
                      title: Text(pet['name']),
                      subtitle: Text(
                          "${pet['species']} - ${pet['edad_YYYY']} años y ${pet['edad_MM']} meses"),
                    );
                  },
                );
              },
            ),
    );
  }
}
