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

class HeroStatsSRD{
  final int hp;
  final int currentHp;
  final int level;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const HeroStatsSRD({
    required this.hp,
    required this.currentHp,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  factory HeroStatsSRD.fromJson(Map<String, dynamic> json) {
    return HeroStatsSRD(
      hp: (json['hpbaseline'] ?? 0) as int,
      currentHp: (json['hpcurrent'] ?? 0) as int,
      level: (json['level'] ?? 1) as int,
      strength: (json['strength'] ?? 10) as int,
      dexterity: (json['dexterity'] ?? 10) as int,
      constitution: (json['constitution'] ?? 10) as int,
      intelligence: (json['intelligence'] ?? 10) as int,
      wisdom: (json['wisdom'] ?? 10) as int,
      charisma: (json['charisma'] ?? 10) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'hpbaseline': hp,
    'hpcurrent': currentHp,
    'level': level,
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
  };

}



extension HeroDataSRDAbilities on HeroDataSRD {
  List<AbilityDataSRD> get abilityList {
    final rawAbilities = abilities['abilities'];
    if (rawAbilities is! List) {
      return const <AbilityDataSRD>[];
    }

    final parsedAbilities = <AbilityDataSRD>[];
    for (final dynamic rawAbility in rawAbilities) {
      if (rawAbility is Map<String, dynamic>) {
        parsedAbilities.add(AbilityDataSRD.fromMap(rawAbility));
        continue;
      }
      if (rawAbility is Map) {
        parsedAbilities.add(
          AbilityDataSRD.fromMap(Map<String, dynamic>.from(rawAbility)),
        );
      }
    }
    return parsedAbilities;
  }
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
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');
    return _map[normalized] ?? AbilityKind.utility;
  }
}

enum AbilityActionCost {
  action,
  bonusAction,
  reaction,
  passive;

  static const Map<String, AbilityActionCost> _map = {
    'action': AbilityActionCost.action,
    'bonusaction': AbilityActionCost.bonusAction,
    'reaction': AbilityActionCost.reaction,
    'passive': AbilityActionCost.passive,
  };

  static AbilityActionCost fromString(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');
    return _map[normalized] ?? AbilityActionCost.action;
  }
}

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
    this.range = 0,
    this.magical = false,
    required this.kind,
    this.actionCost = AbilityActionCost.action,
  });

  factory AbilityDataSRD.fromMap(Map<String, dynamic> map) {
    String readString(dynamic value) {
      if (value == null) {
        return '';
      }
      if (value is String) {
        return value;
      }
      return value.toString();
    }

    int readInt(dynamic value, {int fallback = 0}) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    bool readBool(dynamic value, {bool fallback = false}) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
      return fallback;
    }

    return AbilityDataSRD(
      id: readString(map['id']),
      name: readString(map['name']),
      image: readString(map['image']),
      description: readString(map['description']),
      range: readInt(map["range"]),
      magical: readBool(map["magical"]),
      kind: AbilityKind.fromString(readString(map['kind'])),
      actionCost: AbilityActionCost.fromString(readString(map["actionCost"])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'range': range,
      'magical': magical,
      'kind': kind.name, // sends "attack", "heal", etc.
      'actionCost': actionCost.name,
    };
  }
}
