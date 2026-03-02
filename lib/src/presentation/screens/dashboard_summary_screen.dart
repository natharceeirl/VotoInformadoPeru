import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import '../widgets/indicator_weights_sheet.dart';
import '../widgets/charts/education_donut_chart.dart';

class DashboardSummaryScreen extends ConsumerWidget {
  const DashboardSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final customRankedAsync = ref.watch(customRankedPartiesProvider);
    final isCustom = !ref.watch(customWeightsProvider.notifier).isDefault;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Resumen'),
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
      body: dashboardAsync.when(
        data: (dashboard) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Description banner ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.dashboard_rounded,
                          color: Theme.of(context).colorScheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¿Para qué sirve esta pantalla?',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 4),
                            Text(
                              'Aquí puedes ver el estado general del Senado 2026: cuántos '
                              'partidos y candidatos participan, cuántos tienen alertas REINFO '
                              'o sentencias, y quiénes lideran el ranking de transparencia. '
                              'También puedes personalizar los pesos de cada indicador.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Configurar button (prominent) ───────────────────────────
                if (!isCustom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Personalizar pesos de indicadores'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => showIndicatorWeightsSheet(context, ref),
                    ),
                  ),

                // ── Indicator config banner ─────────────────────────────────
                if (isCustom)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ranking personalizado activo — pesos modificados',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(customWeightsProvider.notifier)
                              .reset(),
                          child: const Text('Restablecer',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Top / Bottom Rankings ────────────────────────────────────
                Text(
                  isCustom ? 'Ranking Personalizado' : 'Top 5 / Últimos 5 Partidos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  isCustom
                      ? 'Ranking recalculado con tus pesos personalizados. Score = promedio ponderado de los 8 indicadores (0–100).'
                      : 'Ranking oficial 0–100. Score 100 = máxima transparencia. Pesos: Libre de Pacto 25%, Sentencias 20%, Preparación 20%, Reelección 10%, Ing. No Declarados 10%, Equipo 5%, Ing. Efectivos 5%, REINFO 5%.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                if (isCustom)
                  customRankedAsync.when(
                    data: (scored) {
                      final top5 = scored.take(5).toList();
                      final bot5 = scored.reversed.take(5).toList().reversed.toList();
                      return _RankingLayout(
                        top: top5.map((s) => (s.graph.partido, s.customScore)).toList(),
                        bottom: bot5.map((s) => (s.graph.partido, s.customScore)).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 800;
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _TopBottomList(
                                title: 'Top 5 Partidos',
                                items: dashboard.top5,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _TopBottomList(
                                title: 'Últimos 5 Partidos',
                                items: dashboard.bottom5,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _TopBottomList(
                            title: 'Top 5 Partidos',
                            items: dashboard.top5,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _TopBottomList(
                            title: 'Últimos 5 Partidos',
                            items: dashboard.bottom5,
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // ── Education Distribution ───────────────────────────────────
                Text(
                  'Distribución Educativa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '% de los 964 candidatos por nivel académico más alto. La preparación tiene peso del 20% en el índice. Toca un sector para ver el detalle y el desglose por partido.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
                const _EduSection(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RankingLayout extends StatelessWidget {
  final List<(String, double)> top;
  final List<(String, double)> bottom;

  const _RankingLayout({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isDesktop = constraints.maxWidth > 800;
      Widget topCard = _CustomRankCard(title: 'Top 5 (Personalizado)', items: top, color: Colors.green);
      Widget botCard = _CustomRankCard(title: 'Últimos 5 5 (Personalizado)', items: bottom, color: Colors.red);
      if (isDesktop) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: topCard),
          const SizedBox(width: 16),
          Expanded(child: botCard),
        ]);
      }
      return Column(children: [topCard, const SizedBox(height: 16), botCard]);
    });
  }
}

class _CustomRankCard extends StatelessWidget {
  final String title;
  final List<(String, double)> items;
  final Color color;

  const _CustomRankCard({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.leaderboard, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((e) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Text('#${e.key + 1}',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                  title: Text(e.value.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${e.value.$2.toStringAsFixed(1)} pts',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _TopBottomList extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Color color;

  const _TopBottomList({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${item.posicion}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: item.posicion >= 10 ? 8 : 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PartyLogo(partyName: item.partido, size: 36, withBorder: true),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.partido,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${item.score.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Education section: donut chart + party breakdown side by side ────────────
class _EduSection extends StatefulWidget {
  const _EduSection();

  @override
  State<_EduSection> createState() => _EduSectionState();
}

class _EduSectionState extends State<_EduSection> {
  String? _selectedEduLevel;

  @override
  Widget build(BuildContext context) {
    // El gráfico gestiona su propia altura internamente (no necesita SizedBox fijo)
    final chartContainer = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: EducationDonutChart(
        onSectionChanged: (level) =>
            setState(() => _selectedEduLevel = level),
      ),
    );

    final breakdown = _EduPartyBreakdown(selectedLevel: _selectedEduLevel);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 640) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: chartContainer),
              const SizedBox(width: 14),
              SizedBox(width: 260, child: breakdown),
            ],
          );
        }
        return Column(
          children: [
            chartContainer,
            const SizedBox(height: 14),
            breakdown,
          ],
        );
      },
    );
  }
}

// ─── Party breakdown by education level ──────────────────────────────────────
class _EduPartyBreakdown extends ConsumerWidget {
  final String? selectedLevel;
  const _EduPartyBreakdown({required this.selectedLevel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allAsync = ref.watch(allCandidatesProvider);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.account_balance_rounded,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Desglose por Partido',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Level chip — siempre visible ────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedLevel ?? 'Todos los niveles',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Lista — siempre visible, internamente desplazable ──────────
            allAsync.when(
              data: (candidates) {
                // Sin selección → todos los candidatos; con selección → filtrar
                final filtered = selectedLevel == null
                    ? candidates
                    : candidates
                        .where(
                            (c) => c.educacion.maxLevel == selectedLevel)
                        .toList();

                final countByParty = <String, int>{};
                for (final c in filtered) {
                  countByParty[c.partido] =
                      (countByParty[c.partido] ?? 0) + 1;
                }
                final sorted = countByParty.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filtered.length} candidatos · ${sorted.length} partidos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista con altura fija para desplazamiento interno
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (context, i) {
                          final e = sorted[i];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                PartyLogo(partyName: e.key, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.value}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
