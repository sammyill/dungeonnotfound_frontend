import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'hero_panel_stats.dart';
import 'srd_models.dart';
import "dnd_characters_panel_parts.dart";


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


class HeroInventory extends StatelessWidget {
  final HeroDataSRD hero;

  const HeroInventory({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryData.fromJson(hero.inventory);
    final mainHandItem = inventory.findItemById(
      inventory.equippedSlots['mainHand'],
    );
    final offHandItem = inventory.findItemById(
      inventory.equippedSlots['offHand'],
    );
    final armorItem = inventory.findItemById(inventory.equippedSlots['armor']);
    final offHandBlocked =
        mainHandItem?.objectType == InventoryObjectType.twohand;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double moneyH = constraints.maxHeight * 0.10;
        final double equippedH = constraints.maxHeight * 0.20;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: moneyH,
              child: _InventoryMoneyBar(currency: inventory.currency),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: equippedH,
              child: _EquippedSlotsRow(
                mainHandItem: mainHandItem,
                offHandItem: offHandItem,
                armorItem: armorItem,
                offHandBlocked: offHandBlocked,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _InventoryItemsList(inventory: inventory)),
          ],
        );
      },
    );
  }
}

class _InventoryMoneyBar extends StatelessWidget {
  final CurrencyData currency;

  const _InventoryMoneyBar({required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 55, 10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text(
            'INVENTORY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          _CurrencyChip(label: 'GP', value: currency.gp),
          const SizedBox(width: 6),
          _CurrencyChip(label: 'SP', value: currency.sp),
          const SizedBox(width: 6),
          _CurrencyChip(label: 'CP', value: currency.cp),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String label;
  final int value;

  const _CurrencyChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 68, 34, 0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EquippedSlotsRow extends StatelessWidget {
  final InventoryItemData? mainHandItem;
  final InventoryItemData? offHandItem;
  final InventoryItemData? armorItem;
  final bool offHandBlocked;

  const _EquippedSlotsRow({
    required this.mainHandItem,
    required this.offHandItem,
    required this.armorItem,
    required this.offHandBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _EquippedSlotCard(slotLabel: 'Main Hand', item: mainHandItem),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EquippedSlotCard(
            slotLabel: 'Off Hand',
            item: offHandBlocked ? null : offHandItem,
            blockedByTwoHand: offHandBlocked,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EquippedSlotCard(slotLabel: 'Armor', item: armorItem),
        ),
      ],
    );
  }
}

class _EquippedSlotCard extends StatelessWidget {
  final String slotLabel;
  final InventoryItemData? item;
  final bool blockedByTwoHand;

  const _EquippedSlotCard({
    required this.slotLabel,
    required this.item,
    this.blockedByTwoHand = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasItem = item != null;
    final String title = blockedByTwoHand
        ? 'Blocked'
        : hasItem
        ? item!.name
        : 'Empty';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 85, 47, 8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slotLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ItemThumb(
                  imagePath: item?.image,
                  fallbackIcon: blockedByTwoHand
                      ? Icons.block
                      : item == null
                      ? Icons.crop_square
                      : _iconForType(item!.objectType),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: blockedByTwoHand
                          ? Colors.orange.shade200
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (blockedByTwoHand)
            const Text(
              'Two-Handed',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

class _InventoryItemsList extends StatelessWidget {
  final InventoryData inventory;

  const _InventoryItemsList({required this.inventory});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 68, 34, 0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Text(
              'Items',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(120, 189, 88, 0)),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: inventory.items.length,
              separatorBuilder: (_, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = inventory.items[index];
                return _InventoryItemTile(
                  item: item,
                  isEquipped: inventory.isEquipped(item.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final InventoryItemData item;
  final bool isEquipped;

  const _InventoryItemTile({required this.item, required this.isEquipped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 55, 10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemThumb(
            imagePath: item.image,
            fallbackIcon: _iconForType(item.objectType),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isEquipped) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 35, 95, 43),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Equipped',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;

  const _ItemThumb({required this.imagePath, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        color: const Color.fromARGB(255, 44, 24, 5),
        child: imagePath == null
            ? Icon(fallbackIcon, size: 18, color: Colors.white70)
            : Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, size: 18, color: Colors.white70);
                },
              ),
      ),
    );
  }
}

IconData _iconForType(InventoryObjectType objectType) {
  switch (objectType) {
    case InventoryObjectType.onehand:
      return Icons.handyman;
    case InventoryObjectType.twohand:
      return Icons.construction;
    case InventoryObjectType.armor:
      return Icons.shield;
    case InventoryObjectType.consumable:
      return Icons.medication;
    case InventoryObjectType.item:
      return Icons.inventory_2;
    case InventoryObjectType.unknown:
      return Icons.help_outline;
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
