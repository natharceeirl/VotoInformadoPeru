import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/new_providers.dart';

class PartyBarChart extends ConsumerWidget {
  const PartyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyStatsAsync = ref.watch(partyStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sentencias por Partido (Top 10)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: partyStatsAsync.when(
                data: (data) {
                  // Sort by sentencias descending and take top 10
                  final sortedList = List.of(data)
                    ..sort(
                      (a, b) => b.sentenciasTotal.compareTo(a.sentenciasTotal),
                    );
                  final topEntries = sortedList.take(10).toList();

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topEntries.isEmpty
                          ? 100
                          : topEntries.first.sentenciasTotal.toDouble() * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              Theme.of(context).colorScheme.surface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${topEntries[group.x.toInt()].partido}\n',
                              const TextStyle(fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: (rod.toY).toStringAsFixed(0),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= topEntries.length) {
                                return const SizedBox.shrink();
                              }
                              String text = topEntries[value.toInt()].partido
                                  .split(' ')
                                  .first; // abbreviation
                              if (text.length > 8) text = text.substring(0, 8);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  text,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: topEntries.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.sentenciasTotal.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: 16,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    const Center(child: Text("Error cargando datos")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
