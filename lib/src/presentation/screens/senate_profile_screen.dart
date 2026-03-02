import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/new_providers.dart';
import '../widgets/charts/education_donut_chart.dart';
import '../widgets/charts/party_bar_chart.dart';
import '../widgets/info_tooltip.dart';

class SenateProfileScreen extends ConsumerWidget {
  const SenateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardSummaryProvider);
    final candidatesAsync = ref.watch(allCandidatesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Senado 2026'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI row
            dashAsync.when(
              data: (d) => _KpiRow(
                kpis: [
                  _KpiItem(
                    label: 'Candidatos con Sentencias',
                    value: d.candidatosConSentencias.toString(),
                    icon: Icons.gavel,
                    color: Colors.red,
                    tooltip: 'Candidatos al Senado Nacional que tienen al menos una sentencia judicial registrada en su contra al momento de la inscripción.',
                  ),
                  _KpiItem(
                    label: 'Candidatos REINFO',
                    value: d.alertasReinfo.toString(),
                    icon: Icons.landscape,
                    color: Colors.orange,
                    tooltip: 'Candidatos vinculados al Registro Integral de Formalización Minera (REINFO). Indica posibles vínculos con minería informal o ilegal.',
                  ),
                  _KpiItem(
                    label: 'Partidos Equipo Completo',
                    value: d.partidosEquipoCompleto.toString(),
                    icon: Icons.group,
                    color: Colors.green,
                    tooltip: 'Número de partidos que presentaron los 30 candidatos reglamentarios al Senado Nacional. Indica seriedad organizativa.',
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Education Donut
            Text(
              'Distribución Educativa de Candidatos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nivel académico más alto declarado por cada candidato',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InfoTooltip(
                  title: 'Distribución Educativa',
                  message:
                      'Muestra cuántos candidatos tienen cada nivel académico como su título más alto. '
                      'El nivel educativo es uno de los 8 indicadores del índice de transparencia '
                      '(peso: 20%). A mayor preparación académica, mejor puntuación para el partido.',
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: const EducationDonutChart(),
            ),
            const SizedBox(height: 16),

            // Legend for donut
            _EducationLegend(),
            const SizedBox(height: 24),

            // Bar chart sentences
            Text(
              'Sentencias por Partido (Top 10)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Candidatos con condenas judiciales registradas',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InfoTooltip(
                  title: 'Sentencias Judiciales',
                  message:
                      'Muestra los 10 partidos con más candidatos que tienen sentencias judiciales. '
                      'Este es uno de los indicadores más importantes del índice (peso: 20%). '
                      'Incluye sentencias firmes registradas al momento de la inscripción electoral.',
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: const PartyBarChart(),
            ),
            const SizedBox(height: 24),

            // Top 10 by income
            Text(
              'Top 10 Candidatos por Ingresos Declarados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ingreso mensual total declarado ante la ONPE',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InfoTooltip(
                  title: 'Ingresos Declarados',
                  message:
                      'Los ingresos son declarados voluntariamente por los candidatos ante la ONPE. '
                      'Un ingreso declarado en cero puede indicar ocultamiento de bienes. '
                      'Los ingresos no declarados tienen un peso del 10% en el índice.',
                ),
              ],
            ),
            const SizedBox(height: 8),
            candidatesAsync.when(
              data: (candidates) {
                final top10 = List.of(candidates)
                  ..sort((a, b) =>
                      b.ingresosTotales.compareTo(a.ingresosTotales));
                final top = top10.take(10).toList();
                return Card(
                  child: Column(
                    children: top.asMap().entries.map((e) {
                      final c = e.value;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              Colors.indigo.withValues(alpha: 0.1),
                          child: Text(
                            '#${e.key + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'DNI ${c.dni}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          c.partido,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          currencyFormat.format(c.ingresosTotales),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final List<_KpiItem> kpis;
  const _KpiRow({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: kpis
                .map((k) => Expanded(child: _KpiCard(item: k)))
                .toList(),
          );
        }
        return Column(
          children: kpis.map((k) => _KpiCard(item: k)).toList(),
        );
      },
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String tooltip;

  const _KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tooltip,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiItem item;
  const _KpiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      InfoTooltip(
                          title: item.label, message: item.tooltip),
                    ],
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: item.color,
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

class _EducationLegend extends StatelessWidget {
  final List<(String, Color)> items = const [
    ('Primaria', Colors.blueAccent),
    ('Secundaria', Colors.orange),
    ('Técnico', Colors.purple),
    ('No Universitario', Colors.redAccent),
    ('Universitario', Colors.green),
    ('Maestría', Colors.teal),
    ('Doctorado', Colors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.$2,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(item.$1, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
