import 'dart:math';

import 'package:flutter/material.dart';

import 'srd_chat_models.dart';
import 'srd_hero_models.dart';

const double _collapsedDockFactor = 0.10;
const double _expandedDockFactor = 0.30;
const int _levelUpPointBudget = 5;

class PartyChat extends StatefulWidget {
  final List<PartyChatInteraction> interactions;
  final List<HeroDataSRD> heroes;
  final HeroDataSRD playerHero;

  const PartyChat({
    super.key,
    required this.interactions,
    required this.heroes,
    required this.playerHero,
  });

  @override
  State<PartyChat> createState() => _PartyChatState();
}

class _PartyChatState extends State<PartyChat> {
  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _actionRequestController =
      TextEditingController();
  final Map<_LevelUpStat, int> _allocatedStatPoints = <_LevelUpStat, int>{};

  bool _isDockExpanded = false;
  int? _actionRoll;

  @override
  void initState() {
    super.initState();
    _composerController.addListener(_handleInputChanged);
    _actionRequestController.addListener(_handleInputChanged);
    _resetLevelUpDraft();
  }

  @override
  void didUpdateWidget(covariant PartyChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRequest = _resolveLatestRequestForHero(
      oldWidget.interactions,
      oldWidget.playerHero.id,
    );
    final newRequest = _resolveLatestRequestForHero(
      widget.interactions,
      widget.playerHero.id,
    );
    if (oldRequest?.messageId != newRequest?.messageId ||
        oldWidget.playerHero.id != widget.playerHero.id) {
      _actionRequestController.clear();
      _actionRoll = null;
      _resetLevelUpDraft();
    }
  }

  @override
  void dispose() {
    _composerController.removeListener(_handleInputChanged);
    _actionRequestController.removeListener(_handleInputChanged);
    _composerController.dispose();
    _actionRequestController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _resetLevelUpDraft() {
    _allocatedStatPoints
      ..clear()
      ..addEntries(
        _LevelUpStat.values.map(
          (_LevelUpStat stat) => MapEntry<_LevelUpStat, int>(stat, 0),
        ),
      );
  }

  void _toggleDockExpanded() {
    setState(() {
      _isDockExpanded = !_isDockExpanded;
    });
  }

  void _rollAction() {
    setState(() {
      _actionRoll = Random().nextInt(21);
    });
  }

  void _incrementStat(_LevelUpStat stat) {
    if (_remainingLevelUpPoints == 0) {
      return;
    }
    setState(() {
      _allocatedStatPoints[stat] = (_allocatedStatPoints[stat] ?? 0) + 1;
    });
  }

  void _decrementStat(_LevelUpStat stat) {
    final currentValue = _allocatedStatPoints[stat] ?? 0;
    if (currentValue == 0) {
      return;
    }
    setState(() {
      _allocatedStatPoints[stat] = currentValue - 1;
    });
  }

  int get _allocatedLevelUpPoints =>
      _allocatedStatPoints.values.fold(0, (int sum, int value) => sum + value);

  int get _remainingLevelUpPoints =>
      _levelUpPointBudget - _allocatedLevelUpPoints;

  PartyChatRequestInteraction? _activeRequest() {
    return _resolveLatestRequestForHero(
      widget.interactions,
      widget.playerHero.id,
    );
  }

  bool _canSend(PartyChatRequestInteraction? activeRequest) {
    if (activeRequest is DmActionRequestInteraction) {
      return _actionRoll != null &&
          _actionRequestController.text.trim().isNotEmpty;
    }
    if (activeRequest is DmLevelUpRequestInteraction) {
      return _remainingLevelUpPoints == 0;
    }
    return _composerController.text.trim().isNotEmpty;
  }

  HeroStatsSRD _levelUpPreviewStats() {
    final HeroStatsSRD stats = widget.playerHero.stats;
    return HeroStatsSRD(
      hp: stats.hp,
      currentHp: stats.hp,
      currentExp: 0,
      level: stats.level + 1,
      strength:
          stats.strength + (_allocatedStatPoints[_LevelUpStat.strength] ?? 0),
      dexterity:
          stats.dexterity + (_allocatedStatPoints[_LevelUpStat.dexterity] ?? 0),
      constitution:
          stats.constitution +
          (_allocatedStatPoints[_LevelUpStat.constitution] ?? 0),
      intelligence:
          stats.intelligence +
          (_allocatedStatPoints[_LevelUpStat.intelligence] ?? 0),
      wisdom: stats.wisdom + (_allocatedStatPoints[_LevelUpStat.wisdom] ?? 0),
      charisma:
          stats.charisma + (_allocatedStatPoints[_LevelUpStat.charisma] ?? 0),
    );
  }

  void _handleSend(PartyChatRequestInteraction? activeRequest) {
    if (!_canSend(activeRequest)) {
      return;
    }

    if (activeRequest is DmActionRequestInteraction) {
      final Map<String, dynamic> payload = <String, dynamic>{
        'message_id': 'pending_player_action',
        'type': PartyChatInteractionType.playerAction.wireValue,
        'owner_id': widget.playerHero.id,
        'owner_label': widget.playerHero.name,
        'message_text': _actionRequestController.text.trim(),
        'roll': _actionRoll,
      };
      // TODO(samuel): Send the player action payload to the backend chat endpoint.
      debugPrint('TODO backend dispatch: $payload');
      return;
    }

    if (activeRequest is DmLevelUpRequestInteraction) {
      final HeroStatsSRD preview = _levelUpPreviewStats();
      final Map<String, dynamic> payload = <String, dynamic>{
        'message_id': 'pending_player_level_up',
        'type': PartyChatInteractionType.playerLevelUp.wireValue,
        'owner_id': widget.playerHero.id,
        'owner_label': widget.playerHero.name,
        'level': preview.level,
        'hp': preview.hp,
        'current_hp': preview.currentHp,
        'current_exp': preview.currentExp,
        'strength': preview.strength,
        'dexterity': preview.dexterity,
        'constitution': preview.constitution,
        'intelligence': preview.intelligence,
        'wisdom': preview.wisdom,
        'charisma': preview.charisma,
      };
      // TODO(samuel): Send the player level-up payload to the backend chat endpoint.
      debugPrint('TODO backend dispatch: $payload');
      return;
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'message_id': 'pending_player_message',
      'type': PartyChatInteractionType.freeMessage.wireValue,
      'owner_id': widget.playerHero.id,
      'owner_label': widget.playerHero.name,
      'message_text': _composerController.text.trim(),
    };
    // TODO(samuel): Send the player free-message payload to the backend chat endpoint.
    debugPrint('TODO backend dispatch: $payload');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> heroNameById = <String, String>{
      for (final HeroDataSRD hero in widget.heroes) hero.id: hero.name,
    };
    final PartyChatRequestInteraction? activeRequest = _activeRequest();

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 20, 12),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double dockHeight =
              constraints.maxHeight *
              (_isDockExpanded ? _expandedDockFactor : _collapsedDockFactor);

          return Column(
            children: <Widget>[
              Expanded(child: _buildHistory(heroNameById)),
              AnimatedContainer(
                key: const ValueKey<String>('party-chat-dock'),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                height: dockHeight,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 46, 28, 14),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 189, 88, 0),
                      width: 1.5,
                    ),
                  ),
                ),
                child: _buildInteractionDock(activeRequest),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistory(Map<String, String> heroNameById) {
    if (widget.interactions.isEmpty) {
      return const Center(
        child: Text(
          'No party chat interactions',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey<String>('party-chat-history'),
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, int index) {
        return _PartyChatInteractionCard(
          interaction: widget.interactions[index],
          heroNameById: heroNameById,
        );
      },
      separatorBuilder: (_, int index) => const SizedBox(height: 10),
      itemCount: widget.interactions.length,
    );
  }

  Widget _buildInteractionDock(PartyChatRequestInteraction? activeRequest) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double portraitSize = constraints.maxHeight.clamp(34.0, 52.0);
        final bool compactActions = constraints.maxHeight < 72;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildPlayerPortrait(size: portraitSize),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                child: _buildDockContent(activeRequest),
              ),
            ),
            const SizedBox(width: 10),
            _buildDockActions(activeRequest, compactActions: compactActions),
          ],
        );
      },
    );
  }

  Widget _buildDockActions(
    PartyChatRequestInteraction? activeRequest, {
    required bool compactActions,
  }) {
    final List<Widget> actions = <Widget>[
      _buildDockIconButton(
        key: const ValueKey<String>('party-chat-expand-button'),
        onPressed: _toggleDockExpanded,
        tooltip: _isDockExpanded ? 'Collapse dock' : 'Expand dock',
        icon: _isDockExpanded ? Icons.expand_more : Icons.expand_less,
      ),
      _buildDockIconButton(
        key: const ValueKey<String>('party-chat-send-button'),
        onPressed: _canSend(activeRequest)
            ? () => _handleSend(activeRequest)
            : null,
        tooltip: 'Send',
        icon: Icons.send_rounded,
      ),
    ];

    if (compactActions) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[actions[0], const SizedBox(width: 4), actions[1]],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions,
    );
  }

  Widget _buildDockIconButton({
    required Key key,
    required VoidCallback? onPressed,
    required String tooltip,
    required IconData icon,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        key: key,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        visualDensity: VisualDensity.compact,
        splashRadius: 16,
        iconSize: 18,
        tooltip: tooltip,
        color: Colors.white,
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildPlayerPortrait({required double size}) {
    return ClipOval(
      child: SizedBox(
        key: const ValueKey<String>('party-chat-player-portrait'),
        width: size,
        height: size,
        child: Image.asset(
          widget.playerHero.imagePortrait,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return const ColoredBox(
                  color: Color.fromARGB(255, 106, 66, 26),
                  child: Icon(Icons.person, color: Colors.white),
                );
              },
        ),
      ),
    );
  }

  Widget _buildDockContent(PartyChatRequestInteraction? activeRequest) {
    if (activeRequest is DmActionRequestInteraction) {
      return _buildActionRequestComposer(activeRequest);
    }
    if (activeRequest is DmLevelUpRequestInteraction) {
      return _buildLevelUpComposer(activeRequest);
    }
    return _buildDefaultComposer();
  }

  Widget _buildDefaultComposer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Party chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey<String>('party-chat-composer-field'),
          controller: _composerController,
          minLines: _isDockExpanded ? 3 : 1,
          maxLines: _isDockExpanded ? 5 : 1,
          style: const TextStyle(color: Colors.white),
          decoration: _composerDecoration(
            hintText: 'Write a message for the party...',
          ),
        ),
      ],
    );
  }

  Widget _buildActionRequestComposer(DmActionRequestInteraction request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          request.messageText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            Container(
              key: const ValueKey<String>('party-chat-roll-value'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 106, 66, 26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _actionRoll == null ? 'Roll: -' : 'Roll: $_actionRoll',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey<String>('party-chat-roll-button'),
              onPressed: _rollAction,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Roll 0-20'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color.fromARGB(255, 189, 88, 0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey<String>('party-chat-action-field'),
          controller: _actionRequestController,
          minLines: _isDockExpanded ? 3 : 1,
          maxLines: _isDockExpanded ? 4 : 2,
          style: const TextStyle(color: Colors.white),
          decoration: _composerDecoration(
            hintText: 'Describe the action you want to take...',
          ),
        ),
      ],
    );
  }

  Widget _buildLevelUpComposer(DmLevelUpRequestInteraction request) {
    final HeroStatsSRD currentStats = widget.playerHero.stats;
    final HeroStatsSRD previewStats = _levelUpPreviewStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          request.messageText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Points left: $_remainingLevelUpPoints',
          key: const ValueKey<String>('party-chat-points-remaining'),
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ..._LevelUpStat.values.map(
          (_LevelUpStat stat) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LevelUpStatEditor(
              stat: stat,
              baseValue: stat.read(currentStats),
              allocatedValue: _allocatedStatPoints[stat] ?? 0,
              onDecrement: () => _decrementStat(stat),
              onIncrement: () => _incrementStat(stat),
              canDecrement: (_allocatedStatPoints[stat] ?? 0) > 0,
              canIncrement: _remainingLevelUpPoints > 0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _previewChip('Preview Level ${previewStats.level}'),
            _previewChip(
              'Preview HP ${previewStats.currentHp}/${previewStats.hp}',
            ),
            _previewChip('Preview EXP ${previewStats.currentExp}'),
          ],
        ),
      ],
    );
  }

  InputDecoration _composerDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color.fromARGB(255, 65, 42, 21),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 189, 88, 0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 189, 88, 0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 235, 180, 70),
          width: 2,
        ),
      ),
    );
  }

  Widget _previewChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 106, 66, 26),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static PartyChatRequestInteraction? _resolveLatestRequestForHero(
    List<PartyChatInteraction> interactions,
    String heroId,
  ) {
    for (int index = interactions.length - 1; index >= 0; index -= 1) {
      final PartyChatInteraction interaction = interactions[index];
      if (interaction is PartyChatRequestInteraction &&
          interaction.targetHeroId == heroId) {
        return interaction;
      }
    }
    return null;
  }
}

class _PartyChatInteractionCard extends StatelessWidget {
  final PartyChatInteraction interaction;
  final Map<String, String> heroNameById;

  const _PartyChatInteractionCard({
    required this.interaction,
    required this.heroNameById,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 58, 36, 16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  interaction.ownerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 106, 66, 26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  interaction.type.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (interaction is FreeMessageInteraction) {
      final FreeMessageInteraction msg = interaction as FreeMessageInteraction;
      return _messageText(msg.messageText);
    }

    if (interaction is DmLevelUpRequestInteraction) {
      final DmLevelUpRequestInteraction msg =
          interaction as DmLevelUpRequestInteraction;
      return _buildRequestBody(
        messageText: msg.messageText,
        targetHeroId: msg.targetHeroId,
      );
    }

    if (interaction is PlayerLevelUpInteraction) {
      final PlayerLevelUpInteraction msg =
          interaction as PlayerLevelUpInteraction;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _statChip('STR', msg.strength),
          _statChip('DEX', msg.dexterity),
          _statChip('CON', msg.constitution),
          _statChip('INT', msg.intelligence),
          _statChip('WIS', msg.wisdom),
          _statChip('CHA', msg.charisma),
        ],
      );
    }

    if (interaction is DmActionInteraction) {
      final DmActionInteraction msg = interaction as DmActionInteraction;
      return _buildRequestBody(
        messageText: msg.messageText,
        targetHeroId: msg.actionTarget,
      );
    }

    if (interaction is DmActionRequestInteraction) {
      final DmActionRequestInteraction msg =
          interaction as DmActionRequestInteraction;
      return _buildRequestBody(
        messageText: msg.messageText,
        targetHeroId: msg.targetHeroId,
      );
    }

    if (interaction is PlayerActionInteraction) {
      final PlayerActionInteraction msg =
          interaction as PlayerActionInteraction;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _messageText(msg.messageText),
          const SizedBox(height: 6),
          Text(
            'Roll: ${msg.roll}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRequestBody({
    required String messageText,
    required String targetHeroId,
  }) {
    final String? targetName = heroNameById[targetHeroId];
    final String targetLabel = targetName == null
        ? targetHeroId
        : '$targetName ($targetHeroId)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _messageText(messageText),
        const SizedBox(height: 6),
        Text(
          'Target: $targetLabel',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _messageText(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.25),
    );
  }

  Widget _statChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 106, 66, 26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _LevelUpStat {
  strength('STR', 'strength'),
  dexterity('DEX', 'dexterity'),
  constitution('CON', 'constitution'),
  intelligence('INT', 'intelligence'),
  wisdom('WIS', 'wisdom'),
  charisma('CHA', 'charisma');

  final String shortLabel;
  final String keyName;

  const _LevelUpStat(this.shortLabel, this.keyName);

  int read(HeroStatsSRD stats) {
    switch (this) {
      case _LevelUpStat.strength:
        return stats.strength;
      case _LevelUpStat.dexterity:
        return stats.dexterity;
      case _LevelUpStat.constitution:
        return stats.constitution;
      case _LevelUpStat.intelligence:
        return stats.intelligence;
      case _LevelUpStat.wisdom:
        return stats.wisdom;
      case _LevelUpStat.charisma:
        return stats.charisma;
    }
  }
}

class _LevelUpStatEditor extends StatelessWidget {
  final _LevelUpStat stat;
  final int baseValue;
  final int allocatedValue;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  const _LevelUpStatEditor({
    required this.stat,
    required this.baseValue,
    required this.allocatedValue,
    required this.onIncrement,
    required this.onDecrement,
    required this.canIncrement,
    required this.canDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final int previewValue = baseValue + allocatedValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 65, 42, 21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${stat.shortLabel}: $baseValue -> $previewValue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            key: ValueKey<String>('party-chat-levelup-minus-${stat.keyName}'),
            onPressed: canDecrement ? onDecrement : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '+$allocatedValue',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            key: ValueKey<String>('party-chat-levelup-plus-${stat.keyName}'),
            onPressed: canIncrement ? onIncrement : null,
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
