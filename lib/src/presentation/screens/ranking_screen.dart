import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import '../widgets/indicator_weights_sheet.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCustom = !ref.watch(customWeightsProvider.notifier).isDefault;
    final customAsync = ref.watch(customRankedPartiesProvider);
    final rankingAsync = ref.watch(ranking100Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Transparencia'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: isCustom,
              label: const Text('!'),
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Configurar indicadores',
            onPressed: () => showIndicatorWeightsSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Description banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.leaderboard_rounded,
                    color: Colors.indigo, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ranking de transparencia de los 35 partidos en escala 0–100. '
                    'Un score alto significa menor riesgo de corrupción. '
                    'Personaliza los 8 indicadores para ver cómo cambia el orden.',
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

          // Configurar button (when in default mode)
          if (!isCustom)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: FilledButton.icon(
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Personalizar indicadores y pesos',
                    style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => showIndicatorWeightsSheet(context, ref),
              ),
            ),

          // Custom mode banner
          if (isCustom)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ranking con pesos personalizados activo',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(customWeightsProvider.notifier).reset(),
                    child: const Text('Restablecer',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

          // Column legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isCustom
                        ? 'Ordenado por tu configuración personalizada'
                        : '35 partidos ordenados por Índice de Transparencia (mayor = mejor)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
                _LegendDot(Colors.green, '< 30%'),
                const SizedBox(width: 8),
                _LegendDot(Colors.orange, '30-60%'),
                const SizedBox(width: 8),
                _LegendDot(Colors.red, '> 60%'),
              ],
            ),
          ),

          // List
          Expanded(
            child: isCustom
                ? customAsync.when(
                    data: (scored) => _buildCustomList(context, scored),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  )
                : rankingAsync.when(
                    data: (rankings) =>
                        _buildOfficialList(context, ref, rankings),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialList(
      BuildContext context, WidgetRef ref, List rankings) {
    if (rankings.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final rank = rankings[index];
        return _RankCard(
          position: rank.posicion,
          partido: rank.partido,
          score: rank.score,
          tasaCorrupcion: rank.tasaCorrupcion,
          onTap: () => _showPartyDetail(context, ref, rank.partido),
        );
      },
    );
  }

  Widget _buildCustomList(BuildContext context, List scored) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: scored.length,
      itemBuilder: (context, index) {
        final s = scored[index];
        return _RankCard(
          position: index + 1,
          partido: s.graph.partido,
          score: s.customScore,
          tasaCorrupcion: s.graph.tasaCorrupcion,
          isCustom: true,
        );
      },
    );
  }

  void _showPartyDetail(
      BuildContext context, WidgetRef ref, String partyName) {
    final graphsAsync = ref.read(indicatorsGraphProvider);
    graphsAsync.whenData((graphs) {
      final g = graphs.firstWhere(
        (e) => e.partido == partyName,
        orElse: () => graphs.first,
      );
      showDialog(
        context: context,
        builder: (_) => _PartyDetailSheet(graph: g),
      );
    });
  }
}

class _RankCard extends StatelessWidget {
  final int position;
  final String partido;
  final double score;
  final double? tasaCorrupcion;
  final bool isCustom;
  final VoidCallback? onTap;

  const _RankCard({
    required this.position,
    required this.partido,
    required this.score,
    this.tasaCorrupcion,
    this.isCustom = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corr = tasaCorrupcion ?? 0;
    final corrColor = corr < 29.9
        ? Colors.green
        : corr < 60
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Position number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _positionColor(position),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$position',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: position >= 10 ? 9 : 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Party logo
              PartyLogo(partyName: partido, size: 38, withBorder: true),
              const SizedBox(width: 12),

              // Party name + score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partido,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isCustom
                              ? 'Score personalizado: '
                              : 'Score Global: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          '${score.toStringAsFixed(1)} / 100',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Corruption rate badge
              if (tasaCorrupcion != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TK Corrupción',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: corrColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${corr.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

              if (onTap != null)
                const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _positionColor(int pos) {
    if (pos <= 5) return Colors.green;
    if (pos <= 15) return Colors.blue;
    if (pos <= 25) return Colors.orange;
    return Colors.red;
  }
}

class _PartyDetailSheet extends StatelessWidget {
  final dynamic graph;
  const _PartyDetailSheet({required this.graph});

  @override
  Widget build(BuildContext context) {
    final indicators = [
      ('Sentencias', graph.sentencias, Icons.gavel, Colors.red,
          'Score de ausencia de sentencias judiciales (100 = ninguna sentencia en el equipo)'),
      ('Preparación Académica', graph.preparacion, Icons.school, Colors.blue,
          'Índice de formación académica promedio del equipo (100 = máxima preparación)'),
      ('Ingresos No Declarados', graph.ingresosNoDeclarados, Icons.money_off,
          Colors.brown,
          'Score de transparencia en declaración de ingresos (100 = todos declaran ingresos válidos)'),
      ('Ingresos Efectivos', graph.ingresosEfectivos, Icons.attach_money,
          Colors.green,
          'Score basado en ingresos mensuales efectivos promedio del partido'),
      ('Libre de Pacto Corrupto', graph.librePacto, Icons.handshake,
          Colors.purple,
          'Score de ausencia de vínculos con el Pacto de Corrupción #PorEstosNo (25% del índice)'),
      ('Sin Reelección', graph.reeleccion, Icons.how_to_vote, Colors.teal,
          'Score basado en ausencia de excongresistas en la lista'),
      ('Equipo Completo', graph.equipoCompleto, Icons.group, Colors.cyan,
          'Score por presentar el equipo de 30 candidatos completo'),
      ('Sin REINFO', graph.reinfo, Icons.landscape, Colors.orange,
          'Score de ausencia de candidatos vinculados a minería informal (REINFO)'),
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  PartyLogo(partyName: graph.partido, size: 40, withBorder: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          graph.partido,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Score Total: ${graph.scoreFinal.toStringAsFixed(1)} / 100',
                          style: const TextStyle(color: Colors.indigo, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                children: indicators.map((ind) {
                  final score = (ind.$2 as num).toDouble();
                  return _IndicatorRow(
                    label: ind.$1,
                    score: score,
                    icon: ind.$3,
                    color: ind.$4,
                    description: ind.$5,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  final String label;
  final double score;
  final IconData icon;
  final Color color;
  final String description;

  const _IndicatorRow({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              Text('/100',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
