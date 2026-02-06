import 'package:flutter/material.dart';

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

class ImageButtonData extends ChangeNotifier {
  String _selectedId;
  final List<Map<String, String>> _buttons;

  ImageButtonData({required List<Map<String, String>> buttons})
    : _buttons = buttons,
      _selectedId = buttons.isNotEmpty ? buttons[0]['id']! : '';

  String get selectedId => _selectedId;

  List<Map<String, String>> get buttons => _buttons;

  void selectButton(String id) {
    if (_selectedId != id) {
      _selectedId = id;
      notifyListeners();
    }
  }
}

class PgView extends StatelessWidget {
  final HeroData hero;

  const PgView({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  hero.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 28,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Stats: ${hero.stats}\\n'
                  'Inventory: ${hero.inventory}\\n'
                  'Abilities: ${hero.abilities}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
