import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_app/main.dart';
import 'package:vetcare_app/services/pet_provider.dart';

void main() {
  testWidgets('VetCare Home Screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen appears with VetCare title
    expect(find.text('🐾 VetCare'), findsOneWidget);
    expect(find.text('Daily Pet Care Tip'), findsOneWidget);
    expect(find.text('Your Pets (0)'), findsOneWidget);
    expect(find.text('No pets added yet'), findsOneWidget);

    // Verify that FAB exists to add pets
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Can add a new pet to the app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify initial state
    expect(find.text('Your Pets (0)'), findsOneWidget);

    // Tap the FAB to add a pet
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Add New Pet'), findsOneWidget);

    // Fill in the pet form
    await tester.enterText(find.byType(TextField).at(0), 'Buddy');
    await tester.enterText(find.byType(TextField).at(1), 'Dog');
    await tester.enterText(find.byType(TextField).at(2), '3');
    await tester.enterText(find.byType(TextField).at(3), 'John Doe');

    // Tap Add button
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify pet was added (pet count should be 1)
    expect(find.text('Your Pets (1)'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
  });
}
