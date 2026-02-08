import 'package:flutter/material.dart';

import 'characterstats.dart';
import 'imgbuttoncomponent.dart';
class HeroData {
  final String id;
  final String name;
  final String imageUrl;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> inventory;
  final Map<String, dynamic> abilities;

  const HeroData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.stats,
    required this.inventory,
    required this.abilities,
  });
}

class DNDCharactersPanel extends StatefulWidget {
  final HeroData hero;
  final List<String> heroIds;
  final HeroData Function(String heroId) heroById;

  const DNDCharactersPanel({
    super.key,
    required this.hero,
    required this.heroIds,
    required this.heroById,
  });

  @override
  State<DNDCharactersPanel> createState() => _DNDCharactersPanelState();
}

class _DNDCharactersPanelState extends State<DNDCharactersPanel> {
  late String _selectedHeroId;

  @override
  void initState() {
    super.initState();
    _selectedHeroId = _resolveInitialSelectedId();
  }

  @override
  void didUpdateWidget(covariant DNDCharactersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.heroIds.contains(_selectedHeroId)) {
      _selectedHeroId = _resolveInitialSelectedId();
    }
  }

  String _resolveInitialSelectedId() {
    if (widget.heroIds.contains(widget.hero.id)) {
      return widget.hero.id;
    }
    if (widget.heroIds.isNotEmpty) {
      return widget.heroIds.first;
    }
    return widget.hero.id;
  }

  void _selectHero(String heroId) {
    if (_selectedHeroId == heroId) {
      return;
    }
    setState(() {
      _selectedHeroId = heroId;
    });
  }

  Widget _buildHeroImage(HeroData hero) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        hero.imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 220,
            color: const Color.fromARGB(255, 20, 210, 128),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.white54,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroButtons() {
    return Container(
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
          children: widget.heroIds.map<Widget>((String heroId) {
            final HeroData hero = widget.heroById(heroId);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ImgButtonComponent(
                id: heroId,
                imageUrl: hero.imageUrl,
                isSelected: _selectedHeroId == heroId,
                onTap: () => _selectHero(heroId),
                itemDiameter: 90.0,
              ),
            );
          }).toList(),
        ),
    );
  }

  Widget _buildSelectedHeroPanel(HeroData hero) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 68, 34, 0),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hero.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildHeroImage(hero),
          const SizedBox(height: 16),
          CharacterStats(stats: hero.stats),
          const SizedBox(height: 16),
          // Inventory and abilities widgets will go here later.
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heroIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final HeroData selectedHero = widget.heroById(_selectedHeroId);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroButtons(),
        const SizedBox(height: 16),
        _buildSelectedHeroPanel(selectedHero),
      ],
    );
  }
}
