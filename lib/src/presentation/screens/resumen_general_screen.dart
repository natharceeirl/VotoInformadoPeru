import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ─── Pantalla Resumen General ─────────────────────────────────────────────────

class ResumenGeneralScreen extends ConsumerStatefulWidget {
  const ResumenGeneralScreen({super.key});

  @override
  ConsumerState<ResumenGeneralScreen> createState() =>
      _ResumenGeneralScreenState();
}

class _ResumenGeneralScreenState extends ConsumerState<ResumenGeneralScreen> {
  static const _procesos = [
    ProcesoElectoral.presidentes,
    ProcesoElectoral.senadores,
    ProcesoElectoral.diputados,
    ProcesoElectoral.parlamentoAndino,
  ];

  String _norm(String s) {
    var r = s.toUpperCase();
    r = r
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
    r = r.replaceAll(',', '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final excluir = ref.watch(excluirPartidosRiesgoProvider);
    final porEstosNo = ref.watch(porEstosNoProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Resumen General'),
        centerTitle: true,
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App logo + descripción ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          'Voto Informado Perú',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Vista consolidada de los candidatos con mejor perfil de integridad '
                    'en los 4 procesos electorales de 2026.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Banner de filtro ───────────────────────────────────────────
            _FilterBanner(norm: _norm),
            const SizedBox(height: 12),

            // ── Información general ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF37474F).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF37474F).withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF37474F), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El puntaje de integridad combina nivel educativo, antecedentes '
                      'judiciales, cumplimiento de obligaciones y penalizaciones por '
                      'leyes pro-crimen o investigaciones documentadas.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Secciones por proceso ──────────────────────────────────────
            for (final proceso in _procesos) ...[
              _ProcesoSection(
                proceso: proceso,
                excluir: excluir,
                porEstosNo: porEstosNo,
                norm: _norm,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Banner de filtro expandible con chips de partidos ────────────────────────

class _FilterBanner extends ConsumerStatefulWidget {
  final String Function(String) norm;
  const _FilterBanner({required this.norm});

  @override
  ConsumerState<_FilterBanner> createState() => _FilterBannerState();
}

class _FilterBannerState extends ConsumerState<_FilterBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final excluir = ref.watch(excluirPartidosRiesgoProvider);
    final detalleAsync = ref.watch(porEstosNoDetalleProvider);
    final detalle = detalleAsync.asData?.value ?? [];

    return GestureDetector(
      onTap: () => _showPorEstosNoDialog(context, detalle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: excluir ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: excluir ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: excluir
                        ? Colors.orange.shade700
                        : Colors.grey.shade400,
                    size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    excluir
                        ? 'Filtrando partidos con riesgo de corrupción:'
                        : 'Mostrando todos los partidos — toca para filtrar por riesgo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: excluir ? FontWeight.w600 : FontWeight.normal,
                      color: excluir
                          ? Colors.orange.shade800
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (excluir && detalle.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => _expanded = !_expanded);
                    },
                    child: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                Switch.adaptive(
                  value: excluir,
                  onChanged: (_) {
                    ref
                        .read(excluirPartidosRiesgoProvider.notifier)
                        .toggle();
                    if (!excluir) setState(() => _expanded = false);
                  },
                  activeThumbColor: Colors.orange.shade700,
                  activeTrackColor: Colors.orange.shade300,
                ),
              ],
            ),
            if (excluir && _expanded && detalle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: detalle.map((p) {
                  final nombre =
                      (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel =
                      (p['nivel_riesgo'] as String? ?? '').toLowerCase();
                  final isAlto = nivel == 'alto';
                  final chipColor =
                      isAlto ? Colors.red.shade600 : Colors.orange.shade700;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: chipColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      nombre,
                      style: TextStyle(
                          fontSize: 10,
                          color: chipColor,
                          fontWeight: FontWeight.w600),
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

  void _showPorEstosNoDialog(
      BuildContext ctx, List<Map<String, dynamic>> detalle) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('#PorEstosNo', style: TextStyle(fontSize: 16)),
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
                  final nombre =
                      (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel =
                      (p['nivel_riesgo'] as String? ?? '').toUpperCase();
                  final indice =
                      (p['indice_riesgo_corrupcion'] as num?)?.toDouble() ??
                          0.0;
                  final isAlto = nivel == 'ALTO';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle,
                            size: 6,
                            color: isAlto
                                ? Colors.red.shade700
                                : Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      ' — $nivel (${indice.toStringAsFixed(2)})',
                                  style: TextStyle(
                                    color: isAlto
                                        ? Colors.red.shade700
                                        : Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                const SizedBox(height: 4),
              ],
              Text(
                'Al activar el filtro, los candidatos de estos partidos '
                'no se muestran en el resumen. Puedes desactivarlo en cualquier momento.\n\n'
                'Información orientativa — no constituye acusación formal.',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Entendido')),
        ],
      ),
    );
  }
}

// ─── Sección por proceso electoral ────────────────────────────────────────────

class _ProcesoSection extends ConsumerWidget {
  final ProcesoElectoral proceso;
  final bool excluir;
  final List<String> porEstosNo;
  final String Function(String) norm;

  const _ProcesoSection({
    required this.proceso,
    required this.excluir,
    required this.porEstosNo,
    required this.norm,
  });

  String get _label {
    switch (proceso) {
      case ProcesoElectoral.presidentes:
        return 'Presidente y Vicepresidentes';
      case ProcesoElectoral.senadores:
        return 'Senadores 2026';
      case ProcesoElectoral.diputados:
        return 'Diputados 2026';
      case ProcesoElectoral.parlamentoAndino:
        return 'Parlamento Andino';
    }
  }

  String get _explanation {
    switch (proceso) {
      case ProcesoElectoral.presidentes:
        return 'Los candidatos se ordenan por su perfil de integridad. '
            'La plancha completa refleja el puntaje del candidato presidencial.';
      case ProcesoElectoral.senadores:
        return 'Se eligen 60 senadores. Se muestran los 10 candidatos individuales '
            'con mejor perfil de integridad.';
      case ProcesoElectoral.diputados:
        return 'Se eligen 130 diputados. Se muestran los 10 candidatos individuales '
            'con mejor perfil de integridad.';
      case ProcesoElectoral.parlamentoAndino:
        return 'Se eligen 5 representantes. Se muestran los 10 candidatos con '
            'mejor perfil de integridad.';
    }
  }

  String _statsLabel(int total) {
    switch (proceso) {
      case ProcesoElectoral.presidentes:
        return 'De $total candidatos • Se presentan fórmulas de 3 integrantes';
      case ProcesoElectoral.senadores:
        return 'De $total candidatos, se eligen 60 escaños';
      case ProcesoElectoral.diputados:
        return 'De $total candidatos, se eligen 130 escaños';
      case ProcesoElectoral.parlamentoAndino:
        return 'De $total candidatos, se eligen 5 escaños';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = proceso.color;
    final icon = proceso.icon;
    final async = ref.watch(candidatosConHVProcesoProvider(proceso));

    return async.when(
      loading: () => _buildShell(
        color: color,
        icon: icon,
        totalCount: null,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => _buildShell(
        color: color,
        icon: icon,
        totalCount: null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error al cargar datos: $e',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (todos) {
        var lista = todos;
        if (excluir && porEstosNo.isNotEmpty) {
          lista = lista
              .where((c) => !porEstosNo.contains(norm(c.hv.partido)))
              .toList();
        }

        Widget content;
        if (proceso == ProcesoElectoral.presidentes) {
          content = _buildPlanchasSection(context, lista);
        } else {
          lista.sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
          final top = lista.take(10).toList();
          if (top.isEmpty) {
            content = Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No hay candidatos disponibles',
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          } else {
            content = Column(
              children: top
                  .asMap()
                  .entries
                  .map((e) => _buildCandidatoRow(
                      context, e.key + 1, e.value, color, proceso))
                  .toList(),
            );
          }
        }

        return _buildShell(
          color: color,
          icon: icon,
          totalCount: todos.length,
          child: content,
        );
      },
    );
  }

  Widget _buildShell({
    required Color color,
    required IconData icon,
    required int? totalCount,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800),
              ),
            ),
            if (totalCount != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount candidatos',
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Estadísticas contextuales
        if (totalCount != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 14, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _statsLabel(totalCount),
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        // Explicación
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            _explanation,
            style:
                TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
          ),
        ),

        // Contenido
        child,
      ],
    );
  }

  Widget _buildPlanchasSection(
      BuildContext context, List<CandidatoConHV> lista) {
    // Agrupar por partido
    final Map<String, List<CandidatoConHV>> byPartido = {};
    for (final c in lista) {
      byPartido.putIfAbsent(c.hv.partido, () => []).add(c);
    }

    // Construir planchas: cada partido tiene presidente (pos 1), VP1 (pos 2), VP2 (pos 3)
    final planchas = <_Plancha>[];
    for (final entry in byPartido.entries) {
      final miembros = entry.value;
      CandidatoConHV? pres;
      CandidatoConHV? vp1;
      CandidatoConHV? vp2;
      for (final c in miembros) {
        if (c.posicion == 1) pres = c;
        if (c.posicion == 2) vp1 = c;
        if (c.posicion == 3) vp2 = c;
      }
      if (pres != null) {
        planchas.add(_Plancha(
          partido: entry.key,
          presidente: pres,
          vp1: vp1,
          vp2: vp2,
        ));
      }
    }

    // Ordenar por puntaje del presidente
    planchas
        .sort((a, b) => b.presidente.hv.scoreFinal.compareTo(a.presidente.hv.scoreFinal));

    final top5 = planchas.take(5).toList();

    if (top5.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No hay planchas disponibles',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }

    return Column(
      children: top5
          .asMap()
          .entries
          .map((e) => _buildPlanchaCard(context, e.key + 1, e.value))
          .toList(),
    );
  }

  Widget _buildPlanchaCard(BuildContext context, int rank, _Plancha plancha) {
    final color = proceso.color;
    final pres = plancha.presidente;
    final score = pres.hv.scoreFinal;

    return GestureDetector(
      onTap: () => _showResumenDetalle(context, pres, proceso),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de plancha
            Row(
              children: [
                // Rank badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? color.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? color : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PartyLogo(partyName: plancha.partido, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plancha.partido,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Score chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pres.hv.scoreColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: pres.hv.scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: pres.hv.scoreColor,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                            fontSize: 8,
                            color: pres.hv.scoreColor.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Miembros de la plancha
            _planchaMemberRow(plancha.presidente, 'Presidente/a'),
            if (plancha.vp1 != null) ...[
              const SizedBox(height: 6),
              _planchaMemberRow(plancha.vp1!, '1er Vicepresidente/a'),
            ],
            if (plancha.vp2 != null) ...[
              const SizedBox(height: 6),
              _planchaMemberRow(plancha.vp2!, '2do Vicepresidente/a'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _planchaMemberRow(CandidatoConHV c, String cargoLabel) {
    final nombre = c.hv.nombre;
    final fotoUrl = c.fotoUrl;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              fotoUrl != null ? NetworkImage(fotoUrl) : null,
          child: fotoUrl == null
              ? Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                cargoLabel,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidatoRow(BuildContext context, int rank,
      CandidatoConHV candidato, Color color, ProcesoElectoral proceso) {
    final hv = candidato.hv;
    final fotoUrl = candidato.fotoUrl;
    final nombre = hv.nombre;

    return GestureDetector(
      onTap: () => _showResumenDetalle(context, candidato, proceso),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? color.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? color : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Foto
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null
                  ? Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 8),

            // Logo partido
            PartyLogo(partyName: hv.partido, size: 24),
            const SizedBox(width: 8),

            // Nombre, partido, depto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          hv.partido,
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (candidato.departamento.isNotEmpty) ...[
                        Text(' · ',
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey.shade400)),
                        Flexible(
                          child: Text(
                            candidato.departamento,
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Posición chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '#${candidato.posicion}',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 6),

            // Score chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: hv.scoreColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: hv.scoreColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '${hv.scoreFinal}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hv.scoreColor,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                        fontSize: 7,
                        color: hv.scoreColor.withValues(alpha: 0.7)),
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

// ─── Modelo interno: Plancha presidencial ─────────────────────────────────────

class _Plancha {
  final String partido;
  final CandidatoConHV presidente;
  final CandidatoConHV? vp1;
  final CandidatoConHV? vp2;

  const _Plancha({
    required this.partido,
    required this.presidente,
    this.vp1,
    this.vp2,
  });
}

// ─── Bottom sheet de detalle básico (inline, sin depender de _showDetalle) ────

void _showResumenDetalle(
    BuildContext context, CandidatoConHV c, ProcesoElectoral proceso) {
  final hv = c.hv;
  final fotoUrl = c.fotoUrl;
  final nombre = hv.nombre;
  final color = proceso.color;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Foto + nombre + partido
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      fotoUrl != null ? NetworkImage(fotoUrl) : null,
                  child: fotoUrl == null
                      ? Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          PartyLogo(partyName: hv.partido, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hv.partido,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (c.cargo.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          c.cargo,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Score chip centrado
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: hv.scoreBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: hv.scoreColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${hv.scoreFinal}/100',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: hv.scoreColor,
                      ),
                    ),
                    Text(
                      hv.scoreLabel,
                      style: TextStyle(
                          fontSize: 13, color: hv.scoreColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Educación
            _DetailRow(
              icon: Icons.school_rounded,
              color: color,
              label: 'Educación',
              value: hv.educacionLabel,
            ),
            const SizedBox(height: 8),

            // Partido + posición
            _DetailRow(
              icon: Icons.how_to_vote_rounded,
              color: color,
              label: 'Posición en lista',
              value: '#${c.posicion}',
            ),
            if (c.departamento.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.location_on_rounded,
                color: color,
                label: 'Circunscripción',
                value: c.departamento,
              ),
            ],
            const SizedBox(height: 20),

            // Nota
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para ver el perfil completo, accede desde "Conoce tu Candidato".',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
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

// ─── Widget auxiliar para filas de detalle ────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
