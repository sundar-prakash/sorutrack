import 'package:flutter_test/flutter_test.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/level_system.dart';

void main() {
  group('LevelSystem Tests', () {
    test('calculateLevel - initial levels', () {
      expect(LevelSystem.calculateLevel(0), 1);
      expect(LevelSystem.calculateLevel(100), 2);
      expect(LevelSystem.calculateLevel(499), 5);
    });

    test('calculateLevel - sprout tier', () {
      expect(LevelSystem.calculateLevel(500), 6);
      expect(LevelSystem.calculateLevel(800), 7);
      expect(LevelSystem.calculateLevel(1999), 10);
    });

    test('calculateLevel - leaf tier', () {
      expect(LevelSystem.calculateLevel(2000), 11);
      expect(LevelSystem.calculateLevel(4999), 20);
    });

    test('calculateLevel - higher tiers', () {
      expect(LevelSystem.calculateLevel(5000), 21);
      expect(LevelSystem.calculateLevel(15000), 36);
      expect(LevelSystem.calculateLevel(40000), 51);
    });

    test('getTier - seedling', () {
      expect(LevelSystem.getTier(1), LevelTier.seedling);
      expect(LevelSystem.getTier(5), LevelTier.seedling);
    });

    test('getTier - sprout', () {
      expect(LevelSystem.getTier(6), LevelTier.sprout);
      expect(LevelSystem.getTier(10), LevelTier.sprout);
    });
  });
}
