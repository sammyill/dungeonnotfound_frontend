enum PartyChatInteractionType {
  freeMessage,
  dmLevelUp,
  playerLevelUp,
  dmAction,
  playerAction,
}

extension PartyChatInteractionTypeCodec on PartyChatInteractionType {
  String get wireValue {
    switch (this) {
      case PartyChatInteractionType.freeMessage:
        return 'free_message';
      case PartyChatInteractionType.dmLevelUp:
        return 'dm_level_up';
      case PartyChatInteractionType.playerLevelUp:
        return 'player_level_up';
      case PartyChatInteractionType.dmAction:
        return 'dm_action';
      case PartyChatInteractionType.playerAction:
        return 'player_action';
    }
  }

  String get label {
    switch (this) {
      case PartyChatInteractionType.freeMessage:
        return 'Free Message';
      case PartyChatInteractionType.dmLevelUp:
        return 'DM Level Up';
      case PartyChatInteractionType.playerLevelUp:
        return 'Player Level Up';
      case PartyChatInteractionType.dmAction:
        return 'DM Action';
      case PartyChatInteractionType.playerAction:
        return 'Player Action';
    }
  }

  static PartyChatInteractionType fromWire(String? rawValue) {
    switch ((rawValue ?? '').trim().toLowerCase()) {
      case 'free_message':
        return PartyChatInteractionType.freeMessage;
      case 'dm_level_up':
        return PartyChatInteractionType.dmLevelUp;
      case 'player_level_up':
        return PartyChatInteractionType.playerLevelUp;
      case 'dm_action':
        return PartyChatInteractionType.dmAction;
      case 'player_action':
        return PartyChatInteractionType.playerAction;
      default:
        throw FormatException('Unknown party chat interaction type: $rawValue');
    }
  }
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

int _clampRoll(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > 20) {
    return 20;
  }
  return value;
}

sealed class PartyChatInteraction {
  final String messageId;
  final PartyChatInteractionType type;
  final String ownerId;
  final String ownerLabel;

  const PartyChatInteraction({
    required this.messageId,
    required this.type,
    required this.ownerId,
    required this.ownerLabel,
  });

  static PartyChatInteraction fromJson(Map<String, dynamic> json) {
    final type = PartyChatInteractionTypeCodec.fromWire(
      _readString(json['type']),
    );
    switch (type) {
      case PartyChatInteractionType.freeMessage:
        return FreeMessageInteraction.fromJson(json);
      case PartyChatInteractionType.dmLevelUp:
        return DmLevelUpInteraction.fromJson(json);
      case PartyChatInteractionType.playerLevelUp:
        return PlayerLevelUpInteraction.fromJson(json);
      case PartyChatInteractionType.dmAction:
        return DmActionInteraction.fromJson(json);
      case PartyChatInteractionType.playerAction:
        return PlayerActionInteraction.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  Map<String, dynamic> toJsonBase() => {
    'message_id': messageId,
    'type': type.wireValue,
    'owner_id': ownerId,
    'owner_label': ownerLabel,
  };
}

class FreeMessageInteraction extends PartyChatInteraction {
  final String messageText;

  const FreeMessageInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required this.messageText,
  }) : super(type: PartyChatInteractionType.freeMessage);

  factory FreeMessageInteraction.fromJson(Map<String, dynamic> json) {
    return FreeMessageInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      messageText: _readString(json['message_text']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonBase(),
    'message_text': messageText,
  };
}

class DmLevelUpInteraction extends PartyChatInteraction {
  final String messageText;

  const DmLevelUpInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required this.messageText,
  }) : super(type: PartyChatInteractionType.dmLevelUp);

  factory DmLevelUpInteraction.fromJson(Map<String, dynamic> json) {
    return DmLevelUpInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      messageText: _readString(json['message_text']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonBase(),
    'message_text': messageText,
  };
}

class PlayerLevelUpInteraction extends PartyChatInteraction {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const PlayerLevelUpInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  }) : super(type: PartyChatInteractionType.playerLevelUp);

  factory PlayerLevelUpInteraction.fromJson(Map<String, dynamic> json) {
    return PlayerLevelUpInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      strength: _readInt(json['strength']),
      dexterity: _readInt(json['dexterity']),
      constitution: _readInt(json['constitution']),
      intelligence: _readInt(json['intelligence']),
      wisdom: _readInt(json['wisdom']),
      charisma: _readInt(json['charisma']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonBase(),
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
  };
}

class DmActionInteraction extends PartyChatInteraction {
  final String messageText;
  final String actionTarget;

  const DmActionInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required this.messageText,
    required this.actionTarget,
  }) : super(type: PartyChatInteractionType.dmAction);

  factory DmActionInteraction.fromJson(Map<String, dynamic> json) {
    return DmActionInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      messageText: _readString(json['message_text']),
      actionTarget: _readString(json['action_target']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonBase(),
    'message_text': messageText,
    'action_target': actionTarget,
  };
}

class PlayerActionInteraction extends PartyChatInteraction {
  final String messageText;
  final int roll;

  const PlayerActionInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required this.messageText,
    required this.roll,
  }) : super(type: PartyChatInteractionType.playerAction);

  factory PlayerActionInteraction.fromJson(Map<String, dynamic> json) {
    return PlayerActionInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      messageText: _readString(json['message_text']),
      roll: _clampRoll(_readInt(json['roll'])),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonBase(),
    'message_text': messageText,
    'roll': _clampRoll(roll),
  };
}
