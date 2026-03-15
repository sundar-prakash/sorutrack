enum LevelTier { seedling, sprout, leaf, branch, forest, elder }

class LevelSystem {
  static LevelTier getTier(int level) {
    if (level <= 5) return LevelTier.seedling;
    if (level <= 10) return LevelTier.sprout;
    if (level <= 20) return LevelTier.leaf;
    if (level <= 35) return LevelTier.branch;
    if (level <= 50) return LevelTier.forest;
    return LevelTier.elder;
  }

  static String getTierName(LevelTier tier) {
    return switch (tier) {
      LevelTier.seedling => 'Seedling 🌱',
      LevelTier.sprout => 'Sprout 🌿',
      LevelTier.leaf => 'Leaf 🍃',
      LevelTier.branch => 'Branch 🌳',
      LevelTier.forest => 'Forest 🌲',
      LevelTier.elder => 'Elder 🌏',
    };
  }

  static (int, int) getXPForLevel(int level) {
    if (level <= 5) return (0, 500);
    if (level <= 10) return (500, 2000);
    if (level <= 20) return (2000, 5000);
    if (level <= 35) return (5000, 15000);
    if (level <= 50) return (15000, 40000);
    return (40000, 1000000); // Max cap or infinite
  }

  static int calculateLevel(int xp) {
    if (xp < 500) return (xp / 100).floor() + 1;
    if (xp < 2000) return 6 + ((xp - 500) / 300).floor();
    if (xp < 5000) return 11 + ((xp - 2000) / 300).floor();
    if (xp < 15000) return 21 + ((xp - 5000) / 666).floor();
    if (xp < 40000) return 36 + ((xp - 15000) / 1666).floor();
    return 51 + ((xp - 40000) / 5000).floor();
  }
}
