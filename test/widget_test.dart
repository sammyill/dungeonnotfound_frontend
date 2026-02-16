import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_models.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/characters_panel.dart';

void main() {
  HeroDataSRD buildHero({
    required String mainHandType,
    String? offHandEquippedId,
  }) {
    return HeroDataSRD(
      id: 'hero-1',
      name: 'Arden',
      imageUrl: 'assets/images/missing_fullbody.webp',
      imagePortrait: 'assets/images/missing_portrait.png',
      characterClass: 'paladin',
      stats: const {
        'hpbaseline': 140,
        'hpcurrent': 120,
        'level': 6,
        'strength': 16,
        'dexterity': 12,
        'constitution': 15,
        'intelligence': 10,
        'wisdom': 11,
        'charisma': 9,
      },
      inventory: {
        'currency': {'gp': 250, 'sp': 8, 'cp': 14},
        'equippedSlots': {
          'mainHand': 'itm_main',
          'offHand': offHandEquippedId,
          'armor': 'itm_armor',
        },
        'items': [
          {
            'id': 'itm_main',
            'name': 'Main Weapon',
            'image': 'assets/items/missing_main.png',
            'quantity': 1,
            'objectType': mainHandType,
            'description': 'Primary weapon',
          },
          {
            'id': 'itm_off',
            'name': 'Offhand Shield',
            'image': 'assets/items/missing_off.png',
            'quantity': 1,
            'objectType': 'onehand',
            'description': 'Off hand defense',
          },
          {
            'id': 'itm_armor',
            'name': 'Armor',
            'image': 'assets/items/missing_armor.png',
            'quantity': 1,
            'objectType': 'armor',
            'description': 'Body armor',
          },
          {
            'id': 'itm_potion',
            'name': 'Potion',
            'image': 'assets/items/missing_potion.png',
            'quantity': 2,
            'objectType': 'consumable',
            'description': 'Healing potion',
          },
        ],
      },
      abilities: const {
        'skills': ['Slash'],
      },
    );
  }

  Future<void> pumpInventory(
    WidgetTester tester, {
    required HeroDataSRD hero,
    double width = 420,
    double height = 520,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: HeroInventory(hero: hero),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('HeroInventory shows money bar values', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'onehand', offHandEquippedId: 'itm_off'),
    );

    expect(find.text('INVENTORY'), findsOneWidget);
    expect(find.text('GP 250'), findsOneWidget);
    expect(find.text('SP 8'), findsOneWidget);
    expect(find.text('CP 14'), findsOneWidget);
  });

  testWidgets('HeroInventory shows equipped slot labels and names', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'onehand', offHandEquippedId: 'itm_off'),
    );

    expect(find.text('Main Hand'), findsOneWidget);
    expect(find.text('Off Hand'), findsOneWidget);
    expect(find.text('Armor'), findsWidgets);

    expect(find.text('Main Weapon'), findsWidgets);
    expect(find.text('Offhand Shield'), findsWidgets);
    expect(find.text('Armor'), findsWidgets);
  });

  testWidgets('Two-handed main hand blocks off hand', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'twohand', offHandEquippedId: 'itm_off'),
    );

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Two-Handed'), findsOneWidget);
  });

  testWidgets('Items list shows all items and equipped badges', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'onehand', offHandEquippedId: 'itm_off'),
    );

    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Main Weapon'), findsWidgets);
    expect(find.text('Offhand Shield'), findsWidgets);
    expect(find.text('Potion'), findsOneWidget);

    // Equipped items: main hand, off hand, armor.
    expect(find.text('Equipped'), findsNWidgets(3));
  });

  testWidgets('Missing item images fall back to icon and do not crash', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'onehand', offHandEquippedId: 'itm_off'),
    );

    expect(find.byIcon(Icons.handyman), findsWidgets);
    expect(find.byIcon(Icons.medication), findsOneWidget);
  });

  testWidgets('HeroInventory handles tighter height without throwing', (
    WidgetTester tester,
  ) async {
    await pumpInventory(
      tester,
      hero: buildHero(mainHandType: 'onehand', offHandEquippedId: 'itm_off'),
      height: 260,
    );

    expect(tester.takeException(), isNull);
  });
}
