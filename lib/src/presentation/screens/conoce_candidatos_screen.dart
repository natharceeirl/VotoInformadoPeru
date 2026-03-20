import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ─── Pantalla principal "Conoce a tus Candidatos" ─────────────────────────────

class ConoceCandidatosScreen extends ConsumerStatefulWidget {
  final ProcesoElectoral proceso;

  const ConoceCandidatosScreen({super.key, required this.proceso});

  @override
  ConsumerState<ConoceCandidatosScreen> createState() =>
      _ConoceCandidatosScreenState();
}

class _ConoceCandidatosScreenState
    extends ConsumerState<ConoceCandidatosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _nameFilter = '';
  late TextEditingController _nameCtrl;
  String? _partidoFilter;
  String? _deptoFilter;
  bool _bannerExpanded = false;

  bool get _hasTabs => widget.proceso == ProcesoElectoral.senadores;
  bool get _hasActiveFilter => _nameFilter.isNotEmpty || _partidoFilter != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _tabCtrl = TabController(length: _hasTabs ? 2 : 1, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String _normPartido(String s) {
    var r = s.toUpperCase().replaceAll(',', ' ')
        .replaceAll('Á', 'A').replaceAll('É', 'E')
        .replaceAll('Í', 'I').replaceAll('Ó', 'O').replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
    while (r.contains('  ')) { r = r.replaceAll('  ', ' '); }
    return r.trim();
  }

  List<CandidatoConHV> _applyFilters(
    List<CandidatoConHV> todos,
    List<String> porEstosNo,
    bool excluir,
  ) {
    var result = todos;
    if (_nameFilter.isNotEmpty) {
      final q = _nameFilter.toUpperCase();
      result = result.where((c) => c.hv.nombre.toUpperCase().contains(q)).toList();
    }
    if (_partidoFilter != null) {
      result = result.where((c) => c.hv.partido == _partidoFilter).toList();
    }

    if (excluir && porEstosNo.isNotEmpty) {
      result = result.where((c) {
        final r = _normPartido(c.hv.partido);
        return !porEstosNo.any((n) => r == n || r.contains(n));
      }).toList();
    }
    return result;
  }

  Widget _buildFilters(List<CandidatoConHV> todos) {
    // Region filter is handled internally by _SingleListView / _SenadoresView
    final partidos = todos.map((c) => c.hv.partido).toSet().toList()..sort();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              filled: true, fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
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
          if (_hasActiveFilter) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _nameCtrl.clear();
                  setState(() {
                    _nameFilter = '';
                    _partidoFilter = null;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        ? '#PORESTOSNO: ocultando ${porEstosNo.length} partidos con riesgo'
                        : 'Hay ${porEstosNo.length} partidos con riesgo — toca para filtrar',
                    style: TextStyle(
                      fontSize: 11,
                      color: excluir ? const Color(0xFFB71C1C) : Colors.orange.shade800,
                    ),
                  ),
                ),
                if (excluir && detalle.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _bannerExpanded = !_bannerExpanded),
                    child: Icon(
                      _bannerExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      size: 18, color: const Color(0xFFB71C1C),
                    ),
                  ),
                Switch(
                  value: excluir,
                  onChanged: (_) {
                    ref.read(excluirPartidosRiesgoProvider.notifier).toggle();
                    if (!excluir) setState(() => _bannerExpanded = false);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeThumbColor: const Color(0xFFB71C1C),
                  activeTrackColor: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                ),
              ],
            ),
            if (excluir && _bannerExpanded && detalle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: detalle.map((p) {
                  final nombre = (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel = (p['nivel_riesgo'] as String? ?? '').toLowerCase();
                  final color = nivel == 'alto' ? Colors.red.shade600 : Colors.orange.shade700;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 18, height: 18,
                            child: PartyLogo(partyName: nombre, size: 18)),
                        const SizedBox(width: 5),
                        Text(nombre,
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPorEstosNoDialog(BuildContext ctx, List<Map<String, dynamic>> detalle) {
    showDialog(
      context: ctx,
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
                            SizedBox(width: 32, height: 32,
                                child: PartyLogo(partyName: nombre, size: 32)),
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
              onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proceso     = widget.proceso;
    final color       = proceso.color;
    final async       = ref.watch(candidatosConHVProcesoProvider(proceso));
    final porEstosNo  = ref.watch(porEstosNoProvider).asData?.value ?? [];
    final detalle     = ref.watch(porEstosNoDetalleProvider).asData?.value ?? [];
    final excluir     = ref.watch(excluirPartidosRiesgoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(proceso.displayName),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: _hasTabs
            ? TabBar(
                controller: _tabCtrl,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(color: Colors.white, width: 3),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.flag_rounded),     text: 'Nacional (Único)'),
                  Tab(icon: Icon(Icons.map_rounded),       text: 'Por Región (Múltiple)'),
                ],
              )
            : null,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => _ErrorWidget(error: e.toString()),
        data:    (todos) {
          if (todos.isEmpty) {
            return _NoDataWidget(proceso: proceso);
          }
          final filtrados = _applyFilters(todos, porEstosNo, excluir);
          return Column(
            children: [
              _buildFilters(todos),
              if (porEstosNo.isNotEmpty) _buildFilterBanner(porEstosNo, detalle),
              Expanded(
                child: _hasTabs
                    ? _SenadoresView(
                        todos:          filtrados,
                        tabCtrl:        _tabCtrl,
                        deptoFilter:    _deptoFilter,
                        onDeptoChanged: (d) => setState(() => _deptoFilter = d),
                        proceso:        proceso,
                      )
                    : _SingleListView(
                        todos:          filtrados,
                        proceso:        proceso,
                        deptoFilter:    _deptoFilter,
                        onDeptoChanged: (d) => setState(() => _deptoFilter = d),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Vista para Senadores (2 tabs) ────────────────────────────────────────────

class _SenadoresView extends StatelessWidget {
  final List<CandidatoConHV> todos;
  final TabController tabCtrl;
  final String? deptoFilter;
  final ValueChanged<String?> onDeptoChanged;
  final ProcesoElectoral proceso;

  const _SenadoresView({
    required this.todos,
    required this.tabCtrl,
    required this.deptoFilter,
    required this.onDeptoChanged,
    required this.proceso,
  });

  @override
  Widget build(BuildContext context) {
    final unicos    = todos.where((c) => c.tipoDistrito == 'ÚNICO').toList()
      ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
    final multiples = todos.where((c) => c.tipoDistrito == 'MÚLTIPLE').toList();

    final deptos = multiples.map((c) => c.departamento).toSet().toList()..sort();
    final filtrados = (deptoFilter == null
            ? multiples
            : multiples.where((c) => c.departamento == deptoFilter).toList())
        ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

    return TabBarView(
      controller: tabCtrl,
      children: [
        _CandidatosList(
          candidatos: unicos,
          headerText: 'Candidatos al Senado Nacional ordenados por perfil de integridad.',
          proceso: proceso,
        ),
        Column(
          children: [
            _DeptoFilter(
              deptos: deptos,
              selected: deptoFilter,
              onChanged: onDeptoChanged,
            ),
            Expanded(
              child: _CandidatosList(
                candidatos: filtrados,
                headerText: deptoFilter == null
                    ? 'Candidatos por región — selecciona un departamento para filtrar.'
                    : 'Candidatos de $deptoFilter ordenados por perfil de integridad.',
                proceso: proceso,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Vista de lista única (Presidentes, Diputados, Parlamento Andino) ─────────

class _SingleListView extends StatelessWidget {
  final List<CandidatoConHV> todos;
  final ProcesoElectoral proceso;
  final String? deptoFilter;
  final ValueChanged<String?> onDeptoChanged;

  const _SingleListView({
    required this.todos,
    required this.proceso,
    required this.deptoFilter,
    required this.onDeptoChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ── Presidentes: filter by cargo (Presidente / 1er VP / 2do VP) ──────────
    if (proceso == ProcesoElectoral.presidentes) {
      final cargos = todos.map((c) => c.cargo)
          .where((c) => c.isNotEmpty).toSet().toList()
          ..sort();

      // Sort cargos in logical order: Presidente → 1er VP → 2do VP
      const cargoOrder = [
        'PRESIDENTE DE LA REPÚBLICA',
        'PRIMER VICEPRESIDENTE DE LA REPÚBLICA',
        'SEGUNDO VICEPRESIDENTE DE LA REPÚBLICA',
      ];
      cargos.sort((a, b) {
        final ia = cargoOrder.indexOf(a);
        final ib = cargoOrder.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

      // Default to first cargo (PRESIDENTE) if none selected
      final effectiveFilter = (deptoFilter == null || deptoFilter!.isEmpty)
          ? (cargos.isNotEmpty ? cargos.first : null)
          : deptoFilter;

      final filtrados = (effectiveFilter == null
              ? todos
              : todos.where((c) => c.cargo == effectiveFilter).toList())
          ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

      return Column(
        children: [
          _ValueFilter(
            icon: Icons.work_outline_rounded,
            hint: 'Selecciona cargo',
            values: cargos,
            selected: effectiveFilter,
            // When user picks a value, propagate upward; never allow null
            onChanged: (v) => onDeptoChanged(v ?? effectiveFilter),
            allowAll: false,
          ),
          Expanded(
            child: _CandidatosList(
              candidatos: filtrados,
              headerText: '${_shortCargo(effectiveFilter ?? '')} — ordenado por perfil de integridad.',
              proceso: proceso,
            ),
          ),
        ],
      );
    }

    // ── Otros procesos: filter by departamento ─────────────────────────────
    final hasDepts =
        proceso == ProcesoElectoral.diputados ||
        todos.any((c) => c.departamento.isNotEmpty);

    final deptos = todos.map((c) => c.departamento)
        .where((d) => d.isNotEmpty).toSet().toList()..sort();

    final filtrados = (deptoFilter == null || deptoFilter!.isEmpty
            ? todos
            : todos.where((c) => c.departamento == deptoFilter).toList())
        ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

    if (!hasDepts || deptos.isEmpty) {
      return _CandidatosList(
        candidatos: filtrados..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal)),
        headerText: 'Candidatos ordenados por perfil de integridad.',
        proceso: proceso,
      );
    }

    return Column(
      children: [
        _DeptoFilter(
          deptos: deptos,
          selected: deptoFilter,
          onChanged: onDeptoChanged,
        ),
        Expanded(
          child: _CandidatosList(
            candidatos: filtrados,
            headerText: deptoFilter == null
                ? 'Todos los candidatos — selecciona un departamento para filtrar.'
                : 'Candidatos de $deptoFilter — ordenados por perfil de integridad.',
            proceso: proceso,
          ),
        ),
      ],
    );
  }

  static String _shortCargo(String cargo) {
    if (cargo.contains('SEGUNDO VICE')) return '2do Vicepresidente';
    if (cargo.contains('PRIMER VICE'))  return '1er Vicepresidente';
    if (cargo.contains('PRESIDENTE'))   return 'Presidentes';
    return cargo;
  }
}

// ─── Filtro genérico (departamento o cargo) ───────────────────────────────────

class _ValueFilter extends StatelessWidget {
  final IconData icon;
  final String hint;
  final List<String> values;
  final String? selected;
  final ValueChanged<String?> onChanged;
  /// If false, no "Todos" null option is shown and selection is required.
  final bool allowAll;

  const _ValueFilter({
    required this.icon,
    required this.hint,
    required this.values,
    required this.selected,
    required this.onChanged,
    this.allowAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text(hint),
                items: [
                  if (allowAll)
                    DropdownMenuItem<String>(value: null, child: Text(hint)),
                  ...values.map((v) =>
                    DropdownMenuItem<String>(value: v, child: Text(v)),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filtro de departamento ───────────────────────────────────────────────────

class _DeptoFilter extends StatelessWidget {
  final List<String> deptos;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _DeptoFilter({
    required this.deptos,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.place_rounded, size: 18,
                color: cs.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Todos los departamentos'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todos los departamentos'),
                  ),
                  ...deptos.map((d) =>
                    DropdownMenuItem<String>(value: d, child: Text(d)),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lista de candidatos ──────────────────────────────────────────────────────

class _CandidatosList extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final String headerText;
  final ProcesoElectoral proceso;

  const _CandidatosList({
    required this.candidatos,
    required this.headerText,
    required this.proceso,
  });

  @override
  Widget build(BuildContext context) {
    if (candidatos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('Sin candidatos en este filtro.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 24),
      itemCount: candidatos.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return _ListHeader(text: headerText, count: candidatos.length,
              color: proceso.color);
        }
        return _CandidatoCard(c: candidatos[i - 1], rank: i, proceso: proceso);
      },
    );
  }
}

// ─── Encabezado de lista ──────────────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  final String text;
  final int count;
  final Color color;

  const _ListHeader({required this.text, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de candidato ─────────────────────────────────────────────────────

class _CandidatoCard extends StatelessWidget {
  final CandidatoConHV c;
  final int rank;
  final ProcesoElectoral proceso;

  const _CandidatoCard({required this.c, required this.rank, required this.proceso});

  @override
  Widget build(BuildContext context) {
    final hv    = c.hv;
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: hv.scoreColor.withValues(alpha: 0.3), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetalle(context, c, proceso),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Score badge ─────────────────────────────────────────────
              _ScoreBadge(rank: rank, hv: hv),
              const SizedBox(width: 8),

              // ── Foto ────────────────────────────────────────────────────
              _PhotoCircle(fotoUrl: c.fotoUrl, nombre: hv.nombre, size: 44),
              const SizedBox(width: 10),

              // ── Info central ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hv.nombre,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SizedBox(
                          width: 16, height: 16,
                          child: PartyLogo(partyName: hv.partido, size: 16),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(hv.partido,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    if (c.cargo.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(c.cargo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: proceso.color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5, runSpacing: 3,
                      children: [
                        _Chip(icon: hv.educacionIcon,
                              label: hv.educacionLabel,
                              color: hv.educacionColor),
                        if (hv.totalSentenciasPenales > 0)
                          _Chip(icon: Icons.gavel_rounded,
                                label: '${hv.totalSentenciasPenales} penal${hv.totalSentenciasPenales > 1 ? "es" : ""}',
                                color: const Color(0xFFC62828)),
                        if (hv.totalSentenciasObligaciones > 0)
                          _Chip(icon: Icons.warning_amber_rounded,
                                label: '${hv.totalSentenciasObligaciones} oblig.',
                                color: Colors.orange),
                        if (hv.totalSentenciasPenales == 0 &&
                            hv.totalSentenciasObligaciones == 0)
                          _Chip(icon: Icons.verified_rounded,
                                label: 'Sin antecedentes',
                                color: const Color(0xFF2E7D32)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Logo + número de lista (derecha, horizontal) ──────────
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: PartyLogo(partyName: hv.partido, size: 36),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: proceso.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: proceso.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '#${c.posicion}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: proceso.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 16,
                  color: cs.onSurface.withValues(alpha: 0.25)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Score badge ──────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int rank;
  final HojaVida hv;

  const _ScoreBadge({required this.rank, required this.hv});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$rank',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35))),
        const SizedBox(height: 2),
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: hv.scoreBgColor,
            shape: BoxShape.circle,
            border: Border.all(color: hv.scoreColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${hv.scoreFinal}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: hv.scoreColor, height: 1)),
              Text('/105',
                style: TextStyle(fontSize: 7,
                    color: hv.scoreColor.withValues(alpha: 0.7), height: 1)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Foto o avatar ────────────────────────────────────────────────────────────

class _PhotoCircle extends StatelessWidget {
  final String? fotoUrl;
  final String nombre;
  final double size;

  const _PhotoCircle({required this.fotoUrl, required this.nombre, this.size = 44});

  String _initials() {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = size / 2;
    if (fotoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: NetworkImage(fotoUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(_initials(),
        style: TextStyle(fontSize: radius * 0.65, fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer)),
    );
  }
}

// ─── Chip de indicador ────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─── Widgets de estado ────────────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String error;
  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error al cargar datos', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(error, style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NoDataWidget extends StatelessWidget {
  final ProcesoElectoral proceso;
  const _NoDataWidget({required this.proceso});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 56, color: proceso.color),
            const SizedBox(height: 16),
            Text('Datos no disponibles aún',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Las hojas de vida de ${proceso.displayName} aún no han sido descargadas.\n\n'
              'Ejecuta el script descargar_hojas_vida_v2.py para obtener los datos '
              'del JNE y vuelve a compilar la app.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Diálogo de detalle ───────────────────────────────────────────────────────

void _showDetalle(BuildContext context, CandidatoConHV c, ProcesoElectoral proceso) {
  final hv    = c.hv;
  final theme = Theme.of(context);
  final cs    = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
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
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ─────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoCircle(fotoUrl: c.fotoUrl, nombre: hv.nombre, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hv.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(hv.partido,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6))),
                      if (c.cargo.isNotEmpty)
                        Text(c.cargo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: proceso.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          )),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: PartyLogo(partyName: hv.partido, size: 24)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: proceso.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: proceso.color.withValues(alpha: 0.3)),
                            ),
                            child: Text('#${c.posicion}',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold,
                                color: proceso.color)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Score grande
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: hv.scoreBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hv.scoreColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text('${hv.scoreFinal}',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                            color: hv.scoreColor, height: 1)),
                      Text(hv.scoreLabel,
                        style: TextStyle(fontSize: 9, color: hv.scoreColor,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Distrito / departamento
            if (c.departamento.isNotEmpty || c.tipoDistrito.isNotEmpty)
              _DetailRow(Icons.place_rounded,
                '${c.tipoDistrito.isNotEmpty ? "${c.tipoDistrito} · " : ""}${c.departamento}',
                cs.onSurface.withValues(alpha: 0.5)),

            const Divider(height: 20),

            // ── Educación ─────────────────────────────────────────────────
            _SectionTitle('EDUCACIÓN', proceso.color),
            _DetailRow(hv.educacionIcon, hv.educacionLabel, hv.educacionColor),
            if (hv.posgrados.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...hv.posgrados.map((p) => _BulletText(p)),
            ],
            if (hv.universidades.isNotEmpty) ...[
              const SizedBox(height: 2),
              ...hv.universidades.map((u) => _BulletText(u)),
            ],
            const Divider(height: 20),

            // ── Integridad Judicial ────────────────────────────────────────
            _SectionTitle('INTEGRIDAD JUDICIAL', proceso.color),
            _DetailRow(
              hv.totalSentenciasPenales == 0 ? Icons.check_circle_rounded : Icons.gavel_rounded,
              hv.totalSentenciasPenales == 0
                  ? 'Sin sentencias penales'
                  : '${hv.totalSentenciasPenales} sentencia(s) penal(es)',
              hv.totalSentenciasPenales == 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
            _DetailRow(
              hv.totalSentenciasObligaciones == 0 ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              hv.totalSentenciasObligaciones == 0
                  ? 'Sin sentencias de obligación'
                  : '${hv.totalSentenciasObligaciones} sentencia(s) de obligación',
              hv.totalSentenciasObligaciones == 0 ? const Color(0xFF2E7D32) : Colors.orange,
            ),
            const Divider(height: 20),

            // ── Experiencia Laboral ────────────────────────────────────────
            if (hv.experienciaLaboral.isNotEmpty) ...[
              _SectionTitle('EXPERIENCIA LABORAL', proceso.color),
              ...hv.experienciaLaboral.take(5).map((e) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.work_outline_rounded, size: 14,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e.resumen,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.75))),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
            ],

            // ── Cargos de Elección Popular ────────────────────────────────
            if (hv.cargosEleccionPopular.isNotEmpty) ...[
              _SectionTitle('CARGOS DE ELECCIÓN POPULAR', Colors.orange),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: hv.cargosEleccionPopular.take(5).map((cargo) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.how_to_vote_rounded, size: 13,
                              color: Colors.orange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${cargo.cargo}${cargo.entidad.isNotEmpty ? " — ${cargo.entidad}" : ""}${cargo.periodo.isNotEmpty ? " (${cargo.periodo})" : ""}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
              const Divider(height: 20),
            ],

            // ── Investigaciones y Controversias ───────────────────────────
            if (hv.investigacionesConocidas.isNotEmpty) ...[
              _SectionTitle('INVESTIGACIONES Y CONTROVERSIAS',
                  Colors.red.shade700),
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
                      child: Text(hv.investigacionesConocidas,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade800)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
            ],

            // ── Cargos Partidarios ─────────────────────────────────────────
            if (hv.cargosPartidarios.isNotEmpty) ...[
              _SectionTitle('CARGOS PARTIDARIOS', Colors.deepPurple),
              ...hv.cargosPartidarios.take(3).map((cargo) =>
                _DetailRow(Icons.groups_rounded,
                  '${cargo.cargo}${cargo.entidad.isNotEmpty ? " · ${cargo.entidad}" : ""}',
                  Colors.deepPurple),
              ),
              const Divider(height: 20),
            ],

            // ── Nota Adicional ─────────────────────────────────────────────
            if (hv.notaAdicional.isNotEmpty) ...[
              _SectionTitle('NOTA ADICIONAL', Colors.blueGrey),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.blueGrey.withValues(alpha: 0.2)),
                ),
                child: Text(hv.notaAdicional,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  )),
              ),
              const Divider(height: 20),
            ],

            // ── Ingresos declarados ────────────────────────────────────────
            _SectionTitle('INGRESOS DECLARADOS${hv.anioIngresos.isNotEmpty ? " (${hv.anioIngresos})" : ""}', const Color(0xFF1565C0)),
            _IngresosBienesCard(hv: hv, cs: cs, theme: theme),
            const Divider(height: 20),

            // ── Score breakdown ────────────────────────────────────────────
            _SectionTitle('DESGLOSE DEL PUNTAJE', proceso.color),
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
              _ScoreRow('Leyes pro-crimen (penalización)',
                  -hv.penaltyProCrimen, 0, Colors.deepOrange),
            if (hv.penaltyCargosPublicos > 0)
              _ScoreRow('Cargos públicos previos (penalización)',
                  -hv.penaltyCargosPublicos, 0, Colors.orange),
            if (hv.penaltyInvestigaciones > 0)
              _ScoreRow('Investigaciones/controversias (penalización)',
                  -hv.penaltyInvestigaciones, 0, Colors.red.shade700),
            if (hv.penaltyReinfo > 0)
              _ScoreRow('Vinculado a minería informal REINFO (penalización)',
                  -hv.penaltyReinfo, 0, const Color(0xFF7B1FA2)),
            if (hv.penaltyUniversidadCuestionada > 0)
              _ScoreRow('Universidad con licencia denegada (penalización)',
                  -hv.penaltyUniversidadCuestionada, 0, Colors.brown.shade700),
            if (hv.bonusUniversidadElite > 0)
              _ScoreRow('Universidad de élite reconocida (bonus)',
                  hv.bonusUniversidadElite, 5, const Color(0xFF1565C0)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hv.scoreBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hv.scoreColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Puntaje total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                  Text('${hv.scoreFinal} / 100',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16, color: hv.scoreColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Enlace al JNE ──────────────────────────────────────────────
            _JneLink(hv: hv),
            const SizedBox(height: 12),

            // ── Nota legal ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14,
                      color: cs.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Puntaje calculado con datos públicos del JNE. Esta información '
                      'es orientativa y no constituye una acusación formal ni una '
                      'recomendación de voto. Verifica siempre en la fuente oficial.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Helpers para el diálogo ──────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color, fontWeight: FontWeight.w500)),
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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
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
    final pct = maxScore > 0 ? score / maxScore : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
              style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$score/$maxScore',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: color)),
        ],
      ),
    );
  }
}

// ─── Ingresos y Bienes Declarados ────────────────────────────────────────────

class _IngresosBienesCard extends StatelessWidget {
  final HojaVida hv;
  final ColorScheme cs;
  final ThemeData theme;

  const _IngresosBienesCard({
    required this.hv,
    required this.cs,
    required this.theme,
  });

  String _formatMoney(double v) {
    if (v == 0) return 'S/ 0';
    if (v >= 1000000) return 'S/ ${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000)    return 'S/ ${(v / 1000).toStringAsFixed(1)}K';
    return 'S/ ${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ingresos ─────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 14,
                  color: Color(0xFF1565C0)),
              const SizedBox(width: 6),
              Text('Ingreso total declarado',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55))),
              const Spacer(),
              Text(_formatMoney(hv.ingresoTotal),
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1565C0))),
            ],
          ),
          if (hv.ingresoPublico > 0 || hv.ingresoPrivado > 0) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: [
                  if (hv.ingresoPublico > 0)
                    _subRow('Sector público', _formatMoney(hv.ingresoPublico),
                        theme, cs),
                  if (hv.ingresoPrivado > 0)
                    _subRow('Sector privado', _formatMoney(hv.ingresoPrivado),
                        theme, cs),
                ],
              ),
            ),
          ],
          const Divider(height: 14),
          // ── Bienes ───────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.home_rounded, size: 14,
                  color: Color(0xFF00695C)),
              const SizedBox(width: 6),
              Text('Inmuebles declarados',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55))),
              const Spacer(),
              Text('${hv.numInmuebles} inmueble${hv.numInmuebles != 1 ? "s" : ""}',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00695C))),
            ],
          ),
          if (hv.valorInmuebles > 0) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _subRow('Valor total', _formatMoney(hv.valorInmuebles),
                  theme, cs),
            ),
          ],
          if (hv.numVehiculos > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.directions_car_rounded, size: 14,
                    color: Color(0xFF6A1B9A)),
                const SizedBox(width: 6),
                Text('Vehículos declarados',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55))),
                const Spacer(),
                Text('${hv.numVehiculos} vehículo${hv.numVehiculos != 1 ? "s" : ""}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6A1B9A))),
              ],
            ),
          ],
          if (hv.ingresoTotal == 0 && hv.numInmuebles == 0 &&
              hv.numVehiculos == 0)
            Text('No se declararon ingresos ni bienes.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.45),
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _subRow(String label, String value, ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label:',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45), fontSize: 10)),
          const Spacer(),
          Text(value,
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65), fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Enlace al portal JNE ─────────────────────────────────────────────────────

class _JneLink extends StatelessWidget {
  final HojaVida hv;
  const _JneLink({required this.hv});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(hv.jneHvUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el portal del JNE')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ver en el portal oficial del JNE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
                  Text('Verifica esta información en la fuente oficial',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.blue.withValues(alpha: 0.7),
                    )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12,
                color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
