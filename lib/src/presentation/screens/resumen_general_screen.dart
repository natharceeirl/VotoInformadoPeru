import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import 'credits_screen.dart';

// ── Colors ────────────────────────────────────────────────────────────────────

const _navy = Color(0xFF1E3A5F);

// ── Helpers ───────────────────────────────────────────────────────────────────

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

// ── Main screen ───────────────────────────────────────────────────────────────

class ResumenGeneralScreen extends ConsumerWidget {
  const ResumenGeneralScreen({super.key});

  static const _procesos = [
    ProcesoElectoral.presidentes,
    ProcesoElectoral.senadores,
    ProcesoElectoral.diputados,
    ProcesoElectoral.parlamentoAndino,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excluir = ref.watch(excluirPartidosRiesgoProvider);
    final porEstosNo = ref.watch(porEstosNoProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        title: const Text('Resumen General',
            style: TextStyle(
                color: _navy, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navy),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App brand header ─────────────────────────────────────────
            const AppBrandHeader(),

            // ── Descripción ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: _navy.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _navy, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vista consolidada de candidatos con mejor perfil de integridad '
                      'en los 4 procesos electorales de 2026. '
                      'El puntaje combina educación, antecedentes judiciales, '
                      'cumplimiento de obligaciones y penalizaciones por '
                      'vínculos con corrupción o leyes pro-crimen.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filtro #PorEstosNo ────────────────────────────────────────
            _FilterBanner(),
            const SizedBox(height: 20),

            // ── Voto estratégico ─────────────────────────────────────────
            _StrategicVoteSection(
                excluir: excluir, porEstosNo: porEstosNo),
            const SizedBox(height: 24),

            // ── Secciones por proceso ────────────────────────────────────
            for (final proceso in _procesos) ...[
              _ProcesoSection(
                proceso: proceso,
                excluir: excluir,
                porEstosNo: porEstosNo,
              ),
              const SizedBox(height: 24),
            ],

            // ── Footer ───────────────────────────────────────────────────
            const CreditsFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Filter banner ─────────────────────────────────────────────────────────────

class _FilterBanner extends ConsumerStatefulWidget {
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

    final activeColor = Colors.red.shade700;
    final activeBg = Colors.red.shade50;
    final activeBorder = Colors.red.shade300;

    return GestureDetector(
      onTap: () => _showDialog(context, detalle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: excluir ? activeBg : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: excluir ? activeBorder : Colors.grey.shade300,
            width: excluir ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.block_rounded,
                  color: excluir ? activeColor : Colors.grey.shade400,
                  size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  excluir
                      ? '#PorEstosNo — Filtrando ${detalle.length} partidos con riesgo de corrupción'
                      : 'Mostrando todos los partidos · Activa #PorEstosNo para filtrar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        excluir ? FontWeight.w600 : FontWeight.normal,
                    color: excluir ? activeColor : Colors.grey.shade600,
                  ),
                ),
              ),
              if (excluir && detalle.isNotEmpty)
                GestureDetector(
                  onTap: () =>
                      setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: activeColor,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 4),
              // Red toggle switch
              Switch.adaptive(
                value: excluir,
                onChanged: (_) {
                  ref
                      .read(excluirPartidosRiesgoProvider.notifier)
                      .toggle();
                  if (!excluir) setState(() => _expanded = false);
                },
                activeThumbColor: activeColor,
                activeTrackColor: Colors.red.shade200,
              ),
            ]),
            if (excluir && _expanded && detalle.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: detalle.map((p) {
                  final nombre =
                      (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel = (p['nivel_riesgo'] as String? ?? '')
                      .toLowerCase();
                  final isAlto = nivel == 'alto';
                  final chipColor = isAlto
                      ? Colors.red.shade700
                      : Colors.orange.shade700;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: chipColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PartyLogo(partyName: nombre, size: 16),
                        const SizedBox(width: 5),
                        Text(nombre,
                            style: TextStyle(
                                fontSize: 10,
                                color: chipColor,
                                fontWeight: FontWeight.w600)),
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

  void _showDialog(BuildContext ctx, List<Map<String, dynamic>> detalle) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Row(children: const [
          Icon(Icons.block_rounded, color: Colors.red),
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
                  final nivel = (p['nivel_riesgo'] as String? ?? '')
                      .toUpperCase();
                  final indice =
                      (p['indice_riesgo_corrupcion'] as num?)
                              ?.toDouble() ??
                          0.0;
                  final isAlto = nivel == 'ALTO';
                  final chipColor = isAlto
                      ? Colors.red.shade700
                      : Colors.orange.shade700;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PartyLogo(partyName: nombre, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                              Text(
                                '$nivel · índice ${indice.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: chipColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
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
                'no aparecen en el resumen.\n\n'
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

// ── Strategic vote section ────────────────────────────────────────────────────

class _StrategicVoteSection extends ConsumerStatefulWidget {
  final bool excluir;
  final List<String> porEstosNo;

  const _StrategicVoteSection(
      {required this.excluir, required this.porEstosNo});

  @override
  ConsumerState<_StrategicVoteSection> createState() =>
      _StrategicVoteSectionState();
}

class _StrategicVoteSectionState
    extends ConsumerState<_StrategicVoteSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dipAsync = ref.watch(
        candidatosConHVProcesoProvider(ProcesoElectoral.diputados));
    final senAsync = ref.watch(
        candidatosConHVProcesoProvider(ProcesoElectoral.senadores));

    final loading = dipAsync.isLoading || senAsync.isLoading;
    final dipList = dipAsync.asData?.value ?? [];
    final senList = senAsync.asData?.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tap
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voto Estratégico — Valla Electoral',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
                      Text('¿Tu voto puede quedar sin efecto?',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: const Color(0xFF1565C0)),
              ]),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reglas de la valla
                  _vallaRulesCard(),
                  const SizedBox(height: 14),

                  if (loading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  else ...[
                    _buildViabilityBlock(
                        'Diputados',
                        dipList,
                        widget.excluir,
                        widget.porEstosNo,
                        const Color(0xFF1B4F72),
                        Icons.account_balance_rounded),
                    const SizedBox(height: 12),
                    _buildViabilityBlock(
                        'Senadores',
                        senList,
                        widget.excluir,
                        widget.porEstosNo,
                        const Color(0xFF154360),
                        Icons.gavel_rounded),
                  ],

                  const SizedBox(height: 14),
                  // Nota metodológica
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Estimación basada en el número de candidatos inscritos como '
                            'indicador de capacidad organizacional del partido. '
                            'Sin datos de encuestas — usa como orientación, no como certeza.',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _vallaRulesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFF1565C0).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Qué es la valla electoral?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 8),
          const Text(
            'Para que los votos a un partido se conviertan en escaños, '
            'ese partido debe superar la valla electoral. Si no la supera, '
            'los votos dados a ese partido no se convierten en representación — '
            'se pierden en el cálculo de distribución de escaños.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 10),
          _vallaRule(
            'Cámara de Diputados',
            '• Al menos 5% de los votos válidos a nivel nacional, O\n'
                '• Alcanzar como mínimo 7 escaños.',
            const Color(0xFF1B4F72),
          ),
          const SizedBox(height: 6),
          _vallaRule(
            'Cámara de Senadores',
            '• Al menos 5% de los votos válidos en elección senatorial, O\n'
                '• Lograr al menos 3 senadores.',
            const Color(0xFF154360),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              '⚠ Los votos cruzados (partido diferente en cada sección) son válidos, '
              'pero si el partido al que votas no supera la valla, '
              'ese voto no genera escaños.',
              style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF6D4C00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vallaRule(String title, String rules, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(rules,
              style: const TextStyle(fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildViabilityBlock(
    String title,
    List<CandidatoConHV> candidatos,
    bool excluir,
    List<String> porEstosNo,
    Color color,
    IconData icon,
  ) {
    // Compute party candidate counts (proxy for organizational strength)
    final Map<String, int> partyCount = {};
    for (final c in candidatos) {
      partyCount[c.hv.partido] = (partyCount[c.hv.partido] ?? 0) + 1;
    }
    if (partyCount.isEmpty) return const SizedBox.shrink();

    // Sort parties by candidate count descending
    final sorted = partyCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.length;
    // Classify: top 1/3 verde, mid 1/3 amarillo, bottom 1/3 rojo
    final verde = (total / 3).ceil();
    final amarillo = (total / 3).ceil();

    // Identify recommended parties: verde + not in PorEstosNo
    final recommended = sorted.take(verde).where((e) {
      if (!excluir) return true;
      final n = _norm(e.key);
      return !porEstosNo.any(
          (p) => n == p || n.contains(p) || p.contains(n));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ]),
        const SizedBox(height: 8),
        // Zones
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _viabilityZone(
              'Probable pase',
              Icons.check_circle_rounded,
              Colors.green.shade600,
              Colors.green.shade50,
              Colors.green.shade200,
              sorted.take(verde).toList(),
              porEstosNo,
              excluir,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _viabilityZone(
              'En riesgo',
              Icons.warning_rounded,
              Colors.orange.shade700,
              Colors.orange.shade50,
              Colors.orange.shade200,
              sorted.skip(verde).take(amarillo).toList(),
              porEstosNo,
              excluir,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _viabilityZone(
              'Difícil pase',
              Icons.cancel_rounded,
              Colors.red.shade600,
              Colors.red.shade50,
              Colors.red.shade200,
              sorted.skip(verde + amarillo).toList(),
              porEstosNo,
              excluir,
            ),
          ),
        ]),
        if (recommended.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '✓ Partidos con mayor probabilidad de superar la valla${excluir ? ' (excluyendo #PorEstosNo)' : ''}:',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recommended.take(6).map((e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PartyLogo(partyName: e.key, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _shortName(e.key),
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade800),
                      ),
                      const SizedBox(width: 4),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _viabilityZone(
    String label,
    IconData icon,
    Color color,
    Color bgColor,
    Color borderColor,
    List<MapEntry<String, int>> parties,
    List<String> porEstosNo,
    bool excluir,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ),
          ]),
          const SizedBox(height: 4),
          ...parties.take(5).map((e) {
            final isExcluido = excluir &&
                porEstosNo.any((p) {
                  final n = _norm(e.key);
                  return n == p || n.contains(p) || p.contains(n);
                });
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PartyLogo(partyName: e.key, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _shortName(e.key),
                      style: TextStyle(
                          fontSize: 9,
                          color: isExcluido
                              ? Colors.grey
                              : color.withValues(alpha: 0.8),
                          decoration: isExcluido
                              ? TextDecoration.lineThrough
                              : null),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (parties.length > 5)
            Text('+${parties.length - 5} más',
                style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  String _shortName(String name) {
    const abbreviations = {
      'ALIANZA PARA EL PROGRESO': 'APP',
      'PARTIDO POLITICO NACIONAL PERU LIBRE': 'Perú Libre',
      'JUNTOS POR EL PERU': 'JPP',
      'RENOVACION POPULAR': 'Renov. Pop.',
      'FUERZA POPULAR': 'Fuerza Pop.',
      'AVANZA PAIS': 'Avanza País',
      'PODEMOS PERU': 'Podemos',
      'SOMOS PERU': 'Somos Perú',
      'PARTIDO APRISTA PERUANO': 'APRA',
      'PARTIDO MORADO': 'P. Morado',
    };
    final upper = name.toUpperCase();
    for (final entry in abbreviations.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }
    // If long, take first 12 chars
    return name.length > 14 ? '${name.substring(0, 12)}…' : name;
  }
}

// ── Sección por proceso electoral ─────────────────────────────────────────────

class _ProcesoSection extends ConsumerWidget {
  final ProcesoElectoral proceso;
  final bool excluir;
  final List<String> porEstosNo;

  const _ProcesoSection({
    required this.proceso,
    required this.excluir,
    required this.porEstosNo,
  });

  bool _isExcluido(String partido) {
    if (!excluir || porEstosNo.isEmpty) return false;
    final n = _norm(partido);
    return porEstosNo.any(
        (p) => n == p || n.contains(p) || p.contains(n));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = proceso.color;
    final icon = proceso.icon;
    final async = ref.watch(candidatosConHVProcesoProvider(proceso));

    return async.when(
      loading: () => _shell(color, icon, null,
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))),
      error: (e, _) => _shell(color, icon, null,
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e',
                  style: const TextStyle(color: Colors.red)))),
      data: (todos) {
        var lista = todos
            .where((c) => !_isExcluido(c.hv.partido))
            .toList();

        if (proceso == ProcesoElectoral.presidentes) {
          return _shell(color, icon, todos.length,
              _buildPlanchas(context, lista));
        }

        if (proceso == ProcesoElectoral.senadores) {
          return _shell(color, icon, todos.length,
              _buildSenadores(context, lista, color));
        }

        // Diputados y Parlamento Andino: top 10 por score
        lista.sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
        final top = lista.take(10).toList();
        if (top.isEmpty) {
          return _shell(color, icon, todos.length,
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No hay candidatos disponibles',
                      style: TextStyle(color: Colors.grey.shade500))));
        }
        return _shell(
          color,
          icon,
          todos.length,
          Column(
            children: top
                .asMap()
                .entries
                .map((e) =>
                    _candidatoRow(context, e.key + 1, e.value, color))
                .toList(),
          ),
        );
      },
    );
  }

  // ── Senadores: split by tipoDistrito ─────────────────────────────────────

  Widget _buildSenadores(
      BuildContext context, List<CandidatoConHV> lista, Color color) {
    final unicos =
        lista.where((c) => c.tipoDistrito == 'ÚNICO').toList()
          ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
    final multiples =
        lista.where((c) => c.tipoDistrito == 'MÚLTIPLE').toList()
          ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subSection(
          context,
          'Senadores Nacionales — Distrito Único',
          '30 escaños elegidos a nivel nacional',
          unicos.take(10).toList(),
          color,
          Icons.public_rounded,
        ),
        const SizedBox(height: 16),
        _subSection(
          context,
          'Senadores Regionales — Distrito Múltiple',
          '30 escaños distribuidos por departamento',
          multiples.take(10).toList(),
          color,
          Icons.map_rounded,
        ),
      ],
    );
  }

  Widget _subSection(
    BuildContext context,
    String title,
    String subtitle,
    List<CandidatoConHV> candidatos,
    Color color,
    IconData subIcon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(subIcon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        if (candidatos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('No hay candidatos disponibles',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500)),
          )
        else
          ...candidatos.asMap().entries.map((e) =>
              _candidatoRow(context, e.key + 1, e.value, color)),
      ],
    );
  }

  // ── Planchas presidenciales ───────────────────────────────────────────────

  Widget _buildPlanchas(
      BuildContext context, List<CandidatoConHV> lista) {
    final Map<String, List<CandidatoConHV>> byPartido = {};
    for (final c in lista) {
      byPartido.putIfAbsent(c.hv.partido, () => []).add(c);
    }

    final planchas = <_Plancha>[];
    for (final entry in byPartido.entries) {
      CandidatoConHV? pres, vp1, vp2;
      for (final c in entry.value) {
        if (c.posicion == 1) pres = c;
        if (c.posicion == 2) vp1 = c;
        if (c.posicion == 3) vp2 = c;
      }
      if (pres != null) {
        planchas.add(_Plancha(
            partido: entry.key, presidente: pres, vp1: vp1, vp2: vp2));
      }
    }

    // Sort by AVERAGE score of the plancha
    double avg(_Plancha p) {
      final members = <CandidatoConHV>[
        p.presidente,
        if (p.vp1 != null) p.vp1!,
        if (p.vp2 != null) p.vp2!,
      ];
      return members.fold(0.0, (s, m) => s + m.hv.scoreFinal) /
          members.length;
    }

    planchas.sort((a, b) => avg(b).compareTo(avg(a)));
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
          .map((e) =>
              _planchaCard(context, e.key + 1, e.value, avg(e.value)))
          .toList(),
    );
  }

  Widget _planchaCard(BuildContext context, int rank, _Plancha plancha,
      double avgScore) {
    final color = proceso.color;
    final pres = plancha.presidente;
    final avgRounded = avgScore.round();

    return GestureDetector(
      onTap: () => _showHV(context, pres),
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
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // Rank
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: rank <= 3
                        ? color.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle),
                child: Center(
                  child: Text('$rank',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 ? color : Colors.grey.shade500)),
                ),
              ),
              const SizedBox(width: 10),
              PartyLogo(partyName: plancha.partido, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(plancha.partido,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              // Average score chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pres.hv.scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: pres.hv.scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(children: [
                  Text('$avgRounded',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: pres.hv.scoreColor)),
                  Text('prom.',
                      style: TextStyle(
                          fontSize: 8,
                          color: pres.hv.scoreColor
                              .withValues(alpha: 0.7))),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _memberRow(plancha.presidente, 'Presidente/a', true, context),
            if (plancha.vp1 != null) ...[
              const SizedBox(height: 6),
              _memberRow(plancha.vp1!, '1er Vicepresidente/a', true,
                  context),
            ],
            if (plancha.vp2 != null) ...[
              const SizedBox(height: 6),
              _memberRow(plancha.vp2!, '2do Vicepresidente/a', true,
                  context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _memberRow(CandidatoConHV c, String label, bool tappable,
      BuildContext context) {
    return GestureDetector(
      onTap: tappable ? () => _showHV(context, c) : null,
      child: Row(children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              c.fotoUrl != null ? NetworkImage(c.fotoUrl!) : null,
          child: c.fotoUrl == null
              ? Text(
                  c.hv.nombre.isNotEmpty
                      ? c.hv.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.hv.nombre,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(label,
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: c.hv.scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('${c.hv.scoreFinal}',
              style: TextStyle(
                  fontSize: 10,
                  color: c.hv.scoreColor,
                  fontWeight: FontWeight.bold)),
        ),
        if (tappable) ...[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              size: 14, color: Colors.grey.shade400),
        ],
      ]),
    );
  }

  // ── Candidato row (non-presidente) ────────────────────────────────────────

  Widget _candidatoRow(BuildContext context, int rank,
      CandidatoConHV candidato, Color color) {
    final hv = candidato.hv;
    final fotoUrl = candidato.fotoUrl;
    final nombre = hv.nombre;

    return GestureDetector(
      onTap: () => _showHV(context, candidato),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          // Rank
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
                color: rank <= 3
                    ? color.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                shape: BoxShape.circle),
            child: Center(
              child: Text('$rank',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? color : Colors.grey.shade500)),
            ),
          ),
          const SizedBox(width: 8),
          // Photo
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                fotoUrl != null ? NetworkImage(fotoUrl) : null,
            child: fotoUrl == null
                ? Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 8),
          // Logo
          PartyLogo(partyName: hv.partido, size: 24),
          const SizedBox(width: 8),
          // Name + party
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Row(children: [
                  Flexible(
                    child: Text(hv.partido,
                        style: TextStyle(
                            fontSize: 9, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (candidato.departamento.isNotEmpty) ...[
                    Text(' · ',
                        style: TextStyle(
                            fontSize: 9, color: Colors.grey.shade400)),
                    Flexible(
                      child: Text(candidato.departamento,
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // #pos
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300)),
            child: Text('#${candidato.posicion}',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 6),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: hv.scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: hv.scoreColor.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text('${hv.scoreFinal}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hv.scoreColor)),
              Text('/105',
                  style: TextStyle(
                      fontSize: 7,
                      color: hv.scoreColor.withValues(alpha: 0.7))),
            ]),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  // ── Shell ─────────────────────────────────────────────────────────────────

  Widget _shell(Color color, IconData icon, int? totalCount, Widget child) {
    final label = _sectionLabel;
    final explanation = _sectionExplanation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
          ),
          if (totalCount != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$totalCount cand.',
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(explanation,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.4)),
        ),
        child,
      ],
    );
  }

  String get _sectionLabel {
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

  String get _sectionExplanation {
    switch (proceso) {
      case ProcesoElectoral.presidentes:
        return 'Las planchas se ordenan por el puntaje promedio de los 3 integrantes. '
            'Toca cualquier miembro para ver su hoja de vida completa.';
      case ProcesoElectoral.senadores:
        return 'Se eligen 60 senadores: 30 nacionales (Distrito Único) y 30 regionales '
            '(Distrito Múltiple). Se muestran los 10 mejores de cada tipo.';
      case ProcesoElectoral.diputados:
        return 'Se eligen 130 diputados. Se muestran los 10 candidatos con mejor perfil de integridad.';
      case ProcesoElectoral.parlamentoAndino:
        return 'Se eligen 5 representantes. Se muestran los 10 candidatos con mejor perfil.';
    }
  }
}

// ── Full HV bottom sheet ──────────────────────────────────────────────────────

void _showHV(BuildContext context, CandidatoConHV c) {
  final hv = c.hv;
  final color = const Color(0xFF1E3A5F);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Photo + name + party
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    c.fotoUrl != null ? NetworkImage(c.fotoUrl!) : null,
                child: c.fotoUrl == null
                    ? Text(
                        hv.nombre.isNotEmpty
                            ? hv.nombre[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hv.nombre,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      PartyLogo(partyName: hv.partido, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(hv.partido,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (c.cargo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(c.cargo,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                    if (c.departamento.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(c.departamento,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ]),
                    ],
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Score chip
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: hv.scoreBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: hv.scoreColor.withValues(alpha: 0.4)),
                ),
                child: Column(children: [
                  Text('${hv.scoreFinal}',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: hv.scoreColor)),
                  Text('/ 105 pts',
                      style: TextStyle(
                          fontSize: 12, color: hv.scoreColor)),
                  Text(hv.scoreLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hv.scoreColor)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Score breakdown
            _hvSection('Desglose del Puntaje', color),
            _scoreRow('Educación', hv.scoreEducacion, 40, color,
                positive: true),
            _scoreRow(
                'Integridad Penal', hv.scoreIntegridadPenal, 35, color,
                positive: true),
            _scoreRow('Obligaciones', hv.scoreIntegridadOblig, 25, color,
                positive: true),
            if (hv.bonusUniversidadElite > 0)
              _scoreRow('+ Univ. de élite', hv.bonusUniversidadElite, 5,
                  Colors.green.shade600,
                  positive: true),
            if (hv.penaltyReinfo > 0)
              _scoreRow('− REINFO (minería)', -hv.penaltyReinfo, 15,
                  Colors.red.shade700,
                  positive: false),
            if (hv.penaltyUniversidadCuestionada > 0)
              _scoreRow('− Univ. cuestionada',
                  -hv.penaltyUniversidadCuestionada, 5,
                  Colors.red.shade700,
                  positive: false),
            if (hv.penaltyProCrimen > 0)
              _scoreRow('− Leyes pro-crimen (personal)',
                  -hv.penaltyProCrimen, 20, Colors.red.shade700,
                  positive: false),
            if (hv.penaltyProCrimenPartido > 0)
              _scoreRow('− Leyes pro-crimen (partido)',
                  -hv.penaltyProCrimenPartido, 25, Colors.red.shade700,
                  positive: false),
            if (hv.penaltyCargosPublicos > 0)
              _scoreRow('− Cargos públicos previos',
                  -hv.penaltyCargosPublicos, 15, Colors.orange.shade700,
                  positive: false),
            if (hv.penaltyInvestigaciones > 0)
              _scoreRow('− Investigaciones conocidas',
                  -hv.penaltyInvestigaciones, 10, Colors.red.shade700,
                  positive: false),
            const SizedBox(height: 12),

            // Education & personal data
            _hvSection('Datos Personales y Académicos', color),
            _detRow(Icons.school_rounded, color, 'Nivel educativo',
                hv.educacionLabel),
            if (hv.universidades.isNotEmpty)
              _detRow(Icons.account_balance_rounded, color,
                  'Universidad(es)', hv.universidades.join(', ')),
            if (hv.universidadElite)
              _flag(Icons.star_rounded, Colors.green.shade600,
                  'Universidad de élite reconocida'),
            if (hv.universidadCuestionada)
              _flag(Icons.warning_rounded, Colors.orange.shade700,
                  'Universidad con licencia cuestionada'),
            const SizedBox(height: 8),

            // Integrity flags
            _hvSection('Integridad y Antecedentes', color),
            _detRow(Icons.gavel_rounded, color, 'Sentencias penales',
                hv.totalSentenciasPenales == 0
                    ? 'Ninguna registrada'
                    : '${hv.totalSentenciasPenales} sentencia(s)'),
            _detRow(Icons.receipt_long_rounded, color,
                'Sent. obligaciones',
                hv.totalSentenciasObligaciones == 0
                    ? 'Ninguna registrada'
                    : '${hv.totalSentenciasObligaciones} sentencia(s)'),
            _detRow(Icons.terrain_rounded,
                hv.esReinfo ? Colors.orange.shade700 : color,
                'REINFO (minería informal)',
                hv.esReinfo
                    ? 'Sí — en registro REINFO'
                    : 'No registrado'),
            if (hv.numLeyesProCrimen > 0)
              _detRow(Icons.policy_rounded, Colors.red.shade700,
                  'Leyes pro-crimen (personal)',
                  '${hv.numLeyesProCrimen} ley(es) apoyada(s)'),
            if (hv.numLeyesProCrimenPartido > 0)
              _detRow(Icons.policy_rounded, Colors.red.shade700,
                  'Leyes pro-crimen (partido)',
                  '${hv.numLeyesProCrimenPartido} ley(es) apoyada(s) por el partido'),
            if (hv.investigacionesConocidas.isNotEmpty)
              _detRow(Icons.search_rounded, Colors.red.shade700,
                  'Investigaciones', hv.investigacionesConocidas),
            const SizedBox(height: 8),

            // Prior roles
            if (hv.cargosEleccionPopular.isNotEmpty ||
                hv.cargosPartidarios.isNotEmpty) ...[
              _hvSection('Cargos Previos', color),
              ...hv.cargosEleccionPopular.take(4).map((cp) => _cargoRow(
                  cp.cargo, cp.entidad, cp.periodo, color)),
              ...hv.cargosPartidarios.take(3).map((cp) =>
                  _cargoRow(cp.cargo, cp.entidad, cp.periodo,
                      Colors.grey.shade600)),
              const SizedBox(height: 8),
            ],

            // JNE link
            Center(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(hv.jneHvUrl);
                  if (!await launchUrl(uri,
                      mode: LaunchMode.externalApplication)) {}
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Ver en portal JNE'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5))),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _hvSection(String title, Color color) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
    child: Row(children: [
      Expanded(
          child: Divider(color: color.withValues(alpha: 0.2), height: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.8)),
      ),
      Expanded(
          child: Divider(color: color.withValues(alpha: 0.2), height: 1)),
    ]),
  );
}

Widget _scoreRow(String label, int value, int max, Color color,
    {required bool positive}) {
  final pct = (value.abs() / max).clamp(0.0, 1.0);
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(
        width: 170,
        child: Text(label,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '${positive ? '+' : ''}$value',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: positive ? color : Colors.red.shade700),
      ),
    ]),
  );
}

Widget _detRow(IconData icon, Color color, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 8),
      Text('$label: ',
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500)),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
      ),
    ]),
  );
}

Widget _flag(IconData icon, Color color, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500))),
    ]),
  );
}

Widget _cargoRow(
    String cargo, String entidad, String periodo, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.circle, size: 5, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '${cargo.isNotEmpty ? cargo : 'Cargo'}'
          '${entidad.isNotEmpty ? ' — $entidad' : ''}'
          '${periodo.isNotEmpty ? ' ($periodo)' : ''}',
          style: const TextStyle(fontSize: 11, height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]),
  );
}

// ── Plancha model ─────────────────────────────────────────────────────────────

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
