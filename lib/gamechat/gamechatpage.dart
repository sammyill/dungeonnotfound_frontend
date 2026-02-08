import 'package:flutter/material.dart';

import 'gamechatcomponents/characterspanel.dart';

class GameChatPage extends StatelessWidget {
  const GameChatPage({super.key});

  static const List<HeroData> _heroes = [
    HeroData(
      id: 'option1',
      name: 'Arden',
      imageUrl: 'https://picsum.photos/seed/hero1/400',
      stats: {
        'hpbaseline': 140,
        'hpcurrent': 120,
        'level': 6,
        'strenght': 16,
        'dexterity': 12,
        'constitution': 15,
        'intelligence': 10,
        'wisdom': 11,
        'charisma': 9,
      },
      inventory: {
        'gold': 250,
        'items': ['Potion', 'Elixir'],
      },
      abilities: {
        'skills': ['Slash', 'Shield Bash'],
      },
    ),
    HeroData(
      id: 'option2',
      name: 'Lyra',
      imageUrl: 'https://picsum.photos/seed/hero2/400',
      stats: {
        'hpbaseline': 100,
        'hpcurrent': 88,
        'level': 5,
        'strenght': 10,
        'dexterity': 17,
        'constitution': 11,
        'intelligence': 13,
        'wisdom': 12,
        'charisma': 14,
      },
      inventory: {
        'gold': 180,
        'items': ['Dagger', 'Smoke Bomb'],
      },
      abilities: {
        'skills': ['Backstab', 'Vanish'],
      },
    ),
    HeroData(
      id: 'option3',
      name: 'Torin',
      imageUrl: 'https://picsum.photos/seed/hero3/400',
      stats: {
        'hpbaseline': 180,
        'hpcurrent': 165,
        'level': 7,
        'strenght': 18,
        'dexterity': 9,
        'constitution': 17,
        'intelligence': 8,
        'wisdom': 10,
        'charisma': 7,
      },
      inventory: {
        'gold': 95,
        'items': ['Greatshield', 'Rations'],
      },
      abilities: {
        'skills': ['Taunt', 'Fortify'],
      },
    ),
    HeroData(
      id: 'option4',
      name: 'Nia',
      imageUrl: 'https://picsum.photos/seed/hero4/400',
      stats: {
        'hpbaseline': 120,
        'hpcurrent': 110,
        'level': 6,
        'strenght': 9,
        'dexterity': 13,
        'constitution': 12,
        'intelligence': 17,
        'wisdom': 15,
        'charisma': 12,
      },
      inventory: {
        'gold': 310,
        'items': ['Staff', 'Mana Potion'],
      },
      abilities: {
        'skills': ['Arc Bolt', 'Heal'],
      },
    ),
  ];

  static final List<String> _heroIds = _heroes
      .map((HeroData hero) => hero.id)
      .toList(growable: false);

  static HeroData _heroById(String heroId) {
    return _heroes.firstWhere(
      (HeroData hero) => hero.id == heroId,
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildGameChatPlaceholder()),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
             
                child: DNDCharactersPanel(
                  hero: _heroes.first,
                  heroIds: _heroIds,
                  heroById: _heroById,
                ),
            ),
          ],
        ),
      ),
    );
  }
}
