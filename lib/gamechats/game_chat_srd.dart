import 'package:flutter/material.dart';
import 'game_chat_components_srd/srd_models.dart';
import 'game_chat_components_srd/characters_panel.dart';

class GameChatPageSRD extends StatelessWidget {
  const GameChatPageSRD({super.key});

  static const List<HeroDataSRD> _heroes = [
    HeroDataSRD(
      id: 'option1',
      name: 'Arden',
      imageUrl: 'assets/images/paladinfullbody.webp',
      imagePortrait: 'assets/images/paladinportrait.png',
      characterClass: "paladin",
      stats: {
        'hpbaseline': 140,
        'hpcurrent': 120,
        'level': 6,
        'strength': 16,
        'dexterity': 12,
        'constitution': 15,
        'intelligence': 10,
        'wisdom': 11,
        'charisma': 9,
      },
      inventory: {
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
            "objectType":"onehand",
            'description':
                'Weapon (martial, melee). +5 to hit. Damage: 1d8+3 slashing. Versatile: 1d10+3.',
          },
          {
            'id': 'itm_arden_shield_01',
            'name': 'Shield',
            'image': 'assets/items/shield.png',
              "objectType":"onehand",
            'quantity': 1,
            'description': 'Armor (shield). While equipped: +2 AC.',
          },
          {
            'id': 'itm_arden_chainmail_01',
            'name': 'Chain Mail',
            'image': 'assets/items/chainmail.png',
              "objectType":"armor",
            'quantity': 1,
            'description':
                'Armor (heavy). AC 16. Disadvantage on Stealth checks.',
          },
          {
            'id': 'itm_arden_potion_heal_01',
            'name': 'Potion of Healing',
            'image': 'assets/items/potion_healing.png',
              "objectType":"consumable",
            'quantity': 2,
            'description':
                'Consumable. Action: regain 2d4+2 HP. Consumed on use.',
          },
          {
            'id': 'itm_arden_holy_symbol_01',
            'name': 'Holy Symbol',
            'image': 'assets/items/holy_symbol.png',
            "objectType":"item",
            'quantity': 1,
            'description':
                'Focus. Used to channel divine power and cast certain spells (if your rules use focuses).',
          },
          {
            'id': 'itm_arden_torch_01',
            'name': 'Torch',
            'image': 'assets/items/torch.png',
            'quantity': 4,
              "objectType":"item",
            'description':
                'Gear. Action to light. Provides light for 1 hour (bright 20 ft, dim 20 ft).',
          },
        ],
      },
      abilities: {
        'skills': ['Slash', 'Shield Bash'],
      },
    ),
    HeroDataSRD(
      id: 'option2',
      name: 'Lyra',
      imageUrl: 'assets/images/clericfullbody.webp',
      imagePortrait: 'assets/images/clericportrait.png',
      characterClass: "cleric",
      stats: {
        'hpbaseline': 100,
        'hpcurrent': 88,
        'level': 5,
        'strength': 10,
        'dexterity': 17,
        'constitution': 11,
        'intelligence': 13,
        'wisdom': 12,
        'charisma': 14,
      },
      inventory: {
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
              "objectType":"onehand",
            'description':
                'Weapon (simple, melee). +4 to hit. Damage: 1d6+2 bludgeoning.',
          },
          {
            'id': 'itm_lyra_shield_01',
            'name': 'Shield',
            'image': 'assets/items/shield.png',
              "objectType":"onehand",
            'quantity': 1,
            'description': 'Armor (shield). While equipped: +2 AC.',
          },
          {
            'id': 'itm_lyra_scale_01',
            'name': 'Scale Mail',
            'image': 'assets/items/scalemail.png',
              "objectType":"armor",
            'quantity': 1,
            'description':
                'Armor (medium). AC 14 + Dex (max 2). Disadvantage on Stealth checks.',
          },
          {
            'id': 'itm_lyra_healers_kit_01',
            'name': "Healer's Kit",
            'image': 'assets/items/healers_kit.png',
            'quantity': 1,
              "objectType":"item",
            'description':
                'Gear. Use to stabilize a creature at 0 HP (consumes 1 use).',
          },
          {
            'id': 'itm_lyra_potion_heal_01',
            'name': 'Potion of Healing',
            'image': 'assets/items/potion_healing.png',
              "objectType":"item",
            'quantity': 1,
            'description':
                'Consumable. Action: regain 2d4+2 HP. Consumed on use.',
          },
          {
            'id': 'itm_lyra_holy_symbol_01',
            'name': 'Holy Symbol',
            'image': 'assets/items/holy_symbol.png',
              "objectType":"item",
            'quantity': 1,
            'description':
                'Focus. Used to channel divine power and cast certain spells (if your rules use focuses).',
          },
        ],
      },
      abilities: {
        'skills': ['Backstab', 'Vanish'],
      },
    ),
    HeroDataSRD(
      id: 'option3',
      name: 'Torin',
      imageUrl: 'assets/images/thieffullbody.webp',
      imagePortrait: 'assets/images/thiefportrait.png',
      characterClass: "thief",
      stats: {
        'hpbaseline': 180,
        'hpcurrent': 165,
        'level': 7,
        'strength': 18,
        'dexterity': 9,
        'constitution': 17,
        'intelligence': 8,
        'wisdom': 10,
        'charisma': 7,
      },
      inventory: {
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
            "objectType":"onehand",
            'description':
                'Weapon (simple, finesse, light). +6 to hit. Damage: 1d4+4 piercing. Can be thrown (20/60).',
          },
          {
            'id': 'itm_torin_dagger_02',
            'name': 'Dagger',
            'image': 'assets/items/dagger.png',
            'quantity': 1,
            "objectType":"onehand",
            'description':
                'Weapon (simple, finesse, light). +6 to hit. Damage: 1d4+4 piercing. Can be thrown (20/60).',
          },
          {
            'id': 'itm_torin_leather_01',
            'name': 'Leather Armor',
            "objectType":"armor",
            'image': 'assets/items/leather_armor.png',
            'quantity': 1,
            'description': 'Armor (light). AC 11 + Dex.',
          },
          {
            'id': 'itm_torin_cloak_01',
            'name': 'Dark Cloak',
            'image': 'assets/items/cloak_dark.png',
              "objectType":"item",
            'quantity': 1,
            'description':
                'Gear. Helps conceal you in dim light (flavor / DM rulings).',
          },
          {
            'id': 'itm_torin_thieves_tools_01',
            'name': "Thieves' Tools",
            'image': 'assets/items/thieves_tools.png',
              "objectType":"item",
            'quantity': 1,
            'description': 'Tools. Used for lockpicking and disarming traps.',
          },
          {
            'id': 'itm_torin_smoke_01',
            'name': 'Smoke Bomb',
            'image': 'assets/items/bomb_smoke.png',
              "objectType":"consumable",
            'quantity': 2,
            'description':
                'Consumable. Action: create smoke to obscure an area. Consumed on use.',
          },
          {
            'id': 'itm_torin_rations_01',
            'name': 'Rations (1 day)',
            'image': 'assets/items/rations.png',
              "objectType":"consumable",
            'quantity': 5,
            'description': 'Consumable. Food for travel. Consumed on use.',
          },
        ],
      },
      abilities: {
        'skills': ['Taunt', 'Fortify'],
      },
    ),
    HeroDataSRD(
      id: 'option4',
      name: 'Nia',
      imageUrl: 'assets/images/wizardfullbody.webp',
      imagePortrait: 'assets/images/wizardportrait.png',
      characterClass: "wizard",
      stats: {
        'hpbaseline': 120,
        'hpcurrent': 110,
        'level': 6,
        'strength': 9,
        'dexterity': 13,
        'constitution': 12,
        'intelligence': 17,
        'wisdom': 15,
        'charisma': 12,
      },
      inventory: {
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
              "objectType":"twohand",
            'description':
                'Arcane focus. Melee weapon: +3 to hit, 1d6 bludgeoning. Used to channel spells.',
          },
          {
            'id': 'itm_nia_spellbook_01',
            'name': 'Spellbook',
            'image': 'assets/items/spellbook.png',
            'quantity': 1,
              "objectType":"item",
            'description':
                'Book containing your prepared knowledge. Needed to learn/prepare spells (depending on rules).',
          },
          {
            'id': 'itm_nia_mana_potion_01',
            'name': 'Mana Potion',
            'image': 'assets/items/potion_mana.png',
              "objectType":"consumable",
            'quantity': 2,
            'description':
                'Consumable. Action: restore magical energy (how much depends on your system).',
          },
          {
            'id': 'itm_nia_scroll_01',
            'name': 'Spell Scroll (Magic Missile)',
            'image': 'assets/items/scroll.png',
              "objectType":"consumable",
            'quantity': 1,
            'description':
                'Consumable. Action: cast Magic Missile from the scroll. Consumed on use.',
          },
          {
            'id': 'itm_nia_component_pouch_01',
            'name': 'Component Pouch',
            'image': 'assets/items/component_pouch.png',
              "objectType":"consumable",
            'quantity': 1,
            'description':
                'Gear. Contains basic spell components (if your rules use components).',
          },
        ],
      },
      abilities: {
        'skills': ['Arc Bolt', 'Heal'],
      },
    ),
  ];

  static final List<String> _heroIds = _heroes
      .map((HeroDataSRD hero) => hero.id)
      .toList(growable: false);

  static HeroDataSRD _heroById(String heroId) {
    return _heroes.firstWhere(
      (HeroDataSRD hero) => hero.id == heroId,
      orElse: () => _heroes.first,
    );
  }

  Widget _buildGameChatPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 20, 12),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Game Chat Placeholder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_heroes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SizedBox.expand(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: _buildGameChatPlaceholder()),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: CharactersPanelSRD(
                    hero: _heroes.first,
                    heroIds: _heroIds,
                    heroById: _heroById,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
