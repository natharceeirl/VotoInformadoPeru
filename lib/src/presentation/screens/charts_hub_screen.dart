import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/new_providers.dart';
import '../../domain/models/new_models.dart';
import '../../domain/models/reinfo_models.dart';
import '../widgets/party_logo.dart';

// ─── Sort Enum ───────────────────────────────────────────────────────────────
enum _Sort { descValor, ascValor, alfa }

// ─── Main Screen ─────────────────────────────────────────────────────────────
class ChartsHubScreen extends ConsumerStatefulWidget {
  const ChartsHubScreen({super.key});

  @override
  ConsumerState<ChartsHubScreen> createState() => _ChartsHubScreenState();
}

class _ChartsHubScreenState extends ConsumerState<ChartsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sort states per indicator (ordered I1 → I8 + Radar)
  _Sort _sortI1  = _Sort.descValor;
  _Sort _sortI2  = _Sort.descValor;
  _Sort _sortI3  = _Sort.descValor;
  _Sort _sortI4  = _Sort.descValor;
  _Sort _sortI4b = _Sort.descValor;
  _Sort _sortI4c = _Sort.descValor;
  _Sort _sortI6a = _Sort.descValor;
  _Sort _sortI6b = _Sort.descValor;
  _Sort _sortI7  = _Sort.descValor;
  _Sort _sortI8  = _Sort.descValor;
  String? _selectedPartyRadar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumenAsync      = ref.watch(partyResumenRawProvider);
    final indicadoresAsync  = ref.watch(indicatorsGraphProvider);
    final reinfoAsync       = ref.watch(reinfoCandidatesRawProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores Interactivos'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'I1 Sentencias'),
            Tab(text: 'I2 Preparación'),
            Tab(text: 'I3 Ingre. S/0'),
            Tab(text: 'I4 Ingre. Mensual'),
            Tab(text: 'I4B Ingre. Anual'),
            Tab(text: 'I4C Ingre. Efectivo'),
            Tab(text: 'I6 Reelección'),
            Tab(text: 'I6 TK3'),
            Tab(text: 'I7 Candidatos'),
            Tab(text: 'I8 REINFO'),
            Tab(text: 'Radar'),
          ],
        ),
      ),
      body: resumenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (partidos) {
          return TabBarView(
            controller: _tabController,
            children: [

              // ── I1: % Candidatos con Sentencia ───────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 1 — % Candidatos con Sentencia',
                  subtitle:
                      'Porcentaje de candidatos activos del partido con al menos '
                      'una sentencia judicial registrada. 0% = ningún candidato sentenciado.',
                  icon: Icons.gavel,
                  color: Colors.red,
                  sort: _sortI1,
                  onSortChanged: (s) => setState(() => _sortI1 = s),
                  data: _sorted(
                    partidos.map((p) => _Bar(p.partido, p.porcentajeSentencias)).toList(),
                    _sortI1,
                  ),
                  maxValue: 30,
                  valueLabel: (v) => '${v.toStringAsFixed(1)}%',
                  colorOf: (v) =>
                      v == 0 ? Colors.green : (v < 5 ? Colors.amber : Colors.red),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I2: Preparación Académica ─────────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 2 — Índice de Preparación Académica (0–20)',
                  subtitle:
                      'Promedio del puntaje de educación formal por candidato. '
                      '0 = sin estudios · 20 = máximo (doctorado + todos los niveles previos).',
                  icon: Icons.school,
                  color: Colors.blue,
                  sort: _sortI2,
                  onSortChanged: (s) => setState(() => _sortI2 = s),
                  data: _sorted(
                    partidos.map((p) => _Bar(p.partido, p.promedioPreparacion)).toList(),
                    _sortI2,
                  ),
                  maxValue: 20,
                  valueLabel: (v) => v.toStringAsFixed(1),
                  colorOf: (v) =>
                      v >= 12 ? Colors.green : (v >= 6 ? Colors.amber : Colors.red),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I3: Candidatos con Ingresos en S/0 ───────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 3 — Candidatos con Ingresos Declarados en S/0',
                  subtitle:
                      'Número de candidatos que declararon cero ingresos ante la ONPE. '
                      'Puede indicar evasión o informalidad económica.',
                  icon: Icons.money_off,
                  color: Colors.orange,
                  sort: _sortI3,
                  onSortChanged: (s) => setState(() => _sortI3 = s),
                  data: _sorted(
                    partidos.map((p) => _Bar(p.partido, p.numConCero.toDouble())).toList(),
                    _sortI3,
                  ),
                  maxValue: null,
                  valueLabel: (v) => v.toInt().toString(),
                  colorOf: (v) =>
                      v == 0 ? Colors.green : (v < 5 ? Colors.amber : Colors.red),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I4: Ingreso Mensual Total ─────────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 4 — Promedio de Ingreso Mensual Total Declarado',
                  subtitle:
                      'Promedio del ingreso mensual total reportado por todos los '
                      'candidatos del partido (incluye quienes declararon S/0).',
                  icon: Icons.payments,
                  color: Colors.teal,
                  sort: _sortI4,
                  onSortChanged: (s) => setState(() => _sortI4 = s),
                  data: _sorted(
                    partidos.map((p) =>
                        _Bar(p.partido, p.promedioIngresosMensualesTotales)).toList(),
                    _sortI4,
                  ),
                  maxValue: null,
                  valueLabel: (v) => _currencyShort(v),
                  colorOf: (_) => Colors.teal,
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I4B: Ingreso Anual Total ──────────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 4B — Promedio de Ingreso Anual Total Declarado',
                  subtitle:
                      'Ingreso mensual × 12. Referencial para comparar poder económico '
                      'declarado entre partidos.',
                  icon: Icons.calendar_month,
                  color: Colors.green,
                  sort: _sortI4b,
                  onSortChanged: (s) => setState(() => _sortI4b = s),
                  data: _sorted(
                    partidos.map((p) =>
                        _Bar(p.partido, p.promedioIngresosAnuales)).toList(),
                    _sortI4b,
                  ),
                  maxValue: null,
                  valueLabel: (v) => _currencyShort(v),
                  colorOf: (_) => Colors.green,
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I4C: Ingreso Mensual Efectivo ─────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 4C — Promedio de Ingreso Mensual Efectivo',
                  subtitle:
                      'Promedio de ingreso mensual solo de candidatos que SÍ declararon '
                      'ingresos (excluyendo S/0). Refleja mejor el perfil económico real.',
                  icon: Icons.trending_up,
                  color: Colors.indigo,
                  sort: _sortI4c,
                  onSortChanged: (s) => setState(() => _sortI4c = s),
                  data: _sorted(
                    partidos.map((p) =>
                        _Bar(p.partido, p.promedioIngresosMensualesEfectivos)).toList(),
                    _sortI4c,
                  ),
                  maxValue: null,
                  valueLabel: (v) => _currencyShort(v),
                  colorOf: (_) => Colors.indigo,
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I6a: Candidatos que Buscan Reelección ────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 6 — Candidatos que Buscan Reelección',
                  subtitle:
                      'Número de excongresistas en la lista de candidatos al Senado '
                      'Nacional de cada partido.',
                  icon: Icons.history_edu,
                  color: Colors.purple,
                  sort: _sortI6a,
                  onSortChanged: (s) => setState(() => _sortI6a = s),
                  data: _sorted(
                    partidos.map((p) =>
                        _Bar(p.partido, p.reeleccionCongresistas.toDouble())).toList(),
                    _sortI6a,
                  ),
                  maxValue: null,
                  valueLabel: (v) => v.toInt().toString(),
                  colorOf: (v) =>
                      v == 0 ? Colors.green : (v <= 2 ? Colors.amber : Colors.deepOrange),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I6b: Tasa de Corrupción TK3 ──────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 6 — Tasa de Corrupción TK3',
                  subtitle:
                      'Índice compuesto de correlación con corrupción (0=bajo riesgo, '
                      '1=alto riesgo). Combina infiltración, pactos y otras métricas.',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.deepOrange,
                  sort: _sortI6b,
                  onSortChanged: (s) => setState(() => _sortI6b = s),
                  data: _sorted(
                    partidos.map((p) => _Bar(p.partido, p.tk3)).toList(),
                    _sortI6b,
                  ),
                  maxValue: 1.0,
                  valueLabel: (v) => v.toStringAsFixed(2),
                  colorOf: (v) =>
                      v < 0.2 ? Colors.green : (v < 0.5 ? Colors.amber : Colors.red),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I7: Total de Candidatos ───────────────────────────────────
              _TabScrollable(children: [
                _ChartSection(
                  title: 'INDICADOR 7 — Total de Candidatos al Senado Nacional',
                  subtitle:
                      'Número de candidatos inscritos por partido. Los partidos con '
                      '30 candidatos tienen "equipo completo".',
                  icon: Icons.groups,
                  color: Colors.cyan,
                  sort: _sortI7,
                  onSortChanged: (s) => setState(() => _sortI7 = s),
                  data: _sorted(
                    partidos.map((p) =>
                        _Bar(p.partido, p.totalCandidatos.toDouble())).toList(),
                    _sortI7,
                  ),
                  maxValue: 30,
                  valueLabel: (v) => v.toInt().toString(),
                  colorOf: (v) =>
                      v >= 30 ? Colors.green : (v >= 20 ? Colors.amber : Colors.red),
                  onTap: (b) => _showPartyDetail(context, b.label, partidos),
                ),
              ]),

              // ── I8: Candidatos en REINFO por Partido ────────────────────
              reinfoAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (reinfoCands) {
                  final countByParty = <String, int>{};
                  for (final c in reinfoCands) {
                    countByParty[c.partido] =
                        (countByParty[c.partido] ?? 0) + 1;
                  }
                  final bars = _sorted(
                    countByParty.entries
                        .map((e) => _Bar(e.key, e.value.toDouble()))
                        .toList(),
                    _sortI8,
                  );
                  return _TabScrollable(children: [
                    _ChartSection(
                      title: 'INDICADOR 8 — Candidatos en REINFO por Partido',
                      subtitle:
                          'Número de candidatos por partido con registros en el REINFO '
                          '(Registro Integral de Formalización Minera — minería informal). '
                          'Solo aparecen partidos con al menos un candidato en el registro. '
                          'Toca un partido para ver los nombres de los candidatos.',
                      icon: Icons.landscape,
                      color: Colors.brown,
                      sort: _sortI8,
                      onSortChanged: (s) => setState(() => _sortI8 = s),
                      data: bars,
                      maxValue: null,
                      valueLabel: (v) => v.toInt().toString(),
                      colorOf: (v) => v <= 1
                          ? Colors.amber
                          : (v <= 3 ? Colors.deepOrange : Colors.red),
                      onTap: (b) => _showPartyDetail(
                        context, b.label, partidos,
                        reinfoCands: reinfoCands,
                      ),
                    ),
                  ]);
                },
              ),

              // ── Radar: Perfil Multidimensional ────────────────────────────
              indicadoresAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (graphs) {
                  final partyNames =
                      graphs.map((g) => g.partido).toList()..sort();
                  _selectedPartyRadar ??= partyNames.first;
                  final graph = graphs.firstWhere(
                    (g) => g.partido == _selectedPartyRadar,
                    orElse: () => graphs.first,
                  );
                  return _RadarTab(
                    graph: graph,
                    partyNames: partyNames,
                    selectedParty: _selectedPartyRadar!,
                    onPartyChanged: (p) =>
                        setState(() => _selectedPartyRadar = p),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
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

  void _showPartyDetail(
    BuildContext context,
    String partyName,
    List<PartyResumenRaw> partidos, {
    List<ReinfoCandidate>? reinfoCands,
  }) {
    final matches = partidos.where((p) => p.partido == partyName).toList();
    final p = matches.isNotEmpty ? matches.first : null;
    final reinfoForParty =
        reinfoCands?.where((c) => c.partido == partyName).toList() ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            PartyLogo(partyName: partyName, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                partyName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p == null)
                  const Text(
                    'No hay datos detallados para este partido.',
                    style: TextStyle(color: Colors.grey),
                  )
                else ...[
                  _dRow(Icons.groups, 'Total candidatos',
                      p.totalCandidatos.toString()),
                  _dRow(Icons.person_outline, 'Candidatos efectivos',
                      p.candidatosEfectivos.toString()),
                  const Divider(height: 20),
                  _dRow(Icons.gavel, '% con sentencia',
                      '${p.porcentajeSentencias.toStringAsFixed(1)}%'),
                  _dRow(Icons.list_alt, 'Total sentencias',
                      p.totalSentencias.toString()),
                  const Divider(height: 20),
                  _dRow(Icons.school, 'Preparación promedio',
                      p.promedioPreparacion.toStringAsFixed(2)),
                  const Divider(height: 20),
                  _dRow(Icons.payments, 'Ing. mensual total',
                      _currency(p.promedioIngresosMensualesTotales)),
                  _dRow(Icons.trending_up, 'Ing. mensual efectivo',
                      _currency(p.promedioIngresosMensualesEfectivos)),
                  _dRow(Icons.money_off, 'Con ingresos S/0',
                      p.numConCero.toString()),
                  const Divider(height: 20),
                  _dRow(Icons.warning_amber_rounded,
                      'TK3 (riesgo corrupción)', p.tk3.toStringAsFixed(3)),
                  _dRow(Icons.history_edu, 'Candidatos reeleccionistas',
                      p.reeleccionCongresistas.toString()),
                ],
                // REINFO section (only shown for I8)
                if (reinfoCands != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.landscape,
                          color: Colors.brown, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'En REINFO: ${reinfoForParty.length} candidato(s)',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reinfoForParty.isEmpty)
                    const Text(
                      'Ningún candidato de este partido en REINFO.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  else
                    ...reinfoForParty.map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    Colors.orange.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.orange, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  c.candidato,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (c.cantidadMineras > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.cantidadMineras > 3
                                        ? Colors.red
                                            .withValues(alpha: 0.12)
                                        : Colors.orange
                                            .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${c.cantidadMineras} reg.',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: c.cantidadMineras > 3
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

// ─── Simple data holder ───────────────────────────────────────────────────────
class _Bar {
  final String label;
  final double value;
  const _Bar(this.label, this.value);
}

// ─── Dialog row helper ────────────────────────────────────────────────────────
Widget _dRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ─── Currency helpers ─────────────────────────────────────────────────────────
String _currency(double v) =>
    NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ').format(v);

String _currencyShort(double v) {
  if (v >= 1000000) return 'S/ ${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return 'S/ ${(v / 1000).toStringAsFixed(1)}K';
  return 'S/ ${v.toStringAsFixed(0)}';
}

// ─── Tab scrollable wrapper ──────────────────────────────────────────────────
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

// ─── Chart Section ───────────────────────────────────────────────────────────
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
        // Header
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
        // Sort row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Ordenar: ', style: theme.textTheme.bodySmall),
            _SortChip('↓ Mayor', _Sort.descValor, sort, onSortChanged, color),
            const SizedBox(width: 6),
            _SortChip('↑ Menor', _Sort.ascValor, sort, onSortChanged, color),
            const SizedBox(width: 6),
            _SortChip('A-Z', _Sort.alfa, sort, onSortChanged, color),
          ],
        ),
        const SizedBox(height: 8),
        // Bars
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

// ─── Sort Chip ───────────────────────────────────────────────────────────────
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

// ─── Bar Row (with logo + internal label) ────────────────────────────────────
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
            // Party logo
            PartyLogo(partyName: bar.label, size: 20),
            const SizedBox(width: 4),
            // Party name
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
            // Bar with overlaid value label
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

// ─── Radar Tab ───────────────────────────────────────────────────────────────
class _RadarTab extends StatelessWidget {
  final dynamic graph;
  final List<String> partyNames;
  final String selectedParty;
  final ValueChanged<String> onPartyChanged;

  const _RadarTab({
    required this.graph,
    required this.partyNames,
    required this.selectedParty,
    required this.onPartyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final axes = [
      _RadarAxis('Sin\nSentencias', graph.sentencias as double, Colors.red),
      _RadarAxis('Preparación', graph.preparacion as double, Colors.blue),
      _RadarAxis('Ing. No\nDeclarados', graph.ingresosNoDeclarados as double,
          Colors.orange),
      _RadarAxis(
          'Ing.\nEfectivos', graph.ingresosEfectivos as double, Colors.green),
      _RadarAxis(
          'Libre\ndel Pacto', graph.librePacto as double, Colors.purple),
      _RadarAxis(
          'Sin\nReelección', graph.reeleccion as double, Colors.teal),
      _RadarAxis(
          'Equipo\nCompleto', graph.equipoCompleto as double, Colors.indigo),
      _RadarAxis(
          'Libre de\nREINFO', graph.reinfo as double, Colors.brown),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'INDICADOR GLOBAL — Radar por Partido',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Perfil multidimensional en 8 indicadores normalizados (0–100). '
                'Mayor área = mejor desempeño general.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),

              // Party selector — logo is INSIDE each dropdown item
              DropdownButtonFormField<String>(
                initialValue: selectedParty,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Partido',
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
                                child: Text(
                                  p,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onPartyChanged(v);
                },
              ),
              const SizedBox(height: 8),

              // Score chip
              Center(
                child: Chip(
                  avatar:
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                  label: Text(
                    'Score Final: ${(graph.scoreFinal as double).toStringAsFixed(1)} / 100',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 12),

              // Radar chart — more prominent, constrained height
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          fillColor:
                              theme.colorScheme.primary.withValues(alpha: 0.25),
                          borderColor: theme.colorScheme.primary,
                          borderWidth: 2.5,
                          entryRadius: 5,
                          dataEntries: axes
                              .map((a) => RadarEntry(value: a.value))
                              .toList(),
                        ),
                      ],
                      radarShape: RadarShape.polygon,
                      radarBackgroundColor: Colors.transparent,
                      gridBorderData: BorderSide(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      tickCount: 5,
                      ticksTextStyle: const TextStyle(
                          fontSize: 8, color: Colors.transparent),
                      getTitle: (index, angle) => RadarChartTitle(
                        text: axes[index].label,
                        angle: angle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Legend — compact Wrap chips
              Text(
                'Detalle de indicadores',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: axes
                    .map((a) => _RadarLegendChip(
                          label: a.label.replaceAll('\n', ' '),
                          value: a.value,
                          color: a.color,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarAxis {
  final String label;
  final double value;
  final Color color;
  const _RadarAxis(this.label, this.value, this.color);
}

class _RadarLegendChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _RadarLegendChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
