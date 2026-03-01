import 'package:flutter/material.dart';

import 'srd_models.dart';

const Color _abilityCardColor = Color.fromARGB(255, 120, 74, 18);
const Color _abilityTagColor = Color.fromARGB(255, 68, 34, 0);

class HeroAbilities extends StatelessWidget {
  final HeroDataSRD hero;

  const HeroAbilities({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final abilities = hero.abilities.abilityList;

    return SizedBox(
      width: double.infinity,

      child: abilities.isEmpty
          ? const Center(
              child: Text(
                'No abilities available',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: abilities.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _AbilityCard(ability: abilities[index]);
              },
            ),
    );
  }
}

class _AbilityCard extends StatelessWidget {
  final AbilityDataSRD ability;

  const _AbilityCard({required this.ability});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _abilityCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AbilityImage(imagePath: ability.image),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ability.name.isEmpty ? 'Unknown Ability' : ability.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ability.description.isEmpty
                      ? 'No description'
                      : ability.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _AbilityTag(label: _kindLabel(ability.kind)),
                    _AbilityTag(label: _actionCostLabel(ability.actionCost)),
                    _AbilityTag(label: _rangeLabel(ability.range)),
                    _AbilityTag(
                      label: ability.magical ? 'Magical' : 'Non-magical',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityTag extends StatelessWidget {
  final String label;

  const _AbilityTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _abilityTagColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AbilityImage extends StatelessWidget {
  final String imagePath;

  const _AbilityImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 52,
        child: hasImage
            ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _abilityFallbackIcon();
                },
              )
            : _abilityFallbackIcon(),
      ),
    );
  }
}

Widget _abilityFallbackIcon() {
  return Container(
    color: const Color.fromARGB(255, 53, 30, 7),
    child: const Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
  );
}

String _kindLabel(AbilityKind kind) {
  switch (kind) {
    case AbilityKind.attack:
      return 'Attack';
    case AbilityKind.heal:
      return 'Heal';
    case AbilityKind.utility:
      return 'Utility';
    case AbilityKind.passive:
      return 'Passive';
  }
}

String _actionCostLabel(AbilityActionCost actionCost) {
  switch (actionCost) {
    case AbilityActionCost.action:
      return 'Action';
    case AbilityActionCost.bonusAction:
      return 'Bonus Action';
    case AbilityActionCost.reaction:
      return 'Reaction';
    case AbilityActionCost.passive:
      return 'Passive';
  }
}

String _rangeLabel(int range) {
  if (range <= 0) {
    return 'Range: Self';
  }
  return 'Range: $range ft';
}
