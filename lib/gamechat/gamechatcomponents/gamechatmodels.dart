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
  final String objectType;
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
      objectType:json["objectType"] as String,
      quantity: (json['quantity'] ?? 1) as int,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'quantity': quantity,
        'objectType':objectType,
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
      equippedSlots: (json['equippedSlots'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v as String?)),
      items: ((json['items'] as List<dynamic>? ?? const []))
          .map((e) => InventoryItemData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency.toJson(),
        'equippedSlots': equippedSlots,
        'items': items.map((e) => e.toJson()).toList(),
      };
}