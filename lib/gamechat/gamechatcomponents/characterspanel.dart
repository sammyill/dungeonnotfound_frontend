import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'characterstats.dart';
import 'imgbuttoncomponent.dart';

class HeroData {
  final String id;
  final String name;
  final String imageUrl;
  final String imagePortrait;
  final String characterclass;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> inventory;
  final Map<String, dynamic> abilities;

  const HeroData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imagePortrait,
    required this.characterclass,
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
  final ScrollController _headerScrollController = ScrollController();
  late String _selectedHeroId;

  @override
  void initState() {
    super.initState();
    _selectedHeroId = _resolveInitialSelectedId();
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    super.dispose();
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
      child: Image.asset(
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

  Widget _buildHeroButtons({
    required double height,
    required double itemDiameter,
  }) {
    final controller = _headerScrollController;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 121, 57, 0),
          border: Border.all(
            color: const Color.fromARGB(255, 189, 88, 0),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          child: RawScrollbar(
            controller: controller,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 14,
            radius: const Radius.circular(12),
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                bottom: 18,
              ), // <— important: leaves grab space
              itemCount: widget.heroIds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final heroId = widget.heroIds[index];
                final hero = widget.heroById(heroId);
                return ImgButtonComponent(
                  id: heroId,
                  imageUrl: hero.imagePortrait,
                  isSelected: _selectedHeroId == heroId,
                  onTap: () => _selectHero(heroId),
                  itemDiameter: itemDiameter,
                );
              },
            ),
          ),
        ),
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

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonsHeight = constraints.maxHeight * 0.20;
          final itemDiameter = buttonsHeight * 0.72;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroButtons(
                height: buttonsHeight,
                itemDiameter: itemDiameter,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildSelectedHeroPanel(selectedHero)),
            ],
          );
        },
      ),
    );
  }
}
