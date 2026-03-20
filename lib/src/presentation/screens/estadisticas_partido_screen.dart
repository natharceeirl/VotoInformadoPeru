import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ─── Pantalla: Estadísticas por Partido ──────────────────────────────────────

class EstadisticasPartidoScreen extends ConsumerStatefulWidget {
  final ProcesoElectoral proceso;
  const EstadisticasPartidoScreen({super.key, required this.proceso});

  @override
  ConsumerState<EstadisticasPartidoScreen> createState() =>
      _EstadisticasPartidoScreenState();
}

class _EstadisticasPartidoScreenState
    extends ConsumerState<EstadisticasPartidoScreen> {
  String _nameFilter = '';
  String? _partidoFilter;
  String? _regionFilter;
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<CandidatoConHV> _applyFilters(
    List<CandidatoConHV> candidatos,
    List<String> porEstosNo,
    bool excluir,
  ) {
    var result = candidatos;
    if (_nameFilter.isNotEmpty) {
      final q = _nameFilter.toUpperCase();
      result = result.where((c) => c.hv.nombre.toUpperCase().contains(q)).toList();
    }
    if (_partidoFilter != null) {
      result = result.where((c) => c.hv.partido == _partidoFilter).toList();
    }
    if (_regionFilter != null) {
      result = result.where((c) => c.departamento == _regionFilter).toList();
    }
    if (excluir && porEstosNo.isNotEmpty) {
      result = result.where((c) {
        final norm = _normName(c.hv.partido);
        return !porEstosNo.any((p) => norm == p || norm.contains(p));
      }).toList();
    }
    return result;
  }

  Widget _buildFilters(List<CandidatoConHV> todos) {
    final cs = Theme.of(context).colorScheme;
    final partidos = todos.map((c) => c.hv.partido).toSet().toList()..sort();
    final proceso = widget.proceso;
    final hasRegion = proceso == ProcesoElectoral.diputados ||
        proceso == ProcesoElectoral.parlamentoAndino;
    final regiones = hasRegion
        ? (todos.map((c) => c.departamento).where((d) => d.isNotEmpty).toSet().toList()..sort())
        : <String>[];
    final hasActive = _nameFilter.isNotEmpty || _partidoFilter != null || _regionFilter != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name search
          TextField(
            controller: _nameCtrl,
            onChanged: (v) => setState(() => _nameFilter = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o apellido...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.person_search_rounded, size: 18),
              suffixIcon: _nameFilter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _nameCtrl.clear();
                        setState(() => _nameFilter = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Party dropdown
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: _partidoFilter,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: const Text('Partido...', style: TextStyle(fontSize: 12)),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos los partidos', style: TextStyle(fontSize: 12)),
                ),
                ...partidos.map((p) => DropdownMenuItem<String>(
                      value: p,
                      child: Row(children: [
                        PartyLogo(partyName: p, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(p,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    )),
              ],
              onChanged: (v) => setState(() => _partidoFilter = v),
            ),
          ),
          // Region dropdown (Diputados / Parlamento Andino only)
          if (hasRegion && regiones.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _regionFilter,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Row(children: [
                  Icon(Icons.map_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Todas las regiones', style: TextStyle(fontSize: 12)),
                ]),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todas las regiones', style: TextStyle(fontSize: 12)),
                  ),
                  ...regiones.map((r) => DropdownMenuItem<String>(
                        value: r,
                        child: Text(r, style: const TextStyle(fontSize: 12)),
                      )),
                ],
                onChanged: (v) => setState(() => _regionFilter = v),
              ),
            ),
          ],
          if (hasActive) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _nameCtrl.clear();
                  setState(() {
                    _nameFilter = '';
                    _partidoFilter = null;
                    _regionFilter = null;
                  });
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 14),
                label: const Text('Limpiar filtros', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBanner(List<String> porEstosNo, List<Map<String, dynamic>> detalle) {
    final excluir = ref.watch(excluirPartidosRiesgoProvider);
    return InkWell(
      onTap: () => _showPorEstosNoDialog(context, detalle),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: excluir
              ? const Color(0xFFB71C1C).withValues(alpha: 0.08)
              : Colors.orange.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: excluir
                ? const Color(0xFFB71C1C).withValues(alpha: 0.3)
                : Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              excluir ? Icons.block_rounded : Icons.warning_amber_rounded,
              size: 16,
              color: excluir ? const Color(0xFFB71C1C) : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                excluir
                    ? 'Filtro activo: ocultando ${porEstosNo.length} partidos con riesgo de corrupción'
                    : 'Hay ${porEstosNo.length} partidos con riesgo de corrupción — toca para filtrar',
                style: TextStyle(
                  fontSize: 11,
                  color: excluir
                      ? const Color(0xFFB71C1C)
                      : Colors.orange.shade800,
                ),
              ),
            ),
            Switch(
              value: excluir,
              onChanged: (_) =>
                  ref.read(excluirPartidosRiesgoProvider.notifier).toggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeThumbColor: const Color(0xFFB71C1C),
              activeTrackColor: const Color(0xFFB71C1C).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showPorEstosNoDialog(BuildContext context, List<Map<String, dynamic>> detalle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('#PORESTOSNO', style: TextStyle(fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Partidos con antecedentes documentados de corrupción según '
                'registros públicos e investigaciones judiciales.\n',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
              if (detalle.isNotEmpty) ...[
                const Divider(),
                ...detalle.map((p) {
                  final nombre = (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel = (p['nivel_riesgo'] as String? ?? '').toUpperCase();
                  final indice = (p['indice_riesgo_corrupcion'] as num?)?.toDouble() ?? 0.0;
                  final casos = (p['casos_corrupcion'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                  final isAlto = nivel == 'ALTO';
                  final riskColor = isAlto ? Colors.red.shade700 : Colors.orange.shade700;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 32, height: 32,
                              child: PartyLogo(partyName: nombre, size: 32),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  children: [
                                    TextSpan(text: nombre,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    TextSpan(
                                      text: ' — $nivel (${indice.toStringAsFixed(2)})',
                                      style: TextStyle(color: riskColor, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (casos.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...casos.take(2).map((c) {
                            final caso = c['nombre_caso'] as String? ?? '';
                            final estado = c['estado'] as String? ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(left: 40, top: 2),
                              child: Text(
                                '• $caso${estado.isNotEmpty ? ' ($estado)' : ''}',
                                style: TextStyle(fontSize: 10, color: riskColor, height: 1.4),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],
              Text(
                'Al activar el filtro, sus candidatos serán ocultados. '
                'Información orientativa — no constituye acusación formal.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final proceso    = widget.proceso;
    final color      = proceso.color;
    final async      = ref.watch(candidatosConHVProcesoProvider(proceso));
    final porEstosNo = ref.watch(porEstosNoProvider).asData?.value ?? [];
    final detalle    = ref.watch(porEstosNoDetalleProvider).asData?.value ?? [];
    final excluir    = ref.watch(excluirPartidosRiesgoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${widget.proceso.displayName} — Estadísticas'),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (candidatos) {
          if (candidatos.isEmpty) return _emptyState(context, proceso);
          final filtrados = _applyFilters(candidatos, porEstosNo, excluir);
          return Column(
            children: [
              _buildFilters(candidatos),
              if (porEstosNo.isNotEmpty) _buildFilterBanner(porEstosNo, detalle),
              Expanded(
                child: proceso == ProcesoElectoral.presidentes
                    ? _PlanchaView(
                        candidatos: filtrados,
                        color: color,
                        proceso: proceso,
                        proCrimenPartido:
                            ref.watch(proCrimenPartidoProvider).asData?.value ?? {},
                      )
                    : _PartidoView(
                        candidatos: filtrados,
                        color: color,
                        proceso: proceso,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Vista Plancha Presidencial ───────────────────────────────────────────────

class _PlanchaView extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final Color color;
  final ProcesoElectoral proceso;
  final Map<String, int> proCrimenPartido; // party_norm → leyes count

  const _PlanchaView({
    required this.candidatos,
    required this.color,
    required this.proceso,
    required this.proCrimenPartido,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<CandidatoConHV>> byParty = {};
    for (final c in candidatos) {
      (byParty[c.hv.partido] ??= []).add(c);
    }

    final planchas = byParty.entries
        .map((e) => _PlanchaStat(e.key, e.value))
        .toList()
      ..sort((a, b) => b.scorePromedio.compareTo(a.scorePromedio));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoBanner(
            color: color,
            text: 'Ranking de planchas presidenciales por puntaje promedio '
                'de integridad (educación + antecedentes − penalizaciones). '
                'Los votantes eligen la plancha completa.',
          ),
          const SizedBox(height: 14),

          // ── Podio top-3 ──────────────────────────────────────────────────
          if (planchas.length >= 2) ...[
            _SectionHeader('MEJORES PLANCHAS', color),
            const SizedBox(height: 8),
            _ScoreLeaderboard(
              items: planchas.take(10).toList().asMap().entries
                  .map((e) => _LeaderEntry(
                    rank:    e.key + 1,
                    nombre:  e.value.partido,
                    score:   e.value.scorePromedio,
                  )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Ranking cards ─────────────────────────────────────────────────
          _SectionHeader('RANKING COMPLETO', color),
          const SizedBox(height: 8),
          ...planchas.asMap().entries.map((e) =>
            _PlanchaCard(rank: e.key + 1, stat: e.value, color: color,
                         proceso: proceso,
                         proCrimenPartido: proCrimenPartido)),
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

  bool get todosSinSentencia =>
      miembros.every((c) => c.hv.totalSentenciasPenales == 0 &&
          c.hv.totalSentenciasObligaciones == 0);

  bool get algunoConSentencia =>
      miembros.any((c) => c.hv.totalSentenciasPenales > 0 ||
          c.hv.totalSentenciasObligaciones > 0);

  int get totalLeyesProCrimen =>
      miembros.fold(0, (s, c) => s + c.hv.numLeyesProCrimen);
}

class _PlanchaCard extends StatelessWidget {
  final int rank;
  final _PlanchaStat stat;
  final Color color;
  final ProcesoElectoral proceso;
  final Map<String, int> proCrimenPartido;

  const _PlanchaCard({
    required this.rank, required this.stat,
    required this.color, required this.proceso,
    required this.proCrimenPartido,
  });

  static const _cargoOrder = [
    'PRESIDENTE DE LA REPÚBLICA',
    'PRIMER VICEPRESIDENTE DE LA REPÚBLICA',
    'SEGUNDO VICEPRESIDENTE DE LA REPÚBLICA',
  ];

  @override
  Widget build(BuildContext context) {
    final score = stat.scorePromedio;
    final scoreColor = _scoreColor(score);
    final scoreBg    = _scoreBg(score);

    final miembrosOrdenados = [...stat.miembros]
      ..sort((a, b) {
        final ia = _cargoOrder.indexOf(a.cargo);
        final ib = _cargoOrder.indexOf(b.cargo);
        return ia == -1 ? 1 : ib == -1 ? -1 : ia.compareTo(ib);
      });

    // Leyes pro-crimen a nivel de partido parlamentario (GRUPO_PARLAMENTARIO)
    final normPartido  = _normName(stat.partido);
    final pcPartidoCount = proCrimenPartido[normPartido] ?? 0;
    // Investigaciones: tomadas del primer miembro que tenga texto
    final invText = stat.miembros
        .map((c) => c.hv.investigacionesConocidas)
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header tappable ──────────────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => _showPlanchaDetalle(context, stat, proceso,
                pcPartidoCount, invText),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  _RankCircle(rank: rank),
                  const SizedBox(width: 10),
                  SizedBox(width: 32, height: 32,
                    child: PartyLogo(partyName: stat.partido, size: 32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stat.partido,
                          style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 5, runSpacing: 4,
                          children: [
                            if (stat.todosSinSentencia)
                              _StatChip(Icons.verified_rounded,
                                  'Sin antecedentes', const Color(0xFF2E7D32)),
                            if (stat.algunoConSentencia)
                              _StatChip(Icons.gavel_rounded,
                                  'Con antecedentes', const Color(0xFFC62828)),
                            if (stat.totalLeyesProCrimen > 0 || pcPartidoCount > 0)
                              _StatChip(Icons.dangerous_rounded,
                                  '${stat.totalLeyesProCrimen + pcPartidoCount} pro-crimen',
                                  Colors.deepOrange),
                            if (invText.isNotEmpty)
                              _StatChip(Icons.report_rounded,
                                  'Con denuncias', Colors.red.shade700),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ScoreBadge(score: score, scoreColor: scoreColor, scoreBg: scoreBg),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          // ── Miembros (tappables) ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: miembrosOrdenados.map((c) =>
                _MiembroRow(c: c, proceso: proceso)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiembroRow extends StatelessWidget {
  final CandidatoConHV c;
  final ProcesoElectoral proceso;
  const _MiembroRow({required this.c, required this.proceso});

  String _shortCargo(String cargo) {
    if (cargo.contains('SEGUNDO VICE')) return '2do VP';
    if (cargo.contains('PRIMER VICE'))  return '1er VP';
    if (cargo.contains('PRESIDENTE'))   return 'Pdte.';
    return cargo;
  }

  @override
  Widget build(BuildContext context) {
    final hv = c.hv;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _showCandidatoDetalle(context, c, proceso),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(_shortCargo(c.cargo),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(hv.nombre,
                style: const TextStyle(fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            // Pro-crimen indicator
            if (hv.numLeyesProCrimen > 0)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: '${hv.numLeyesProCrimen} ley(es) pro-crimen',
                  child: const Icon(Icons.dangerous_rounded,
                      size: 13, color: Colors.deepOrange),
                ),
              ),
            // Score mini
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: hv.scoreBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${hv.scoreFinal}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: hv.scoreColor)),
            ),
            const SizedBox(width: 4),
            if (hv.totalSentenciasPenales > 0 || hv.totalSentenciasObligaciones > 0)
              const Icon(Icons.warning_amber_rounded,
                  size: 13, color: Color(0xFFC62828))
            else
              const Icon(Icons.check_circle_rounded,
                  size: 13, color: Color(0xFF2E7D32)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded,
                size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

// ─── Vista por Partido (Diputados / Senadores / Parlamento Andino) ─────────────

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
    final Map<String, _PartidoStat> byParty = {};
    for (final c in candidatos) {
      byParty.putIfAbsent(c.hv.partido, () => _PartidoStat(c.hv.partido, [])).add(c);
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
                'por puntaje promedio de integridad. '
                'Toca un partido para ver sus candidatos.',
          ),
          const SizedBox(height: 10),

          // Summary chips
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
          const SizedBox(height: 14),

          // Leaderboard top 10
          if (stats.length >= 2) ...[
            _SectionHeader('TOP PARTIDOS — PUNTAJE PROMEDIO', color),
            const SizedBox(height: 8),
            _ScoreLeaderboard(
              items: stats.take(10).toList().asMap().entries
                  .map((e) => _LeaderEntry(
                    rank:   e.key + 1,
                    nombre: e.value.partido,
                    score:  e.value.scorePromedio,
                  )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Ranking expandable cards
          _SectionHeader('RANKING COMPLETO', color),
          const SizedBox(height: 8),
          ...stats.asMap().entries.map((e) =>
            _PartidoCard(rank: e.key + 1, stat: e.value, color: color,
                         proceso: proceso)),
        ],
      ),
    );
  }
}

class _PartidoStat {
  final String partido;
  final List<CandidatoConHV> candidatos;
  int total = 0;
  int conPosgrado = 0;
  int sinSentencias = 0;
  int conSentPenal = 0;
  int totalLeyesProCrimen = 0;
  int sumaScore = 0;
  double sumaIngreso = 0;

  _PartidoStat(this.partido, this.candidatos);

  void add(CandidatoConHV c) {
    final hv = c.hv;
    total++;
    if (hv.esMaestro || hv.esDoctor) conPosgrado++;
    if (hv.totalSentenciasPenales == 0 && hv.totalSentenciasObligaciones == 0) {
      sinSentencias++;
    }
    if (hv.totalSentenciasPenales > 0) conSentPenal++;
    totalLeyesProCrimen += hv.numLeyesProCrimen;
    sumaScore += hv.scoreFinal;
    sumaIngreso += hv.ingresoTotal;
    candidatos.add(c);
  }

  double get scorePromedio => total > 0 ? sumaScore / total : 0;
  double get pctSinSentencias =>
      total > 0 ? sinSentencias / total * 100 : 0;
  double get pctPosgrado => total > 0 ? conPosgrado / total * 100 : 0;
  double get ingresoPromedio => total > 0 ? sumaIngreso / total : 0;
}

class _PartidoCard extends StatefulWidget {
  final int rank;
  final _PartidoStat stat;
  final Color color;
  final ProcesoElectoral proceso;

  const _PartidoCard({
    required this.rank, required this.stat,
    required this.color, required this.proceso,
  });

  @override
  State<_PartidoCard> createState() => _PartidoCardState();
}

class _PartidoCardState extends State<_PartidoCard> {
  bool _expanded = false;

  String _formatMoney(double v) {
    if (v == 0) return 'S/ 0';
    if (v >= 1000000) return 'S/ ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return 'S/ ${(v / 1000).toStringAsFixed(0)}K';
    return 'S/ ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final score      = widget.stat.scorePromedio;
    final scoreColor = _scoreColor(score);
    final scoreBg    = _scoreBg(score);

    // Sort candidates by score descending
    final sorted = [...widget.stat.candidatos]
      ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Header row (tappable to expand)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _RankCircle(rank: widget.rank),
                  const SizedBox(width: 8),
                  SizedBox(width: 30, height: 30,
                    child: PartyLogo(partyName: widget.stat.partido, size: 30)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.stat.partido,
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6, runSpacing: 2,
                          children: [
                            _MiniLabel('${widget.stat.total} cand.',
                                Colors.blueGrey),
                            _MiniLabel(
                              '${widget.stat.pctSinSentencias.toStringAsFixed(0)}% sin ant.',
                              widget.stat.pctSinSentencias >= 80
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828)),
                            _MiniLabel(
                              '${widget.stat.pctPosgrado.toStringAsFixed(0)}% posgrado',
                              const Color(0xFF1565C0)),
                            if (widget.stat.ingresoPromedio > 0)
                              _MiniLabel(
                                '~${_formatMoney(widget.stat.ingresoPromedio)} prom.',
                                Colors.grey.shade600),
                            if (widget.stat.totalLeyesProCrimen > 0)
                              _MiniLabel(
                                '⚠ ${widget.stat.totalLeyesProCrimen} pro-crimen',
                                Colors.deepOrange),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ScoreBadge(score: score, scoreColor: scoreColor, scoreBg: scoreBg),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          // Expanded candidate list
          if (_expanded) ...[
            const Divider(height: 1, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Candidatos por puntaje',
                    style: TextStyle(fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...sorted.map((c) => _CandidatoRow(c: c, proceso: widget.proceso)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CandidatoRow extends StatelessWidget {
  final CandidatoConHV c;
  final ProcesoElectoral proceso;
  const _CandidatoRow({required this.c, required this.proceso});

  @override
  Widget build(BuildContext context) {
    final hv = c.hv;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _showCandidatoDetalle(context, c, proceso),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(hv.nombre,
                style: const TextStyle(fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (c.departamento.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(c.departamento,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  maxLines: 1),
              ),
            if (hv.numLeyesProCrimen > 0)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Tooltip(
                  message: '${hv.numLeyesProCrimen} ley(es) pro-crimen',
                  child: const Icon(Icons.dangerous_rounded,
                      size: 11, color: Colors.deepOrange),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: hv.scoreBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${hv.scoreFinal}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: hv.scoreColor)),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded,
                size: 13, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

// ─── Compact Score Leaderboard (replaces BarChart) ────────────────────────────

class _LeaderEntry {
  final int rank;
  final String nombre;
  final double score;
  const _LeaderEntry({required this.rank, required this.nombre,
      required this.score});
}

class _ScoreLeaderboard extends StatelessWidget {
  final List<_LeaderEntry> items;
  const _ScoreLeaderboard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final entry    = e.value;
          final isLast   = e.key == items.length - 1;
          final sc       = entry.score;
          final barColor = _scoreColor(sc);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Rank
                    SizedBox(
                      width: 22,
                      child: Text('#${entry.rank}',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold,
                          color: entry.rank <= 3
                              ? const Color(0xFFF57F17)
                              : Colors.grey.shade500,
                        )),
                    ),
                    const SizedBox(width: 6),
                    // Party logo
                    SizedBox(width: 22, height: 22,
                      child: PartyLogo(partyName: entry.nombre, size: 22)),
                    const SizedBox(width: 8),
                    // Name
                    Expanded(
                      flex: 3,
                      child: Text(entry.nombre,
                        style: const TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    // Score bar
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: sc / 100,
                          minHeight: 10,
                          backgroundColor: barColor.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Score label
                    SizedBox(
                      width: 36,
                      child: Text(sc.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          color: barColor),
                        textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 12, endIndent: 12,
                    color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Detalle del candidato (bottom sheet) ─────────────────────────────────────

void _showCandidatoDetalle(BuildContext context, CandidatoConHV c,
    ProcesoElectoral proceso) {
  final hv    = c.hv;
  final color = proceso.color;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoCircle(fotoUrl: c.fotoUrl, nombre: hv.nombre, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hv.nombre,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(hv.partido,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                      if (c.cargo.isNotEmpty)
                        Text(c.cargo,
                          style: TextStyle(fontSize: 11, color: color,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: hv.scoreBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hv.scoreColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text('${hv.scoreFinal}',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: hv.scoreColor, height: 1)),
                      Text(hv.scoreLabel,
                        style: TextStyle(fontSize: 8,
                            color: hv.scoreColor,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            if (c.departamento.isNotEmpty || c.tipoDistrito.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(Icons.place_rounded,
                '${c.tipoDistrito.isNotEmpty ? "${c.tipoDistrito} · " : ""}${c.departamento}',
                Colors.grey.shade500),
            ],
            const Divider(height: 20),

            // ── Educación ────────────────────────────────────────────────────
            _SheetSection('EDUCACIÓN', color),
            _DetailRow(hv.educacionIcon, hv.educacionLabel, hv.educacionColor),
            if (hv.posgrados.isNotEmpty)
              ...hv.posgrados.map((p) => _BulletText(p)),
            if (hv.universidades.isNotEmpty)
              ...hv.universidades.map((u) => _BulletText(u)),
            const Divider(height: 20),

            // ── Integridad Judicial ──────────────────────────────────────────
            _SheetSection('INTEGRIDAD JUDICIAL', color),
            _DetailRow(
              hv.totalSentenciasPenales == 0
                  ? Icons.check_circle_rounded : Icons.gavel_rounded,
              hv.totalSentenciasPenales == 0
                  ? 'Sin sentencias penales'
                  : '${hv.totalSentenciasPenales} sentencia(s) penal(es)',
              hv.totalSentenciasPenales == 0
                  ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
            _DetailRow(
              hv.totalSentenciasObligaciones == 0
                  ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              hv.totalSentenciasObligaciones == 0
                  ? 'Sin sentencias de obligación'
                  : '${hv.totalSentenciasObligaciones} sentencia(s) de obligación',
              hv.totalSentenciasObligaciones == 0
                  ? const Color(0xFF2E7D32) : Colors.orange,
            ),
            const Divider(height: 20),

            // ── Alertas adicionales ──────────────────────────────────────────
            if (hv.numLeyesProCrimen > 0 || hv.penaltyCargosPublicos > 0 ||
                hv.investigacionesConocidas.isNotEmpty) ...[
              _SheetSection('ALERTAS DE INTEGRIDAD', Colors.deepOrange),
              if (hv.numLeyesProCrimen > 0)
                _DetailRow(
                  Icons.dangerous_rounded,
                  'Apoyó ${hv.numLeyesProCrimen} ley(es) pro-crimen '
                  '(−${hv.penaltyProCrimen} pts)',
                  Colors.deepOrange,
                ),
              if (hv.penaltyCargosPublicos > 0)
                _DetailRow(
                  Icons.work_history_rounded,
                  'Cargos públicos previos detectados '
                  '(−${hv.penaltyCargosPublicos} pts)',
                  Colors.orange,
                ),
              if (hv.investigacionesConocidas.isNotEmpty)
                _DetailRow(
                  Icons.report_rounded,
                  'Investigaciones/controversias conocidas '
                  '(−${hv.penaltyInvestigaciones} pts)',
                  Colors.red.shade700,
                ),
              const Divider(height: 20),
            ],

            // ── Cargos de Elección Popular ───────────────────────────────────
            if (hv.cargosEleccionPopular.isNotEmpty) ...[
              _SheetSection('CARGOS DE ELECCIÓN POPULAR', Colors.orange),
              ...hv.cargosEleccionPopular.take(4).map((cg) =>
                _DetailRow(Icons.how_to_vote_rounded,
                  '${cg.cargo}${cg.entidad.isNotEmpty ? " — ${cg.entidad}" : ""}'
                  '${cg.periodo.isNotEmpty ? " (${cg.periodo})" : ""}',
                  Colors.orange.shade800)),
              const Divider(height: 20),
            ],

            // ── Desglose del puntaje ─────────────────────────────────────────
            _SheetSection('DESGLOSE DEL PUNTAJE', color),
            _ScoreRow('Educación (máx. 40)',
                hv.scoreEducacion, 40, hv.educacionColor),
            _ScoreRow('Integridad penal (máx. 35)',
                hv.scoreIntegridadPenal, 35,
                hv.scoreIntegridadPenal >= 30
                    ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
            _ScoreRow('Cumpl. obligaciones (máx. 25)',
                hv.scoreIntegridadOblig, 25,
                hv.scoreIntegridadOblig >= 20
                    ? const Color(0xFF2E7D32) : Colors.orange),
            if (hv.penaltyProCrimen > 0)
              _ScoreRow('Leyes pro-crimen personales (penalización)',
                  -hv.penaltyProCrimen, 0, Colors.deepOrange),
            if (hv.penaltyProCrimenPartido > 0)
              _ScoreRow('Partido apoyó leyes pro-crimen (penalización)',
                  -hv.penaltyProCrimenPartido, 0, Colors.red.shade800),
            if (hv.penaltyCargosPublicos > 0)
              _ScoreRow('Cargos públicos previos (penalización)',
                  -hv.penaltyCargosPublicos, 0, Colors.orange),
            if (hv.penaltyInvestigaciones > 0)
              _ScoreRow('Investigaciones/controversias (penalización)',
                  -hv.penaltyInvestigaciones, 0, Colors.red.shade700),
            if (hv.penaltyReinfo > 0)
              _ScoreRow('Vinculado a REINFO (penalización)',
                  -hv.penaltyReinfo, 0, const Color(0xFF7B1FA2)),
            if (hv.penaltyUniversidadCuestionada > 0)
              _ScoreRow('Universidad cuestionada (penalización)',
                  -hv.penaltyUniversidadCuestionada, 0, Colors.brown.shade700),
            if (hv.bonusUniversidadElite > 0)
              _ScoreRow('Universidad de élite (bonus)',
                  hv.bonusUniversidadElite, 5, const Color(0xFF1565C0)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hv.scoreBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: hv.scoreColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Puntaje total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${hv.scoreFinal} / 100',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16, color: hv.scoreColor)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── JNE link ────────────────────────────────────────────────────
            _JneButton(hv: hv),
            const SizedBox(height: 12),

            // Nota legal
            Text(
              'Puntaje calculado con datos públicos del JNE. '
              'Información orientativa — no constituye acusación formal.',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Name normalization (mirrors new_providers.dart) ─────────────────────────

String _normName(String s) {
  var r = s.toUpperCase()
      .replaceAll(',', ' ')
      .replaceAll('Á', 'A').replaceAll('É', 'E')
      .replaceAll('Í', 'I').replaceAll('Ó', 'O').replaceAll('Ú', 'U')
      .replaceAll('Ñ', 'N');
  while (r.contains('  ')) { r = r.replaceAll('  ', ' '); }
  return r.trim();
}

// ─── Party detail bottom sheet (Presidentes) ─────────────────────────────────

void _showPlanchaDetalle(
  BuildContext context,
  _PlanchaStat stat,
  ProcesoElectoral proceso,
  int pcPartidoCount,
  String invText,
) {
  final score      = stat.scorePromedio;
  final scoreColor = _scoreColor(score);
  final scoreBg    = _scoreBg(score);

  const cargoOrder = [
    'PRESIDENTE DE LA REPÚBLICA',
    'PRIMER VICEPRESIDENTE DE LA REPÚBLICA',
    'SEGUNDO VICEPRESIDENTE DE LA REPÚBLICA',
  ];
  final miembros = [...stat.miembros]
    ..sort((a, b) {
      final ia = cargoOrder.indexOf(a.cargo);
      final ib = cargoOrder.indexOf(b.cargo);
      return ia == -1 ? 1 : ib == -1 ? -1 : ia.compareTo(ib);
    });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header partido ───────────────────────────────────────────
            Row(
              children: [
                SizedBox(width: 48, height: 48,
                  child: PartyLogo(partyName: stat.partido, size: 48)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(stat.partido,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scoreColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(score.toStringAsFixed(1),
                        style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: scoreColor, height: 1)),
                      Text('prom. plancha',
                        style: TextStyle(fontSize: 8,
                            color: scoreColor,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // ── Alertas ──────────────────────────────────────────────────
            if (invText.isNotEmpty || stat.totalLeyesProCrimen > 0 ||
                pcPartidoCount > 0) ...[
              _SheetSection('ALERTAS DE INTEGRIDAD', Colors.red.shade700),
              if (invText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.report_rounded, size: 14,
                          color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(invText,
                          style: TextStyle(fontSize: 12,
                              color: Colors.red.shade800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (stat.totalLeyesProCrimen > 0)
                _DetailRow(Icons.dangerous_rounded,
                  'Miembro(s) de la plancha apoyó '
                  '${stat.totalLeyesProCrimen} ley(es) pro-crimen',
                  Colors.deepOrange),
              if (pcPartidoCount > 0)
                _DetailRow(Icons.dangerous_rounded,
                  'El bloque parlamentario del partido apoyó '
                  '$pcPartidoCount ley(es) pro-crimen',
                  Colors.orange.shade800),
              const Divider(height: 20),
            ],

            // ── Miembros de la plancha ────────────────────────────────────
            _SheetSection('PLANCHA PRESIDENCIAL', proceso.color),
            ...miembros.map((c) => _PlanchaMiembroCard(c: c, proceso: proceso)),
            const Divider(height: 20),

            // Nota legal
            Text(
              'Puntaje calculado con datos públicos del JNE. '
              'Información orientativa — no constituye acusación formal.',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Plancha miembro card (for detail sheet) ──────────────────────────────────

class _PlanchaMiembroCard extends StatelessWidget {
  final CandidatoConHV c;
  final ProcesoElectoral proceso;
  const _PlanchaMiembroCard({required this.c, required this.proceso});

  String _shortCargo(String cargo) {
    if (cargo.contains('SEGUNDO VICE')) return '2do Vicepresidente';
    if (cargo.contains('PRIMER VICE')) return '1er Vicepresidente';
    if (cargo.contains('PRESIDENTE')) return 'Presidente';
    return cargo;
  }

  @override
  Widget build(BuildContext context) {
    final hv = c.hv;
    final scoreColor = _scoreColor(hv.scoreFinal.toDouble());
    final scoreBg = _scoreBg(hv.scoreFinal.toDouble());

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showCandidatoDetalle(context, c, proceso),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Cargo badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: proceso.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_shortCargo(c.cargo),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: proceso.color)),
                ),
                const Spacer(),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
                  ),
                  child: Text('${hv.scoreFinal} pts',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                          color: scoreColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(hv.nombre,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            // Info chips
            Wrap(
              spacing: 4, runSpacing: 4,
              children: [
                _InfoChip(Icons.school_rounded, hv.educacionLabel, Colors.blue.shade700),
                if (hv.totalSentenciasPenales > 0)
                  _InfoChip(Icons.gavel_rounded,
                      '${hv.totalSentenciasPenales} sentencia(s) penal(es)', Colors.red.shade700)
                else
                  _InfoChip(Icons.verified_rounded, 'Sin sentencias penales', Colors.green.shade700),
                if (hv.esReinfo)
                  _InfoChip(Icons.terrain_rounded, 'Vinculado REINFO', Colors.orange.shade800),
                if (hv.universidadElite)
                  _InfoChip(Icons.star_rounded, 'Univ. élite', Colors.indigo),
                if (hv.universidadCuestionada)
                  _InfoChip(Icons.warning_rounded, 'Univ. cuestionada', Colors.brown.shade700),
                if (hv.investigacionesConocidas.isNotEmpty)
                  _InfoChip(Icons.report_rounded, 'Con investigaciones', Colors.red.shade900),
              ],
            ),
            const SizedBox(height: 4),
            Text('Toca para ver perfil completo',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Shared score helpers ─────────────────────────────────────────────────────

Color _scoreColor(double score) {
  if (score >= 70) return const Color(0xFF2E7D32);
  if (score >= 45) return const Color(0xFFF57F17);
  return const Color(0xFFC62828);
}

Color _scoreBg(double score) {
  if (score >= 70) return const Color(0xFFE8F5E9);
  if (score >= 45) return const Color(0xFFFFF8E1);
  return const Color(0xFFFFEBEE);
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _RankCircle extends StatelessWidget {
  final int rank;
  const _RankCircle({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= 3;
    final colors = [Colors.amber, Colors.grey.shade400,
        const Color(0xFFCD7F32)];
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: isTop ? colors[rank - 1] : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('$rank',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
              color: isTop ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  final Color scoreColor;
  final Color scoreBg;
  const _ScoreBadge({required this.score, required this.scoreColor,
      required this.scoreBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scoreBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(score.toStringAsFixed(1),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: scoreColor, height: 1)),
          Text('pts',
            style: TextStyle(fontSize: 7, color: scoreColor, height: 1)),
        ],
      ),
    );
  }
}

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
          Icon(Icons.info_outline_rounded, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: TextStyle(color: Colors.grey.shade700,
                  fontSize: 12, height: 1.4)),
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
        Container(width: 3, height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
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
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: color)),
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
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }
}

// ─── Detail sheet helpers ─────────────────────────────────────────────────────

class _PhotoCircle extends StatelessWidget {
  final String? fotoUrl;
  final String nombre;
  final double size;
  const _PhotoCircle({required this.fotoUrl, required this.nombre,
      this.size = 44});

  String _initials() {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (fotoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(fotoUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey.shade100,
      child: Text(_initials(),
        style: TextStyle(fontSize: radius * 0.65,
            fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String text;
  final Color color;
  const _SheetSection(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
            color: color, letterSpacing: 1.0)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _DetailRow(this.icon, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
              style: TextStyle(fontSize: 12, color: color,
                  fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, bottom: 3),
      child: Text('• $text',
        style: TextStyle(fontSize: 11,
            color: Colors.grey.shade600)),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;
  final Color color;
  const _ScoreRow(this.label, this.score, this.maxScore, this.color);

  @override
  Widget build(BuildContext context) {
    final isPenalty = score < 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 11))),
          Text(isPenalty ? '$score' : '$score${maxScore > 0 ? "/$maxScore" : ""}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: color)),
        ],
      ),
    );
  }
}

class _JneButton extends StatelessWidget {
  final HojaVida hv;
  const _JneButton({required this.hv});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(hv.jneHvUrl);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      icon: const Icon(Icons.open_in_new_rounded, size: 14),
      label: const Text('Ver hoja de vida en JNE',
          style: TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
      ),
    );
  }
}
