import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'srd_hero_models.dart';

class HeroPanelsStats extends StatelessWidget {
  final HeroDataSRD hero;

  const HeroPanelsStats({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double statsHeight = constraints.maxHeight * 0.30;

        return Stack(
          fit: StackFit.expand,
          children: [
            HeroImageFill(imagePath: hero.imageUrl),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: statsHeight,
              child: Center(child: CharacterStats(stats: hero.stats)),
            ),
          ],
        );
      },
    );
  }
}

class HeroImageFill extends StatelessWidget {
  final String imagePath;

  const HeroImageFill({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
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
}

class CharacterStats extends StatelessWidget {
  final HeroStatsSRD stats;

  const CharacterStats({super.key, required this.stats});

  static const List<_StatField> _charstats = [
    _StatField(
      label: 'Strength',
      iconPath: 'assets/icons/strength.svg',
      selector: _strengthValue,
    ),
    _StatField(
      label: 'Dexterity',
      iconPath: 'assets/icons/dexterity.svg',
      selector: _dexterityValue,
    ),
    _StatField(
      label: 'Constitution',
      iconPath: 'assets/icons/constitution.svg',
      selector: _constitutionValue,
    ),
    _StatField(
      label: 'Intelligence',
      iconPath: 'assets/icons/intelligence.svg',
      selector: _intelligenceValue,
    ),
    _StatField(
      label: 'Wisdom',
      iconPath: 'assets/icons/wisdom.svg',
      selector: _wisdomValue,
    ),
    _StatField(
      label: 'Charisma',
      iconPath: 'assets/icons/charisma.svg',
      selector: _charismaValue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < _charstats.length; i += 2) {
      final _StatField left = _charstats[i];
      final _StatField? right = i + 1 < _charstats.length
          ? _charstats[i + 1]
          : null;

      rows.add(
        SizedBox(
          height: 42,
          child: Row(
            children: [
              Expanded(
                child: DNDStatsDisplay(
                  iconAssetPath: left.iconPath,
                  statName: left.label,
                  value: left.selector(stats).toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : DNDStatsDisplay(
                        iconAssetPath: right.iconPath,
                        statName: right.label,
                        value: right.selector(stats).toString(),
                      ),
              ),
            ],
          ),
        ),
      );

      if (i + 2 < _charstats.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

int _strengthValue(HeroStatsSRD stats) => stats.strength;

int _dexterityValue(HeroStatsSRD stats) => stats.dexterity;

int _constitutionValue(HeroStatsSRD stats) => stats.constitution;

int _intelligenceValue(HeroStatsSRD stats) => stats.intelligence;

int _wisdomValue(HeroStatsSRD stats) => stats.wisdom;

int _charismaValue(HeroStatsSRD stats) => stats.charisma;

class _StatField {
  final String label;
  final String iconPath;
  final int Function(HeroStatsSRD stats) selector;

  const _StatField({
    required this.label,
    required this.iconPath,
    required this.selector,
  });
}

class DNDStatsDisplay extends StatelessWidget {
  final String iconAssetPath;
  final String statName;
  final String value;
  static const EdgeInsetsGeometry contentPadding = EdgeInsets.symmetric(
    horizontal: 14,
  );
  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(10),
  );
  static const TextStyle labelStyle = TextStyle(
    color: Color.fromARGB(255, 0, 0, 0),
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle valueStyle = TextStyle(
    color: Color.fromARGB(255, 0, 0, 0),
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static String scrollBackgroundAssetPath = 'assets/images/scroll.png';

  const DNDStatsDisplay({
    super.key,
    required this.iconAssetPath,
    required this.statName,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1, // square icon area: width == available height
          child: SvgPicture.asset(iconAssetPath, fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(scrollBackgroundAssetPath, fit: BoxFit.fill),
                Center(
                  child: Padding(
                    padding: contentPadding,
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: labelStyle,
                        children: [
                          TextSpan(text: '$statName '),
                          TextSpan(text: value, style: valueStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
