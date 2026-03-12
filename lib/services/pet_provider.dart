import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/vaccine.dart';

class PetProvider extends ChangeNotifier {
  final List<Pet> _pets = [];
  final List<Vaccine> _vaccines = [];

  List<Pet> get pets => List.unmodifiable(_pets);
  List<Vaccine> get vaccines => List.unmodifiable(_vaccines);

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void addVaccine(Vaccine vac) {
    _vaccines.add(vac);
    notifyListeners();
  }

  List<Vaccine> vaccinesForPet(String petName) {
    return _vaccines.where((v) => v.petName == petName).toList();
  }

  /// Vaccines happening within next day
  List<Vaccine> upcomingVaccines() {
    final now = DateTime.now();
    return _vaccines.where((v) {
      final diff = v.date.difference(now).inDays;
      return diff >= 0 && diff <= 1;
    }).toList();
  }
}
