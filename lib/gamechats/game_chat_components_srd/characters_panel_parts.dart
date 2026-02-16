import 'package:flutter/material.dart';


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

