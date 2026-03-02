import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../providers/new_providers.dart';
import '../../domain/models/new_models.dart';
import '../widgets/party_logo.dart';
import '../widgets/candidate_photo.dart';

class CandidatesDirectoryScreen extends ConsumerStatefulWidget {
  const CandidatesDirectoryScreen({super.key});

  @override
  ConsumerState<CandidatesDirectoryScreen> createState() =>
      _CandidatesDirectoryScreenState();
}

class _CandidatesDirectoryScreenState
    extends ConsumerState<CandidatesDirectoryScreen> {
  // ── Search ────────────────────────────────────────────────────────────────
  final _searchController = TextEditingController();

  // ── Sort ──────────────────────────────────────────────────────────────────
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // ── Extra local filters ───────────────────────────────────────────────────
  bool? _filterReinfo;      // null=todos, true=con REINFO, false=sin REINFO
  bool? _filterSentencias;  // null=todos, true=con sentencias, false=sin
  bool? _filterReelecto;    // null=todos, true=reelecto, false=no reelecto

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Sorting logic ─────────────────────────────────────────────────────────
  int _eduRank(CandidateDetailed c) {
    final e = c.educacion;
    if (e.doctorado) return 7;
    if (e.maestria) return 6;
    if (e.univ) return 5;
    if (e.noUniv) return 4;
    if (e.tecnico) return 3;
    if (e.secundaria) return 2;
    if (e.primaria) return 1;
    return 0;
  }

  List<CandidateDetailed> _sort(List<CandidateDetailed> list) {
    if (_sortColumnIndex == null) return list;
    final sorted = List<CandidateDetailed>.from(list);
    int cmp(CandidateDetailed a, CandidateDetailed b) {
      switch (_sortColumnIndex) {
        case 0: return a.dni.compareTo(b.dni);
        case 1: return a.partido.compareTo(b.partido);
        case 2: return _eduRank(a).compareTo(_eduRank(b));
        case 3: return a.ingresosTotales.compareTo(b.ingresosTotales);
        case 4: return a.sentencias.compareTo(b.sentencias);
        case 5: return (a.reinfo ? 1 : 0).compareTo(b.reinfo ? 1 : 0);
        case 6: return (a.congresistaReelecto ? 1 : 0)
            .compareTo(b.congresistaReelecto ? 1 : 0);
        default: return 0;
      }
    }
    sorted.sort(_sortAscending ? cmp : (a, b) => cmp(b, a));
    return sorted;
  }

  // ── Extra filter logic ────────────────────────────────────────────────────
  List<CandidateDetailed> _extraFilter(List<CandidateDetailed> list) {
    return list.where((c) {
      if (_filterReinfo != null && c.reinfo != _filterReinfo) return false;
      if (_filterSentencias == true && c.sentencias == 0) return false;
      if (_filterSentencias == false && c.sentencias > 0) return false;
      if (_filterReelecto != null &&
          c.congresistaReelecto != _filterReelecto) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasExtraFilters =>
      _filterReinfo != null ||
      _filterSentencias != null ||
      _filterReelecto != null;

  void _clearAll() {
    _searchController.clear();
    ref.read(searchCandidateProvider.notifier).update('');
    ref.read(selectedCandidatePartyProvider.notifier).update(null);
    ref.read(selectedEducationProvider.notifier).update(null);
    setState(() {
      _filterReinfo = null;
      _filterSentencias = null;
      _filterReelecto = null;
      _sortColumnIndex = null;
      _sortAscending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(filteredDetailedCandidatesProvider);
    final allCandidatesAsync = ref.watch(allCandidatesProvider);
    final searchQuery = ref.watch(searchCandidateProvider);
    final selectedParty = ref.watch(selectedCandidatePartyProvider);
    final selectedEducation = ref.watch(selectedEducationProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    final hasActiveFilters = searchQuery.isNotEmpty ||
        selectedParty != null ||
        selectedEducation != null ||
        _hasExtraFilters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Candidatos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Description banner ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.manage_search_rounded,
                    color: Colors.teal, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Busca entre los 963 candidatos al Senado Nacional 2026. '
                    'Filtra, ordena columnas o busca por DNI y partido. '
                    'Toca una fila para ver el perfil completo del candidato.',
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

          // ── Party summary (Wrap multilínea) ──────────────────────────────
          /*Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: allCandidatesAsync.when(
              data: (all) {
                final countByParty = <String, int>{};
                for (final c in all) {
                  countByParty[c.partido] = (countByParty[c.partido] ?? 0) + 1;
                }
                final sorted = countByParty.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sorted.map((e) {
                    final isSelected = selectedParty == e.key;
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(selectedCandidatePartyProvider.notifier)
                            .update(isSelected ? null : e.key);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PartyLogo(partyName: e.key, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 36,
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),*/

          // ── Filtros unificados (Wrap responsive) ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Búsqueda
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por DNI o partido',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(searchCandidateProvider.notifier)
                                    .update('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) =>
                        ref.read(searchCandidateProvider.notifier).update(val),
                  ),
                ),

                // Partido
                SizedBox(
                  width: 180,
                  child: allCandidatesAsync.when(
                    data: (all) {
                      final parties =
                          all.map((c) => c.partido).toSet().toList()..sort();
                      return DropdownButtonFormField<String?>(
                        key: ValueKey(selectedParty),
                        decoration: const InputDecoration(
                          labelText: 'Partido',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        isExpanded: true,
                        initialValue: selectedParty,
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Todos')),
                          ...parties.map(
                            (p) => DropdownMenuItem<String?>(
                              value: p,
                              child: Row(children: [
                                PartyLogo(partyName: p, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(p,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ]),
                            ),
                          ),
                        ],
                        onChanged: (val) => ref
                            .read(selectedCandidatePartyProvider.notifier)
                            .update(val),
                      );
                    },
                    loading: () => const SizedBox(
                        height: 40,
                        child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2))),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Nivel Educativo
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey(selectedEducation),
                    decoration: const InputDecoration(
                      labelText: 'Nivel Educativo',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    isExpanded: true,
                    initialValue: selectedEducation,
                    items: const <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(
                          value: null, child: Text('Todos')),
                      DropdownMenuItem<String?>(
                          value: 'Doctorado', child: Text('Doctorado')),
                      DropdownMenuItem<String?>(
                          value: 'Maestría', child: Text('Maestría')),
                      DropdownMenuItem<String?>(
                          value: 'Universitario',
                          child: Text('Universitario')),
                      DropdownMenuItem<String?>(
                          value: 'No Universitario',
                          child: Text('No Universitario')),
                      DropdownMenuItem<String?>(
                          value: 'Técnico', child: Text('Técnico')),
                      DropdownMenuItem<String?>(
                          value: 'Secundaria', child: Text('Secundaria')),
                      DropdownMenuItem<String?>(
                          value: 'Primaria', child: Text('Primaria')),
                      DropdownMenuItem<String?>(
                          value: 'Ninguno', child: Text('Ninguno')),
                    ],
                    onChanged: (val) => ref
                        .read(selectedEducationProvider.notifier)
                        .update(val),
                  ),
                ),

                // REINFO
                _FilterGroup(
                  label: 'REINFO',
                  options: const ['Todos', 'Sí', 'No'],
                  selectedIndex:
                      _filterReinfo == null ? 0 : (_filterReinfo! ? 1 : 2),
                  onChanged: (i) =>
                      setState(() => _filterReinfo = i == 0 ? null : i == 1),
                  activeColor: Colors.orange,
                ),

                // # Sentencias
                _FilterGroup(
                  label: '# Sentencias',
                  options: const ['Todos', 'Con sent.', 'Sin sent.'],
                  selectedIndex: _filterSentencias == null
                      ? 0
                      : (_filterSentencias! ? 1 : 2),
                  onChanged: (i) => setState(
                      () => _filterSentencias = i == 0 ? null : i == 1),
                  activeColor: Colors.red,
                ),

                // Reelecto
                _FilterGroup(
                  label: 'Reelecto',
                  options: const ['Todos', 'Sí', 'No'],
                  selectedIndex: _filterReelecto == null
                      ? 0
                      : (_filterReelecto! ? 1 : 2),
                  onChanged: (i) => setState(
                      () => _filterReelecto = i == 0 ? null : i == 1),
                  activeColor: Colors.purple,
                ),

                // Limpiar filtros
                if (hasActiveFilters)
                  Tooltip(
                    message: 'Limpiar todos los filtros',
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt_off),
                      onPressed: _clearAll,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),

          // ── Results count + column legend ─────────────────────────────────
          candidatesAsync.when(
            data: (raw) {
              final candidates = _sort(_extraFilter(raw));
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      '${candidates.length} candidatos'
                      '${candidates.length > 100 ? ', mostrando primeros 100' : ''}',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                    ),
                    const Spacer(),
                    if (_sortColumnIndex != null)
                      TextButton.icon(
                        icon: const Icon(Icons.sort, size: 14),
                        label: const Text('Quitar orden',
                            style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => setState(() {
                          _sortColumnIndex = null;
                          _sortAscending = true;
                        }),
                      ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(height: 1),

          // ── Data Table ────────────────────────────────────────────────────
          Expanded(
            child: candidatesAsync.when(
              data: (raw) {
                final candidates = _sort(_extraFilter(raw));

                if (candidates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No se encontraron candidatos'),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Limpiar filtros'),
                            onPressed: _clearAll,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return DataTable2(
                  columnSpacing: 10,
                  horizontalMargin: 14,
                  minWidth: 820,
                  showCheckboxColumn: false,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn2(
                      label: const Text('DNI'),
                      size: ColumnSize.S,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Partido'),
                      size: ColumnSize.L,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Educación'),
                      size: ColumnSize.M,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Ingresos Mensuales'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('# Sentencias'),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: Tooltip(
                        message: 'Registro Integral de Formalización Minera',
                        child: const Text('REINFO'),
                      ),
                      size: ColumnSize.S,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Reelecto'),
                      size: ColumnSize.S,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                  ],
                  rows: candidates.take(100).map((c) {
                    return DataRow(
                      onSelectChanged: (_) =>
                          _showCandidateDetail(context, c, currencyFormat),
                      cells: [
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CandidatePhoto(dni: c.dni, size: 28),
                            const SizedBox(width: 6),
                            Text(c.dni,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PartyLogo(partyName: c.partido, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                c.partido,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        )),
                        DataCell(Text(c.educacion.maxLevel,
                            style: const TextStyle(fontSize: 12))),
                        DataCell(
                          Text(currencyFormat.format(c.ingresosTotales),
                              style: const TextStyle(fontSize: 12)),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.sentencias > 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              c.sentencias.toString(),
                              style: TextStyle(
                                color: c.sentencias > 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          c.reinfo
                              ? const Tooltip(
                                  message: 'Vinculado al registro REINFO',
                                  child: Icon(Icons.warning,
                                      color: Colors.orange, size: 20),
                                )
                              : const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                        ),
                        DataCell(
                          c.congresistaReelecto
                              ? Text(
                                  c.periodoCongreso.isNotEmpty
                                      ? c.periodoCongreso.split(' ').first
                                      : 'Sí',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                    fontSize: 12,
                                  ),
                                )
                              : const Text('No',
                                  style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showCandidateDetail(
    BuildContext context,
    CandidateDetailed c,
    NumberFormat currencyFormat,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            CandidatePhoto(dni: c.dni, size: 52),
            const SizedBox(width: 10),
            PartyLogo(partyName: c.partido, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('DNI ${c.dni}',
                      style: const TextStyle(fontSize: 15)),
                  Text(
                    c.partido,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
                _DetailRow('Nivel educativo', c.educacion.maxLevel,
                    Icons.school, Colors.teal),
                _DetailRow(
                  'Ingresos mensuales declarados',
                  currencyFormat.format(c.ingresosTotales),
                  Icons.attach_money,
                  Colors.green,
                ),
                _DetailRow(
                  'Sentencias',
                  c.sentencias > 0
                      ? '${c.sentencias} sentencia(s)'
                      : 'Sin sentencias registradas',
                  Icons.gavel,
                  c.sentencias > 0 ? Colors.red : Colors.green,
                ),
                _DetailRow(
                  'REINFO',
                  c.reinfo
                      ? 'Sí — vinculado al registro REINFO'
                      : 'No registrado en REINFO',
                  Icons.landscape,
                  c.reinfo ? Colors.orange : Colors.green,
                ),
                _DetailRow(
                  'Excongresista',
                  c.congresistaReelecto
                      ? (c.periodoCongreso.isNotEmpty
                          ? 'Sí — Periodo: ${c.periodoCongreso}'
                          : 'Sí')
                      : 'No',
                  Icons.history_edu,
                  c.congresistaReelecto ? Colors.purple : Colors.grey,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// ─── Quick filter chip group ──────────────────────────────────────────────────
class _FilterGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color activeColor;

  const _FilterGroup({
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(width: 5),
        ...options.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: GestureDetector(
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: e.key == selectedIndex
                        ? activeColor
                        : activeColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: activeColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: e.key == selectedIndex
                          ? Colors.white
                          : activeColor,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Detail row widget ────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailRow(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
