import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/new_providers.dart';

class PartyAnalysisScreen extends ConsumerWidget {
  const PartyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesStatsAsync = ref.watch(partyStatsProvider);
    final selectedParty = ref.watch(selectedCandidatePartyProvider);
    final indicadoresAsync = ref.watch(indicatorsGraphProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Partido'),
        centerTitle: true,
      ),
      body: partiesStatsAsync.when(
        data: (statsList) {
          if (statsList.isEmpty) return const Center(child: Text('Sin datos'));

          final partyNames = statsList.map((e) => e.partido).toList()..sort();
          final currentParty = selectedParty ?? partyNames.first;
          final currentStats = statsList.firstWhere(
            (e) => e.partido == currentParty,
            orElse: () => statsList.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: currentParty,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Partido',
                    border: OutlineInputBorder(),
                  ),
                  items: partyNames
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    ref
                        .read(selectedCandidatePartyProvider.notifier)
                        .update(val);
                  },
                ),
                const SizedBox(height: 24),
                // Stats Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int col = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: col,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.0,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _StatCard(
                          'Ingresos Promedio',
                          'S/ ${currentStats.ingresosAvg.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _StatCard(
                          'Tasa Corrupción (TK3)',
                          '${(currentStats.tk3 * 100).toStringAsFixed(1)}%',
                          Icons.warning,
                          Colors.red,
                        ),
                        _StatCard(
                          'Sentencias Totales',
                          currentStats.sentenciasTotal.toString(),
                          Icons.gavel,
                          Colors.orange,
                        ),
                        _StatCard(
                          'Nivel Académico Avg',
                          currentStats.preparacionAvg.toStringAsFixed(1),
                          Icons.school,
                          Colors.blue,
                        ),
                        _StatCard(
                          'Registros REINFO',
                          currentStats.reinfoCount.toString(),
                          Icons.landscape,
                          Colors.brown,
                        ),
                        _StatCard(
                          'Congresistas Reelectos',
                          currentStats.congReel.toString(),
                          Icons.history_edu,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Desempeño por Indicadores (Radar)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                indicadoresAsync.when(
                  data: (graphs) {
                    final pGraph = graphs.firstWhere(
                      (e) => e.partido == currentParty,
                      orElse: () => graphs.first,
                    );
                    return SizedBox(
                      height: 400,
                      child: RadarChart(
                        RadarChartData(
                          dataSets: [
                            RadarDataSet(
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              entryRadius: 4,
                              dataEntries: [
                                RadarEntry(value: pGraph.sentencias),
                                RadarEntry(value: pGraph.preparacion),
                                RadarEntry(value: pGraph.librePacto),
                                RadarEntry(value: pGraph.reinfo),
                                RadarEntry(value: pGraph.reeleccion),
                              ],
                            ),
                          ],
                          radarShape: RadarShape.polygon,
                          getTitle: (index, angle) {
                            switch (index) {
                              case 0:
                                return const RadarChartTitle(text: 'Sentencias');
                              case 1:
                                return const RadarChartTitle(text: 'Preparación');
                              case 2:
                                return const RadarChartTitle(text: 'Libre de Pacto');
                              case 3:
                                return const RadarChartTitle(text: 'REINFO');
                              case 4:
                                return const RadarChartTitle(text: 'Reelección');
                              default:
                                return const RadarChartTitle(text: '');
                            }
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error al cargar gráfica'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.content, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
