import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import 'credits_screen.dart';

// ── Colors ────────────────────────────────────────────────────────────────────

const _navy = Color(0xFF1E3A5F);

// ── Tab definitions ───────────────────────────────────────────────────────────

const _tabs = [
  _TabDef(0, 'Presidente\ny VP', Icons.star_rounded),
  _TabDef(1, 'Senadores\nNacional', Icons.public_rounded),
  _TabDef(2, 'Senadores\nRegional', Icons.map_rounded),
  _TabDef(3, 'Diputados', Icons.account_balance_rounded),
  _TabDef(4, 'Parlamento\nAndino', Icons.account_balance_rounded),
];

const _tabColors = [
  Color(0xFFD97706), // amber — Presidente y VP
  Color(0xFF2563EB), // blue — Senadores Nacional
  Color(0xFF0891B2), // cyan — Senadores Regional
  Color(0xFF7C3AED), // purple — Diputados
  Color(0xFF059669), // green — Parlamento Andino
];

class _TabDef {
  final int idx;
  final String label;
  final IconData icon;
  const _TabDef(this.idx, this.label, this.icon);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _norm(String s) {
  var r = s.toUpperCase()
      .replaceAll('Á', 'A').replaceAll('É', 'E').replaceAll('Í', 'I')
      .replaceAll('Ó', 'O').replaceAll('Ú', 'U').replaceAll('Ñ', 'N');
  return r.replaceAll(',', '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _isExcluido(String partido, List<String> porEstosNo) {
  if (porEstosNo.isEmpty) return false;
  final n = _norm(partido);
  return porEstosNo.any((p) => n == p || n.contains(p) || p.contains(n));
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ResumenGeneralScreen extends ConsumerStatefulWidget {
  const ResumenGeneralScreen({super.key});

  @override
  ConsumerState<ResumenGeneralScreen> createState() =>
      _ResumenGeneralScreenState();
}

class _ResumenGeneralScreenState extends ConsumerState<ResumenGeneralScreen> {
  int _selectedTab = 0;
  String? _selectedRegion; // for senadores regionales

  @override
  Widget build(BuildContext context) {
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
            const AppBrandHeader(),

            // ── Descripción ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _navy.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _navy, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vista consolidada de candidatos con mejor perfil de integridad '
                      'en los 4 procesos electorales 2026. '
                      'Toca cualquier candidato para ver su hoja de vida completa.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filtro #PorEstosNo ─────────────────────────────────────────
            _FilterBanner(),
            const SizedBox(height: 16),

            // ── Voto estratégico ───────────────────────────────────────────
            _StrategicVoteSection(
                excluir: excluir, porEstosNo: porEstosNo),
            const SizedBox(height: 20),

            // ── Tab buttons ────────────────────────────────────────────────
            _buildTabBar(),
            const SizedBox(height: 16),

            // ── Tab content ────────────────────────────────────────────────
            _buildTabContent(excluir, porEstosNo),

            const SizedBox(height: 28),
            const CreditsFooter(),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Column(
      children: _tabs.map((t) {
        final active = _selectedTab == t.idx;
        final tabColor = _tabColors[t.idx];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedTab = t.idx;
              _selectedRegion = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: active ? tabColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? tabColor : Colors.grey.shade300,
                  width: active ? 1.5 : 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: tabColor.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? Colors.white.withValues(alpha: 0.2)
                          : tabColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(t.icon,
                        size: 20,
                        color: active ? Colors.white : tabColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      t.label.replaceAll('\n', ' '),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : Colors.grey.shade800),
                    ),
                  ),
                  Icon(
                    active
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color:
                        active ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Tab content ───────────────────────────────────────────────────────────

  Widget _buildTabContent(bool excluir, List<String> porEstosNo) {
    switch (_selectedTab) {
      case 0:
        return _ProcesoSection(
          proceso: ProcesoElectoral.presidentes,
          excluir: excluir,
          porEstosNo: porEstosNo,
        );
      case 1:
        return _SenadorSection(
          tipo: 'ÚNICO',
          excluir: excluir,
          porEstosNo: porEstosNo,
          selectedRegion: null,
          onRegionChanged: null,
        );
      case 2:
        return _SenadorRegionalSection(
          excluir: excluir,
          porEstosNo: porEstosNo,
          selectedRegion: _selectedRegion,
          onRegionChanged: (r) => setState(() => _selectedRegion = r),
        );
      case 3:
        return _ProcesoSection(
          proceso: ProcesoElectoral.diputados,
          excluir: excluir,
          porEstosNo: porEstosNo,
        );
      case 4:
        return _ProcesoSection(
          proceso: ProcesoElectoral.parlamentoAndino,
          excluir: excluir,
          porEstosNo: porEstosNo,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Filter banner ─────────────────────────────────────────────────────────────

class _FilterBanner extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterBanner> createState() => _FilterBannerState();
}

class _FilterBannerState extends ConsumerState<_FilterBanner> {
  @override
  Widget build(BuildContext context) {
    final excluir = ref.watch(excluirPartidosRiesgoProvider);
    final detalleAsync = ref.watch(porEstosNoDetalleProvider);
    final detalle = detalleAsync.asData?.value ?? [];

    final activeColor = Colors.red.shade700;
    final activeBg = Colors.red.shade50;
    final activeBorder = Colors.red.shade300;

    return Container(
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
                color: excluir ? activeColor : Colors.grey.shade400, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                excluir
                    ? '#PorEstosNo — Filtrando ${detalle.length} partidos'
                    : 'Activar filtro #PorEstosNo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: excluir ? activeColor : Colors.grey.shade700,
                ),
              ),
            ),
            Switch.adaptive(
              value: excluir,
              onChanged: (_) =>
                  ref.read(excluirPartidosRiesgoProvider.notifier).toggle(),
              activeThumbColor: activeColor,
              activeTrackColor: Colors.red.shade200,
            ),
          ]),
          // "Ver partidos" expandable
          GestureDetector(
            onTap: () => _showDialog(context, detalle),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Ver explicación y lista de partidos →',
                  style: TextStyle(
                      fontSize: 11,
                      color: excluir ? activeColor : Colors.grey.shade500,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          excluir ? activeColor : Colors.grey.shade400),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(
      BuildContext ctx, List<Map<String, dynamic>> detalle) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
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
                  final nombre =
                      (p['nombre'] as String? ?? '').toUpperCase();
                  final nivel =
                      (p['nivel_riesgo'] as String? ?? '').toUpperCase();
                  final indice =
                      (p['indice_riesgo_corrupcion'] as num?)?.toDouble() ??
                          0.0;
                  final casos =
                      (p['casos_corrupcion'] as List?)
                              ?.cast<Map<String, dynamic>>() ??
                          [];
                  final isAlto = nivel == 'ALTO';
                  final riskColor =
                      isAlto ? Colors.red.shade700 : Colors.orange.shade700;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: PartyLogo(partyName: nombre, size: 32),
                            ),
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
                                            fontWeight: FontWeight.w600)),
                                    TextSpan(
                                      text:
                                          ' — $nivel (${indice.toStringAsFixed(2)})',
                                      style: TextStyle(
                                          color: riskColor,
                                          fontWeight: FontWeight.w500),
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
                                style: TextStyle(
                                    fontSize: 10,
                                    color: riskColor,
                                    height: 1.4),
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
        border:
            Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.3)),
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
                    color:
                        const Color(0xFF1565C0).withValues(alpha: 0.1),
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
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
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
                  _vallaRulesCard(),
                  const SizedBox(height: 14),
                  if (loading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  /*else ...[
                    _buildViabilityBlock('Diputados', dipList,
                        widget.excluir, widget.porEstosNo,
                        const Color(0xFF1B4F72),
                        Icons.account_balance_rounded),
                    const SizedBox(height: 12),
                    _buildViabilityBlock('Senadores', senList,
                        widget.excluir, widget.porEstosNo,
                        const Color(0xFF154360),
                        Icons.gavel_rounded),
                  ],
                  const SizedBox(height: 14),
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
                            'Estimación basada en candidatos inscritos como proxy '
                            'de capacidad organizacional. Sin encuestas — orientativo.',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),*/
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
            'Un partido debe superar la valla para convertir votos en escaños. '
            'Si no la supera, los votos no generan representación.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 10),
          _vallaRule('Cámara de Diputados',
              '• ≥5% de votos válidos nacionales, O\n• ≥7 escaños',
              const Color(0xFF1B4F72)),
          const SizedBox(height: 6),
          _vallaRule('Cámara de Senadores',
              '• ≥5% de votos válidos senatoriales, O\n• ≥3 senadores',
              const Color(0xFF154360)),
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
              '⚠ Votos cruzados son válidos, pero si el partido no supera '
              'la valla ese voto no genera escaños.',
              style: TextStyle(
                  fontSize: 11, height: 1.4, color: Color(0xFF6D4C00)),
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
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
    final Map<String, int> partyCount = {};
    for (final c in candidatos) {
      partyCount[c.hv.partido] = (partyCount[c.hv.partido] ?? 0) + 1;
    }
    if (partyCount.isEmpty) return const SizedBox.shrink();

    final sorted = partyCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.length;
    final verde = (total / 3).ceil();
    final amarillo = (total / 3).ceil();

    final recommended = sorted.take(verde).where((e) {
      if (!excluir) return true;
      return !_isExcluido(e.key, porEstosNo);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _viabilityZone('Probable pase',
              Icons.check_circle_rounded, Colors.green.shade600,
              Colors.green.shade50, Colors.green.shade200,
              sorted.take(verde).toList(), porEstosNo, excluir)),
          const SizedBox(width: 6),
          Expanded(child: _viabilityZone('En riesgo',
              Icons.warning_rounded, Colors.orange.shade700,
              Colors.orange.shade50, Colors.orange.shade200,
              sorted.skip(verde).take(amarillo).toList(), porEstosNo, excluir)),
          const SizedBox(width: 6),
          Expanded(child: _viabilityZone('Difícil pase',
              Icons.cancel_rounded, Colors.red.shade600,
              Colors.red.shade50, Colors.red.shade200,
              sorted.skip(verde + amarillo).toList(), porEstosNo, excluir)),
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
                    '✓ Mayor probabilidad de superar la valla'
                    '${excluir ? ' (sin #PorEstosNo)' : ''}:',
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
                      Text(_shortName(e.key),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade800)),
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

  Widget _viabilityZone(String label, IconData icon, Color color,
      Color bgColor, Color borderColor,
      List<MapEntry<String, int>> parties,
      List<String> porEstosNo, bool excluir) {
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
                      fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ),
          ]),
          const SizedBox(height: 4),
          ...parties.take(5).map((e) {
            final excluded = excluir && _isExcluido(e.key, porEstosNo);
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                PartyLogo(partyName: e.key, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(_shortName(e.key),
                      style: TextStyle(
                          fontSize: 9,
                          color: excluded
                              ? Colors.grey
                              : color.withValues(alpha: 0.8),
                          decoration: excluded
                              ? TextDecoration.lineThrough
                              : null),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
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
    const abbr = {
      'ALIANZA PARA EL PROGRESO': 'APP',
      'PERU LIBRE': 'Perú Libre',
      'JUNTOS POR EL PERU': 'JPP',
      'RENOVACION POPULAR': 'Renov. Pop.',
      'FUERZA POPULAR': 'Fuerza Pop.',
      'AVANZA PAIS': 'Avanza País',
      'PODEMOS PERU': 'Podemos',
      'SOMOS PERU': 'Somos Perú',
      'PARTIDO APRISTA PERUANO': 'APRA',
      'PARTIDO MORADO': 'P. Morado',
    };
    final upper = _norm(name);
    for (final entry in abbr.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }
    return name.length > 14 ? '${name.substring(0, 12)}…' : name;
  }
}

// ── Senadores Nacional section ────────────────────────────────────────────────

class _SenadorSection extends ConsumerWidget {
  final String tipo; // 'ÚNICO' or 'MÚLTIPLE'
  final bool excluir;
  final List<String> porEstosNo;
  final String? selectedRegion;
  final void Function(String?)? onRegionChanged;

  const _SenadorSection({
    required this.tipo,
    required this.excluir,
    required this.porEstosNo,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(candidatosConHVProcesoProvider(ProcesoElectoral.senadores));
    return async.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e',
          style: const TextStyle(color: Colors.red)),
      data: (todos) {
        var lista = todos
            .where((c) => c.tipoDistrito == tipo)
            .where((c) =>
                !excluir || !_isExcluido(c.hv.partido, porEstosNo))
            .toList()
          ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

        if (lista.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No hay candidatos disponibles',
                style: TextStyle(color: Colors.grey.shade500)),
          );
        }

        return _buildCandidatoList(
            context, lista, ProcesoElectoral.senadores.color);
      },
    );
  }
}

// ── Senadores Regional section (with region filter) ───────────────────────────

class _SenadorRegionalSection extends ConsumerWidget {
  final bool excluir;
  final List<String> porEstosNo;
  final String? selectedRegion;
  final void Function(String?) onRegionChanged;

  const _SenadorRegionalSection({
    required this.excluir,
    required this.porEstosNo,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(candidatosConHVProcesoProvider(ProcesoElectoral.senadores));
    return async.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e',
          style: const TextStyle(color: Colors.red)),
      data: (todos) {
        final multiples = todos
            .where((c) => c.tipoDistrito == 'MÚLTIPLE')
            .where((c) =>
                !excluir || !_isExcluido(c.hv.partido, porEstosNo))
            .toList();

        // Get all unique regions
        final regions = multiples
            .map((c) => c.departamento)
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        // Filter by selected region
        var lista = selectedRegion != null
            ? multiples
                .where((c) => c.departamento == selectedRegion)
                .toList()
            : multiples;
        lista = lista.toList()
          ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

        final color = ProcesoElectoral.senadores.color;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region filter
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(Icons.location_on_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                const Text('Región:',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedRegion,
                      isExpanded: true,
                      hint: Text('Todas las regiones',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas las regiones'),
                        ),
                        ...regions.map((r) => DropdownMenuItem<String?>(
                              value: r,
                              child: Text(r),
                            )),
                      ],
                      onChanged: onRegionChanged,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No hay candidatos para esta región',
                    style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              _buildCandidatoList(context, lista, color),
          ],
        );
      },
    );
  }
}

// ── Generic proceso section (Presidentes, Diputados, Parl. Andino) ────────────

class _ProcesoSection extends ConsumerWidget {
  final ProcesoElectoral proceso;
  final bool excluir;
  final List<String> porEstosNo;

  const _ProcesoSection({
    required this.proceso,
    required this.excluir,
    required this.porEstosNo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = proceso.color;
    final async = ref.watch(candidatosConHVProcesoProvider(proceso));

    return async.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator())),
      error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.red))),
      data: (todos) {
        final lista = todos
            .where((c) =>
                !excluir || !_isExcluido(c.hv.partido, porEstosNo))
            .toList();

        if (proceso == ProcesoElectoral.presidentes) {
          return _buildPlanchas(context, lista, color);
        }

        lista.sort(
            (a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

        if (lista.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No hay candidatos disponibles',
                style: TextStyle(color: Colors.grey.shade500)),
          );
        }

        return _buildCandidatoList(context, lista, color);
      },
    );
  }

  Widget _buildPlanchas(
      BuildContext context, List<CandidatoConHV> lista, Color color) {
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
        planchas.add(
            _Plancha(partido: entry.key, presidente: pres, vp1: vp1, vp2: vp2));
      }
    }

    double avg(_Plancha p) {
      final members = <CandidatoConHV>[
        p.presidente,
        if (p.vp1 != null) p.vp1!,
        if (p.vp2 != null) p.vp2!,
      ];
      return members.fold(0.0, (s, m) => s + m.hv.scoreFinal) / members.length;
    }

    planchas.sort((a, b) => avg(b).compareTo(avg(a)));

    if (planchas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No hay planchas disponibles',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }

    return Column(
      children: planchas
          .asMap()
          .entries
          .map((e) => _planchaCard(context, e.key + 1, e.value,
              avg(e.value), color))
          .toList(),
    );
  }

  Widget _planchaCard(BuildContext context, int rank, _Plancha plancha,
      double avgScore, Color color) {
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
                          color: pres.hv.scoreColor.withValues(alpha: 0.7))),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _memberRow(context, plancha.presidente, 'Presidente/a'),
            if (plancha.vp1 != null) ...[
              const SizedBox(height: 6),
              _memberRow(context, plancha.vp1!, '1er Vicepresidente/a'),
            ],
            if (plancha.vp2 != null) ...[
              const SizedBox(height: 6),
              _memberRow(context, plancha.vp2!, '2do Vicepresidente/a'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _memberRow(
      BuildContext context, CandidatoConHV c, String label) {
    return GestureDetector(
      onTap: () => _showHV(context, c),
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
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded,
            size: 14, color: Colors.grey.shade400),
      ]),
    );
  }
}

// ── Candidato list with limit (shared) ───────────────────────────────────────

Widget _buildCandidatoList(
    BuildContext context, List<CandidatoConHV> lista, Color color) {
  return _CandidatoListPaginated(lista: lista, color: color);
}

// ── Candidato row (shared) ────────────────────────────────────────────────────

Widget _candidatoRow(
    BuildContext context, int rank, CandidatoConHV candidato, Color color) {
  final hv = candidato.hv;
  final fotoUrl = candidato.fotoUrl;

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
          backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
          child: fotoUrl == null
              ? Text(
                  hv.nombre.isNotEmpty ? hv.nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 8),
        PartyLogo(partyName: hv.partido, size: 24),
        const SizedBox(width: 8),
        // Name + partido + depto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hv.nombre,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
            border:
                Border.all(color: hv.scoreColor.withValues(alpha: 0.3)),
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

// ── Full HV bottom sheet (polished) ──────────────────────────────────────────

void _showHV(BuildContext context, CandidatoConHV c) {
  final hv = c.hv;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.zero,
          children: [
            // ── Gradient header ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, const Color(0xFF0D2540)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          backgroundImage: c.fotoUrl != null
                              ? NetworkImage(c.fotoUrl!)
                              : null,
                          child: c.fotoUrl == null
                              ? Text(
                                  hv.nombre.isNotEmpty
                                      ? hv.nombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hv.nombre,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2)),
                            const SizedBox(height: 6),
                            Row(children: [
                              PartyLogo(partyName: hv.partido, size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(hv.partido,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white
                                            .withValues(alpha: 0.75)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ]),
                            if (c.cargo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(c.cargo,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                            if (c.departamento.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.location_on_rounded,
                                    size: 12,
                                    color: Colors.white
                                        .withValues(alpha: 0.6)),
                                const SizedBox(width: 3),
                                Text(c.departamento,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white
                                            .withValues(alpha: 0.7))),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Score badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${hv.scoreFinal}',
                              style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('/ 105 pts',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(alpha: 0.7))),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(hv.scoreLabel,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score breakdown — navy/blue
                  _hvSectionCard('Desglose del Puntaje', _navy,
                      const Color(0xFFEFF6FF), [
                    _scoreRow('Educación', hv.scoreEducacion, 40, _navy,
                        positive: true),
                    _scoreRow('Integridad Penal', hv.scoreIntegridadPenal,
                        35, _navy,
                        positive: true),
                    _scoreRow('Obligaciones', hv.scoreIntegridadOblig, 25,
                        _navy,
                        positive: true),
                    if (hv.bonusUniversidadElite > 0)
                      _scoreRow('+ Univ. de élite', hv.bonusUniversidadElite,
                          5, Colors.green.shade700,
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
                          -hv.penaltyProCrimenPartido, 25,
                          Colors.red.shade700,
                          positive: false),
                    if (hv.penaltyCargosPublicos > 0)
                      _scoreRow('− Cargos públicos previos',
                          -hv.penaltyCargosPublicos, 15,
                          Colors.orange.shade700,
                          positive: false),
                    if (hv.penaltyInvestigaciones > 0)
                      _scoreRow('− Investigaciones conocidas',
                          -hv.penaltyInvestigaciones, 10,
                          Colors.red.shade700,
                          positive: false),
                  ]),

                  // Personal & academic — blue
                  _hvSectionCard('Datos Personales y Académicos',
                      const Color(0xFF2563EB), const Color(0xFFEFF6FF), [
                    _detRow(Icons.badge_rounded, const Color(0xFF2563EB),
                        'DNI', hv.dni),
                    _detRow(Icons.format_list_numbered_rounded,
                        const Color(0xFF2563EB), 'Posición en lista',
                        '#${c.posicion}'),
                    if (c.cargo.isNotEmpty)
                      _detRow(Icons.work_outline_rounded,
                          const Color(0xFF2563EB), 'Cargo', c.cargo),
                    _detRow(Icons.school_rounded, const Color(0xFF2563EB),
                        'Nivel educativo', hv.educacionLabel),
                    if (hv.universidades.isNotEmpty)
                      _detRow(Icons.account_balance_rounded,
                          const Color(0xFF2563EB), 'Universidad(es)',
                          hv.universidades.join('; ')),
                    if (hv.posgrados.isNotEmpty)
                      _detRow(Icons.military_tech_rounded,
                          const Color(0xFF2563EB), 'Posgrado(s)',
                          hv.posgrados.join('; ')),
                    if (hv.universidadElite)
                      _flag(Icons.star_rounded, Colors.green.shade700,
                          'Universidad de élite reconocida'),
                    if (hv.universidadCuestionada)
                      _flag(Icons.warning_rounded, Colors.orange.shade700,
                          'Universidad con licencia cuestionada'),
                  ]),

                  // Integrity — red
                  _hvSectionCard('Integridad y Antecedentes',
                      const Color(0xFFB91C1C), const Color(0xFFFEF2F2), [
                    _detRow(Icons.gavel_rounded, const Color(0xFFB91C1C),
                        'Sentencias penales',
                        hv.totalSentenciasPenales == 0
                            ? 'Ninguna registrada'
                            : '${hv.totalSentenciasPenales} sentencia(s)'),
                    _detRow(Icons.receipt_long_rounded,
                        const Color(0xFFB91C1C), 'Sent. obligaciones',
                        hv.totalSentenciasObligaciones == 0
                            ? 'Ninguna registrada'
                            : '${hv.totalSentenciasObligaciones} sentencia(s)'),
                    _detRow(
                        Icons.terrain_rounded,
                        hv.esReinfo
                            ? Colors.orange.shade700
                            : const Color(0xFFB91C1C),
                        'REINFO (minería informal)',
                        hv.esReinfo
                            ? 'Sí — ${hv.cantidadMineras > 0 ? '${hv.cantidadMineras} registro(s)' : 'en registro REINFO'}'
                            : 'No registrado'),
                    if (hv.numLeyesProCrimen > 0)
                      _detRow(Icons.policy_rounded, Colors.red.shade700,
                          'Leyes pro-crimen (personal)',
                          '${hv.numLeyesProCrimen} ley(es) apoyada(s)'),
                    if (hv.numLeyesProCrimenPartido > 0)
                      _detRow(Icons.policy_rounded, Colors.red.shade700,
                          'Leyes pro-crimen (partido)',
                          '${hv.numLeyesProCrimenPartido} ley(es) por el partido'),
                    if (hv.investigacionesConocidas.isNotEmpty)
                      _detRow(Icons.search_rounded, Colors.red.shade700,
                          'Investigaciones', hv.investigacionesConocidas),
                    if (hv.notaAdicional.isNotEmpty)
                      _detRow(Icons.notes_rounded, Colors.grey.shade600,
                          'Nota', hv.notaAdicional),
                  ]),

                  // Financial — green
                  _hvSectionCard('Información Financiera Declarada',
                      const Color(0xFF059669), const Color(0xFFF0FDF4), [
                    _detRow(Icons.payments_rounded, const Color(0xFF059669),
                        'Ingresos totales',
                        '${_fmtSoles(hv.ingresoTotal)}${hv.anioIngresos.isNotEmpty ? ' (${hv.anioIngresos})' : ''}'),
                    if (hv.ingresoPublico > 0)
                      _detRow(Icons.account_balance_wallet_rounded,
                          const Color(0xFF059669), 'Ingresos públicos',
                          _fmtSoles(hv.ingresoPublico)),
                    if (hv.ingresoPrivado > 0)
                      _detRow(Icons.store_rounded, const Color(0xFF059669),
                          'Ingresos privados', _fmtSoles(hv.ingresoPrivado)),
                    _detRow(Icons.home_rounded, const Color(0xFF059669),
                        'Inmuebles',
                        hv.numInmuebles == 0
                            ? 'No declarado'
                            : '${hv.numInmuebles} bien(es) — ${_fmtSoles(hv.valorInmuebles)}'),
                    if (hv.numVehiculos > 0)
                      _detRow(Icons.directions_car_rounded,
                          const Color(0xFF059669), 'Vehículos',
                          '${hv.numVehiculos}'),
                  ]),

                  // Cargos políticos — indigo
                  if (hv.cargosEleccionPopular.isNotEmpty ||
                      hv.cargosPartidarios.isNotEmpty)
                    _hvSectionCard('Cargos Políticos',
                        const Color(0xFF4338CA), const Color(0xFFEEF2FF), [
                      if (hv.cargosEleccionPopular.isNotEmpty) ...[
                        Text('Por elección popular:',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4338CA))),
                        const SizedBox(height: 4),
                        ...hv.cargosEleccionPopular.take(6).map((cp) =>
                            _cargoRow(cp.cargo, cp.entidad, cp.periodo,
                                const Color(0xFF4338CA))),
                      ],
                      if (hv.cargosPartidarios.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Cargos partidarios:',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        ...hv.cargosPartidarios.take(4).map((cp) =>
                            _cargoRow(cp.cargo, cp.entidad, cp.periodo,
                                Colors.grey.shade600)),
                      ],
                    ]),

                  // Experience — cyan
                  if (hv.experienciaLaboral.isNotEmpty)
                    _hvSectionCard('Experiencia Laboral',
                        const Color(0xFF0891B2), const Color(0xFFECFEFF), [
                      ...hv.experienciaLaboral.take(4).map((e) => _cargoRow(
                          e.cargo,
                          e.institucion,
                          [e.fechaInicio, e.fechaFin]
                              .where((s) => s.isNotEmpty)
                              .join(' – '),
                          const Color(0xFF0891B2))),
                    ]),

                  // Renunció a — amber
                  if (hv.renuncioA.isNotEmpty)
                    _hvSectionCard('Renunció a', const Color(0xFFD97706),
                        const Color(0xFFFFFBEB), [
                      _detRow(Icons.exit_to_app_rounded,
                          const Color(0xFFD97706), 'Partidos anteriores',
                          hv.renuncioA.join(', ')),
                    ]),

                  // JNE link
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(hv.jneHvUrl);
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text('Ver hoja de vida en portal JNE'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: _navy,
                          side: BorderSide(
                              color: _navy.withValues(alpha: 0.5))),
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

// ── HV helpers ────────────────────────────────────────────────────────────────

String _fmtSoles(double v) {
  if (v <= 0) return 'No declarado';
  if (v >= 1000000) return 'S/ ${(v / 1000000).toStringAsFixed(2)}M';
  if (v >= 1000) return 'S/ ${(v / 1000).toStringAsFixed(1)}K';
  return 'S/ ${v.toStringAsFixed(2)}';
}

// ── Paginated candidate list widget ──────────────────────────────────────────

class _CandidatoListPaginated extends StatefulWidget {
  final List<CandidatoConHV> lista;
  final Color color;

  const _CandidatoListPaginated(
      {required this.lista, required this.color});

  @override
  State<_CandidatoListPaginated> createState() =>
      _CandidatoListPaginatedState();
}

class _CandidatoListPaginatedState
    extends State<_CandidatoListPaginated> {
  int _count = 15;

  @override
  Widget build(BuildContext context) {
    final visible = widget.lista.take(_count).toList();
    final remaining = widget.lista.length - _count;
    return Column(
      children: [
        ...visible.asMap().entries.map(
            (e) => _candidatoRow(context, e.key + 1, e.value, widget.color)),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _count += 15),
              icon: const Icon(Icons.expand_more_rounded, size: 16),
              label: Text(
                'Cargar 15 más ($remaining restantes)',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.color,
                side:
                    BorderSide(color: widget.color.withValues(alpha: 0.5)),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Colored section card for HV sheet ────────────────────────────────────────

Widget _hvSectionCard(
    String title, Color color, Color bgColor, List<Widget> rows) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.8),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        ),
      ],
    ),
  );
}

// ── HV helper widgets ─────────────────────────────────────────────────────────

Widget _scoreRow(String label, int value, int max, Color color,
    {required bool positive}) {
  final pct = (value.abs() / max).clamp(0.0, 1.0);
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(children: [
      SizedBox(
        width: 160,
        child: Text(label,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7,
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 36,
        child: Text(
          '${positive ? '+' : ''}$value',
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: positive ? color : Colors.red.shade700),
        ),
      ),
    ]),
  );
}

Widget _detRow(IconData icon, Color color, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
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
    padding: const EdgeInsets.only(bottom: 7),
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
    padding: const EdgeInsets.only(bottom: 5),
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
