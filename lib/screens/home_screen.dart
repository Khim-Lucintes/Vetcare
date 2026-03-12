import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../models/vaccine.dart';
import '../services/api_service.dart';
import '../services/pet_provider.dart';
import 'pet_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tip = 'Loading...';
  bool _reminderShown = false;

  @override
  void initState() {
    super.initState();
    _loadPetCareTip();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForReminders());
  }

  void _loadPetCareTip() async {
    try {
      final tip = await ApiService.fetchPetCareTip();
      setState(() {
        _tip = tip;
      });
    } catch (e) {
      setState(() {
        _tip = 'Unable to fetch tip';
      });
    }
  }

  void _checkForReminders() {
    final provider = Provider.of<PetProvider>(context, listen: false);
    final upcoming = provider.upcomingVaccines();
    if (upcoming.isNotEmpty && !_reminderShown) {
      final vac = upcoming.first;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Reminder: Your pet ${vac.petName} has a vaccination tomorrow.'),
      ));
      _reminderShown = true;
    }
  }

  void _showAddPetDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final ageController = TextEditingController();
    final ownerController = TextEditingController();

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add New Pet'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Pet Name'),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Pet Type'),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: ownerController,
                    decoration: const InputDecoration(labelText: 'Owner Name'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    final pet = Pet(
                      name: nameController.text,
                      type: typeController.text,
                      age: int.tryParse(ageController.text) ?? 0,
                      owner: ownerController.text,
                    );
                    Provider.of<PetProvider>(context, listen: false).addPet(pet);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Add'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);
    final pets = provider.pets;
    final upcoming = provider.upcomingVaccines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VetCare Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet Care Tip:', style: Theme.of(context).textTheme.titleMedium),
            Text(_tip),
            const SizedBox(height: 16),
            Text('Your Pets:', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: pets.isEmpty
                  ? const Center(child: Text('No pets added yet.'))
                  : ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (ctx, i) {
                        final pet = pets[i];
                        return ListTile(
                          title: Text(pet.name),
                          subtitle: Text('${pet.type}, age ${pet.age}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailsScreen(pet: pet),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (upcoming.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upcoming Vaccinations:'),
                  ...upcoming.map(
                    (v) => Text(
                        '${v.petName} - ${v.type} on ${v.date.toLocal().toString().split(' ')[0]}'),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
