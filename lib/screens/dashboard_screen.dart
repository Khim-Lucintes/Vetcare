import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../services/api_service.dart';
import '../services/pet_provider.dart';
import 'pet_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _tip = 'Fetching today\'s pet care tip...';

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  void _loadTip() async {
    try {
      final tip = await ApiService.fetchPetCareTip();
      setState(() => _tip = tip);
    } catch (_) {
      setState(() => _tip = 'Keep your pet healthy with regular vet check-ups!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);
    final pets = provider.pets;
    final upcoming = provider.upcomingVaccines();
    final allVaccines = provider.vaccines;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'VetCare Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: Colors.white.withOpacity(0.15),
                    ),
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
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.pets,
                          label: 'Total Pets',
                          value: '${pets.length}',
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.vaccines,
                          label: 'Vaccines',
                          value: '${allVaccines.length}',
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.notifications_active,
                          label: 'Upcoming',
                          value: '${upcoming.length}',
                          color: upcoming.isEmpty
                              ? const Color(0xFF558B2F)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pet Care Tip Card
                  _SectionTitle(title: '💡 Pet Care Tip', action: TextButton(
                    onPressed: _loadTip,
                    child: const Text('Refresh'),
                  )),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFE8F5E9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb,
                              color: Color(0xFF2E7D32), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _tip,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Vaccinations
                  _SectionTitle(title: '🗓️ Upcoming Vaccinations'),
                  const SizedBox(height: 8),
                  if (upcoming.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green.shade400, size: 28),
                            const SizedBox(width: 12),
                            const Text('No upcoming vaccinations scheduled.'),
                          ],
                        ),
                      ),
                    )
                  else
                    ...upcoming.map(
                      (v) => Card(
                        color: const Color(0xFFFFF3E0),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE65100),
                            child: Icon(Icons.warning,
                                color: Colors.white, size: 18),
                          ),
                          title: Text(v.petName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text('${v.type} — due soon'),
                          trailing: Text(
                            v.date
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100)),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Recent Pets
                  _SectionTitle(title: '🐾 Your Pets'),
                  const SizedBox(height: 8),
                  if (pets.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.pets,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(
                              'No pets added yet.\nGo to My Pets to add your first pet!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: pets.length,
                      itemBuilder: (ctx, i) {
                        final pet = pets[i];
                        final petVaccines =
                            provider.vaccinesForPet(pet.name);
                        return _PetSummaryCard(
                          pet: pet,
                          vaccineCount: petVaccines.length,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailsScreen(pet: pet),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _PetSummaryCard extends StatelessWidget {
  final Pet pet;
  final int vaccineCount;
  final VoidCallback onTap;

  const _PetSummaryCard({
    required this.pet,
    required this.vaccineCount,
    required this.onTap,
  });

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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color(0xFF2E7D32).withOpacity(0.1),
                child: Icon(
                  _petIcon(pet.type),
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pet.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${pet.type} · ${pet.age} yr${pet.age != 1 ? 's' : ''} old',
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.vaccines,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$vaccineCount vaccine${vaccineCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
