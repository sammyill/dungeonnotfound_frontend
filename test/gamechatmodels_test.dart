import 'package:flutter_test/flutter_test.dart';

import 'package:dungeonnotfound_frontend/gamechat/gamechatcomponents/gamechatmodels.dart';

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

  group('InventoryData helpers', () {
    final inventory = InventoryData.fromJson({
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
}
