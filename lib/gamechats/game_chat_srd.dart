import 'package:flutter/material.dart';
import 'game_chat_components_srd/characters_panel.dart';
import 'game_chat_components_srd/party_chat.dart';
import 'game_chat_components_srd/srd_chat_models.dart';
import 'game_chat_components_srd/srd_hero_models.dart';

class GameChatPageSRD extends StatelessWidget {
  final List<Map<String, dynamic>> heroesJson;
  final List<Map<String, dynamic>> chatJson;
  final Map<String, dynamic> playerHeroJson;

  GameChatPageSRD({
    super.key,
    required this.heroesJson,
    required this.chatJson,
    required this.playerHeroJson,
  });

  late final List<HeroDataSRD> _heroes = heroesJson
      .map((heroJson) => HeroDataSRD.fromJson(heroJson))
      .toList(growable: false);

  late final List<PartyChatInteraction> _chatInteractions = chatJson
      .map(PartyChatInteraction.fromJson)
      .toList(growable: false);

  late final List<String> _heroIds = _heroes
      .map((HeroDataSRD hero) => hero.id)
      .toList(growable: false);

  late final String _playerHeroId = _readPlayerHeroId(playerHeroJson);

  late final HeroDataSRD _playerHero = _heroById(_playerHeroId);

  HeroDataSRD _heroById(String heroId) {
    return _heroes.firstWhere(
      (HeroDataSRD hero) => hero.id == heroId,
      orElse: () => _heroes.first,
    );
  }

  static String _readPlayerHeroId(Map<String, dynamic> json) {
    final value = json['hero_id'];
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    return value.toString();
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
                Expanded(
                  flex: 2,
                  child: PartyChat(
                    interactions: _chatInteractions,
                    heroes: _heroes,
                    playerHero: _playerHero,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: CharactersPanelSRD(
                    hero: _playerHero,
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
