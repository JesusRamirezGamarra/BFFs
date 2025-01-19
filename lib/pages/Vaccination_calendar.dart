import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VaccinationCalendar extends StatefulWidget {
  @override
  _VaccinationCalendarState createState() => _VaccinationCalendarState();
}

class _VaccinationCalendarState extends State<VaccinationCalendar> {
  final CollectionReference _vaccinationRef = FirebaseFirestore.instance
      .collection('vaccinations')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('events');

  Future<void> _addVaccinationDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TextEditingController _titleController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Vacuna/Evento"),
            content: TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Nombre de la vacuna"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Guardar"),
              ),
            ],
          );
        },
      );

      if (_titleController.text.isNotEmpty) {
        final event = {
          "date": selectedDate.toIso8601String(),
          "title": _titleController.text,
          "timestamp": Timestamp.now(), // Para ordenar por fecha de creación
        };

        // Guarda el evento en Firebase
        await _vaccinationRef.add(event);

        // Actualiza la interfaz de usuario
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendario de Vacunación"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVaccinationDate,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vaccinationRef.orderBy('timestamp', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No hay eventos registrados."));
          }

          final vaccinationDates = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vaccinationDates.length,
            itemBuilder: (context, index) {
              final event = vaccinationDates[index];
              final String title = event['title'];
              final DateTime date = DateTime.parse(event['date']);

              return ListTile(
                title: Text(title),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
                leading: Icon(Icons.event, color: Colors.blue),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Elimina el evento de Firebase
                    await event.reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class VaccinationCalendar extends StatefulWidget {
//   @override
//   _VaccinationCalendarState createState() => _VaccinationCalendarState();
// }

// class _VaccinationCalendarState extends State<VaccinationCalendar> {
//   final List<Map<String, dynamic>> _vaccinationDates = [];

//   Future<void> _addVaccinationDate() async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (selectedDate != null) {
//       TextEditingController _titleController = TextEditingController();
//       await showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("Vacuna/Evento"),
//             content: TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: "Nombre de la vacuna"),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text("Cancelar"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("Guardar"),
//               ),
//             ],
//           );
//         },
//       );

//       if (_titleController.text.isNotEmpty) {
//         final event = {
//           "date": selectedDate,
//           "title": _titleController.text,
//         };

//         setState(() {
//           _vaccinationDates.add(event);
//         });

//         // // Programar notificación
//         // await NotificationService.showScheduledNotification(
//         //   id: _vaccinationDates.length,
//         //   title: "Recordatorio de Vacuna",
//         //   body:
//         //       "Recuerda: ${event['title']} el ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
//         //   scheduledDate: selectedDate,
//         // );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Calendario de Vacunación"),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addVaccinationDate,
//         child: Icon(Icons.add),
//       ),
//       body: ListView.builder(
//         itemCount: _vaccinationDates.length,
//         itemBuilder: (context, index) {
//           final event = _vaccinationDates[index];
//           return ListTile(
//             title: Text(event['title']),
//             subtitle: Text(DateFormat('dd/MM/yyyy').format(event['date'])),
//             leading: Icon(Icons.event, color: Colors.blue),
//           );
//         },
//       ),
//     );
//   }
// }
