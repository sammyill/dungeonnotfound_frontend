import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/party_chat.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_chat_models.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_hero_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder assetImageFinder(String assetName) {
    return find.byWidgetPredicate((Widget widget) {
      if (widget is! Image) {
        return false;
      }
      final ImageProvider<Object> imageProvider = widget.image;
      return imageProvider is AssetImage &&
          imageProvider.assetName == assetName;
    });
  }

  HeroDataSRD buildHero({
    required String id,
    required String name,
    required String imagePortrait,
  }) {
    return HeroDataSRD(
      id: id,
      name: name,
      imageUrl: 'assets/images/paladinfullbody.webp',
      imagePortrait: imagePortrait,
      characterClass: 'tester',
      stats: const HeroStatsSRD(
        hp: 140,
        currentHp: 120,
        currentExp: 1860,
        level: 6,
        strength: 16,
        dexterity: 12,
        constitution: 15,
        intelligence: 10,
        wisdom: 11,
        charisma: 9,
      ),
      inventory: const HeroInventorySRD(
        currency: CurrencyData(),
        equippedSlots: <String, String?>{},
        items: <InventoryItemData>[],
      ),
      abilities: const HeroAbilitiesSRD(abilityList: <AbilityDataSRD>[]),
    );
  }

  Future<void> pumpPartyChat(
    WidgetTester tester, {
    required List<PartyChatInteraction> interactions,
    required List<HeroDataSRD> heroes,
    required HeroDataSRD playerHero,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 760,
              height: 600,
              child: PartyChat(
                interactions: interactions,
                heroes: heroes,
                playerHero: playerHero,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  PartyChatInteraction parse(Map<String, dynamic> json) {
    return PartyChatInteraction.fromJson(json);
  }

  final HeroDataSRD arden = buildHero(
    id: 'option1',
    name: 'Arden',
    imagePortrait: 'assets/images/paladinportrait.png',
  );
  final HeroDataSRD lyra = buildHero(
    id: 'option2',
    name: 'Lyra',
    imagePortrait: 'assets/images/clericportrait.png',
  );

  group('PartyChat dock', () {
    testWidgets('renders collapsed and expanded dock heights', (tester) async {
      await pumpPartyChat(
        tester,
        interactions: const <PartyChatInteraction>[],
        heroes: <HeroDataSRD>[arden],
        playerHero: arden,
      );

      final Finder dockFinder = find.byKey(
        const ValueKey<String>('party-chat-dock'),
      );
      expect(tester.getSize(dockFinder).height, closeTo(60, 2.0));

      await tester.tap(
        find.byKey(const ValueKey<String>('party-chat-expand-button')),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(dockFinder).height, closeTo(180, 2.0));
    });

    testWidgets('renders the player portrait from imagePortrait', (
      tester,
    ) async {
      await pumpPartyChat(
        tester,
        interactions: const <PartyChatInteraction>[],
        heroes: <HeroDataSRD>[arden],
        playerHero: arden,
      );

      expect(assetImageFinder(arden.imagePortrait), findsOneWidget);
    });

    testWidgets('shows the default composer when no relevant request exists', (
      tester,
    ) async {
      await pumpPartyChat(
        tester,
        interactions: <PartyChatInteraction>[
          parse(<String, dynamic>{
            'message_id': 'msg_1',
            'type': 'dm_action_request',
            'owner_id': 'dm_llm',
            'owner_label': 'DM',
            'message_text': 'Lyra, react now.',
            'target_hero_id': 'option2',
          }),
        ],
        heroes: <HeroDataSRD>[arden, lyra],
        playerHero: arden,
      );

      expect(
        find.byKey(const ValueKey<String>('party-chat-composer-field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('party-chat-action-field')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('party-chat-points-remaining')),
        findsNothing,
      );
    });

    testWidgets('uses the latest targeted request for the player hero', (
      tester,
    ) async {
      await pumpPartyChat(
        tester,
        interactions: <PartyChatInteraction>[
          parse(<String, dynamic>{
            'message_id': 'msg_old',
            'type': 'dm_level_up_request',
            'owner_id': 'dm_llm',
            'owner_label': 'DM',
            'message_text': 'Spend your points.',
            'target_hero_id': 'option1',
          }),
          parse(<String, dynamic>{
            'message_id': 'msg_new',
            'type': 'dm_action_request',
            'owner_id': 'dm_llm',
            'owner_label': 'DM',
            'message_text': 'Arden, react to the sentry.',
            'target_hero_id': 'option1',
          }),
        ],
        heroes: <HeroDataSRD>[arden, lyra],
        playerHero: arden,
      );

      expect(
        find.byKey(const ValueKey<String>('party-chat-action-field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('party-chat-roll-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('party-chat-points-remaining')),
        findsNothing,
      );
    });

    testWidgets('roll button always produces values between 0 and 20', (
      tester,
    ) async {
      await pumpPartyChat(
        tester,
        interactions: <PartyChatInteraction>[
          parse(<String, dynamic>{
            'message_id': 'msg_roll',
            'type': 'dm_action_request',
            'owner_id': 'dm_llm',
            'owner_label': 'DM',
            'message_text': 'Roll now.',
            'target_hero_id': 'option1',
          }),
        ],
        heroes: <HeroDataSRD>[arden],
        playerHero: arden,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('party-chat-expand-button')),
      );
      await tester.pumpAndSettle();

      final Finder rollValueFinder = find.byKey(
        const ValueKey<String>('party-chat-roll-value'),
      );
      final Finder rollButtonFinder = find.byKey(
        const ValueKey<String>('party-chat-roll-button'),
      );

      for (int i = 0; i < 10; i += 1) {
        await tester.tap(rollButtonFinder);
        await tester.pump();

        final Text rollText = tester.widget<Text>(
          find.descendant(of: rollValueFinder, matching: find.byType(Text)),
        );
        final String text = rollText.data!;
        final int value = int.parse(text.replaceFirst('Roll: ', ''));
        expect(value, inInclusiveRange(0, 20));
      }
    });

    testWidgets(
      'level-up form requires all five points before send is enabled',
      (tester) async {
        await pumpPartyChat(
          tester,
          interactions: <PartyChatInteraction>[
            parse(<String, dynamic>{
              'message_id': 'msg_level',
              'type': 'dm_level_up_request',
              'owner_id': 'dm_llm',
              'owner_label': 'DM',
              'message_text': 'Assign your stat points.',
              'target_hero_id': 'option1',
            }),
          ],
          heroes: <HeroDataSRD>[arden],
          playerHero: arden,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('party-chat-expand-button')),
        );
        await tester.pumpAndSettle();

        IconButton sendButton = tester.widget<IconButton>(
          find.byKey(const ValueKey<String>('party-chat-send-button')),
        );
        expect(sendButton.onPressed, isNull);

        final Finder plusStrengthFinder = find.byKey(
          const ValueKey<String>('party-chat-levelup-plus-strength'),
        );
        await tester.ensureVisible(plusStrengthFinder);
        for (int i = 0; i < 5; i += 1) {
          await tester.tap(plusStrengthFinder);
          await tester.pump();
        }

        expect(find.text('Points left: 0'), findsOneWidget);

        sendButton = tester.widget<IconButton>(
          find.byKey(const ValueKey<String>('party-chat-send-button')),
        );
        expect(sendButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'level-up preview shows preview level hp and exp reset values',
      (tester) async {
        await pumpPartyChat(
          tester,
          interactions: <PartyChatInteraction>[
            parse(<String, dynamic>{
              'message_id': 'msg_level_preview',
              'type': 'dm_level_up_request',
              'owner_id': 'dm_llm',
              'owner_label': 'DM',
              'message_text': 'Spend five points.',
              'target_hero_id': 'option1',
            }),
          ],
          heroes: <HeroDataSRD>[arden],
          playerHero: arden,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('party-chat-expand-button')),
        );
        await tester.pumpAndSettle();

        final Finder plusStrengthFinder = find.byKey(
          const ValueKey<String>('party-chat-levelup-plus-strength'),
        );
        await tester.ensureVisible(plusStrengthFinder);
        for (int i = 0; i < 5; i += 1) {
          await tester.tap(plusStrengthFinder);
          await tester.pump();
        }

        expect(find.text('Preview Level 7'), findsOneWidget);
        expect(find.text('Preview HP 140/140'), findsOneWidget);
        expect(find.text('Preview EXP 0'), findsOneWidget);
      },
    );

    testWidgets(
      'send interactions do not mutate the provided interaction list',
      (tester) async {
        final List<PartyChatInteraction> interactions = <PartyChatInteraction>[
          parse(<String, dynamic>{
            'message_id': 'msg_base',
            'type': 'free_message',
            'owner_id': 'dm_llm',
            'owner_label': 'DM',
            'message_text': 'Narration',
          }),
        ];

        await pumpPartyChat(
          tester,
          interactions: interactions,
          heroes: <HeroDataSRD>[arden],
          playerHero: arden,
        );

        await tester.enterText(
          find.byKey(const ValueKey<String>('party-chat-composer-field')),
          'Testing local draft only',
        );
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey<String>('party-chat-send-button')),
        );
        await tester.pump();

        expect(interactions, hasLength(1));
        expect(interactions.first.messageId, 'msg_base');
      },
    );
  });
}
