import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pet.dart';
import '../models/vaccine.dart';
import '../services/pet_provider.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  void _showAddVaccineDialog(BuildContext context) {
    final typeController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState) {
          return AlertDialog(
            title: const Text('Add Vaccine'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration:
                      const InputDecoration(labelText: 'Vaccine Type'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                        'Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                    IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                                const Duration(days: 365)),
                            lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today))
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    final vac = Vaccine(
                      petName: pet.name,
                      type: typeController.text,
                      date: selectedDate,
                    );
                    Provider.of<PetProvider>(context, listen: false)
                        .addVaccine(vac);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Add'))
            ],
          );
        });
      },
    );
  }

  void _callEmergency() async {
    const tel = 'tel:09123456789';
    if (await canLaunch(tel)) {
      await launch(tel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);
    final vaccines = provider.vaccinesForPet(pet.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${pet.type}'),
            Text('Age: ${pet.age}'),
            Text('Owner: ${pet.owner}'),
            const SizedBox(height: 16),
            const Text('Vaccination Schedule:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (vaccines.isEmpty) const Text('No vaccines scheduled.'),
            ...vaccines.map((v) => Text(
                '${v.type} at ${v.date.toLocal().toString().split(' ')[0]}')),
            const SizedBox(height: 16),
            const Text('Doctor Availability:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Dr. Cruz – Available'),
            const Text('Dr. Santos – Not Available'),
            const SizedBox(height: 16),
            const Text('Emergency Contacts:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Barangay Animal Rescue'),
            const Text('Municipal Agriculture Office'),
            const Text('Emergency Hotline: 09123456789'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _callEmergency,
              child: const Text('Call Emergency'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVaccineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
