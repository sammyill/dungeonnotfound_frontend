import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImgButtonComponent extends StatelessWidget {
  final String id;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final double itemDiameter;
  final Color itemColor;
  final double borderThickness;
  final double lineThickness;

  const ImgButtonComponent({
    super.key,
    required this.id,
    required this.imageUrl,
    this.isSelected = false,
    required this.onTap,
    this.itemDiameter = 90.0,
    this.itemColor = const Color.fromARGB(255, 194, 145, 1),
    this.borderThickness = 4.0,
    this.lineThickness = 4.0,
  });

  static const double _kVerticalSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final double innerSize = itemDiameter - (borderThickness * 2);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: itemDiameter,
            height: itemDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: itemColor, width: borderThickness)
                  : Border.all(color: itemColor, width: 2),
            ),
            child: ClipOval(
              child: ColoredBox(
                color: Colors.grey.shade200,
                child: Image.asset(
                  imageUrl,
                  width: innerSize,
                  height: innerSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.black45,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: _kVerticalSpacing),
              width: itemDiameter * 0.9,
              height: lineThickness,
              decoration: BoxDecoration(
                color: itemColor,
                borderRadius: BorderRadius.circular(lineThickness / 2),
              ),
            ),
        ],
      ),
    );
  }
}

class DNDStatsDisplay extends StatelessWidget {
  final String iconAssetPath;
  final String statName;
  final String value;
  static const EdgeInsetsGeometry contentPadding=EdgeInsets.symmetric(horizontal: 14);
   static const BorderRadius borderRadius=BorderRadius.all(Radius.circular(10));
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
  static String scrollBackgroundAssetPath =
      'assets/images/scroll.png';

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
        child: SvgPicture.asset(
          iconAssetPath,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                scrollBackgroundAssetPath,
                fit: BoxFit.fill,
              ),
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
