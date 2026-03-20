import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sorutrack_pro/core/services/export_service.dart';
import 'package:sorutrack_pro/features/reports/presentation/bloc/report_filter_cubit.dart';
import 'package:sorutrack_pro/features/reports/presentation/bloc/reports_cubit.dart';
import 'package:sorutrack_pro/features/reports/presentation/widgets/report_charts.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

class ReportsMainScreen extends StatefulWidget {
  const ReportsMainScreen({super.key});

  @override
  State<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends State<ReportsMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final filterState = context.read<ReportFilterCubit>().state;
        context.read<ReportsCubit>().loadReports(filterState, 'default_user');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Insights'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Nutrition'),
            Tab(text: 'Body'),
            Tab(text: 'Food Diary'),
            Tab(text: 'Goals'),
            Tab(text: 'Insights'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDateRangePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: BlocListener<ReportFilterCubit, ReportFilterState>(
          listener: (context, filterState) {
            context.read<ReportsCubit>().loadReports(filterState, 'default_user');
          },
          child: BlocBuilder<ReportFilterCubit, ReportFilterState>(
            builder: (context, filterState) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(),
                  _NutritionTab(),
                  _BodyTab(),
                  _FoodDiaryTab(),
                  _GoalsTab(),
                  _InsightsTab(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final reportsCubit = context.read<ReportsCubit>();
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return BlocProvider.value(
          value: reportsCubit,
          child: BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: const Text('Export as PDF'),
                      onTap: () {
                        if (state is ReportsLoaded) {
                          ExportService.exportToPdf(
                            calorieTrend: state.calorieTrend,
                            macroTrend: state.macroTrend,
                            topFoods: state.topFoods,
                          );
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.table_chart),
                      title: const Text('Export Food Diary as CSV'),
                      onTap: () {
                        if (state is ReportsLoaded) {
                          ExportService.exportToCsv(state.foodDiary);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.grid_on),
                      title: const Text('Export Food Diary as Excel'),
                      onTap: () {
                        if (state is ReportsLoaded) {
                          ExportService.exportToExcel(state.foodDiary);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Share Screenshot'),
                      onTap: () async {
                         final image = await _screenshotController.capture();
                         if (image != null) {
                           // Save and share logic
                           final directory = await getTemporaryDirectory();
                           final file = File('${directory.path}/report_screenshot.png');
                           await file.writeAsBytes(image);
                           await Share.shareXFiles([XFile(file.path)], text: 'My Nutrition Report');
                         }
                         if (context.mounted) {
                           Navigator.pop(context);
                         }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDateRangePicker(BuildContext context) {
    final filterCubit = context.read<ReportFilterCubit>();
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return BlocProvider.value(
          value: filterCubit,
          child: BlocBuilder<ReportFilterCubit, ReportFilterState>(
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Today'),
                      trailing: state.rangeType == DateRangeType.today ? const Icon(Icons.check) : null,
                      onTap: () {
                        context.read<ReportFilterCubit>().setRange(DateRangeType.today);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('This Week'),
                      trailing: state.rangeType == DateRangeType.thisWeek ? const Icon(Icons.check) : null,
                      onTap: () {
                        context.read<ReportFilterCubit>().setRange(DateRangeType.thisWeek);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('This Month'),
                      trailing: state.rangeType == DateRangeType.thisMonth ? const Icon(Icons.check) : null,
                      onTap: () {
                        context.read<ReportFilterCubit>().setRange(DateRangeType.thisMonth);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Last 30 Days'),
                      trailing: state.rangeType == DateRangeType.last30Days ? const Icon(Icons.check) : null,
                      onTap: () {
                        context.read<ReportFilterCubit>().setRange(DateRangeType.last30Days);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Custom Range'),
                      trailing: state.rangeType == DateRangeType.custom ? const Icon(Icons.check) : null,
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        final scaffold = context;
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (!scaffold.mounted) return;
                        if (picked != null) {
                          scaffold.read<ReportFilterCubit>().setRange(
                            DateRangeType.custom,
                            customStart: picked.start,
                            customEnd: picked.end,
                          );
                        }
                        navigator.pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
        if (state is ReportsError) return Center(child: Text(state.message));
        if (state is! ReportsLoaded) return const Center(child: Text('No data loaded'));

        final avgCalories = state.calorieTrend.isEmpty 
          ? 0.0 
          : state.calorieTrend.map((e) => e.value).reduce((a, b) => a + b) / state.calorieTrend.length;
        
        final maxCalories = state.calorieTrend.isEmpty 
          ? 0.0 
          : state.calorieTrend.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        final daysOnTrack = state.goalAdherence.where((e) => e.isOnTrack).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(avgCalories, maxCalories, daysOnTrack, state.goalAdherence.length, state.currentStreak),
              const SizedBox(height: 24),
              const Text('Calorie Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  final target = profileState.maybeMap(
                    loaded: (s) => s.calorieTarget,
                    orElse: () => 2000.0,
                  );
                  return SizedBox(
                    height: 200,
                    child: CalorieTrendChart(data: state.calorieTrend, goalLine: target),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Macro Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: MacroStackedBarChart(data: state.macroTrend),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double avg, double max, int onTrack, int total, int streak) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Avg Calories', avg.toStringAsFixed(0), Icons.local_fire_department, Colors.orange),
        _buildStatCard('Best Day', max.toStringAsFixed(0), Icons.star, Colors.yellow[700]!),
        _buildStatCard('Goals Met', '$onTrack/$total', Icons.check_circle, Colors.green),
        _buildStatCard('Streak', '$streak days', Icons.bolt, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _NutritionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Micronutrient Adherence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 300, child: MicronutrientRadarChart(data: state.micronutrients)),
              const SizedBox(height: 24),
              const Text('Top Foods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 300, child: TopFoodsDonutChart(data: state.topFoods)),
            ],
          ),
        );
      },
    );
  }
}

class _BodyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Weight Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 200, child: CalorieTrendChart(data: state.weightTrend)),
            ],
          ),
        );
      },
    );
  }
}

class _FoodDiaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) return const Center(child: CircularProgressIndicator());
        
        return Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: ListView.builder(
                itemCount: state.foodDiary.length,
                itemBuilder: (context, index) {
                  final entry = state.foodDiary[index];
                  return ListTile(
                    title: Text(entry.foodName),
                    subtitle: Text('${entry.mealType} • ${DateFormat('HH:mm').format(entry.dateTime)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${entry.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('P:${entry.protein.toStringAsFixed(0)} C:${entry.carbs.toStringAsFixed(0)} F:${entry.fat.toStringAsFixed(0)}', 
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search food log...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => context.read<ReportFilterCubit>().updateFilters(query: value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final filterCubit = context.read<ReportFilterCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: filterCubit,
          child: BlocBuilder<ReportFilterCubit, ReportFilterState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Meal Types'),
                    Wrap(
                      spacing: 8,
                      children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((type) {
                        final isSelected = state.mealTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            final newList = List<String>.from(state.mealTypes);
                            if (selected) {
                              newList.add(type);
                            } else {
                              newList.remove(type);
                            }
                            context.read<ReportFilterCubit>().updateFilters(mealTypes: newList);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Calories Range'),
                    RangeSlider(
                      values: RangeValues(state.minCalories ?? 0, state.maxCalories ?? 2000),
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      labels: RangeLabels(
                        (state.minCalories ?? 0).toStringAsFixed(0),
                        (state.maxCalories ?? 2000).toStringAsFixed(0),
                      ),
                      onChanged: (values) {
                        context.read<ReportFilterCubit>().updateFilters(
                          minCalories: values.start,
                          maxCalories: values.end,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Center(child: Text('Apply Filters')),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ReportFilterCubit>().resetFilters();
                        Navigator.pop(context);
                      },
                      child: const Center(child: Text('Reset')),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GoalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) return const Center(child: CircularProgressIndicator());
        
        final adherence = state.goalAdherence;
        if (adherence.isEmpty) return const Center(child: Text('No adherence data yet.'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Goal Adherence Heatmap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: adherence.length,
                itemBuilder: (context, index) {
                  final day = adherence[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: day.isOnTrack ? Colors.green : Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('d').format(DateTime.parse(day.date)),
                        style: TextStyle(
                          color: day.isOnTrack ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildAdherenceStats(adherence),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdherenceStats(List<GoalAdherenceData> data) {
    final onTrack = data.where((e) => e.isOnTrack).length;
    final percentage = (onTrack / data.length * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('$percentage%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('Goal Adherence Rate', style: TextStyle(color: Colors.grey)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('On Track', onTrack.toString(), Colors.green),
                _buildMiniStat('Off Track', (data.length - onTrack).toString(), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _InsightsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) return const Center(child: CircularProgressIndicator());
        
        if (state.insights == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64, color: Colors.purple),
                const SizedBox(height: 16),
                const Text('Generate AI Insights for your nutrition'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ReportsCubit>().loadInsights(),
                  child: const Text('Generate with Gemini'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text('AI Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<ReportsCubit>().loadInsights(),
                  ),
                ],
              ),
              const Divider(),
              // Using a simple SelectableText as markdown renderer might not be available or imported
              SelectableText(state.insights!),
            ],
          ),
        );
      },
    );
  }
}
