import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/new_providers.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../widgets/party_logo.dart';
import 'estadisticas_partido_screen.dart' show showCandidatoDetalle;

// â”€â”€â”€ Sort enum â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum _Sort { descValor, ascValor, alfa }

// â”€â”€â”€ Per-party aggregated stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PStats {
  final String partido;
  int total = 0;
  int conSentencia = 0;
  int conIngresoCero = 0;
  int enReinfo = 0;
  int conProCrimen = 0;
  double sumScoreEdu = 0;
  double sumScoreFinal = 0;
  double sumIngreso = 0;
  int ingresoCount = 0;

  _PStats(this.partido);

  double get pctSentencia => total > 0 ? conSentencia / total * 100 : 0;
  double get pctIngresoCero => total > 0 ? conIngresoCero / total * 100 : 0;
  double get avgScoreEdu => total > 0 ? sumScoreEdu / total : 0;
  double get avgScoreFinal => total > 0 ? sumScoreFinal / total : 0;
  double get avgIngreso => ingresoCount > 0 ? sumIngreso / ingresoCount : 0;
}

Map<String, _PStats> _computeStats(List<CandidatoConHV> lista) {
  final map = <String, _PStats>{};
  for (final c in lista) {
    final h = c.hv;
    final ps = map.putIfAbsent(h.partido, () => _PStats(h.partido));
    ps.total++;
    if (h.totalSentenciasPenales > 0 || h.totalSentenciasObligaciones > 0) {
      ps.conSentencia++;
    }
    if (h.ingresoTotal <= 0) ps.conIngresoCero++;
    if (h.esReinfo) ps.enReinfo++;
    if (h.numLeyesProCrimen > 0) ps.conProCrimen++;
    ps.sumScoreEdu += h.scoreEducacion;
    ps.sumScoreFinal += h.scoreFinal;
    if (h.ingresoTotal > 0) {
      ps.sumIngreso += h.ingresoTotal;
      ps.ingresoCount++;
    }
  }
  return map;
}

// â”€â”€â”€ Main Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class IndicadoresProcesoScreen extends ConsumerStatefulWidget {
  final ProcesoElectoral proceso;
  const IndicadoresProcesoScreen({super.key, required this.proceso});

  @override
  ConsumerState<IndicadoresProcesoScreen> createState() =>
      _IndicadoresProcesoScreenState();
}

class _IndicadoresProcesoScreenState
    extends ConsumerState<IndicadoresProcesoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _Sort _sortSent   = _Sort.descValor;
  _Sort _sortEdu    = _Sort.descValor;
  _Sort _sortCero   = _Sort.descValor;
  _Sort _sortIngr   = _Sort.descValor;
  _Sort _sortReinfo = _Sort.descValor;
  _Sort _sortFinal  = _Sort.descValor;
  String? _selectedPartyRadar;
  String? _regionFilter;

  static const _tabs = [
    'Sentencias',
    'PreparaciÃ³n',
    'Ingre. S/0',
    'Ing. Promedio',
    'REINFO',
    'Score Final',
    'Radar',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Bar> _sorted(List<_Bar> data, _Sort sort) {
    final list = List<_Bar>.from(data);
    switch (sort) {
      case _Sort.descValor:
        list.sort((a, b) => b.value.compareTo(a.value));
      case _Sort.ascValor:
        list.sort((a, b) => a.value.compareTo(b.value));
      case _Sort.alfa:
        list.sort((a, b) => a.label.compareTo(b.label));
    }
    return list;
  }

  void _showDetail(
    BuildContext context,
    String partyName,
    _PStats? ps,
    List<CandidatoConHV> allCandidatos,
  ) {
    final partyCandidatos = allCandidatos
        .where((c) => c.hv.partido == partyName)
        .toList()
      ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PartyDetailSheet(
        partyName: partyName,
        ps: ps,
        candidatos: partyCandidatos,
        proceso: widget.proceso,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidatosAsync =
        ref.watch(candidatosConHVProcesoProvider(widget.proceso));

    return Scaffold(
      appBar: AppBar(
        title: Text('Indicadores â€” ${widget.proceso.displayName}'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: candidatosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (candidatos) {
          // â”€â”€ Region filter (Diputados / Parlamento Andino) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          final hasRegion = widget.proceso == ProcesoElectoral.diputados ||
              widget.proceso == ProcesoElectoral.parlamentoAndino;
          final regiones = hasRegion
              ? (candidatos.map((c) => c.departamento).where((d) => d.isNotEmpty).toSet().toList()..sort())
              : <String>[];
          final filtered = (hasRegion && _regionFilter != null)
              ? candidatos.where((c) => c.departamento == _regionFilter).toList()
              : candidatos;

          final statsMap = _computeStats(filtered);
          final parties = statsMap.values.toList();

          // Pre-build bar lists
          final barsSent = _sorted(
            parties
                .map((p) => _Bar(p.partido, p.pctSentencia))
                .toList(),
            _sortSent,
          );
          final barsEdu = _sorted(
            parties
                .map((p) => _Bar(p.partido, p.avgScoreEdu))
                .toList(),
            _sortEdu,
          );
          final barsCero = _sorted(
            parties
                .map((p) => _Bar(p.partido, p.pctIngresoCero))
                .toList(),
            _sortCero,
          );
          final barsIngr = _sorted(
            parties
                .where((p) => p.avgIngreso > 0)
                .map((p) => _Bar(p.partido, p.avgIngreso))
                .toList(),
            _sortIngr,
          );
          final barsReinfo = _sorted(
            parties
                .where((p) => p.enReinfo > 0)
                .map((p) => _Bar(p.partido, p.enReinfo.toDouble()))
                .toList(),
            _sortReinfo,
          );
          final barsFinal = _sorted(
            parties
                .map((p) => _Bar(p.partido, p.avgScoreFinal))
                .toList(),
            _sortFinal,
          );

          // Radar party list
          final radarParties = parties.map((p) => p.partido).toList()..sort();
          _selectedPartyRadar ??=
              radarParties.isNotEmpty ? radarParties.first : null;

          return Column(
            children: [
              // â”€â”€ Region filter bar (Diputados / Parlamento Andino) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (hasRegion && regiones.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String?>(
                      value: _regionFilter,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Row(children: [
                        Icon(Icons.map_outlined, size: 15, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Todas las regiones', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas las regiones', style: TextStyle(fontSize: 12)),
                        ),
                        ...regiones.map((r) => DropdownMenuItem<String?>(
                              value: r,
                              child: Text(r, style: const TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (v) => setState(() {
                        _regionFilter = v;
                        _selectedPartyRadar = null; // reset radar on region change
                      }),
                    ),
                  ),
                ),
              if (hasRegion && _regionFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list_rounded, size: 13, color: Colors.indigo),
                      const SizedBox(width: 4),
                      Text('RegiÃ³n: $_regionFilter Â· ${filtered.length} candidatos',
                          style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          _regionFilter = null;
                          _selectedPartyRadar = null;
                        }),
                        child: const Text('Limpiar', style: TextStyle(fontSize: 11, color: Colors.indigo)),
                      ),
                    ],
                  ),
                ),
              // â”€â”€ Charts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
              // â”€â”€ Sentencias â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: '% Candidatos con Sentencia',
                  subtitle:
                      'Porcentaje de candidatos del partido con al menos una '
                      'sentencia penal o de obligaciones registrada. '
                      '0% = ningÃºn candidato sentenciado. Toca un partido para ver detalles.',
                  icon: Icons.gavel,
                  color: Colors.red,
                  sort: _sortSent,
                  onSortChanged: (s) => setState(() => _sortSent = s),
                  data: barsSent,
                  maxValue: 100,
                  valueLabel: (v) => '${v.toStringAsFixed(1)}%',
                  colorOf: (v) => v < 10
                      ? Colors.green
                      : v < 30
                          ? Colors.orange
                          : Colors.red,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ PreparaciÃ³n â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: 'PreparaciÃ³n AcadÃ©mica Promedio',
                  subtitle:
                      'Score educativo promedio (0â€“40 pts) de los candidatos '
                      'del partido: Doctorado=40, MaestrÃ­a=35, Universitaria=15, TÃ©cnica=8. '
                      'Mayor puntaje = mejor preparaciÃ³n formal.',
                  icon: Icons.school,
                  color: Colors.blue,
                  sort: _sortEdu,
                  onSortChanged: (s) => setState(() => _sortEdu = s),
                  data: barsEdu,
                  maxValue: 40,
                  valueLabel: (v) => v.toStringAsFixed(1),
                  colorOf: (v) => v >= 20
                      ? Colors.blue.shade700
                      : v >= 12
                          ? Colors.blue.shade400
                          : Colors.blueGrey,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ Ingresos S/0 â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: '% Candidatos con Ingresos S/ 0',
                  subtitle:
                      'Porcentaje de candidatos del partido que declararon '
                      'ingresos de S/ 0 en su hoja de vida. Un porcentaje alto '
                      'puede indicar omisiÃ³n de declaraciÃ³n de ingresos.',
                  icon: Icons.money_off,
                  color: Colors.deepOrange,
                  sort: _sortCero,
                  onSortChanged: (s) => setState(() => _sortCero = s),
                  data: barsCero,
                  maxValue: 100,
                  valueLabel: (v) => '${v.toStringAsFixed(1)}%',
                  colorOf: (v) => v < 20
                      ? Colors.green
                      : v < 50
                          ? Colors.orange
                          : Colors.red,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ Ingresos Promedio â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: 'Ingreso Anual Promedio (candidatos con ingresos)',
                  subtitle:
                      'Promedio de ingresos totales anuales declarados (en soles) '
                      'por partido. Solo incluye candidatos que declararon ingresos '
                      'mayores a S/ 0.',
                  icon: Icons.payments,
                  color: Colors.teal,
                  sort: _sortIngr,
                  onSortChanged: (s) => setState(() => _sortIngr = s),
                  data: barsIngr,
                  maxValue: null,
                  valueLabel: (v) {
                    if (v >= 1000000) return 'S/${(v / 1000000).toStringAsFixed(1)}M';
                    if (v >= 1000) return 'S/${(v / 1000).toStringAsFixed(0)}K';
                    return 'S/${v.toStringAsFixed(0)}';
                  },
                  colorOf: (_) => Colors.teal,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ REINFO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: 'Candidatos en REINFO por Partido',
                  subtitle:
                      'NÃºmero de candidatos del partido registrados en el REINFO '
                      '(Registro Integral de FormalizaciÃ³n Minera â€” minerÃ­a informal). '
                      'Solo aparecen partidos con al menos un candidato en el registro.',
                  icon: Icons.terrain_rounded,
                  color: Colors.brown,
                  sort: _sortReinfo,
                  onSortChanged: (s) => setState(() => _sortReinfo = s),
                  data: barsReinfo,
                  maxValue: null,
                  valueLabel: (v) => v.toInt().toString(),
                  colorOf: (v) => v <= 1
                      ? Colors.amber
                      : v <= 3
                          ? Colors.deepOrange
                          : Colors.red,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ Score Final â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _TabScrollable(children: [
                _ChartSection(
                  title: 'Score Final Promedio por Partido',
                  subtitle:
                      'Score de integridad compuesto promedio (educaciÃ³n + '
                      'sentencias âˆ’ penalizaciones) de los candidatos del partido. '
                      'Mayor puntaje = mejor perfil de integridad global.',
                  icon: Icons.star_rate_rounded,
                  color: Colors.indigo,
                  sort: _sortFinal,
                  onSortChanged: (s) => setState(() => _sortFinal = s),
                  data: barsFinal,
                  maxValue: null,
                  valueLabel: (v) => v.toStringAsFixed(1),
                  colorOf: (v) => v >= 50
                      ? Colors.green.shade700
                      : v >= 25
                          ? Colors.indigo
                          : Colors.grey.shade600,
                  onTap: (b) =>
                      _showDetail(context, b.label, statsMap[b.label], candidatos),
                ),
              ]),

              // â”€â”€ Radar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _selectedPartyRadar == null
                  ? const Center(child: Text('Sin datos'))
                  : _RadarTab(
                      statsMap: statsMap,
                      partyNames: radarParties,
                      selectedParty: _selectedPartyRadar!,
                      onPartyChanged: (p) =>
                          setState(() => _selectedPartyRadar = p),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€ Simple data holder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Bar {
  final String label;
  final double value;
  const _Bar(this.label, this.value);
}

// â”€â”€â”€ Party Detail Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PartyDetailSheet extends StatelessWidget {
  final String partyName;
  final _PStats? ps;
  final List<CandidatoConHV> candidatos;
  final ProcesoElectoral proceso;

  const _PartyDetailSheet({
    required this.partyName,
    required this.ps,
    required this.candidatos,
    required this.proceso,
  });

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 0)
          .format(v);

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = proceso.color;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // â”€â”€ Handle + header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      PartyLogo(partyName: partyName, size: 44, withBorder: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(partyName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            if (ps != null)
                              Text(
                                '${ps!.total} candidatos Â· Score final prom. ${ps!.avgScoreFinal.toStringAsFixed(1)}/105',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                children: [
                  if (ps != null) ...[
                    // â”€â”€ Stats grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        _statCard(Icons.groups_rounded,
                            'Candidatos', '${ps!.total}', Colors.blueGrey),
                        _statCard(Icons.gavel_rounded, 'Con sentencia',
                            '${ps!.conSentencia}',
                            ps!.conSentencia == 0
                                ? Colors.green
                                : Colors.red),
                        _statCard(Icons.school_rounded, 'Score edu.',
                            ps!.avgScoreEdu.toStringAsFixed(1),
                            Colors.blue),
                        _statCard(Icons.star_rate_rounded, 'Score final',
                            ps!.avgScoreFinal.toStringAsFixed(1),
                            ps!.avgScoreFinal >= 50
                                ? Colors.green.shade700
                                : Colors.indigo),
                        _statCard(Icons.money_off_rounded, 'Ingreso S/0',
                            '${ps!.pctIngresoCero.toStringAsFixed(0)}%',
                            ps!.pctIngresoCero < 20
                                ? Colors.green
                                : Colors.deepOrange),
                        _statCard(Icons.terrain_rounded, 'En REINFO',
                            '${ps!.enReinfo}',
                            ps!.enReinfo == 0
                                ? Colors.green
                                : Colors.brown),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // â”€â”€ Ingreso promedio â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (ps!.avgIngreso > 0)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.teal.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_rounded,
                                color: Colors.teal, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ingreso anual promedio (candidatos con ingresos)',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                  Text(_fmt(ps!.avgIngreso),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.teal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // â”€â”€ Pro-crimen alert â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (ps!.conProCrimen > 0)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.deepOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.dangerous_rounded,
                                color: Colors.deepOrange, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${ps!.conProCrimen} candidato(s) votaron a favor '
                                'de leyes pro-crimen en el Congreso anterior.',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.deepOrange),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 20),
                  ],

                  // â”€â”€ Candidate list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.people_rounded, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text('CANDIDATOS (${candidatos.length})',
                            style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold, color: color,
                                letterSpacing: 0.8)),
                        const Spacer(),
                        Text('ordenados por perfil de integridad',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),

                  if (candidatos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text('Sin candidatos con hoja de vida.',
                              style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...candidatos.map((c) => _CandidatoTile(
                          c: c,
                          proceso: proceso,
                          color: color,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Candidate tile inside detail sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _CandidatoTile extends StatelessWidget {
  final CandidatoConHV c;
  final ProcesoElectoral proceso;
  final Color color;

  const _CandidatoTile({
    required this.c,
    required this.proceso,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hv = c.hv;
    final hasAlert = hv.totalSentenciasPenales > 0 ||
        hv.totalSentenciasObligaciones > 0 ||
        hv.numLeyesProCrimen > 0 ||
        hv.esReinfo;

    return InkWell(
      onTap: () => showCandidatoDetalle(context, c, proceso),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: hasAlert
                  ? Colors.red.withValues(alpha: 0.25)
                  : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Photo
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              backgroundImage:
                  c.fotoUrl != null ? NetworkImage(c.fotoUrl!) : null,
              onBackgroundImageError: c.fotoUrl != null ? (_, __) {} : null,
              child: c.fotoUrl == null
                  ? Text(
                      hv.nombre.isNotEmpty ? hv.nombre[0] : '?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hv.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4, runSpacing: 2,
                    children: [
                      // Cargo
                      if (c.cargo.isNotEmpty)
                        _MiniChip(c.cargo.split(' ').take(2).join(' '),
                            color.withValues(alpha: 0.8)),
                      // Posicion
                      _MiniChip('#${c.posicion}', Colors.blueGrey),
                      // Departamento
                      if (c.departamento.isNotEmpty)
                        _MiniChip(c.departamento, Colors.teal),
                      // Alerts
                      if (hv.totalSentenciasPenales > 0)
                        _MiniChip(
                            '${hv.totalSentenciasPenales} penal(es)',
                            Colors.red),
                      if (hv.numLeyesProCrimen > 0)
                        _MiniChip('Pro-crimen', Colors.deepOrange),
                      if (hv.esReinfo)
                        _MiniChip('REINFO', Colors.brown),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: hv.scoreBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hv.scoreColor),
              ),
              child: Text('${hv.scoreFinal}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: hv.scoreColor)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Tab scrollable wrapper ───────────────────────────────────────────────────
class _TabScrollable extends StatelessWidget {
  final List<Widget> children;
  const _TabScrollable({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// â”€â”€â”€ Chart Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ChartSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _Sort sort;
  final ValueChanged<_Sort> onSortChanged;
  final List<_Bar> data;
  final double? maxValue;
  final String Function(double) valueLabel;
  final Color Function(double) colorOf;
  final void Function(_Bar) onTap;

  const _ChartSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.sort,
    required this.onSortChanged,
    required this.data,
    required this.maxValue,
    required this.valueLabel,
    required this.colorOf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveMax = maxValue ??
        (data.isEmpty
            ? 1.0
            : data.map((b) => b.value).reduce((a, b) => a > b ? a : b) * 1.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Ordenar: ', style: theme.textTheme.bodySmall),
            _SortChip('â†“ Mayor', _Sort.descValor, sort, onSortChanged, color),
            const SizedBox(width: 6),
            _SortChip('â†‘ Menor', _Sort.ascValor, sort, onSortChanged, color),
            const SizedBox(width: 6),
            _SortChip('A-Z', _Sort.alfa, sort, onSortChanged, color),
          ],
        ),
        const SizedBox(height: 8),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Sin datos disponibles para este proceso.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...data.map((bar) => _BarRow(
                bar: bar,
                max: effectiveMax,
                valueLabel: valueLabel(bar.value),
                barColor: colorOf(bar.value),
                onTap: () => onTap(bar),
              )),
      ],
    );
  }
}

// â”€â”€â”€ Sort Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SortChip extends StatelessWidget {
  final String label;
  final _Sort value;
  final _Sort current;
  final ValueChanged<_Sort> onChanged;
  final Color color;

  const _SortChip(
      this.label, this.value, this.current, this.onChanged, this.color);

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Bar Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BarRow extends StatelessWidget {
  final _Bar bar;
  final double max;
  final String valueLabel;
  final Color barColor;
  final VoidCallback onTap;

  const _BarRow({
    required this.bar,
    required this.max,
    required this.valueLabel,
    required this.barColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (bar.value / max).clamp(0.0, 1.0) : 0.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            PartyLogo(partyName: bar.label, size: 20),
            const SizedBox(width: 4),
            SizedBox(
              width: 96,
              child: Text(
                bar.label,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    LinearProgressIndicator(
                      value: fraction,
                      minHeight: 22,
                      backgroundColor: barColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            valueLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: fraction >= 0.5
                                  ? Colors.white
                                  : barColor,
                              shadows: fraction >= 0.5
                                  ? [
                                      const Shadow(
                                          color: Colors.black26,
                                          blurRadius: 1)
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Radar Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RadarTab extends StatelessWidget {
  final Map<String, _PStats> statsMap;
  final List<String> partyNames;
  final String selectedParty;
  final ValueChanged<String> onPartyChanged;

  const _RadarTab({
    required this.statsMap,
    required this.partyNames,
    required this.selectedParty,
    required this.onPartyChanged,
  });

  // Axis labels (6 dimensions)
  static const _axisLabels = [
    'Sin Sentencias',
    'PreparaciÃ³n',
    'Ingresos',
    'Sin REINFO',
    'Score Final',
    'Sin Pro-Crimen',
  ];

  List<double> _radarValues(_PStats? ps) {
    if (ps == null) return List.filled(6, 0);
    return [
      // Sin sentencias: inverse of pct with sentence, 0â€“100 â†’ 0â€“1
      ((100 - ps.pctSentencia) / 100).clamp(0.0, 1.0),
      // PreparaciÃ³n: avg edu score 0â€“40 â†’ 0â€“1
      (ps.avgScoreEdu / 40).clamp(0.0, 1.0),
      // Ingresos: avg income capped at 200k, 0â€“1
      (ps.avgIngreso / 200000).clamp(0.0, 1.0),
      // Sin REINFO: inverse of reinfo fraction
      ps.total > 0
          ? ((ps.total - ps.enReinfo) / ps.total).clamp(0.0, 1.0)
          : 0.0,
      // Score Final: avg final score capped at 80 â†’ 0â€“1
      (ps.avgScoreFinal / 80).clamp(0.0, 1.0),
      // Sin Pro-Crimen: inverse of pro-crimen fraction
      ps.total > 0
          ? ((ps.total - ps.conProCrimen) / ps.total).clamp(0.0, 1.0)
          : 1.0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ps = statsMap[selectedParty];
    final values = _radarValues(ps);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Party selector
          DropdownButtonFormField<String>(
            initialValue: selectedParty,
            decoration: const InputDecoration(
              labelText: 'Seleccionar partido',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: partyNames
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Row(children: [
                        PartyLogo(partyName: p, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(p,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ]),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onPartyChanged(v);
            },
          ),
          const SizedBox(height: 20),

          // Party header
          Row(
            children: [
              PartyLogo(partyName: selectedParty, size: 48, withBorder: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedParty,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (ps != null)
                      Text(
                        '${ps.total} candidato(s) Â· Score final promedio: ${ps.avgScoreFinal.toStringAsFixed(1)}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Radar chart
          SizedBox(
            height: 280,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor:
                        Colors.indigo.withValues(alpha: 0.2),
                    borderColor: Colors.indigo,
                    borderWidth: 2,
                    entryRadius: 4,
                    dataEntries: values
                        .map((v) => RadarEntry(value: v))
                        .toList(),
                  ),
                ],
                radarShape: RadarShape.polygon,
                radarBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData:
                    BorderSide(color: Colors.grey.shade300, width: 1),
                tickCount: 4,
                tickBorderData:
                    BorderSide(color: Colors.grey.shade300, width: 1),
                ticksTextStyle: const TextStyle(
                    color: Colors.transparent, fontSize: 10),
                getTitle: (index, angle) => RadarChartTitle(
                  text: _axisLabels[index % _axisLabels.length],
                  angle: 0,
                  positionPercentageOffset: 0.05,
                ),
                titleTextStyle: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w600),
                titlePositionPercentageOffset: 0.18,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Axis legend
          ..._axisLabels.asMap().entries.map((e) {
            final idx = e.key;
            final pct = (values[idx] * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(e.value,
                          style: const TextStyle(fontSize: 12))),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Text(
              'El grÃ¡fico radar muestra el perfil multidimensional del partido. '
              'Valores mÃ¡s cercanos al 100% indican mejor desempeÃ±o en cada dimensiÃ³n. '
              'Datos calculados sobre los candidatos inscritos con hoja de vida disponible.',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
