import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<ReportTrendData> data;
  final double? goalLine;

  const CalorieTrendChart({super.key, required this.data, this.goalLine});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data available'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = DateTime.parse(data[value.toInt()].date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.1),
            ),
          ),
          if (goalLine != null)
            LineChartBarData(
              spots: [
                FlSpot(0, goalLine!),
                FlSpot(data.length.toDouble() - 1, goalLine!),
              ],
              color: Colors.red.withValues(alpha: 0.5),
              barWidth: 1,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }
}

class MacroStackedBarChart extends StatelessWidget {
  final List<MacroDistribution> data;

  const MacroStackedBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CartesianSeries>[
        StackedColumnSeries<MacroDistribution, String>(
          dataSource: data,
          xValueMapper: (MacroDistribution d, _) => DateFormat('dd/MM').format(DateTime.parse(d.date)),
          yValueMapper: (MacroDistribution d, _) => d.protein,
          name: 'Protein',
          color: Colors.blue,
        ),
        StackedColumnSeries<MacroDistribution, String>(
          dataSource: data,
          xValueMapper: (MacroDistribution d, _) => DateFormat('dd/MM').format(DateTime.parse(d.date)),
          yValueMapper: (MacroDistribution d, _) => d.carbs,
          name: 'Carbs',
          color: Colors.green,
        ),
        StackedColumnSeries<MacroDistribution, String>(
          dataSource: data,
          xValueMapper: (MacroDistribution d, _) => DateFormat('dd/MM').format(DateTime.parse(d.date)),
          yValueMapper: (MacroDistribution d, _) => d.fat,
          name: 'Fat',
          color: Colors.orange,
        ),
      ],
    );
  }
}

class MicronutrientRadarChart extends StatelessWidget {
  final MicronutrientData data;

  const MicronutrientRadarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Mapping actual values to % of RDA (hypothetical RDA)
    final rdas = {
      'Fiber': 30.0,
      'Sodium': 2300.0,
      'Sugar': 50.0,
      'Potassium': 3500.0,
    };

    final percentageData = [
      (data.fiber / rdas['Fiber']!) * 100,
      (data.sodium / rdas['Sodium']!) * 100,
      (data.sugar / rdas['Sugar']!) * 100,
      (data.potassium / rdas['Potassium']!) * 100,
    ];

    return SfCircularChart(
      series: <CircularSeries>[
        RadialBarSeries<double, String>(
          dataSource: percentageData,
          xValueMapper: (double d, index) {
            switch (index) {
              case 0: return 'Fiber';
              case 1: return 'Sodium';
              case 2: return 'Sugar';
              case 3: return 'Potassium';
              default: return '';
            }
          },
          yValueMapper: (double d, _) => d > 100 ? 100 : d,
          useSeriesColor: true,
          trackColor: Colors.grey.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}

class TopFoodsDonutChart extends StatelessWidget {
  final List<TopFood> data;

  const TopFoodsDonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(isVisible: true),
      series: <CircularSeries>[
        DoughnutSeries<TopFood, String>(
          dataSource: data,
          xValueMapper: (TopFood d, _) => d.name,
          yValueMapper: (TopFood d, _) => d.frequency.toDouble(),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          innerRadius: '60%',
        ),
      ],
    );
  }
}
