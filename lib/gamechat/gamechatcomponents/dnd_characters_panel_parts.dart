import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
