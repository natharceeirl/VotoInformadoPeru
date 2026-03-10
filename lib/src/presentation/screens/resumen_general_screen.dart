import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';

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

  static const _procesoLabels = {
    ProcesoElectoral.presidentes: 'Presidente y Vicepresidentes',
    ProcesoElectoral.senadores: 'Senadores 2026',
    ProcesoElectoral.diputados: 'Diputados',
    ProcesoElectoral.parlamentoAndino: 'Parlamento Andino',
  };

  static const _procesoColors = {
    ProcesoElectoral.presidentes: Color(0xFF7B1FA2),
    ProcesoElectoral.senadores: Color(0xFF00695C),
    ProcesoElectoral.diputados: Color(0xFF1565C0),
    ProcesoElectoral.parlamentoAndino: Color(0xFFBF360C),
  };

  static const _procesoIcons = {
    ProcesoElectoral.presidentes: Icons.star_rounded,
    ProcesoElectoral.senadores: Icons.gavel_rounded,
    ProcesoElectoral.diputados: Icons.account_balance_rounded,
    ProcesoElectoral.parlamentoAndino: Icons.public_rounded,
  };

  // Normalizer (same as in providers)
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBanner(porEstosNo, excluir),
            const SizedBox(height: 12),
            // info banner
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
                      'Vista consolidada de los candidatos con mejor perfil de integridad '
                      'en todos los procesos electorales. El puntaje combina educación, '
                      'antecedentes legales, cumplimiento de obligaciones y penalizaciones.',
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
            for (final proceso in _procesos) ...[
              _ProcesoSection(
                proceso: proceso,
                label: _procesoLabels[proceso]!,
                color: _procesoColors[proceso]!,
                icon: _procesoIcons[proceso]!,
                excluir: excluir,
                porEstosNo: porEstosNo,
                norm: _norm,
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBanner(List<String> porEstosNo, bool excluir) {
    return GestureDetector(
      onTap: () => _showPorEstosNoDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: excluir ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: excluir ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
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
                    ? 'Filtrando ${porEstosNo.length} partidos con riesgo de corrupción'
                    : 'Mostrando todos los partidos — toca para filtrar por riesgo',
                style: TextStyle(
                  fontSize: 12,
                  color: excluir
                      ? Colors.orange.shade800
                      : Colors.grey.shade600,
                ),
              ),
            ),
            Switch.adaptive(
              value: excluir,
              onChanged: (_) =>
                  ref.read(excluirPartidosRiesgoProvider.notifier).toggle(),
              activeThumbColor: Colors.orange.shade700,
              activeTrackColor: Colors.orange.shade300,
            ),
          ],
        ),
      ),
    );
  }

  void _showPorEstosNoDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('#PorEstosNo — ¿Por qué filtrar?'),
        content: const SingleChildScrollView(
          child: Text(
            'Algunos partidos tienen antecedentes documentados de corrupción '
            'según registros públicos e investigaciones judiciales.\n\n'
            'Al activar este filtro, los candidatos de esos partidos no se muestran '
            'en el resumen, facilitando la búsqueda de alternativas con mejor perfil.',
            style: TextStyle(height: 1.5),
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

// ─── Sección por proceso electoral ───────────────────────────────────────────

class _ProcesoSection extends ConsumerWidget {
  final ProcesoElectoral proceso;
  final String label;
  final Color color;
  final IconData icon;
  final bool excluir;
  final List<String> porEstosNo;
  final String Function(String) norm;

  const _ProcesoSection({
    required this.proceso,
    required this.label,
    required this.color,
    required this.icon,
    required this.excluir,
    required this.porEstosNo,
    required this.norm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(candidatosConHVProcesoProvider(proceso));
    return async.when(
      loading: () => _sectionHeader(
          child: const Center(child: CircularProgressIndicator())),
      error: (e, _) => _sectionHeader(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.red))),
      data: (todos) {
        var lista = todos;
        if (excluir && porEstosNo.isNotEmpty) {
          lista = lista
              .where((c) => !porEstosNo.contains(norm(c.hv.partido)))
              .toList();
        }
        // Sort by scoreFinal desc, take top 10 (5 for presidents)
        lista.sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
        final top = lista
            .take(proceso == ProcesoElectoral.presidentes ? 5 : 10)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${todos.length} candidatos',
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (top.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No hay candidatos disponibles',
                    style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              ...top.asMap().entries.map((e) => _CandidatoRow(
                    rank: e.key + 1,
                    candidato: e.value,
                    color: color,
                  )),
          ],
        );
      },
    );
  }

  Widget _sectionHeader({required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
        ]),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ─── Fila de candidato ────────────────────────────────────────────────────────

class _CandidatoRow extends StatelessWidget {
  final int rank;
  final CandidatoConHV candidato;
  final Color color;

  const _CandidatoRow(
      {required this.rank, required this.candidato, required this.color});

  @override
  Widget build(BuildContext context) {
    final hv = candidato.hv;
    final score = hv.scoreFinal;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // rank badge
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hv.nombre,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hv.partido,
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (candidato.departamento.isNotEmpty) ...[
                      Text(' · ',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400)),
                      Flexible(
                        child: Text(
                          candidato.departamento,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
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
          const SizedBox(width: 8),
          // Score chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: hv.scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: hv.scoreColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: hv.scoreColor,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                      fontSize: 8,
                      color: hv.scoreColor.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
