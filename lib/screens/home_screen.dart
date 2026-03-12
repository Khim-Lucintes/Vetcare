import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../services/pet_provider.dart';
import 'pet_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _reminderShown = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForReminders());
  }

  void _checkForReminders() {
    final provider = Provider.of<PetProvider>(context, listen: false);
    final upcoming = provider.upcomingVaccines();
    if (upcoming.isNotEmpty && !_reminderShown) {
      final vac = upcoming.first;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Reminder: ${vac.petName} has a vaccination due very soon.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ));
      _reminderShown = true;
    }
  }

  void _showAddPetDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final ageController = TextEditingController();
    final ownerController = TextEditingController();
    String selectedType = 'Dog';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pets, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                const Text('Add New Pet'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Pet Type',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Dog', child: Text('🐕 Dog')),
                      DropdownMenuItem(value: 'Cat', child: Text('🐈 Cat')),
                      DropdownMenuItem(value: 'Bird', child: Text('🐦 Bird')),
                      DropdownMenuItem(
                          value: 'Rabbit', child: Text('🐰 Rabbit')),
                      DropdownMenuItem(
                          value: 'Other', child: Text('🐾 Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedType = val);
                        typeController.text = val;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ownerController,
                    decoration: const InputDecoration(
                      labelText: 'Owner Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a pet name.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final pet = Pet(
                    name: nameController.text.trim(),
                    type: selectedType,
                    age: int.tryParse(ageController.text) ?? 0,
                    owner: ownerController.text.trim(),
                  );
                  Provider.of<PetProvider>(context, listen: false).addPet(pet);
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Add Pet'),
              ),
            ],
          );
        });
      },
    );
  }

  IconData _petIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.catching_pokemon;
      case 'bird':
        return Icons.flutter_dash;
      default:
        return Icons.cruelty_free;
    }
  }

  Color _petColor(int index) {
    const colors = [
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFE65100),
      Color(0xFF00695C),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);
    final allPets = provider.pets;
    final pets = _searchQuery.isEmpty
        ? allPets
        : allPets
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.owner.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              backgroundColor: Colors.white.withOpacity(0.2),
              label: Text(
                '${allPets.length} pet${allPets.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (q) => setState(() => _searchQuery = q),
              decoration: InputDecoration(
                hintText: 'Search pets by name, type, or owner…',
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF2E7D32)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: pets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pets,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No pets match your search.'
                              : 'No pets added yet.',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first pet!',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final pet = pets[i];
                      final petVaccines =
                          provider.vaccinesForPet(pet.name);
                      final color = _petColor(i);
                      return Card(
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailsScreen(pet: pet),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      color.withOpacity(0.12),
                                  child: Icon(_petIcon(pet.type),
                                      color: color, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${pet.type} · ${pet.age} yr${pet.age != 1 ? 's' : ''} old',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 12,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            pet.owner,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.vaccines,
                                              size: 12, color: color),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${petVaccines.length}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: color,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(Icons.chevron_right,
                                        color: Colors.grey.shade400),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
    );
  }
}
