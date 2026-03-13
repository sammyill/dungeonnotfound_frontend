import 'package:dungeonnotfound_frontend/gamechats/game_chat_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSessionState', () {
    test('copyWith preserves playerHeroJson unless replaced', () {
      const GameSessionState state = GameSessionState(
        heroesJson: <Map<String, dynamic>>[],
        chatJson: <Map<String, dynamic>>[],
        playerHeroJson: <String, dynamic>{'hero_id': 'option1'},
      );

      final GameSessionState preserved = state.copyWith(
        chatJson: <Map<String, dynamic>>[
          <String, dynamic>{'message_id': 'm1'},
        ],
      );
      final GameSessionState replaced = state.copyWith(
        playerHeroJson: <String, dynamic>{'hero_id': 'option2'},
      );

      expect(preserved.playerHeroJson, <String, dynamic>{'hero_id': 'option1'});
      expect(replaced.playerHeroJson, <String, dynamic>{'hero_id': 'option2'});
    });

    test('exposes playerHeroId from playerHeroJson hero_id', () {
      const GameSessionState state = GameSessionState(
        heroesJson: <Map<String, dynamic>>[],
        chatJson: <Map<String, dynamic>>[],
        playerHeroJson: <String, dynamic>{'hero_id': 'option1'},
      );

      expect(state.playerHeroId, 'option1');
    });
  });
}
