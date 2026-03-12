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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.vaccines, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 12),
                const Text('Add Vaccine'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccine Type',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 365)),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF2E7D32), size: 20),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Scheduled Date',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(
                              selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B5E20)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_calendar,
                            color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (typeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a vaccine type.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final vac = Vaccine(
                    petName: pet.name,
                    type: typeController.text.trim(),
                    date: selectedDate,
                  );
                  Provider.of<PetProvider>(context, listen: false)
                      .addVaccine(vac);
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Schedule'),
              ),
            ],
          );
        });
      },
    );
  }

  void _callEmergency() async {
    final uri = Uri.parse('tel:09123456789');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);
    final vaccines = provider.vaccinesForPet(pet.name);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pet.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(
                          _petIcon(pet.type),
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                              icon: Icons.category_outlined,
                              label: 'Type',
                              value: pet.type),
                          const Divider(height: 20),
                          _InfoRow(
                              icon: Icons.cake_outlined,
                              label: 'Age',
                              value:
                                  '${pet.age} year${pet.age != 1 ? 's' : ''} old'),
                          const Divider(height: 20),
                          _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Owner',
                              value: pet.owner),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vaccination schedule
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('💉 Vaccination Schedule',
                          style: theme.textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () => _showAddVaccineDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (vaccines.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.event_available,
                                color: Colors.grey.shade400, size: 28),
                            const SizedBox(width: 12),
                            const Text('No vaccines scheduled yet.'),
                          ],
                        ),
                      ),
                    )
                  else
                    ...vaccines.asMap().entries.map((entry) {
                      final v = entry.value;
                      final isUpcoming =
                          v.date.isAfter(DateTime.now());
                      return Card(
                        color: isUpcoming
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFF1F8E9),
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUpcoming
                                ? const Color(0xFF1565C0)
                                    .withOpacity(0.15)
                                : const Color(0xFF2E7D32)
                                    .withOpacity(0.15),
                            child: Icon(
                              isUpcoming
                                  ? Icons.event_upcoming
                                  : Icons.check_circle,
                              color: isUpcoming
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF2E7D32),
                              size: 20,
                            ),
                          ),
                          title: Text(v.type,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(isUpcoming
                              ? 'Scheduled'
                              : 'Administered'),
                          trailing: Text(
                            v.date
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUpcoming
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // Doctor availability
                  Text('👨‍⚕️ Doctor Availability',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _DoctorTile(
                          name: 'Dr. Cruz',
                          available: true,
                        ),
                        const Divider(height: 1),
                        _DoctorTile(
                          name: 'Dr. Santos',
                          available: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Emergency contacts
                  Text('🚨 Emergency Contacts',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFFFF8E1),
                    child: Column(
                      children: [
                        _ContactTile(
                          icon: Icons.home_outlined,
                          title: 'Barangay Animal Rescue',
                          subtitle: 'Local rescue service',
                        ),
                        const Divider(height: 1),
                        _ContactTile(
                          icon: Icons.account_balance_outlined,
                          title: 'Municipal Agriculture Office',
                          subtitle: 'Government animal services',
                        ),
                        const Divider(height: 1),
                        _ContactTile(
                          icon: Icons.phone,
                          title: 'Emergency Hotline',
                          subtitle: '09123456789',
                          trailing: ElevatedButton.icon(
                            onPressed: _callEmergency,
                            icon: const Icon(Icons.call, size: 16),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVaccineDialog(context),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.vaccines),
        label: const Text('Add Vaccine'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(width: 12),
        Text('$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final String name;
  final bool available;

  const _DoctorTile({required this.name, required this.available});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            available ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          Icons.person,
          color: available ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Chip(
        label: Text(
          available ? 'Available' : 'Unavailable',
          style: TextStyle(
            color: available ? Colors.green.shade700 : Colors.red.shade700,
            fontSize: 12,
          ),
        ),
        backgroundColor:
            available ? Colors.green.shade50 : Colors.red.shade50,
        side: BorderSide(
          color: available ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE65100)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }
}
