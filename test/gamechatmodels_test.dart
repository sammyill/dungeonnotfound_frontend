import 'package:flutter_test/flutter_test.dart';

import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_chat_models.dart';
import 'package:dungeonnotfound_frontend/gamechats/game_chat_components_srd/srd_hero_models.dart';

void main() {
  group('InventoryObjectTypeParsing', () {
    test('parses known object types', () {
      final inputToExpected = <String, InventoryObjectType>{
        'onehand': InventoryObjectType.onehand,
        'twohand': InventoryObjectType.twohand,
        'armor': InventoryObjectType.armor,
        'consumable': InventoryObjectType.consumable,
        'item': InventoryObjectType.item,
      };

      for (final entry in inputToExpected.entries) {
        expect(InventoryObjectTypeParsing.fromString(entry.key), entry.value);
      }
    });

    test('normalizes case and whitespace', () {
      expect(
        InventoryObjectTypeParsing.fromString('  TwOhAnD '),
        InventoryObjectType.twohand,
      );
    });

    test('defaults missing value to item', () {
      expect(
        InventoryObjectTypeParsing.fromString(null),
        InventoryObjectType.item,
      );
      expect(
        InventoryObjectTypeParsing.fromString(''),
        InventoryObjectType.item,
      );
    });

    test('maps unknown value to unknown', () {
      expect(
        InventoryObjectTypeParsing.fromString('artifact'),
        InventoryObjectType.unknown,
      );
    });
  });

  group('HeroInventorySRD helpers', () {
    final inventory = HeroInventorySRD.fromJson({
      'currency': {'gp': 10, 'sp': 5, 'cp': 1},
      'equippedSlots': {
        'mainHand': 'itm_sword',
        'offHand': 'itm_shield',
        'armor': null,
      },
      'items': [
        {
          'id': 'itm_sword',
          'name': 'Sword',
          'image': 'assets/items/sword.png',
          'quantity': 1,
          'objectType': 'onehand',
          'description': 'Sword description',
        },
        {
          'id': 'itm_shield',
          'name': 'Shield',
          'image': 'assets/items/shield.png',
          'quantity': 1,
          'objectType': 'onehand',
          'description': 'Shield description',
        },
      ],
    });

    test('findItemById finds existing items', () {
      expect(inventory.findItemById('itm_sword')?.name, 'Sword');
      expect(inventory.findItemById('itm_missing'), isNull);
      expect(inventory.findItemById(null), isNull);
    });

    test('equippedItemIds exposes slotted IDs', () {
      expect(inventory.equippedItemIds, {'itm_sword', 'itm_shield'});
    });

    test('isEquipped reports equipped state', () {
      expect(inventory.isEquipped('itm_sword'), isTrue);
      expect(inventory.isEquipped('itm_unknown'), isFalse);
    });
  });

  group('HeroStatsSRD JSON contract', () {
    test('reads new keys and writes new keys only', () {
      final stats = HeroStatsSRD.fromJson({
        'hp': '140',
        'currentHp': 120,
        'level': '6',
        'strength': 16,
        'dexterity': 12,
        'constitution': 15,
        'intelligence': 10,
        'wisdom': 11,
        'charisma': 9,
      });

      expect(stats.hp, 140);
      expect(stats.currentHp, 120);
      expect(stats.level, 6);

      final json = stats.toJson();
      expect(json['hp'], 140);
      expect(json['currentHp'], 120);
      expect(json.containsKey('hpbaseline'), isFalse);
      expect(json.containsKey('hpcurrent'), isFalse);
    });

    test('does not consume legacy hpbaseline/hpcurrent keys', () {
      final stats = HeroStatsSRD.fromJson({
        'hpbaseline': 200,
        'hpcurrent': 175,
      });

      expect(stats.hp, 0);
      expect(stats.currentHp, 0);
    });
  });

  group('HeroAbilitiesSRD parsing', () {
    test('parses and serializes abilities list with tolerant values', () {
      final abilities = HeroAbilitiesSRD.fromJson({
        'abilities': [
          {
            'id': 'ab_1',
            'name': 'Arc Bolt',
            'image': 'assets/items/staff.png',
            'description': 'Magic attack',
            'range': '60',
            'magical': 'true',
            'kind': 'attack',
            'actionCost': 'bonusAction',
          },
        ],
      });

      expect(abilities.abilityList, hasLength(1));
      expect(abilities.abilityList.first.range, 60);
      expect(abilities.abilityList.first.magical, isTrue);
      expect(
        abilities.abilityList.first.actionCost,
        AbilityActionCost.bonusAction,
      );

      final json = abilities.toJson();
      final list = json['abilities'] as List<dynamic>;
      final first = list.first as Map<String, dynamic>;
      expect(first['actionCost'], 'bonusAction');
    });
  });

  group('HeroDataSRD round-trip', () {
    test('parses backend-shaped hero json and serializes typed model', () {
      final payload = <String, dynamic>{
        'id': 'option1',
        'name': 'Arden',
        'imageUrl': 'assets/images/paladinfullbody.webp',
        'imagePortrait': 'assets/images/paladinportrait.png',
        'characterClass': 'paladin',
        'stats': {
          'hp': '140',
          'currentHp': 120,
          'level': '6',
          'strength': 16,
          'dexterity': 12,
          'constitution': 15,
          'intelligence': 10,
          'wisdom': 11,
          'charisma': 9,
        },
        'inventory': {
          'currency': {'gp': '250', 'sp': 8, 'cp': 14},
          'equippedSlots': {
            'mainHand': 'itm_sword',
            'offHand': null,
            'armor': 'itm_armor',
          },
          'items': [
            {
              'id': 'itm_sword',
              'name': 'Longsword',
              'image': 'assets/items/longsword.png',
              'quantity': '1',
              'objectType': 'onehand',
              'description': 'A sword',
            },
          ],
        },
        'abilities': {
          'abilities': [
            {
              'id': 'ab_1',
              'name': 'Radiant Slash',
              'image': 'assets/items/longsword.png',
              'description': 'Attack',
              'range': '5',
              'magical': 1,
              'kind': 'attack',
              'actionCost': 'action',
            },
          ],
        },
      };

      final hero = HeroDataSRD.fromJson(payload);
      expect(hero.id, 'option1');
      expect(hero.stats.hp, 140);
      expect(hero.inventory.currency.gp, 250);
      expect(hero.abilities.abilityList.first.magical, isTrue);

      final json = hero.toJson();
      final statsJson = json['stats'] as Map<String, dynamic>;
      final inventoryJson = json['inventory'] as Map<String, dynamic>;
      final abilitiesJson = json['abilities'] as Map<String, dynamic>;
      expect(statsJson['hp'], 140);
      expect(statsJson['currentHp'], 120);
      expect(inventoryJson['currency'], isA<Map<String, dynamic>>());
      expect(abilitiesJson['abilities'], isA<List<dynamic>>());
    });
  });

  group('PartyChatInteraction parse/serialize by type', () {
    final payloads = <Map<String, dynamic>>[
      {
        'message_id': 'msg_001',
        'type': 'free_message',
        'owner_id': 'dm_llm',
        'owner_label': 'DM',
        'message_text': 'Narration',
      },
      {
        'message_id': 'msg_002',
        'type': 'dm_level_up',
        'owner_id': 'dm_llm',
        'owner_label': 'DM',
        'message_text': 'Level up now',
      },
      {
        'message_id': 'msg_003',
        'type': 'player_level_up',
        'owner_id': 'option2',
        'owner_label': 'Lyra',
        'strength': 11,
        'dexterity': 12,
        'constitution': 13,
        'intelligence': 14,
        'wisdom': 15,
        'charisma': 16,
      },
      {
        'message_id': 'msg_004',
        'type': 'dm_action',
        'owner_id': 'dm_llm',
        'owner_label': 'DM',
        'message_text': 'Torin, roll stealth',
        'action_target': 'option3',
      },
      {
        'message_id': 'msg_005',
        'type': 'player_action',
        'owner_id': 'option3',
        'owner_label': 'Torin',
        'message_text': 'I hide behind a pillar',
        'roll': 18,
      },
    ];

    for (final payload in payloads) {
      test('round-trips ${payload['type']}', () {
        final interaction = PartyChatInteraction.fromJson(payload);
        final json = interaction.toJson();
        expect(json['message_id'], payload['message_id']);
        expect(json['type'], payload['type']);
        expect(json['owner_id'], payload['owner_id']);
        expect(json['owner_label'], payload['owner_label']);
      });
    }
  });

  group('PartyChatInteraction list and validation', () {
    test('parses mixed list preserving order', () {
      final raw = <Map<String, dynamic>>[
        {
          'message_id': 'm1',
          'type': 'free_message',
          'owner_id': 'dm_llm',
          'owner_label': 'DM',
          'message_text': 'start',
        },
        {
          'message_id': 'm2',
          'type': 'player_action',
          'owner_id': 'option1',
          'owner_label': 'Arden',
          'message_text': 'I attack',
          'roll': 12,
        },
      ];

      final parsed = raw.map(PartyChatInteraction.fromJson).toList();
      expect(parsed, hasLength(2));
      expect(parsed.first.messageId, 'm1');
      expect(parsed.last.messageId, 'm2');
      expect(parsed.first.type, PartyChatInteractionType.freeMessage);
      expect(parsed.last.type, PartyChatInteractionType.playerAction);
    });

    test('clamps player_action roll to 0..20', () {
      final low =
          PartyChatInteraction.fromJson({
                'message_id': 'm_low',
                'type': 'player_action',
                'owner_id': 'option1',
                'owner_label': 'Arden',
                'message_text': 'low roll',
                'roll': -4,
              })
              as PlayerActionInteraction;

      final high =
          PartyChatInteraction.fromJson({
                'message_id': 'm_high',
                'type': 'player_action',
                'owner_id': 'option1',
                'owner_label': 'Arden',
                'message_text': 'high roll',
                'roll': 42,
              })
              as PlayerActionInteraction;

      expect(low.roll, 0);
      expect(high.roll, 20);
      expect(low.toJson()['roll'], 0);
      expect(high.toJson()['roll'], 20);
    });

    test('player_level_up parses numeric strings', () {
      final interaction =
          PartyChatInteraction.fromJson({
                'message_id': 'm3',
                'type': 'player_level_up',
                'owner_id': 'option2',
                'owner_label': 'Lyra',
                'strength': '11',
                'dexterity': '12',
                'constitution': '13',
                'intelligence': '14',
                'wisdom': '15',
                'charisma': '16',
              })
              as PlayerLevelUpInteraction;

      expect(interaction.strength, 11);
      expect(interaction.dexterity, 12);
      expect(interaction.constitution, 13);
      expect(interaction.intelligence, 14);
      expect(interaction.wisdom, 15);
      expect(interaction.charisma, 16);
    });

    test('unknown type throws FormatException', () {
      expect(
        () => PartyChatInteraction.fromJson({
          'message_id': 'bad_1',
          'type': 'unknown_type',
          'owner_id': 'dm_llm',
          'owner_label': 'DM',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
