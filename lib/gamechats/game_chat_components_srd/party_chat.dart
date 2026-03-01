import 'package:flutter/material.dart';

import 'srd_chat_models.dart';
import 'srd_hero_models.dart';

class PartyChat extends StatelessWidget {
  final List<PartyChatInteraction> interactions;
  final List<HeroDataSRD> heroes;

  const PartyChat({
    super.key,
    required this.interactions,
    required this.heroes,
  });

  @override
  Widget build(BuildContext context) {
    final heroNameById = <String, String>{
      for (final hero in heroes) hero.id: hero.name,
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 20, 12),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: interactions.isEmpty
          ? const Center(
              child: Text(
                'No party chat interactions',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, index) {
                return _PartyChatInteractionCard(
                  interaction: interactions[index],
                  heroNameById: heroNameById,
                );
              },
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemCount: interactions.length,
            ),
    );
  }
}

class _PartyChatInteractionCard extends StatelessWidget {
  final PartyChatInteraction interaction;
  final Map<String, String> heroNameById;

  const _PartyChatInteractionCard({
    required this.interaction,
    required this.heroNameById,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 58, 36, 16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  interaction.ownerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 106, 66, 26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  interaction.type.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (interaction is FreeMessageInteraction) {
      final msg = interaction as FreeMessageInteraction;
      return _messageText(msg.messageText);
    }

    if (interaction is DmLevelUpInteraction) {
      final msg = interaction as DmLevelUpInteraction;
      return _messageText(msg.messageText);
    }

    if (interaction is PlayerLevelUpInteraction) {
      final msg = interaction as PlayerLevelUpInteraction;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _statChip('STR', msg.strength),
          _statChip('DEX', msg.dexterity),
          _statChip('CON', msg.constitution),
          _statChip('INT', msg.intelligence),
          _statChip('WIS', msg.wisdom),
          _statChip('CHA', msg.charisma),
        ],
      );
    }

    if (interaction is DmActionInteraction) {
      final msg = interaction as DmActionInteraction;
      final targetName = heroNameById[msg.actionTarget];
      final targetLabel = targetName == null
          ? msg.actionTarget
          : '$targetName (${msg.actionTarget})';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _messageText(msg.messageText),
          const SizedBox(height: 6),
          Text(
            'Target: $targetLabel',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (interaction is PlayerActionInteraction) {
      final msg = interaction as PlayerActionInteraction;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _messageText(msg.messageText),
          const SizedBox(height: 6),
          Text(
            'Roll: ${msg.roll}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _messageText(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.25),
    );
  }

  Widget _statChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 106, 66, 26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
