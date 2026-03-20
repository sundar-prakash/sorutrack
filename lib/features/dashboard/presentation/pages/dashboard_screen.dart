import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/calorie_ring_widget.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/header_section.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/insights_card.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/macro_bars_widget.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/meal_section_widget.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/streak_card_widget.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/water_tracker_widget.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/weekly_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            loaded: (data, selectedDate, isRefreshing) => RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().loadDashboard(isRefresh: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1024) {
                    return _buildDesktopLayout(data, selectedDate);
                  } else if (constraints.maxWidth > 600) {
                    return _buildTabletLayout(data, selectedDate);
                  } else {
                    return _buildMobileLayout(data, selectedDate);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(dynamic data, DateTime selectedDate) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () async {
                 final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  if (!mounted) return;
                  context.read<DashboardCubit>().loadDashboard(date: picked);
                }
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HeaderSection(
                greeting: data.greeting,
                streak: data.currentStreak,
                selectedDate: selectedDate,
              ),
              const SizedBox(height: 16),
              const StreakCardWidget(),
              const SizedBox(height: 24),
              CalorieRingWidget(summary: data.nutritionSummary),
              const SizedBox(height: 32),
              MacroBarsWidget(summary: data.nutritionSummary),
              const SizedBox(height: 32),
              const QuickActionsRow(),
              const SizedBox(height: 32),
              InsightsCard(insight: data.dailyInsight),
              const SizedBox(height: 32),
              WaterTrackerWidget(
                currentMl: data.waterIntakeMl,
                targetMl: data.waterTargetMl,
                onAddWater: () => context.read<DashboardCubit>().addWater(250),
              ),
              const SizedBox(height: 32),
              WeeklyChartWidget(data: data.weeklyCalories),
              const SizedBox(height: 32),
              Text(
                'Meals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MealSectionWidget(meals: data.meals),
              const SizedBox(height: 80), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(dynamic data, DateTime selectedDate) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('Dashboard')),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                HeaderSection(
                  greeting: data.greeting,
                  streak: data.currentStreak,
                  selectedDate: selectedDate,
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: CalorieRingWidget(summary: data.nutritionSummary),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Meals',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          MealSectionWidget(meals: data.meals),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: MacroBarsWidget(summary: data.nutritionSummary),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const QuickActionsRow(),
                          const SizedBox(height: 32),
                          InsightsCard(insight: data.dailyInsight),
                          const SizedBox(height: 32),
                          WaterTrackerWidget(
                            currentMl: data.waterIntakeMl,
                            targetMl: data.waterTargetMl,
                            onAddWater: () => context.read<DashboardCubit>().addWater(250),
                          ),
                          const SizedBox(height: 32),
                          WeeklyChartWidget(data: data.weeklyCalories),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(dynamic data, DateTime selectedDate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(
            greeting: data.greeting,
            streak: data.currentStreak,
            selectedDate: selectedDate,
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Nutrition Overview
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: CalorieRingWidget(summary: data.nutritionSummary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: MacroBarsWidget(summary: data.nutritionSummary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    WeeklyChartWidget(data: data.weeklyCalories),
                    const SizedBox(height: 32),
                    InsightsCard(insight: data.dailyInsight),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right Column: Meals & Actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const QuickActionsRow(),
                    const SizedBox(height: 32),
                    WaterTrackerWidget(
                      currentMl: data.waterIntakeMl,
                      targetMl: data.waterTargetMl,
                      onAddWater: () => context.read<DashboardCubit>().addWater(250),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Daily Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    MealSectionWidget(meals: data.meals),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
