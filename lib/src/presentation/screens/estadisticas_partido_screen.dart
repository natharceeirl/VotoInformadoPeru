import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ─── Pantalla: Estadísticas por Partido ──────────────────────────────────────

class EstadisticasPartidoScreen extends ConsumerWidget {
  final ProcesoElectoral proceso;
  const EstadisticasPartidoScreen({super.key, required this.proceso});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = proceso.color;
    final async = ref.watch(candidatosConHVProcesoProvider(proceso));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Estadísticas por Partido'),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (candidatos) {
          if (candidatos.isEmpty) {
            return _emptyState(context, proceso);
          }
          return proceso == ProcesoElectoral.presidentes
              ? _PlanchaView(candidatos: candidatos, color: color)
              : _PartidoView(candidatos: candidatos, color: color,
                             proceso: proceso);
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context, ProcesoElectoral p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 56, color: p.color),
            const SizedBox(height: 16),
            Text('Datos no disponibles aún',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Ejecuta el script de descarga para ${p.displayName}.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Vista Plancha Presidencial ───────────────────────────────────────────────

class _PlanchaView extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final Color color;

  const _PlanchaView({required this.candidatos, required this.color});

  @override
  Widget build(BuildContext context) {
    // Group by partido (idOrg as key for stability)
    final Map<String, List<CandidatoConHV>> byParty = {};
    for (final c in candidatos) {
      final key = c.hv.partido;
      (byParty[key] ??= []).add(c);
    }

    // Build plancha stats
    final planchas = byParty.entries.map((e) {
      return _PlanchaStat(e.key, e.value);
    }).toList()
      ..sort((a, b) => b.scorePromedio.compareTo(a.scorePromedio));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Info banner ─────────────────────────────────────────────────
          _InfoBanner(
            color: color,
            text: 'Ranking de planchas presidenciales por puntaje promedio '
                'de integridad (educación + antecedentes). '
                'Los votantes eligen la plancha completa.',
          ),
          const SizedBox(height: 16),

          // ── Bar chart top 10 ────────────────────────────────────────────
          if (planchas.length >= 2) ...[
            _SectionHeader('TOP PLANCHAS — PUNTAJE PROMEDIO', color),
            const SizedBox(height: 8),
            _PlanchaBarChart(planchas: planchas.take(10).toList(), color: color),
            const SizedBox(height: 20),
          ],

          // ── Ranking cards ───────────────────────────────────────────────
          _SectionHeader('RANKING COMPLETO', color),
          const SizedBox(height: 8),
          ...planchas.asMap().entries.map((e) =>
            _PlanchaCard(rank: e.key + 1, stat: e.value, color: color)),
        ],
      ),
    );
  }
}

class _PlanchaStat {
  final String partido;
  final List<CandidatoConHV> miembros;

  _PlanchaStat(this.partido, this.miembros);

  double get scorePromedio {
    if (miembros.isEmpty) return 0;
    return miembros.fold<double>(0, (s, c) => s + c.hv.scoreFinal) /
        miembros.length;
  }

  int get scoreMin => miembros.isEmpty
      ? 0
      : miembros.map((c) => c.hv.scoreFinal).reduce((a, b) => a < b ? a : b);

  bool get todosSinSentencia =>
      miembros.every((c) => c.hv.totalSentenciasPenales == 0 &&
          c.hv.totalSentenciasObligaciones == 0);

  bool get algunoConSentencia =>
      miembros.any((c) => c.hv.totalSentenciasPenales > 0 ||
          c.hv.totalSentenciasObligaciones > 0);

  String get nivelEduMax {
    const order = [
      'DOCTORADO', 'MAESTRIA', 'POSGRADO', 'UNIVERSITARIA',
      'UNIVERSITARIA_INCOMPLETA', 'TECNICA', 'NO_UNIVERSITARIA',
      'SECUNDARIA', 'PRIMARIA', 'SIN_DATOS',
    ];
    String best = 'SIN_DATOS';
    for (final c in miembros) {
      final idx = order.indexOf(c.hv.nivelEducacion);
      if (idx != -1 && idx < order.indexOf(best)) best = c.hv.nivelEducacion;
    }
    return best;
  }
}

class _PlanchaBarChart extends StatelessWidget {
  final List<_PlanchaStat> planchas;
  final Color color;
  const _PlanchaBarChart({required this.planchas, required this.color});

  @override
  Widget build(BuildContext context) {
    final bars = planchas.asMap().entries.map((e) {
      final score = e.value.scorePromedio;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: score,
            color: score >= 70
                ? const Color(0xFF2E7D32)
                : score >= 45
                    ? const Color(0xFFF57F17)
                    : const Color(0xFFC62828),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 12, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: bars,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= planchas.length) return const SizedBox();
                  final name = planchas[i].partido;
                  // Show short abbreviation
                  final short = name.split(' ').map((w) => w.isNotEmpty
                      ? w[0].toUpperCase() : '').take(3).join();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(short,
                      style: const TextStyle(fontSize: 8, color: Colors.grey)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

class _PlanchaCard extends StatelessWidget {
  final int rank;
  final _PlanchaStat stat;
  final Color color;

  const _PlanchaCard({
    required this.rank, required this.stat, required this.color});

  static const _cargoOrder = [
    'PRESIDENTE DE LA REPÚBLICA',
    'PRIMER VICEPRESIDENTE DE LA REPÚBLICA',
    'SEGUNDO VICEPRESIDENTE DE LA REPÚBLICA',
  ];

  @override
  Widget build(BuildContext context) {
    final score = stat.scorePromedio;
    final scoreColor = score >= 70
        ? const Color(0xFF2E7D32)
        : score >= 45 ? const Color(0xFFF57F17) : const Color(0xFFC62828);
    final scoreBg = score >= 70
        ? const Color(0xFFE8F5E9)
        : score >= 45 ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);

    final miembrosOrdenados = [...stat.miembros]
      ..sort((a, b) {
        final ia = _cargoOrder.indexOf(a.cargo);
        final ib = _cargoOrder.indexOf(b.cargo);
        return ia == -1 ? 1 : ib == -1 ? -1 : ia.compareTo(ib);
      });

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: rank + partido + score ──────────────────────────
            Row(
              children: [
                // Rank
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? [Colors.amber, Colors.grey.shade400,
                           const Color(0xFFCD7F32)][rank - 1]
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$rank',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                      )),
                  ),
                ),
                const SizedBox(width: 10),
                // Logo
                SizedBox(
                  width: 32, height: 32,
                  child: PartyLogo(partyName: stat.partido, size: 32)),
                const SizedBox(width: 8),
                // Name
                Expanded(
                  child: Text(stat.partido,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: scoreColor, height: 1)),
                      Text('/100',
                        style: TextStyle(
                          fontSize: 8, color: scoreColor, height: 1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Chips de alertas ────────────────────────────────────────
            Wrap(
              spacing: 5, runSpacing: 4,
              children: [
                if (stat.todosSinSentencia)
                  _StatChip(Icons.verified_rounded,
                      'Sin antecedentes', const Color(0xFF2E7D32)),
                if (stat.algunoConSentencia)
                  _StatChip(Icons.gavel_rounded,
                      'Con antecedentes', const Color(0xFFC62828)),
                _StatChip(Icons.people_rounded,
                    '${stat.miembros.length} candidatos', Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 10),

            // ── Miembros de la plancha ───────────────────────────────────
            ...miembrosOrdenados.map((c) => _MiembroRow(c: c)),
          ],
        ),
      ),
    );
  }
}

class _MiembroRow extends StatelessWidget {
  final CandidatoConHV c;
  const _MiembroRow({required this.c});

  String _shortCargo(String cargo) {
    if (cargo.contains('SEGUNDO VICE')) return '2do VP';
    if (cargo.contains('PRIMER VICE'))  return '1er VP';
    if (cargo.contains('PRESIDENTE'))   return 'Presidente';
    return cargo;
  }

  @override
  Widget build(BuildContext context) {
    final hv = c.hv;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_shortCargo(c.cargo),
              style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold,
                color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(hv.nombre,
              style: const TextStyle(fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          // Score mini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: hv.scoreBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${hv.scoreFinal}',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold,
                color: hv.scoreColor)),
          ),
          const SizedBox(width: 6),
          // Sentencias indicator
          if (hv.totalSentenciasPenales > 0 ||
              hv.totalSentenciasObligaciones > 0)
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: Color(0xFFC62828))
          else
            const Icon(Icons.check_circle_rounded,
                size: 14, color: Color(0xFF2E7D32)),
        ],
      ),
    );
  }
}

// ─── Vista por Partido (Diputados / Senadores / Parlamento Andino) ────────────

class _PartidoView extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final Color color;
  final ProcesoElectoral proceso;

  const _PartidoView({
    required this.candidatos,
    required this.color,
    required this.proceso,
  });

  @override
  Widget build(BuildContext context) {
    // Aggregate by partido
    final Map<String, _PartidoStat> byParty = {};
    for (final c in candidatos) {
      final p = byParty.putIfAbsent(c.hv.partido, () => _PartidoStat(c.hv.partido));
      p.add(c.hv);
    }
    final stats = byParty.values.toList()
      ..sort((a, b) => b.scorePromedio.compareTo(a.scorePromedio));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoBanner(
            color: color,
            text: 'Ranking de partidos para ${proceso.displayName} ordenado '
                'por puntaje promedio de integridad de sus candidatos.',
          ),
          const SizedBox(height: 16),

          // ── Summary chips ─────────────────────────────────────────────
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              _StatChip(Icons.people_rounded,
                  '${candidatos.length} candidatos', Colors.blueGrey),
              _StatChip(Icons.groups_rounded,
                  '${stats.length} partidos', color),
              _StatChip(Icons.verified_rounded,
                  '${candidatos.where((c) => c.hv.totalSentenciasPenales == 0 && c.hv.totalSentenciasObligaciones == 0).length} sin antecedentes',
                  const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Bar chart top 10 ──────────────────────────────────────────
          if (stats.length >= 2) ...[
            _SectionHeader('TOP PARTIDOS — PUNTAJE PROMEDIO', color),
            const SizedBox(height: 8),
            _PartidoBarChart(stats: stats.take(10).toList(), color: color),
            const SizedBox(height: 20),
          ],

          // ── Ranking table ─────────────────────────────────────────────
          _SectionHeader('RANKING COMPLETO', color),
          const SizedBox(height: 8),
          ...stats.asMap().entries.map((e) =>
            _PartidoCard(rank: e.key + 1, stat: e.value, color: color)),
        ],
      ),
    );
  }
}

class _PartidoStat {
  final String partido;
  int total = 0;
  int conPosgrado = 0;
  int sinSentencias = 0;
  int conSentPenal = 0;
  int sumaScore = 0;
  double sumaIngreso = 0;

  _PartidoStat(this.partido);

  void add(HojaVida hv) {
    total++;
    if (hv.esMaestro || hv.esDoctor) conPosgrado++;
    if (hv.totalSentenciasPenales == 0 && hv.totalSentenciasObligaciones == 0) {
      sinSentencias++;
    }
    if (hv.totalSentenciasPenales > 0) conSentPenal++;
    sumaScore += hv.scoreFinal;
    sumaIngreso += hv.ingresoTotal;
  }

  double get scorePromedio => total > 0 ? sumaScore / total : 0;
  double get pctSinSentencias =>
      total > 0 ? sinSentencias / total * 100 : 0;
  double get pctPosgrado => total > 0 ? conPosgrado / total * 100 : 0;
  double get ingresoPromedio => total > 0 ? sumaIngreso / total : 0;
}

class _PartidoBarChart extends StatelessWidget {
  final List<_PartidoStat> stats;
  final Color color;
  const _PartidoBarChart({required this.stats, required this.color});

  @override
  Widget build(BuildContext context) {
    final bars = stats.asMap().entries.map((e) {
      final score = e.value.scorePromedio;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: score,
            color: score >= 70
                ? const Color(0xFF2E7D32)
                : score >= 45
                    ? const Color(0xFFF57F17)
                    : const Color(0xFFC62828),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 12, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: bars,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= stats.length) return const SizedBox();
                  final name = stats[i].partido;
                  final short = name.split(' ')
                      .where((w) => w.isNotEmpty)
                      .map((w) => w[0].toUpperCase())
                      .take(3).join();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(short,
                      style: const TextStyle(fontSize: 8, color: Colors.grey)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

class _PartidoCard extends StatelessWidget {
  final int rank;
  final _PartidoStat stat;
  final Color color;

  const _PartidoCard({
    required this.rank, required this.stat, required this.color});

  String _formatMoney(double v) {
    if (v == 0) return 'S/ 0';
    if (v >= 1000000) return 'S/ ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return 'S/ ${(v / 1000).toStringAsFixed(0)}K';
    return 'S/ ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final score = stat.scorePromedio;
    final scoreColor = score >= 70
        ? const Color(0xFF2E7D32)
        : score >= 45 ? const Color(0xFFF57F17) : const Color(0xFFC62828);
    final scoreBg = score >= 70
        ? const Color(0xFFE8F5E9)
        : score >= 45 ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank circle
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? [Colors.amber, Colors.grey.shade400,
                       const Color(0xFFCD7F32)][rank - 1]
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$rank',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : Colors.grey.shade600)),
              ),
            ),
            const SizedBox(width: 8),
            // Logo
            SizedBox(width: 30, height: 30,
              child: PartyLogo(partyName: stat.partido, size: 30)),
            const SizedBox(width: 8),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat.partido,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6, runSpacing: 3,
                    children: [
                      _MiniLabel('${stat.total} cand.', Colors.blueGrey),
                      _MiniLabel(
                          '${stat.pctSinSentencias.toStringAsFixed(0)}% sin ant.',
                          stat.pctSinSentencias >= 80
                              ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                      _MiniLabel(
                          '${stat.pctPosgrado.toStringAsFixed(0)}% posgrado',
                          const Color(0xFF1565C0)),
                      if (stat.ingresoPromedio > 0)
                        _MiniLabel(
                            '~${_formatMoney(stat.ingresoPromedio)} prom.',
                            Colors.grey.shade600),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scoreBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: scoreColor, height: 1)),
                  Text('/100',
                    style: TextStyle(
                      fontSize: 7, color: scoreColor, height: 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers compartidos ──────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final Color color;
  final String text;
  const _InfoBanner({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: TextStyle(
                color: Colors.grey.shade700, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionHeader(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold,
            color: Colors.grey.shade600, letterSpacing: 0.8)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(fontSize: 10, color: color));
  }
}
