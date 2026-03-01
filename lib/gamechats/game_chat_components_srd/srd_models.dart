enum InventoryObjectType { onehand, twohand, armor, consumable, item, unknown }

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return const <String, dynamic>{};
}

List<dynamic> _readList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  if (value is List) {
    return List<dynamic>.from(value);
  }
  return const <dynamic>[];
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

bool _readBool(dynamic value, {bool fallback = false}) {
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

class HeroDataSRD {
  final String id;
  final String name;
  final String imageUrl;
  final String imagePortrait;
  final String characterClass;
  final HeroStatsSRD stats;
  final HeroInventorySRD inventory;
  final HeroAbilitiesSRD abilities;

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

  factory HeroDataSRD.fromJson(Map<String, dynamic> json) {
    return HeroDataSRD(
      id: _readString(json['id']),
      name: _readString(json['name']),
      imageUrl: _readString(json['imageUrl']),
      imagePortrait: _readString(json['imagePortrait']),
      characterClass: _readString(json['characterClass']),
      stats: HeroStatsSRD.fromJson(_readMap(json['stats'])),
      inventory: HeroInventorySRD.fromJson(_readMap(json['inventory'])),
      abilities: HeroAbilitiesSRD.fromJson(_readMap(json['abilities'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'imagePortrait': imagePortrait,
    'characterClass': characterClass,
    'stats': stats.toJson(),
    'inventory': inventory.toJson(),
    'abilities': abilities.toJson(),
  };
}

class HeroStatsSRD {
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
      hp: _readInt(json['hp']),
      currentHp: _readInt(json['currentHp']),
      level: _readInt(json['level'], fallback: 1),
      strength: _readInt(json['strength'], fallback: 10),
      dexterity: _readInt(json['dexterity'], fallback: 10),
      constitution: _readInt(json['constitution'], fallback: 10),
      intelligence: _readInt(json['intelligence'], fallback: 10),
      wisdom: _readInt(json['wisdom'], fallback: 10),
      charisma: _readInt(json['charisma'], fallback: 10),
    );
  }

  Map<String, dynamic> toJson() => {
    'hp': hp,
    'currentHp': currentHp,
    'level': level,
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
  };
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
      gp: _readInt(json['gp']),
      sp: _readInt(json['sp']),
      cp: _readInt(json['cp']),
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
      id: _readString(json['id']),
      name: _readString(json['name']),
      image: _readString(json['image']),
      objectType: InventoryObjectTypeParsing.fromString(
        _readString(json['objectType']),
      ),
      quantity: _readInt(json['quantity'], fallback: 1),
      description: _readString(json['description']),
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

class HeroInventorySRD {
  final CurrencyData currency;

  /// slot -> itemId (or null if empty)
  final Map<String, String?> equippedSlots;

  final List<InventoryItemData> items;

  const HeroInventorySRD({
    required this.currency,
    required this.equippedSlots,
    required this.items,
  });

  factory HeroInventorySRD.fromJson(Map<String, dynamic> json) {
    final rawSlots = _readMap(json['equippedSlots']);
    final parsedSlots = <String, String?>{};
    for (final entry in rawSlots.entries) {
      if (entry.value == null) {
        parsedSlots[entry.key] = null;
        continue;
      }
      final value = _readString(entry.value).trim();
      parsedSlots[entry.key] = value.isEmpty ? null : value;
    }

    return HeroInventorySRD(
      currency: CurrencyData.fromJson(_readMap(json['currency'])),
      equippedSlots: parsedSlots,
      items: _readList(json['items'])
          .map((e) => InventoryItemData.fromJson(_readMap(e)))
          .toList(growable: false),
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

class HeroAbilitiesSRD {
  final List<AbilityDataSRD> abilityList;

  const HeroAbilitiesSRD({required this.abilityList});

  factory HeroAbilitiesSRD.fromJson(Map<String, dynamic> json) {
    return HeroAbilitiesSRD(
      abilityList: _readList(json['abilities'])
          .map((e) => AbilityDataSRD.fromJson(_readMap(e)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'abilities': abilityList.map((ability) => ability.toJson()).toList(),
  };
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

  factory AbilityDataSRD.fromJson(Map<String, dynamic> map) {
    return AbilityDataSRD(
      id: _readString(map['id']),
      name: _readString(map['name']),
      image: _readString(map['image']),
      description: _readString(map['description']),
      range: _readInt(map['range']),
      magical: _readBool(map['magical']),
      kind: AbilityKind.fromString(_readString(map['kind'])),
      actionCost: AbilityActionCost.fromString(_readString(map['actionCost'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'description': description,
    'range': range,
    'magical': magical,
    'kind': kind.name,
    'actionCost': actionCost.name,
  };
}
