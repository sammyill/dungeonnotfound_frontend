import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gamechatcomponents/imgbuttoncomponent.dart';
import 'gamechatcomponents/pgview.dart';

class GameChatPage extends StatelessWidget {
  const GameChatPage({super.key});

  static const List<HeroData> _heroes = [
    HeroData(
      id: 'option1',
      name: 'Arden',
      imageUrl: 'https://picsum.photos/seed/hero1/400',
      stats: {'hp': 120, 'atk': 34, 'def': 20},
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
      stats: {'hp': 90, 'atk': 48, 'def': 12},
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
      stats: {'hp': 160, 'atk': 26, 'def': 40},
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
      stats: {'hp': 110, 'atk': 30, 'def': 18},
      inventory: {
        'gold': 310,
        'items': ['Staff', 'Mana Potion'],
      },
      abilities: {
        'skills': ['Arc Bolt', 'Heal'],
      },
    ),
  ];

  static final List<Map<String, String>> _buttons = _heroes
      .map(
        (HeroData hero) => <String, String>{
          'id': hero.id,
          'imageUrl': hero.imageUrl,
        },
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImageButtonData>(
      create: (BuildContext context) => ImageButtonData(buttons: _buttons),
      child: SizedBox.expand(
        child: Consumer<ImageButtonData>(
          builder:
              (BuildContext context, ImageButtonData imageData, Widget? child) {
                if (imageData.buttons.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 121, 57, 0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 189, 88, 0),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: imageData.buttons.map<Widget>((
                          Map<String, String> buttonMap,
                        ) {
                          final String id = buttonMap['id']!;
                          final String imageUrl = buttonMap['imageUrl']!;
                          final bool isSelected = imageData.selectedId == id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ImgButtonComponent(
                              id: id,
                              imageUrl: imageUrl,
                              isSelected: isSelected,
                              onTap: () => imageData.selectButton(id),
                              itemDiameter: 90.0,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PgView(
                      hero: _heroes.firstWhere(
                        (HeroData hero) => hero.id == imageData.selectedId,
                        orElse: () => _heroes.first,
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}
