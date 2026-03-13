import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

class GameSessionState {
  final List<Map<String, dynamic>> heroesJson;
  final List<Map<String, dynamic>> chatJson;
  final Map<String, dynamic> playerHeroJson;

  const GameSessionState({
    required this.heroesJson,
    required this.chatJson,
    required this.playerHeroJson,
  });

  String get playerHeroId => _readString(playerHeroJson['hero_id']);

  GameSessionState copyWith({
    List<Map<String, dynamic>>? heroesJson,
    List<Map<String, dynamic>>? chatJson,
    Map<String, dynamic>? playerHeroJson,
  }) {
    return GameSessionState(
      heroesJson: heroesJson ?? this.heroesJson,
      chatJson: chatJson ?? this.chatJson,
      playerHeroJson: playerHeroJson ?? this.playerHeroJson,
    );
  }
}

final gameSessionProvider =
    AsyncNotifierProvider<GameSessionController, GameSessionState>(
      GameSessionController.new,
    );

class GameSessionController extends AsyncNotifier<GameSessionState> {
  StreamSubscription<Map<String, dynamic>>? _chatUpdatesSubscription;

  @override
  Future<GameSessionState> build() async {
    ref.onDispose(() => _chatUpdatesSubscription?.cancel());

    // Replace these mock values with backend calls when the API exists.
    // final heroesJson = await _loadHeroesFromBackend();
    // final chatJson = await _loadChatFromBackend();
    final heroesJson = _cloneJsonList(_mockHeroesJson);
    final chatJson = _cloneJsonList(_mockChatJson);
    final playerHeroJson = _cloneJsonMap(_mockPlayerHeroJson);

    _startChatUpdatesSubscription();

    return GameSessionState(
      heroesJson: heroesJson,
      chatJson: chatJson,
      playerHeroJson: playerHeroJson,
    );
  }

  void _startChatUpdatesSubscription() {
    _chatUpdatesSubscription?.cancel();

    // Wire the backend stream here when it exists.
    // _chatUpdatesSubscription = watchIncomingChatMessagesFromBackend().listen(
    //   _applyIncomingChatMessage,
    //   onError: (Object error, StackTrace stackTrace) {
    //     state = AsyncError(error, stackTrace);
    //   },
    // );

    _chatUpdatesSubscription = null;
  }

  void _applyIncomingChatMessage(Map<String, dynamic> message) {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final messageId = message['message_id'];
    final alreadyExists = currentState.chatJson.any(
      (existingMessage) => existingMessage['message_id'] == messageId,
    );
    if (alreadyExists) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        chatJson: [
          ...currentState.chatJson,
          Map<String, dynamic>.from(message),
        ],
      ),
    );
  }

  // Useful while there is no backend stream yet.
  void addLocalChatMessage(Map<String, dynamic> message) {
    _applyIncomingChatMessage(message);
  }
}

List<Map<String, dynamic>> _cloneJsonList(List<Map<String, dynamic>> source) {
  return source.map(Map<String, dynamic>.from).toList(growable: false);
}

Map<String, dynamic> _cloneJsonMap(Map<String, dynamic> source) {
  return Map<String, dynamic>.from(source);
}

final Map<String, dynamic> _mockPlayerHeroJson = {'hero_id': 'option1'};

final List<Map<String, dynamic>> _mockHeroesJson = [
  {
    'id': 'option1',
    'name': 'Arden',
    'imageUrl': 'assets/images/paladinfullbody.webp',
    'imagePortrait': 'assets/images/paladinportrait.png',
    'characterClass': "paladin",
    'stats': {
      'hp': 140,
      'currentHp': 120,
      'currentExp': 1860,
      'level': 6,
      'strength': 16,
      'dexterity': 12,
      'constitution': 15,
      'intelligence': 10,
      'wisdom': 11,
      'charisma': 9,
    },
    'inventory': {
      'currency': {'gp': 250, 'sp': 8, 'cp': 14},
      'equippedSlots': {
        'mainHand': 'itm_arden_longsword_01',
        'offHand': 'itm_arden_shield_01',
        'armor': 'itm_arden_chainmail_01',
      },
      'items': [
        {
          'id': 'itm_arden_longsword_01',
          'name': 'Longsword',
          'image': 'assets/items/longsword.png',
          'quantity': 1,
          "objectType": "onehand",
          'description':
              'Weapon (martial, melee). +5 to hit. Damage: 1d8+3 slashing. Versatile: 1d10+3.',
        },
        {
          'id': 'itm_arden_shield_01',
          'name': 'Shield',
          'image': 'assets/items/shield.png',
          "objectType": "onehand",
          'quantity': 1,
          'description': 'Armor (shield). While equipped: +2 AC.',
        },
        {
          'id': 'itm_arden_chainmail_01',
          'name': 'Chain Mail',
          'image': 'assets/items/chainmail.png',
          "objectType": "armor",
          'quantity': 1,
          'description':
              'Armor (heavy). AC 16. Disadvantage on Stealth checks.',
        },
        {
          'id': 'itm_arden_potion_heal_01',
          'name': 'Potion of Healing',
          'image': 'assets/items/potion_healing.png',
          "objectType": "consumable",
          'quantity': 2,
          'description':
              'Consumable. Action: regain 2d4+2 HP. Consumed on use.',
        },
        {
          'id': 'itm_arden_holy_symbol_01',
          'name': 'Holy Symbol',
          'image': 'assets/items/holy_symbol.png',
          "objectType": "item",
          'quantity': 1,
          'description':
              'Focus. Used to channel divine power and cast certain spells (if your rules use focuses).',
        },
        {
          'id': 'itm_arden_torch_01',
          'name': 'Torch',
          'image': 'assets/items/torch.png',
          'quantity': 4,
          "objectType": "item",
          'description':
              'Gear. Action to light. Provides light for 1 hour (bright 20 ft, dim 20 ft).',
        },
      ],
    },
    'abilities': {
      'abilities': [
        {
          'id': 'ab_arden_slash_01',
          'name': 'Radiant Slash',
          'image': 'assets/items/longsword.png',
          'description':
              'Strike an enemy with a blessed blade, dealing weapon damage plus radiant force.',
          'range': 5,
          'magical': true,
          'kind': 'attack',
          'actionCost': 'action',
        },
        {
          'id': 'ab_arden_shield_bash_01',
          'name': 'Shield Bash',
          'image': 'assets/items/shield.png',
          'description':
              'Slam your shield into a target to stagger them and reduce their next attack.',
          'range': 5,
          'magical': false,
          'kind': 'utility',
          'actionCost': 'bonusAction',
        },
        {
          'id': 'ab_arden_holy_vow_01',
          'name': 'Holy Vow',
          'image': 'assets/items/holy_symbol.png',
          'description':
              'Invoke divine light to restore an ally and grant minor resistance for one turn.',
          'range': 30,
          'magical': true,
          'kind': 'heal',
          'actionCost': 'action',
        },
      ],
    },
  },
  {
    'id': 'option2',
    'name': 'Lyra',
    'imageUrl': 'assets/images/clericfullbody.webp',
    'imagePortrait': 'assets/images/clericportrait.png',
    'characterClass': "cleric",
    'stats': {
      'hp': 100,
      'currentHp': 88,
      'currentExp': 980,
      'level': 5,
      'strength': 10,
      'dexterity': 17,
      'constitution': 11,
      'intelligence': 13,
      'wisdom': 12,
      'charisma': 14,
    },
    'inventory': {
      'currency': {'gp': 180, 'sp': 15, 'cp': 3},
      'equippedSlots': {
        'mainHand': 'itm_lyra_mace_01',
        'offHand': 'itm_lyra_shield_01',
        'armor': 'itm_lyra_scale_01',
      },
      'items': [
        {
          'id': 'itm_lyra_mace_01',
          'name': 'Mace',
          'image': 'assets/items/mace.png',
          'quantity': 1,
          "objectType": "onehand",
          'description':
              'Weapon (simple, melee). +4 to hit. Damage: 1d6+2 bludgeoning.',
        },
        {
          'id': 'itm_lyra_shield_01',
          'name': 'Shield',
          'image': 'assets/items/shield.png',
          "objectType": "onehand",
          'quantity': 1,
          'description': 'Armor (shield). While equipped: +2 AC.',
        },
        {
          'id': 'itm_lyra_scale_01',
          'name': 'Scale Mail',
          'image': 'assets/items/scalemail.png',
          "objectType": "armor",
          'quantity': 1,
          'description':
              'Armor (medium). AC 14 + Dex (max 2). Disadvantage on Stealth checks.',
        },
        {
          'id': 'itm_lyra_healers_kit_01',
          'name': "Healer's Kit",
          'image': 'assets/items/healers_kit.png',
          'quantity': 1,
          "objectType": "item",
          'description':
              'Gear. Use to stabilize a creature at 0 HP (consumes 1 use).',
        },
        {
          'id': 'itm_lyra_potion_heal_01',
          'name': 'Potion of Healing',
          'image': 'assets/items/potion_healing.png',
          "objectType": "item",
          'quantity': 1,
          'description':
              'Consumable. Action: regain 2d4+2 HP. Consumed on use.',
        },
        {
          'id': 'itm_lyra_holy_symbol_01',
          'name': 'Holy Symbol',
          'image': 'assets/items/holy_symbol.png',
          "objectType": "item",
          'quantity': 1,
          'description':
              'Focus. Used to channel divine power and cast certain spells (if your rules use focuses).',
        },
      ],
    },
    'abilities': {
      'abilities': [
        {
          'id': 'ab_lyra_mace_strike_01',
          'name': 'Mace Strike',
          'image': 'assets/items/mace.png',
          'description':
              'Deliver a disciplined melee hit that may briefly weaken enemy armor.',
          'range': 5,
          'magical': false,
          'kind': 'attack',
          'actionCost': 'action',
        },
        {
          'id': 'ab_lyra_healing_prayer_01',
          'name': 'Healing Prayer',
          'image': 'assets/items/holy_symbol.png',
          'description':
              'Channel restorative power to recover an ally and cleanse minor wounds.',
          'range': 30,
          'magical': true,
          'kind': 'heal',
          'actionCost': 'action',
        },
        {
          'id': 'ab_lyra_guardian_blessing_01',
          'name': 'Guardian Blessing',
          'image': 'assets/items/shield.png',
          'description':
              'Grant a protective ward that reduces incoming damage for one attack.',
          'range': 20,
          'magical': true,
          'kind': 'utility',
          'actionCost': 'bonusAction',
        },
      ],
    },
  },
  {
    'id': 'option3',
    'name': 'Torin',
    'imageUrl': 'assets/images/thieffullbody.webp',
    'imagePortrait': 'assets/images/thiefportrait.png',
    'characterClass': "thief",
    'stats': {
      'hp': 180,
      'currentHp': 165,
      'currentExp': 3200,
      'level': 7,
      'strength': 18,
      'dexterity': 9,
      'constitution': 17,
      'intelligence': 8,
      'wisdom': 10,
      'charisma': 7,
    },
    'inventory': {
      'currency': {'gp': 95, 'sp': 22, 'cp': 40},
      'equippedSlots': {
        'mainHand': 'itm_torin_dagger_01',
        'offHand': "itm_torin_dagger_02",
        'armor': 'itm_torin_leather_01',
      },
      'items': [
        {
          'id': 'itm_torin_dagger_01',
          'name': 'Dagger',
          'image': 'assets/items/dagger.png',
          'quantity': 1,
          "objectType": "onehand",
          'description':
              'Weapon (simple, finesse, light). +6 to hit. Damage: 1d4+4 piercing. Can be thrown (20/60).',
        },
        {
          'id': 'itm_torin_dagger_02',
          'name': 'Dagger',
          'image': 'assets/items/dagger.png',
          'quantity': 1,
          "objectType": "onehand",
          'description':
              'Weapon (simple, finesse, light). +6 to hit. Damage: 1d4+4 piercing. Can be thrown (20/60).',
        },
        {
          'id': 'itm_torin_leather_01',
          'name': 'Leather Armor',
          "objectType": "armor",
          'image': 'assets/items/leather_armor.png',
          'quantity': 1,
          'description': 'Armor (light). AC 11 + Dex.',
        },
        {
          'id': 'itm_torin_cloak_01',
          'name': 'Dark Cloak',
          'image': 'assets/items/cloak_dark.png',
          "objectType": "item",
          'quantity': 1,
          'description':
              'Gear. Helps conceal you in dim light (flavor / DM rulings).',
        },
        {
          'id': 'itm_torin_thieves_tools_01',
          'name': "Thieves' Tools",
          'image': 'assets/items/thieves_tools.png',
          "objectType": "item",
          'quantity': 1,
          'description': 'Tools. Used for lockpicking and disarming traps.',
        },
        {
          'id': 'itm_torin_smoke_01',
          'name': 'Smoke Bomb',
          'image': 'assets/items/bomb_smoke.png',
          "objectType": "consumable",
          'quantity': 2,
          'description':
              'Consumable. Action: create smoke to obscure an area. Consumed on use.',
        },
        {
          'id': 'itm_torin_rations_01',
          'name': 'Rations (1 day)',
          'image': 'assets/items/rations.png',
          "objectType": "consumable",
          'quantity': 5,
          'description': 'Consumable. Food for travel. Consumed on use.',
        },
      ],
    },
    'abilities': {
      'abilities': [
        {
          'id': 'ab_torin_backstab_01',
          'name': 'Backstab',
          'image': 'assets/items/dagger.png',
          'description':
              'Exploit an opening for heavy precision damage when attacking from advantage.',
          'range': 5,
          'magical': false,
          'kind': 'attack',
          'actionCost': 'action',
        },
        {
          'id': 'ab_torin_smoke_escape_01',
          'name': 'Smoke Escape',
          'image': 'assets/items/bomb_smoke.png',
          'description':
              'Create a smoke screen and reposition to a safer nearby location.',
          'range': 15,
          'magical': false,
          'kind': 'utility',
          'actionCost': 'bonusAction',
        },
        {
          'id': 'ab_torin_evasion_01',
          'name': 'Evasion',
          'image': 'assets/items/cloak_dark.png',
          'description':
              'Passive agility that reduces damage from area effects when you react quickly.',
          'range': 0,
          'magical': false,
          'kind': 'passive',
          'actionCost': 'passive',
        },
      ],
    },
  },
  {
    'id': 'option4',
    'name': 'Nia',
    'imageUrl': 'assets/images/wizardfullbody.webp',
    'imagePortrait': 'assets/images/wizardportrait.png',
    'characterClass': "wizard",
    'stats': {
      'hp': 120,
      'currentHp': 110,
      'currentExp': 2450,
      'level': 6,
      'strength': 9,
      'dexterity': 13,
      'constitution': 12,
      'intelligence': 17,
      'wisdom': 15,
      'charisma': 12,
    },
    'inventory': {
      'currency': {'gp': 310, 'sp': 5, 'cp': 0},
      'equippedSlots': {
        'mainHand': 'itm_nia_staff_01',
        'offHand': null,
        'armor': null,
      },
      'items': [
        {
          'id': 'itm_nia_staff_01',
          'name': 'Wizard Staff',
          'image': 'assets/items/staff.png',
          'quantity': 1,
          "objectType": "twohand",
          'description':
              'Arcane focus. Melee weapon: +3 to hit, 1d6 bludgeoning. Used to channel spells.',
        },
        {
          'id': 'itm_nia_spellbook_01',
          'name': 'Spellbook',
          'image': 'assets/items/spellbook.png',
          'quantity': 1,
          "objectType": "item",
          'description':
              'Book containing your prepared knowledge. Needed to learn/prepare spells (depending on rules).',
        },
        {
          'id': 'itm_nia_mana_potion_01',
          'name': 'Mana Potion',
          'image': 'assets/items/potion_mana.png',
          "objectType": "consumable",
          'quantity': 2,
          'description':
              'Consumable. Action: restore magical energy (how much depends on your system).',
        },
        {
          'id': 'itm_nia_scroll_01',
          'name': 'Spell Scroll (Magic Missile)',
          'image': 'assets/items/scroll.png',
          "objectType": "consumable",
          'quantity': 1,
          'description':
              'Consumable. Action: cast Magic Missile from the scroll. Consumed on use.',
        },
        {
          'id': 'itm_nia_component_pouch_01',
          'name': 'Component Pouch',
          'image': 'assets/items/component_pouch.png',
          "objectType": "consumable",
          'quantity': 1,
          'description':
              'Gear. Contains basic spell components (if your rules use components).',
        },
      ],
    },
    'abilities': {
      'abilities': [
        {
          'id': 'ab_nia_arc_bolt_01',
          'name': 'Arc Bolt',
          'image': 'assets/items/staff.png',
          'description':
              'Launch a focused bolt of arcane energy that strikes a single target at range.',
          'range': 60,
          'magical': true,
          'kind': 'attack',
          'actionCost': 'action',
        },
        {
          'id': 'ab_nia_arcane_barrier_01',
          'name': 'Arcane Barrier',
          'image': 'assets/items/spellbook.png',
          'description':
              'Conjure a quick defensive ward in response to an incoming attack.',
          'range': 0,
          'magical': true,
          'kind': 'utility',
          'actionCost': 'reaction',
        },
        {
          'id': 'ab_nia_meditative_focus_01',
          'name': 'Meditative Focus',
          'image': 'assets/items/component_pouch.png',
          'description':
              'Passive concentration that stabilizes spellcasting and improves control.',
          'range': 0,
          'magical': true,
          'kind': 'passive',
          'actionCost': 'passive',
        },
      ],
    },
  },
];

final List<Map<String, dynamic>> _mockChatJson = [
  {
    'message_id': 'msg_001',
    'type': 'free_message',
    'owner_id': 'dm_llm',
    'owner_label': 'DM',
    'message_text':
        'The cavern opens before you. Your torchlight catches ancient carvings on the wall.',
  },
  {
    'message_id': 'msg_002',
    'type': 'dm_level_up_request',
    'owner_id': 'dm_llm',
    'owner_label': 'DM',
    'message_text':
        'Arden has gained enough experience to level up. Assign five stat points before continuing.',
    'target_hero_id': 'option1',
  },
  {
    'message_id': 'msg_003',
    'type': 'player_level_up',
    'owner_id': 'option1',
    'owner_label': 'Arden',
    'strength': 18,
    'dexterity': 13,
    'constitution': 16,
    'intelligence': 11,
    'wisdom': 11,
    'charisma': 9,
  },
  {
    'message_id': 'msg_004',
    'type': 'dm_action',
    'owner_id': 'dm_llm',
    'owner_label': 'DM',
    'message_text': 'Arden, hold the broken arch and watch the sentry path.',
    'action_target': 'option1',
  },
  {
    'message_id': 'msg_006',
    'type': 'dm_action_request',
    'owner_id': 'dm_llm',
    'owner_label': 'DM',
    'message_text':
        'Arden, a sentry is moving toward your position. Describe your action and roll.',
    'target_hero_id': 'option1',
  },
  {
    'message_id': 'msg_007',
    'type': 'player_action',
    'owner_id': 'option1',
    'owner_label': 'Arden',
    'message_text':
        'I brace behind the archway and wait for the sentry to step into reach.',
    'roll': 17,
  },
];
