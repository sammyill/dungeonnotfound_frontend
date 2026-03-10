import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/characters_panel.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_hero_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder portraitFinder(String assetName) {
    return find.byWidgetPredicate((widget) {
      if (widget is! Image) {
        return false;
      }
      final imageProvider = widget.image;
      return imageProvider is AssetImage &&
          imageProvider.assetName == assetName;
    });
  }

  HeroDataSRD buildHero({
    required String id,
    required String name,
    required int hp,
    required int currentHp,
    required int currentExp,
    required int level,
    required String imageUrl,
    required String imagePortrait,
  }) {
    return HeroDataSRD(
      id: id,
      name: name,
      imageUrl: imageUrl,
      imagePortrait: imagePortrait,
      characterClass: 'tester',
      stats: HeroStatsSRD(
        hp: hp,
        currentHp: currentHp,
        currentExp: currentExp,
        level: level,
        strength: 10,
        dexterity: 10,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      ),
      inventory: const HeroInventorySRD(
        currency: CurrencyData(),
        equippedSlots: <String, String?>{},
        items: <InventoryItemData>[],
      ),
      abilities: const HeroAbilitiesSRD(abilityList: <AbilityDataSRD>[]),
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester, {
    required List<HeroDataSRD> heroes,
    required HeroDataSRD selectedHero,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final heroById = <String, HeroDataSRD>{
      for (final hero in heroes) hero.id: hero,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              height: 1200,
              child: CharactersPanelSRD(
                hero: selectedHero,
                heroIds: heroes.map((hero) => hero.id).toList(growable: false),
                heroById: (heroId) => heroById[heroId]!,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CharactersPanelSRD status cards', () {
    final heroOne = buildHero(
      id: 'hero_1',
      name: 'Arden',
      hp: 100,
      currentHp: 60,
      currentExp: 250,
      level: 2,
      imageUrl: 'assets/images/paladinfullbody.webp',
      imagePortrait: 'assets/images/paladinportrait.png',
    );
    final heroTwo = buildHero(
      id: 'hero_2',
      name: 'Lyra',
      hp: 150,
      currentHp: 90,
      currentExp: 600,
      level: 5,
      imageUrl: 'assets/images/clericfullbody.webp',
      imagePortrait: 'assets/images/clericportrait.png',
    );
    final heroMax = buildHero(
      id: 'hero_3',
      name: 'Nia',
      hp: 120,
      currentHp: 120,
      currentExp: 47000,
      level: 20,
      imageUrl: 'assets/images/wizardfullbody.webp',
      imagePortrait: 'assets/images/wizardportrait.png',
    );

    testWidgets('renders health and exp cards for the selected hero', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        heroes: [heroOne, heroTwo],
        selectedHero: heroOne,
      );

      expect(find.text('Health'), findsOneWidget);
      expect(find.text('EXP'), findsOneWidget);
      expect(find.text('60/100'), findsOneWidget);
      expect(find.text('250/600'), findsOneWidget);
      expect(find.text('Arden lv.2'), findsOneWidget);
    });

    testWidgets('updates health and exp when switching heroes', (tester) async {
      await pumpPanel(
        tester,
        heroes: [heroOne, heroTwo],
        selectedHero: heroOne,
      );

      await tester.tap(portraitFinder(heroTwo.imagePortrait));
      await tester.pumpAndSettle();

      expect(find.text('Arden lv.2'), findsNothing);
      expect(find.text('Lyra lv.5'), findsOneWidget);
      expect(find.text('90/150'), findsOneWidget);
      expect(find.text('600/2100'), findsOneWidget);
    });

    testWidgets('shows max exp state with a full bar for level 20 heroes', (
      tester,
    ) async {
      await pumpPanel(tester, heroes: [heroMax], selectedHero: heroMax);

      expect(find.text('Max/Max'), findsOneWidget);

      final expFill = tester.widget<FractionallySizedBox>(
        find.byKey(const ValueKey('hero-exp-fill')),
      );
      expect(expFill.widthFactor, 1.0);
    });
  });
}
