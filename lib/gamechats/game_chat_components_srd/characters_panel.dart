import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'hero_panel_stats.dart';
import 'srd_hero_models.dart';
import "characters_panel_parts.dart";
import "hero_inventory.dart";
import 'hero_ability.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  '${hero.name} lv.${hero.stats.level}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildPanelContent(hero)),
            ],
          ),
        ),
        Positioned(top: 16, right: 16, child: _buildPanelTabs()),
      ],
    );
  }

  Widget _buildPanelTabs() {
  
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        _PanelIconButton(
          assetPath: 'assets/icons/Character.svg',
          isSelected: _selectedTab == HeroPanelTab.stats,
          onTap: () => _selectTab(HeroPanelTab.stats),
        ),
        const SizedBox(height: 8),
        _PanelIconButton(
          assetPath: 'assets/icons/inventory.svg',
          isSelected: _selectedTab == HeroPanelTab.inventory,
          onTap: () => _selectTab(HeroPanelTab.inventory),
        ),
        const SizedBox(height: 8),
        _PanelIconButton(
          assetPath: 'assets/icons/abilities.svg',
          isSelected: _selectedTab == HeroPanelTab.abilities,
          onTap: () => _selectTab(HeroPanelTab.abilities),
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

          return Stack(
            fit: StackFit.expand,
            children: [
              const ImageBackGroundFill(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroButtons(
                    height: buttonsHeight,
                    itemDiameter: itemDiameter,
                  ),
                  SizedBox(
                    height: 16,
                    width: double.infinity,
                    child: SvgPicture.asset(
                      "assets/icons/charcterpaneldivider.svg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(child: _buildSelectedHeroPanel(selectedHero)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStatusSummary extends StatelessWidget {
  final HeroDataSRD hero;

  const _HeroStatusSummary({required this.hero});

  @override
  Widget build(BuildContext context) {
    final stats = hero.stats;
    final hp = stats.hp;
    final currentHp = stats.currentHp;
    final hpProgress = hp <= 0 ? 0.0 : _clampProgress(currentHp / hp);
    final isMaxLevel = stats.level >= heroMaxLevel;
    final expCap = expCapForLevel(stats.level);
    final expProgress = isMaxLevel
        ? 1.0
        : _clampProgress(stats.currentExp / expCap);
    final expValueText = isMaxLevel ? 'Max/Max' : '${stats.currentExp}/$expCap';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 182),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeroProgressCard(
            label: 'Health',
            valueText: '$currentHp/$hp',
            progress: hpProgress,
            fillColor: const Color(0xFFD65245),
            fillKey: const ValueKey('hero-health-fill'),
          ),
          const SizedBox(width: 6),
          _HeroProgressCard(
            label: 'EXP',
            valueText: expValueText,
            progress: expProgress,
            fillColor: const Color(0xFF4C8DDA),
            fillKey: const ValueKey('hero-exp-fill'),
          ),
        ],
      ),
    );
  }

  double _clampProgress(num value) {
    if (!value.isFinite || value <= 0) {
      return 0.0;
    }
    if (value >= 1) {
      return 1.0;
    }
    return value.toDouble();
  }
}

class _HeroProgressCard extends StatelessWidget {
  static const double _cardWidth = 88;
  final String label;
  final String valueText;
  final double progress;
  final Color fillColor;
  final Key fillKey;

  const _HeroProgressCard({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.fillColor,
    required this.fillKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E2B26),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    valueText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF2E2B26),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      ),
                      FractionallySizedBox(
                        key: fillKey,
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: fillColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

class ImageBackGroundFill extends StatelessWidget {
  const ImageBackGroundFill({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        "assets/images/characterpanelbackground.png",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Color.fromARGB(255, 102, 58, 4));
        },
      ),
    );
  }
}
