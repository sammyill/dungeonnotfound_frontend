import 'package:flutter/material.dart';

class CharacterStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const CharacterStats({super.key, required this.stats});

  static const List<_StatField> _fields = [
    _StatField('HP Base', 'hpbaseline'),
    _StatField('HP Current', 'hpcurrent'),
    _StatField('Level', 'level'),
    _StatField('Strength', 'strenght'),
    _StatField('Dexterity', 'dexterity'),
    _StatField('Constitution', 'constitution'),
    _StatField('Intelligence', 'intelligence'),
    _StatField('Wisdom', 'wisdom'),
    _StatField('Charisma', 'charisma'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < _fields.length; i += 2) {
      final _StatField left = _fields[i];
      final _StatField? right = i + 1 < _fields.length ? _fields[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              child: _StatTile(label: left.label, value: stats[left.key]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _StatTile(label: right.label, value: stats[right.key]),
            ),
          ],
        ),
      );

      if (i + 2 < _fields.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _StatField {
  final String label;
  final String key;

  const _StatField(this.label, this.key);
}

class _StatTile extends StatelessWidget {
  final String label;
  final dynamic value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 55, 10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
