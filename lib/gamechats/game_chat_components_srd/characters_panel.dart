import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'hero_panel_stats.dart';
import 'srd_models.dart';
import "characters_panel_parts.dart";
import "hero_inventory.dart";


enum HeroPanelTab { stats, inventory, abilities }

class CharactersPanelSRD extends StatefulWidget {
  final HeroDataSRD hero;
  final List<String> heroIds;
  final HeroDataSRD Function(String heroId) heroById;

  const CharactersPanelSRD({
    super.key,
    required this.hero,
    required this.heroIds,
    required this.heroById,
  });

  @override
  State<CharactersPanelSRD> createState() => _CharactersPanelSRDState();
}

class _CharactersPanelSRDState extends State<CharactersPanelSRD> {
  final ScrollController _headerScrollController = ScrollController();
  late String _selectedHeroId;
  HeroPanelTab _selectedTab = HeroPanelTab.stats;

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
  void didUpdateWidget(covariant CharactersPanelSRD oldWidget) {
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
      _selectedTab = HeroPanelTab.stats;
    });
  }

  void _selectTab(HeroPanelTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
    });
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
              separatorBuilder: (_, index) => const SizedBox(width: 16),
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

  Widget _buildSelectedHeroPanel(HeroDataSRD hero) {
    return Stack(
      children: [
        Container(
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
                "${hero.name} lv.${hero.stats["level"]}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildPanelContent(hero)),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _PanelIconButton(
                assetPath: 'assets/icons/Character.svg',
                isSelected: _selectedTab == HeroPanelTab.stats,
                onTap: () => _selectTab(HeroPanelTab.stats),
              ),
              const SizedBox(width: 8),
              _PanelIconButton(
                assetPath: 'assets/icons/inventory.svg',
                isSelected: _selectedTab == HeroPanelTab.inventory,
                onTap: () => _selectTab(HeroPanelTab.inventory),
              ),
              const SizedBox(width: 8),
              _PanelIconButton(
                assetPath: 'assets/icons/abilities.svg',
                isSelected: _selectedTab == HeroPanelTab.abilities,
                onTap: () => _selectTab(HeroPanelTab.abilities),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanelContent(HeroDataSRD hero) {
    switch (_selectedTab) {
      case HeroPanelTab.stats:
        return HeroPanelsStats(hero: hero);
      case HeroPanelTab.inventory:
        return HeroInventory(hero: hero);
      case HeroPanelTab.abilities:
        return HeroAbilities(hero: hero);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heroIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final HeroDataSRD selectedHero = widget.heroById(_selectedHeroId);

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

class _PanelIconButton extends StatelessWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PanelIconButton({
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? const Color.fromARGB(255, 235, 180, 70)
        : Colors.white30;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}

class HeroAbilities extends StatelessWidget {
  final HeroDataSRD hero;

  const HeroAbilities({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 55, 10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: const Center(
        child: Text(
          'Abilities (placeholder)',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
