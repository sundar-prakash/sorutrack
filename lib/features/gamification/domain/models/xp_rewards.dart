class XPRewards {
  static const Map<String, int> rewards = {
    'log_meal': 10,
    'complete_breakfast': 15,
    'complete_all_meals': 50,
    'hit_calorie_goal': 30,
    'hit_protein_goal': 25,
    'hit_water_goal': 20,
    'log_weight': 10,
    'log_exercise': 15,
    'perfect_macros': 75, // all macros within 5% of target
    'streak_7_days': 100,
    'streak_30_days': 500,
    'streak_100_days': 2000,
    'first_meal': 50, // onboarding
    'complete_profile': 100,
    'invite_friend': 200,
    'share_achievement': 25,
  };

  static int getReward(String key) => rewards[key] ?? 0;
}
