enum PartyChatInteractionType {
  freeMessage,
  dmLevelUpRequest,
  playerLevelUp,
  dmAction,
  dmActionRequest,
  playerAction,
}

extension PartyChatInteractionTypeCodec on PartyChatInteractionType {
  String get wireValue {
    switch (this) {
      case PartyChatInteractionType.freeMessage:
        return 'free_message';
      case PartyChatInteractionType.dmLevelUpRequest:
        return 'dm_level_up_request';
      case PartyChatInteractionType.playerLevelUp:
        return 'player_level_up';
      case PartyChatInteractionType.dmAction:
        return 'dm_action';
      case PartyChatInteractionType.dmActionRequest:
        return 'dm_action_request';
      case PartyChatInteractionType.playerAction:
        return 'player_action';
    }
  }

  String get label {
    switch (this) {
      case PartyChatInteractionType.freeMessage:
        return 'Free Message';
      case PartyChatInteractionType.dmLevelUpRequest:
        return 'DM Level Up Request';
      case PartyChatInteractionType.playerLevelUp:
        return 'Player Level Up';
      case PartyChatInteractionType.dmAction:
        return 'DM Action';
      case PartyChatInteractionType.dmActionRequest:
        return 'DM Action Request';
      case PartyChatInteractionType.playerAction:
        return 'Player Action';
    }
  }

  static PartyChatInteractionType fromWire(String? rawValue) {
    switch ((rawValue ?? '').trim().toLowerCase()) {
      case 'free_message':
        return PartyChatInteractionType.freeMessage;
      case 'dm_level_up_request':
        return PartyChatInteractionType.dmLevelUpRequest;
      case 'player_level_up':
        return PartyChatInteractionType.playerLevelUp;
      case 'dm_action':
        return PartyChatInteractionType.dmAction;
      case 'dm_action_request':
        return PartyChatInteractionType.dmActionRequest;
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
      case PartyChatInteractionType.dmLevelUpRequest:
        return DmLevelUpRequestInteraction.fromJson(json);
      case PartyChatInteractionType.playerLevelUp:
        return PlayerLevelUpInteraction.fromJson(json);
      case PartyChatInteractionType.dmAction:
        return DmActionInteraction.fromJson(json);
      case PartyChatInteractionType.dmActionRequest:
        return DmActionRequestInteraction.fromJson(json);
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

sealed class PartyChatRequestInteraction extends PartyChatInteraction {
  final String targetHeroId;

  const PartyChatRequestInteraction({
    required super.messageId,
    required super.type,
    required super.ownerId,
    required super.ownerLabel,
    required this.targetHeroId,
  });

  Map<String, dynamic> toJsonRequestBase() => {
    ...toJsonBase(),
    'target_hero_id': targetHeroId,
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

class DmLevelUpRequestInteraction extends PartyChatRequestInteraction {
  final String messageText;

  const DmLevelUpRequestInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required super.targetHeroId,
    required this.messageText,
  }) : super(type: PartyChatInteractionType.dmLevelUpRequest);

  factory DmLevelUpRequestInteraction.fromJson(Map<String, dynamic> json) {
    return DmLevelUpRequestInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      targetHeroId: _readString(json['target_hero_id']),
      messageText: _readString(json['message_text']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonRequestBase(),
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

class DmActionRequestInteraction extends PartyChatRequestInteraction {
  final String messageText;

  const DmActionRequestInteraction({
    required super.messageId,
    required super.ownerId,
    required super.ownerLabel,
    required super.targetHeroId,
    required this.messageText,
  }) : super(type: PartyChatInteractionType.dmActionRequest);

  factory DmActionRequestInteraction.fromJson(Map<String, dynamic> json) {
    return DmActionRequestInteraction(
      messageId: _readString(json['message_id']),
      ownerId: _readString(json['owner_id']),
      ownerLabel: _readString(json['owner_label']),
      targetHeroId: _readString(json['target_hero_id']),
      messageText: _readString(json['message_text']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...toJsonRequestBase(),
    'message_text': messageText,
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
