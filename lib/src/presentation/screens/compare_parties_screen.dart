import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import '../widgets/indicator_weights_sheet.dart';

// Local providers for the two selected parties
class CompareParty1Notifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? party) => state = party;
}

final compareParty1Provider = NotifierProvider<CompareParty1Notifier, String?>(
  CompareParty1Notifier.new,
);

class CompareParty2Notifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? party) => state = party;
}

final compareParty2Provider = NotifierProvider<CompareParty2Notifier, String?>(
  CompareParty2Notifier.new,
);

// Indicator metadata for the comparator
const _indicators = [
  ('sentencias', 'Sentencias', Icons.gavel, Colors.red,
      'Ausencia de sentencias judiciales firmes (100 = ninguna sentencia). Peso oficial: 20%.'),
  ('preparacion', 'Preparación', Icons.school, Colors.blue,
      'Nivel de formación académica promedio del equipo (100 = máxima preparación). Peso oficial: 20%.'),
  ('ingresos_no_declarados', 'Ingresos ND', Icons.money_off, Colors.brown,
      'Transparencia en la declaración de ingresos (100 = todos declaran ingresos válidos). Peso oficial: 10%.'),
  ('ingresos_efectivos', 'Ingresos Ef.', Icons.attach_money, Colors.green,
      'Ingresos mensuales efectivos promedio del equipo (100 = ingresos más altos). Peso oficial: 5%.'),
  ('libre_pacto', 'Libre Pacto', Icons.handshake, Colors.purple,
      'Ausencia de vínculos con el Pacto de Corrupción #PorEstosNo (100 = sin vínculos). Peso oficial: 25%.'),
  ('reeleccion', 'Reelección', Icons.how_to_vote, Colors.teal,
      'Ausencia de excongresistas en la lista (100 = ninguno busca reelección). Peso oficial: 10%.'),
  ('equipo_completo', 'Equipo', Icons.group, Colors.cyan,
      'Score por presentar los 30 candidatos reglamentarios (100 = equipo completo). Peso oficial: 5%.'),
  ('reinfo', 'REINFO', Icons.landscape, Colors.orange,
      'Ausencia de candidatos vinculados a minería informal (100 = ninguno en REINFO). Peso oficial: 5%.'),
];

/// Extracts a normalized indicator value (0-100) from an IndicatorGraphic
/// by key, matching the keys used in [_indicators].
double _indicatorValue(dynamic g, String key) {
  switch (key) {
    case 'sentencias':
      return g.sentencias;
    case 'preparacion':
      return g.preparacion;
    case 'ingresos_no_declarados':
      return g.ingresosNoDeclarados;
    case 'ingresos_efectivos':
      return g.ingresosEfectivos;
    case 'libre_pacto':
      return g.librePacto;
    case 'reeleccion':
      return g.reeleccion;
    case 'equipo_completo':
      return g.equipoCompleto;
    case 'reinfo':
      return g.reinfo;
    default:
      return 0.0;
  }
}

class ComparePartiesScreen extends ConsumerWidget {
  const ComparePartiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicadoresAsync = ref.watch(indicatorsGraphProvider);
    final party1 = ref.watch(compareParty1Provider);
    final party2 = ref.watch(compareParty2Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Partidos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Configurar indicadores',
            onPressed: () => showIndicatorWeightsSheet(context, ref),
          ),
        ],
      ),
      body: indicadoresAsync.when(
        data: (graphs) {
          if (graphs.isEmpty) return const Center(child: Text('Sin datos'));
          final partyNames = graphs.map((e) => e.partido).toList()..sort();

          final p1Name =
              party1 ?? (partyNames.isNotEmpty ? partyNames[0] : null);
          final p2Name =
              party2 ?? (partyNames.length > 1 ? partyNames[1] : null);

          final p1Data = graphs.firstWhere(
            (e) => e.partido == p1Name,
            orElse: () => graphs.first,
          );
          final p2Data = graphs.firstWhere(
            (e) => e.partido == p2Name,
            orElse: () => graphs.first,
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Description banner
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.compare_arrows_rounded,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Selecciona dos partidos para comparar sus scores en los '
                          '8 indicadores del Índice de Transparencia. El gráfico y '
                          'la tabla muestran quién lidera en cada dimensión.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Party selectors
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: p1Name,
                        decoration: const InputDecoration(
                          labelText: 'Partido 1',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: partyNames
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      PartyLogo(partyName: p, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(p,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            ref.read(compareParty1Provider.notifier).update(val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: p2Name,
                        decoration: const InputDecoration(
                          labelText: 'Partido 2',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: partyNames
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      PartyLogo(partyName: p, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(p,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            ref.read(compareParty2Provider.notifier).update(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Personalizar indicadores'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => showIndicatorWeightsSheet(context, ref),
                ),
                const SizedBox(height: 16),

                if (p1Name != null && p2Name != null) ...[
                  // Score total comparison
                  _ScoreCompareCard(
                    p1Name: p1Name,
                    p2Name: p2Name,
                    p1Score: p1Data.scoreFinal,
                    p2Score: p2Data.scoreFinal,
                  ),
                  const SizedBox(height: 24),

                  // Chart title
                  const Text(
                    'Comparativa por Indicadores (0-100)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Bar chart — fixed 0-100 scale, no overflow
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: AspectRatio(
                        aspectRatio: 1.7,
                        child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        minY: 0,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) =>
                                Theme.of(context).colorScheme.inverseSurface,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final indicator = _indicators[groupIndex];
                              final partyLabel =
                                  rodIndex == 0 ? p1Name : p2Name;
                              return BarTooltipItem(
                                '$partyLabel\n${indicator.$2}: ${rod.toY.toStringAsFixed(1)}',
                                TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  fontSize: 11,
                                ),
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
                                final idx = value.toInt();
                                if (idx < 0 || idx >= _indicators.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _indicators[idx].$2,
                                    style: const TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 25,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(_indicators.length, (i) {
                          final ind = _indicators[i];
                          final v1 = _indicatorValue(p1Data, ind.$1);
                          final v2 = _indicatorValue(p2Data, ind.$1);
                          return _buildGroup(i, v1, v2);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
                  const SizedBox(height: 16),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(color: Colors.blue, partyName: p1Name),
                      const SizedBox(width: 24),
                      _LegendItem(color: Colors.orange, partyName: p2Name),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detailed comparison table
                  const Text(
                    'Detalle por Indicador',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _ComparisonTable(
                    p1Name: p1Name,
                    p2Name: p2Name,
                    p1Graph: p1Data,
                    p2Graph: p2Data,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  BarChartGroupData _buildGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.blue,
          width: 14,
          borderRadius: BorderRadius.circular(3),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.orange,
          width: 14,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _ScoreCompareCard extends StatelessWidget {
  final String p1Name;
  final String p2Name;
  final double p1Score;
  final double p2Score;

  const _ScoreCompareCard({
    required this.p1Name,
    required this.p2Name,
    required this.p1Score,
    required this.p2Score,
  });

  @override
  Widget build(BuildContext context) {
    final winner = p1Score >= p2Score ? p1Name : p2Name;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Score Total (0–100) — mayor score = más transparente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScoreTile(
                    name: p1Name,
                    score: p1Score,
                    color: Colors.blue,
                    isWinner: p1Score >= p2Score,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoreTile(
                    name: p2Name,
                    score: p2Score,
                    color: Colors.orange,
                    isWinner: p2Score >= p1Score,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${winner == p1Name ? '🏅 ' : ''}$winner lidera por ${(p1Score - p2Score).abs().toStringAsFixed(1)} puntos',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String name;
  final double score;
  final Color color;
  final bool isWinner;

  const _ScoreTile({
    required this.name,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isWinner ? 0.12 : 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: color.withValues(alpha: isWinner ? 0.7 : 0.2),
            width: isWinner ? 2 : 1),
      ),
      child: Column(
        children: [
          if (isWinner)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('✓ Líder',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          PartyLogo(partyName: name, size: 40, withBorder: true),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isWinner ? color : null),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          LinearProgressIndicator(
            value: score / 100,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
            minHeight: 5,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final String p1Name;
  final String p2Name;
  final dynamic p1Graph;
  final dynamic p2Graph;

  const _ComparisonTable({
    required this.p1Name,
    required this.p2Name,
    required this.p1Graph,
    required this.p2Graph,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                const Expanded(flex: 3, child: Text('Indicador',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(
                  flex: 2,
                  child: Text(
                    p1Name,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    p2Name,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...List.generate(_indicators.length, (i) {
              final ind = _indicators[i];
              final v1 = _indicatorValue(p1Graph, ind.$1);
              final v2 = _indicatorValue(p2Graph, ind.$1);
              final p1Wins = v1 >= v2;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(ind.$3, size: 14, color: ind.$4),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ind.$2,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ValueCell(
                        value: v1,
                        isWinner: p1Wins,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ValueCell(
                        value: v2,
                        isWinner: !p1Wins,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final double value;
  final bool isWinner;
  final Color color;

  const _ValueCell({
    required this.value,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: isWinner ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value.toStringAsFixed(1),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          color: isWinner ? color : null,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String partyName;

  const _LegendItem({required this.color, required this.partyName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        PartyLogo(partyName: partyName, size: 28, withBorder: true),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            partyName,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
