import 'package:flutter/material.dart';
import 'srd_hero_models.dart';

const Color inventoryBackGroundColor = Color.fromARGB(255, 160, 120, 70);
const Color inventoryTextColor = Colors.white;

class HeroInventory extends StatelessWidget {
  final HeroDataSRD hero;

  const HeroInventory({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final inventory = hero.inventory;
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
              child: InventoryMoneyBar(currency: inventory.currency),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: equippedH,
              child: EquippedSlotsRow(
                mainHandItem: mainHandItem,
                offHandItem: offHandItem,
                armorItem: armorItem,
                offHandBlocked: offHandBlocked,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: InventoryItemsList(inventory: inventory)),
          ],
        );
      },
    );
  }
}

class InventoryMoneyBar extends StatelessWidget {
  final CurrencyData currency;

  const InventoryMoneyBar({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inventoryBackGroundColor,
        borderRadius: BorderRadius.circular(8),
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
          CurrencyChip(label: 'GP', value: currency.gp),
          const SizedBox(width: 6),
          CurrencyChip(label: 'SP', value: currency.sp),
          const SizedBox(width: 6),
          CurrencyChip(label: 'CP', value: currency.cp),
        ],
      ),
    );
  }
}

class CurrencyChip extends StatelessWidget {
  final String label;
  final int value;

  const CurrencyChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: inventoryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EquippedSlotsRow extends StatelessWidget {
  final InventoryItemData? mainHandItem;
  final InventoryItemData? offHandItem;
  final InventoryItemData? armorItem;
  final bool offHandBlocked;

  const EquippedSlotsRow({
    super.key,
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
          child: EquippedSlotCard(slotLabel: 'Main Hand', item: mainHandItem),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: EquippedSlotCard(
            slotLabel: 'Off Hand',
            item: offHandBlocked ? null : offHandItem,
            blockedByTwoHand: offHandBlocked,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: EquippedSlotCard(slotLabel: 'Armor', item: armorItem),
        ),
      ],
    );
  }
}

class EquippedSlotCard extends StatelessWidget {
  final String slotLabel;
  final InventoryItemData? item;
  final bool blockedByTwoHand;

  const EquippedSlotCard({
    super.key,
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inventoryBackGroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "$slotLabel: $title",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: EquippedItemImage(
              imagePath: item?.image,
              fallbackIcon: blockedByTwoHand
                  ? Icons.block
                  : item == null
                  ? Icons.crop_square
                  : iconForType(item!.objectType),
            ),
          ),
        ],
      ),
    );
  }
}

class EquippedItemImage extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;

  const EquippedItemImage({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: 50,
        height: 50,
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

class InventoryItemsList extends StatelessWidget {
  final HeroInventorySRD inventory;

  const InventoryItemsList({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: Text(
            'Items',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const Divider(height: 1, color: Color.fromARGB(120, 189, 88, 0)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(3),
            itemCount: inventory.items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = inventory.items[index];
              return InventoryItemTile(
                item: item,
                isEquipped: inventory.isEquipped(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class InventoryItemTile extends StatelessWidget {
  final InventoryItemData item;
  final bool isEquipped;

  const InventoryItemTile({
    super.key,
    required this.item,
    required this.isEquipped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: inventoryBackGroundColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemThumb(
            imagePath: item.image,
            fallbackIcon: iconForType(item.objectType),
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
                          color: inventoryTextColor,
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

class ItemThumb extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;

  const ItemThumb({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 30,
        height: 30,
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

IconData iconForType(InventoryObjectType objectType) {
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
