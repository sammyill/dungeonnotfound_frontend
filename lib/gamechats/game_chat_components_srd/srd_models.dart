enum InventoryObjectType { onehand, twohand, armor, consumable, item, unknown }

class HeroDataSRD {
  final String id;
  final String name;
  final String imageUrl;
  final String imagePortrait;
  final String characterClass;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> inventory;
  final Map<String, dynamic> abilities;

  const HeroDataSRD({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imagePortrait,
    required this.characterClass,
    required this.stats,
    required this.inventory,
    required this.abilities,
  });
}


extension InventoryObjectTypeParsing on InventoryObjectType {
  static InventoryObjectType fromString(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'onehand':
        return InventoryObjectType.onehand;
      case 'twohand':
        return InventoryObjectType.twohand;
      case 'armor':
        return InventoryObjectType.armor;
      case 'consumable':
        return InventoryObjectType.consumable;
      case 'item':
      case '':
        return InventoryObjectType.item;
      default:
        return InventoryObjectType.unknown;
    }
  }

  String toJsonValue() {
    switch (this) {
      case InventoryObjectType.onehand:
        return 'onehand';
      case InventoryObjectType.twohand:
        return 'twohand';
      case InventoryObjectType.armor:
        return 'armor';
      case InventoryObjectType.consumable:
        return 'consumable';
      case InventoryObjectType.item:
        return 'item';
      case InventoryObjectType.unknown:
        return 'unknown';
    }
  }
}

class CurrencyData {
  final int gp;
  final int sp;
  final int cp;

  const CurrencyData({this.gp = 0, this.sp = 0, this.cp = 0});

  factory CurrencyData.fromJson(Map<String, dynamic> json) {
    return CurrencyData(
      gp: (json['gp'] ?? 0) as int,
      sp: (json['sp'] ?? 0) as int,
      cp: (json['cp'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {'gp': gp, 'sp': sp, 'cp': cp};
}

class InventoryItemData {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final InventoryObjectType objectType;
  final String description;

  const InventoryItemData({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.objectType,
    required this.description,
  });

  factory InventoryItemData.fromJson(Map<String, dynamic> json) {
    return InventoryItemData(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      objectType: InventoryObjectTypeParsing.fromString(
        json['objectType'] as String?,
      ),
      quantity: (json['quantity'] ?? 1) as int,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'quantity': quantity,
    'objectType': objectType.toJsonValue(),
    'description': description,
  };
}

class InventoryData {
  final CurrencyData currency;

  /// slot -> itemId (or null if empty)
  final Map<String, String?> equippedSlots;

  final List<InventoryItemData> items;

  const InventoryData({
    required this.currency,
    required this.equippedSlots,
    required this.items,
  });

  factory InventoryData.fromJson(Map<String, dynamic> json) {
    return InventoryData(
      currency: CurrencyData.fromJson(
        (json['currency'] as Map<String, dynamic>? ?? const {}),
      ),
      equippedSlots:
          (json['equippedSlots'] as Map<String, dynamic>? ?? const {}).map(
            (k, v) => MapEntry(k, v as String?),
          ),
      items: ((json['items'] as List<dynamic>? ?? const []))
          .map((e) => InventoryItemData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  InventoryItemData? findItemById(String? id) {
    if (id == null) {
      return null;
    }
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Set<String> get equippedItemIds {
    return equippedSlots.values.whereType<String>().toSet();
  }

  bool isEquipped(String itemId) {
    return equippedItemIds.contains(itemId);
  }

  Map<String, dynamic> toJson() => {
    'currency': currency.toJson(),
    'equippedSlots': equippedSlots,
    'items': items.map((e) => e.toJson()).toList(),
  };
}


enum AbilityKind {
  attack,
  heal,
  utility,
  passive;

  static const Map<String, AbilityKind> _map = {
    'attack': AbilityKind.attack,
    'heal': AbilityKind.heal,
    'utility': AbilityKind.utility,
    'passive': AbilityKind.passive,
  };

  static AbilityKind fromString(String? value) {
    return _map[value?.toLowerCase()] ?? AbilityKind.utility;
  }
}

enum AbilityActionCost {
  action,
  bonusAction,
  reaction,
  passive;

  static const Map<String, AbilityActionCost> _map = {
    'action': AbilityActionCost.action,
    'bonusAction': AbilityActionCost.bonusAction,
    'reaction': AbilityActionCost.reaction,
    'passive': AbilityActionCost.passive,
  };

  static AbilityActionCost fromString(String? value) {
    return _map[value?.toLowerCase()] ?? AbilityActionCost.action;
  }


}

/*
class AbilityDataSRD {


;


  /// Small UI/gameplay helpers (optional but useful)

  final AbilityActionCost actionCost;
  final int rangeFeet; // 5 = melee
  final bool magical;

  const AbilityDataSRD({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    this.kind = AbilityKind.utility,
    this.actionCost = AbilityActionCost.action,
    this.rangeFeet = 5,
    this.magical = false,
  });
}
*/


class AbilityDataSRD {
  final String id;
  final String name;
  final String image;
  final String description;
  final int range;
  final bool magical;
  final AbilityKind kind;
  final AbilityActionCost actionCost;
  

  const AbilityDataSRD({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    this.range=0,
    this.magical = false,
    required this.kind,
    this.actionCost = AbilityActionCost.action,
  });

  factory AbilityDataSRD.fromMap(Map<String, dynamic> map) {
    return AbilityDataSRD(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      range:map["range"] ?? 0,
      magical:map["magical"] ?? false,
      kind: AbilityKind.fromString(map['kind']),
      actionCost: AbilityActionCost.fromString(map["actionCost"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'range':range,
      'magical':magical,
      'kind': kind.name, // sends "attack", "heal", etc.
      'actionCost':actionCost.name,
    };
  }
}