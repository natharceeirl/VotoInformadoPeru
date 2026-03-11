import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const List<String> _kMainParties = [
  'ALIANZA PARA EL PROGRESO',
  'FUERZA POPULAR',
  'RENOVACIÓN POPULAR',
  'AVANCEMOS PERÚ',
  'SOMOS PERÚ',
  'PARTIDO POLÍTICO CONTIGO',
  'UNIÓN POR EL PERÚ',
  'FRENTE POPULAR AGRÍCOLA FIA DEL PERÚ',
  'ACCIÓN POPULAR',
  'PODEMOS PERÚ',
];

// ── Small helper widgets ──────────────────────────────────────────────────────

/// A small square input cell for preference numbers on the ballot.
class _PrefBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const _PrefBox({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged?.call(),
        textAlign: TextAlign.center,
        maxLength: 3,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

/// Header for each ballot section with section number, color, and title.
class _SectionHeader extends StatelessWidget {
  final int sectionNumber;
  final String title;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.sectionNumber,
    required this.title,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: isExpanded
              ? const BorderRadius.vertical(top: Radius.circular(8))
              : BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$sectionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact instruction chip shown inside each section.
class _InstructionRow extends StatelessWidget {
  final String text;
  const _InstructionRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✗ ', style: TextStyle(fontSize: 13, color: Color(0xFF795548), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class VoteSimulatorScreen extends ConsumerStatefulWidget {
  const VoteSimulatorScreen({super.key});

  @override
  ConsumerState<VoteSimulatorScreen> createState() => _VoteSimulatorScreenState();
}

class _VoteSimulatorScreenState extends ConsumerState<VoteSimulatorScreen> {
  // Section 1 — Presidente: which party row is marked (index into loaded list)
  int? _presSelectedIndex;
  bool _presShowAll = false;

  // Sections 2-5: preference controllers per party per section
  // _prefControllers[sectionIdx][partyIdx][boxIdx]
  late final List<List<List<TextEditingController>>> _prefControllers;

  // Section 3: each party has one box; stored in _prefControllers[2][partyIdx][0]

  @override
  void initState() {
    super.initState();
    _prefControllers = List.generate(4, (si) {
      // si=0 → sec2, si=1 → sec3, si=2 → sec4, si=3 → sec5
      final boxCount = (si == 1) ? 1 : 2; // section 3 has 1 box, others 2
      return List.generate(
        _kMainParties.length,
        (_) => List.generate(boxCount, (_) => TextEditingController()),
      );
    });
  }

  @override
  void dispose() {
    for (final section in _prefControllers) {
      for (final party in section) {
        for (final ctrl in party) {
          ctrl.dispose();
        }
      }
    }
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _presSelectedIndex = null;
      _presShowAll = false;
    });
    for (final section in _prefControllers) {
      for (final party in section) {
        for (final ctrl in party) {
          ctrl.clear();
        }
      }
    }
  }

  // ── Build helpers ────────────────────────────────────────────────────────────

  Widget _buildVotingRulesCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Reglas de votación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF4E342E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ruleItem('Marca con una CRUZ (✗) dentro del símbolo del partido o la foto del candidato.'),
          _ruleItem('Votar por MÁS DE 1 PARTIDO en una sección ANULA el voto de esa sección.'),
          _ruleItem('PUEDES votar por partidos DISTINTOS en cada sección sin anular tu voto.'),
        ],
      ),
    );
  }

  Widget _ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF795548), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF5D4037), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Presidente ────────────────────────────────────────────────────

  Widget _buildSection1() {
    final color = ProcesoElectoral.presidentes.color;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SectionHeader(
            sectionNumber: 1,
            title: 'Sección 1 — Presidente y Vicepresidentes',
            color: color,
            isExpanded: true,
            onTap: () {},
          ),
          _buildSection1Body(color),
        ],
      ),
    );
  }

  Widget _buildSection1Body(Color color) {
    final asyncCandidatos = ref.watch(
      candidatosConHVProcesoProvider(ProcesoElectoral.presidentes),
    );

    return asyncCandidatos.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error al cargar: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (candidatos) {
        // Group by party — keep only PRESIDENTE candidate per party for display
        final Map<String, CandidatoConHV> byParty = {};
        for (final c in candidatos) {
          final upper = c.cargo.toUpperCase();
          if (upper.contains('PRESIDENTE') && !upper.contains('VICE') &&
              !upper.contains('1') && !upper.contains('2') &&
              !upper.contains('PRIMER') && !upper.contains('SEGUNDO')) {
            byParty.putIfAbsent(c.hv.partido, () => c);
          }
        }
        // Also include any first candidate per party not yet added
        for (final c in candidatos) {
          byParty.putIfAbsent(c.hv.partido, () => c);
        }

        final parties = byParty.entries.toList();
        final showCount = _presShowAll ? parties.length : (parties.length > 6 ? 6 : parties.length);
        final displayedParties = parties.sublist(0, showCount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InstructionRow(
              'Marca con ✗ dentro del símbolo del partido o la foto del candidato.\n'
              'Solo puedes marcar el símbolo del partido O la foto del presidente.',
            ),
            const Divider(height: 1),
            ...displayedParties.asMap().entries.map((entry) {
              final idx = entry.key;
              final partyName = entry.value.key;
              final candidato = entry.value.value;
              final isSelected = _presSelectedIndex == idx;
              return _buildPresidenteRow(idx, partyName, candidato, isSelected, color);
            }),
            if (parties.length > 6)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: TextButton.icon(
                  onPressed: () => setState(() => _presShowAll = !_presShowAll),
                  icon: Icon(_presShowAll ? Icons.expand_less : Icons.expand_more, size: 18),
                  label: Text(
                    _presShowAll
                        ? 'Ver menos'
                        : 'Ver todos (${parties.length - 6} más)',
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildPresidenteRow(
    int idx,
    String partyName,
    CandidatoConHV candidato,
    bool isSelected,
    Color sectionColor,
  ) {
    return InkWell(
      onTap: () => setState(() {
        _presSelectedIndex = isSelected ? null : idx;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? sectionColor.withValues(alpha: 0.08) : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Party logo with selection mark
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? sectionColor : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1,
                    ),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: PartyLogo(partyName: partyName, size: 38),
                    ),
                  ),
                ),
                if (isSelected)
                  Text(
                    '✗',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: sectionColor.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            // Party name
            Expanded(
              child: Text(
                partyName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            // Candidate photo + PRES label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? sectionColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipOval(
                        child: (candidato.fotoUrl != null && candidato.fotoUrl!.isNotEmpty)
                            ? Image.network(
                                candidato.fotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _candidateFallback(candidato),
                              )
                            : _candidateFallback(candidato),
                      ),
                    ),
                    if (isSelected)
                      Text(
                        '✗',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: sectionColor.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: sectionColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'PRES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateFallback(CandidatoConHV c) {
    final letter = c.hv.nombre.isNotEmpty ? c.hv.nombre[0].toUpperCase() : '?';
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  // ── Sections 2-5: party rows with preference boxes ───────────────────────────

  Widget _buildPartySection({
    required int sectionDisplayNumber,
    required int sectionIndex,
    required String title,
    required String instruction,
    required int boxCount,
    required Color color,
    required int expandedIndex, // kept for API compatibility, no longer used
  }) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SectionHeader(
            sectionNumber: sectionDisplayNumber,
            title: title,
            color: color,
            isExpanded: true,
            onTap: () {},
          ),
          _buildPartyRows(
            sectionIndex: sectionIndex,
            instruction: instruction,
            boxCount: boxCount,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildPartyRows({
    required int sectionIndex,
    required String instruction,
    required int boxCount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InstructionRow(instruction),
        const Divider(height: 1),
        ..._kMainParties.asMap().entries.map((entry) {
          final partyIdx = entry.key;
          final partyName = entry.value;
          final controllers = _prefControllers[sectionIndex][partyIdx];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Party logo
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: PartyLogo(partyName: partyName, size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Party name
                Expanded(
                  child: Text(
                    partyName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Preference boxes
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(boxCount, (bi) {
                    return Padding(
                      padding: EdgeInsets.only(left: bi == 0 ? 0 : 6),
                      child: _PrefBox(
                        controller: controllers[bi],
                        onChanged: () => setState(() {}),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Main build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text(
          'Simulador de Cédula',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A5F),
              ),
              child: Column(
                children: [
                  const Text(
                    'Simulador de Cédula de Votación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elecciones Generales Perú 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Cédula image (reference) ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border.all(color: const Color(0xFFFFB300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline, size: 14, color: Color(0xFFF57F17)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Imagen de referencia — la cédula real puede variar',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1E3A5F), width: 2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      color: Colors.white,
                    ),
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                      child: Image.asset(
                        'assets/assets/CedulaVotacion.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.ballot_outlined, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Cédula de Votación', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu cédula tendrá 5 secciones independientes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF555555),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Voting rules card ─────────────────────────────────────────────
            _buildVotingRulesCard(),

            const SizedBox(height: 4),

            // ── Section 1: Presidente ─────────────────────────────────────────
            _buildSection1(),

            // ── Section 2: Senadores Distrito Único ──────────────────────────
            _buildPartySection(
              sectionDisplayNumber: 2,
              sectionIndex: 0,
              title: 'Sección 2 — Senadores Distrito Único (Nacional)',
              instruction: 'Puedes escribir hasta 2 números de preferencia (no repetir)',
              boxCount: 2,
              color: ProcesoElectoral.senadores.color,
              expandedIndex: 1,
            ),

            // ── Section 3: Senadores Distrito Múltiple ────────────────────────
            _buildPartySection(
              sectionDisplayNumber: 3,
              sectionIndex: 1,
              title: 'Sección 3 — Senadores Distrito Múltiple (Regional)',
              instruction: 'Puedes escribir 1 número de preferencia',
              boxCount: 1,
              color: ProcesoElectoral.senadores.color,
              expandedIndex: 2,
            ),

            // ── Section 4: Diputados ──────────────────────────────────────────
            _buildPartySection(
              sectionDisplayNumber: 4,
              sectionIndex: 2,
              title: 'Sección 4 — Diputados',
              instruction: 'Puedes escribir hasta 2 números de preferencia (no repetir)',
              boxCount: 2,
              color: ProcesoElectoral.diputados.color,
              expandedIndex: 3,
            ),

            // ── Section 5: Parlamento Andino ──────────────────────────────────
            _buildPartySection(
              sectionDisplayNumber: 5,
              sectionIndex: 3,
              title: 'Sección 5 — Parlamento Andino',
              instruction: 'Puedes escribir hasta 2 números de preferencia (no repetir)',
              boxCount: 2,
              color: ProcesoElectoral.parlamentoAndino.color,
              expandedIndex: 4,
            ),

            const SizedBox(height: 16),

            // ── LIMPIAR TODO button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Limpiar todo'),
                      content: const Text(
                        '¿Deseas borrar todas tus marcas y preferencias en este simulador?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                          onPressed: () {
                            Navigator.pop(context);
                            _clearAll();
                          },
                          child: const Text('Limpiar todo'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                label: const Text(
                  'LIMPIAR TODO',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
