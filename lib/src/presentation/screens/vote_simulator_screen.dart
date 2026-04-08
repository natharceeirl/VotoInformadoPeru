import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import 'credits_screen.dart';
import 'resumen_general_screen.dart' show showCandidatoHV;

// ── Party order (Secciones 2–5) ───────────────────────────────────────────────

const List<String> _kPartyOrder = [
  'Venceremos',
  'Partido Patriótico del Perú',
  'Obras',
  'Frepap',
  'Partido Demócrata Verde',
  'Partido del Buen Gobierno',
  'Perú Acción',
  'PRIN',
  'Progresemos',
  'Partido Sí Creo',
  'País Para Todos',
  'Partido Frente de la Esperanza 2021',
  'Perú Libre',
  'Ciudadanos por el Perú',
  'Primero La Gente',
  'JPP',
  'Podemos Perú',
  'Partido Democrático Federal',
  'Fe en el Perú',
  'Integridad Democrática',
  'Fuerza Popular',
  'APP',
  'Cooperación Popular',
  'Ahora Nación',
  'Libertad Popular',
  'Un Camino Diferente',
  'Avanza País',
  'Perú Moderno',
  'Perú Primero',
  'Salvemos al Perú',
  'Somos Perú',
  'Partido Aprista Peruano',
  'Renovación Popular',
  'Partido Demócrata Unido Perú',
  'Fuerza y Libertad',
  'PTE',
  'Unidad Nacional',
  'Partido Morado',
];

// Maps _kPartyOrder display names → JNE hv.partido values for names that don't
// fuzzy-match directly (abbreviations and merged words).
const _kPartyDataName = <String, String>{
  'JPP':                          'JUNTOS POR EL PERU',
  'APP':                          'ALIANZA PARA EL PROGRESO',
  'Partido Sí Creo':              'PARTIDO SICREO',
  'Partido Frente de la Esperanza 2021': 'PARTIDO FRENTE DE LA ESPERANZA 2021',
  'PTE':                          'PARTIDO DE LOS TRABAJADORES Y EMPRENDEDORES PTE - PERU',
};

// ── Colors ────────────────────────────────────────────────────────────────────

const _navy = Color(0xFF1E3A5F);

// ── Simulation integrity warning data class ───────────────────────────────────

class _SimWarning {
  final String party;
  final IconData icon;
  final Color color;
  final String message;
  const _SimWarning({
    required this.party,
    required this.icon,
    required this.color,
    required this.message,
  });
}

// ── Peruvian regions (for Senadores Múltiple and Diputados) ──────────────────
const _kRegiones = [
  'AMAZONAS', 'ANCASH', 'APURIMAC', 'AREQUIPA', 'AYACUCHO',
  'CAJAMARCA', 'CALLAO', 'CUSCO', 'HUANCAVELICA', 'HUANUCO',
  'ICA', 'JUNIN', 'LA LIBERTAD', 'LAMBAYEQUE',
  'LIMA METROPOLITANA', 'LIMA PROVINCIAS', 'LORETO',
  'MADRE DE DIOS', 'MOQUEGUA', 'PASCO',
  'PERUANOS RESIDENTES EN EL EXTRANJERO',
  'PIURA', 'PUNO', 'SAN MARTIN', 'TACNA', 'TUMBES', 'UCAYALI',
];

// ── Section definitions ───────────────────────────────────────────────────────

class _SecDef {
  final int number;
  final String title;
  final Color color;
  final String explanation;
  final String instruction;
  final int boxCount; // 0 = special presidente selector

  const _SecDef({
    required this.number,
    required this.title,
    required this.color,
    required this.explanation,
    required this.instruction,
    required this.boxCount,
  });
}

final _kSections = <_SecDef>[
  const _SecDef(
    number: 1,
    title: 'Presidente y Vicepresidentes',
    color: Color(0xFF1E3A5F),
    explanation:
        'Votas por la plancha presidencial completa: Presidente, 1er Vicepresidente y 2do Vicepresidente.\n\n'
        'Puedes marcar el símbolo del partido O la foto del candidato presidencial — ambas acciones cuentan como voto para la misma plancha.',
    instruction: 'Marca con ✗ dentro del símbolo del partido o la foto del candidato.',
    boxCount: 0,
  ),
  const _SecDef(
    number: 2,
    title: 'Senadores — Distrito Único (Nacional)',
    color: Color(0xFF154360),
    explanation:
        'Votas por senadores que representarán a TODO el Perú. Se elegirán 30 senadores nacionales.\n\n'
        'Primero marca el recuadro del partido y, opcionalmente, escribe el o los números de preferencia de tus candidatos favoritos dentro de ese partido.',
    instruction: 'Puedes escribir hasta 2 números de preferencia (no puedes repetir el mismo número).',
    boxCount: 2,
  ),
  const _SecDef(
    number: 3,
    title: 'Senadores — Distrito Múltiple (Regional)',
    color: Color(0xFF154360),
    explanation:
        'Votas por senadores que representarán a TU REGIÓN. Se elegirán 30 senadores regionales distribuidos por departamento.\n\n'
        'Primero marca el recuadro del partido y, opcionalmente, escribe el número de preferencia de tu candidato favorito de ese partido en tu región.',
    instruction: 'Puedes escribir 1 número de preferencia.',
    boxCount: 1,
  ),
  const _SecDef(
    number: 4,
    title: 'Diputados',
    color: Color(0xFF1B4F72),
    explanation:
        'Votas por diputados que integrarán la Cámara de Diputados. Se elegirán 130 diputados.\n\n'
        'Esta es la cámara baja del Congreso Bicameral del Perú. Puedes indicar tus candidatos preferidos dentro del partido elegido.',
    instruction: 'Puedes escribir hasta 2 números de preferencia (no puedes repetir el mismo número).',
    boxCount: 2,
  ),
  const _SecDef(
    number: 5,
    title: 'Parlamento Andino',
    color: Color(0xFF1A5276),
    explanation:
        'Votas por representantes de Perú ante el Parlamento Andino. Se elegirán 5 representantes.\n\n'
        'El Parlamento Andino es el órgano legislativo de la Comunidad Andina (Colombia, Ecuador, Bolivia y Perú).',
    instruction: 'Puedes escribir hasta 2 números de preferencia (no puedes repetir el mismo número).',
    boxCount: 2,
  ),
];

// ── Preference box ────────────────────────────────────────────────────────────

class _PrefBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const _PrefBox({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: _navy, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          final active = i == current;
          final done = i < current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 36 : 28,
              height: 28,
              decoration: BoxDecoration(
                color: active
                    ? _navy
                    : (done ? _navy.withValues(alpha: 0.40) : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: (active || done) ? Colors.white : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class VoteSimulatorScreen extends ConsumerStatefulWidget {
  const VoteSimulatorScreen({super.key});

  @override
  ConsumerState<VoteSimulatorScreen> createState() => _VoteSimulatorState();
}

class _VoteSimulatorState extends ConsumerState<VoteSimulatorScreen> {
  late final PageController _pc;
  int _currentPage = 0;

  // Intro state
  bool _started = false;

  // Section 1 state
  int? _presIdx;
  String? _presPartySelected;
  String? _presNameSelected;

  // Sections 2–5 selected party per section (ctrlIdx 0-3)
  List<int?> _selParty = [null, null, null, null];

  // Region for Senadores Múltiple (Sec3) and Diputados (Sec4)
  String? _regionSenMultiple;
  String? _regionDiputados;

  // Sections 2–5: [sectionControllerIdx][partyIdx][boxIdx]
  // sectionControllerIdx 0=Sec2, 1=Sec3, 2=Sec4, 3=Sec5
  late final List<List<List<TextEditingController>>> _ctrl;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _ctrl = List.generate(4, (si) {
      final boxes = (si == 1) ? 1 : 2; // Sec3 has 1 box
      return List.generate(
        _kPartyOrder.length,
        (_) => List.generate(boxes, (_) => TextEditingController()),
      );
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    for (final s in _ctrl) {
      for (final p in s) {
        for (final c in p) {
          c.dispose();
        }
      }
    }
    super.dispose();
  }

  void _goTo(int page) {
    _pc.animateToPage(page,
        duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    setState(() => _currentPage = page);
  }

  void _clearAll() {
    setState(() {
      _presIdx = null;
      _presPartySelected = null;
      _presNameSelected = null;
      _selParty = [null, null, null, null];
      _regionSenMultiple = null;
      _regionDiputados = null;
      _started = false;
    });
    for (final s in _ctrl) {
      for (final p in s) {
        for (final c in p) {
          c.clear();
        }
      }
    }
  }

  // ── Shared rule images card ────────────────────────────────────────────────

  Widget _rulesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
            SizedBox(width: 8),
            Text('Reglas de votación',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF4E342E))),
          ]),
          const SizedBox(height: 10),

          // Regla 1
          _ruleText('Marca con una CRUZ (✗) dentro del símbolo del partido o la foto del candidato.'),
          const SizedBox(height: 10),
          _ruleImg('assets/assets/MarcaCruz.png', 'Marca Cruz'),
          const SizedBox(height: 8),
          _ruleImg('assets/assets/MarcaX.png', 'Marca X'),
          const SizedBox(height: 12),

          // Regla 2
          _ruleText('Votar por MÁS DE 1 PARTIDO en una sección ANULA ese voto.'),
          const SizedBox(height: 10),
          _ruleImg('assets/assets/VotoInv\u00e1lido.png', 'Voto Inválido'),
          const SizedBox(height: 12),

          // Regla 3
          _ruleText('PUEDES votar por partidos DISTINTOS en cada sección sin anular ningún voto.'),
          const SizedBox(height: 10),
          _ruleImg('assets/assets/VotoPreferencial.png', 'Voto Preferencial'),
          const SizedBox(height: 8),
          _ruleImg('assets/assets/VotoV\u00e1lido.png', 'Voto Válido'),
        ],
      ),
    );
  }

  Widget _ruleText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(
                color: Color(0xFF795548), fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12.5, color: Color(0xFF5D4037), height: 1.4)),
        ),
      ],
    );
  }

  Widget _ruleImg(String path, String label) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            path,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Web-safe content wrapper (caps width on wide screens) ─────────────────

  Widget _webSafe(Widget child) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      );

  // ── Candidate lookup helper for results page ──────────────────────────────

  static String _normSim(String s) => s
      .toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ñ', 'N')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  CandidatoConHV? _findCand(
      List<CandidatoConHV> lista, String? partyName, String prefStr) {
    if (partyName == null) return null;
    final num = int.tryParse(prefStr.trim());
    if (num == null || num <= 0) return null;
    // Use _kPartyIdx so "JPP" matches "JUNTOS POR EL PERU" etc.
    final targetIdx = _kPartyIdx(partyName);
    if (targetIdx >= 0) {
      return lista
          .where((c) => _kPartyIdx(c.hv.partido) == targetIdx && c.posicion == num)
          .firstOrNull;
    }
    // Fallback: direct fuzzy match
    final norm = _normSim(partyName);
    return lista
        .where((c) {
          final cn = _normSim(c.hv.partido);
          return (cn == norm || cn.contains(norm) || norm.contains(cn)) &&
              c.posicion == num;
        })
        .firstOrNull;
  }

  // ── Duplicate preference prevention ──────────────────────────────────────

  void _checkDuplicatePref(int ctrlIdx, int partyIdx, int changedBoxIdx) {
    final controllers = _ctrl[ctrlIdx][partyIdx];
    final changedVal = controllers[changedBoxIdx].text.trim();
    if (changedVal.isNotEmpty) {
      for (int bi = 0; bi < controllers.length; bi++) {
        if (bi != changedBoxIdx &&
            controllers[bi].text.trim() == changedVal) {
          controllers[changedBoxIdx].clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No puedes ingresar el mismo número de preferencia dos veces.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          break;
        }
      }
    }
    setState(() {});
  }

  // ── Find index of a party name in _kPartyOrder (fuzzy, accent-insensitive) ─

  int _kPartyIdx(String partyName) {
    final norm = _normSim(partyName);
    final normNS = norm.replaceAll(' ', ''); // no-spaces variant
    for (int i = 0; i < _kPartyOrder.length; i++) {
      final k = _normSim(_kPartyOrder[i]);
      // Direct / contains match
      if (norm == k || norm.contains(k) || k.contains(norm)) return i;
      // Space-stripped match (e.g. "PARTIDO SICREO" ↔ "PARTIDO SI CREO")
      if (normNS == k.replaceAll(' ', '')) return i;
      // Alias match (e.g. "JUNTOS POR EL PERU" ↔ "JPP")
      final alias = _normSim(_kPartyDataName[_kPartyOrder[i]] ?? '');
      if (alias.isNotEmpty &&
          (norm == alias || norm.contains(alias) || alias.contains(norm))) {
        return i;
      }
    }
    return -1;
  }

  // ── Section explanation card ──────────────────────────────────────────────

  Widget _secCard(_SecDef def) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: def.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: def.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: def.color,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Sección ${def.number}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(def.title,
                  style: TextStyle(
                      color: def.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(def.explanation,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.5, color: Color(0xFF333333))),
          if (def.boxCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: def.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Icon(Icons.edit_rounded, size: 14, color: def.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(def.instruction,
                      style: TextStyle(
                          fontSize: 12,
                          color: def.color,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ── Cedula reference image (zoomable) ─────────────────────────────────────

  Widget _cedulaImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: const Color(0xFFFFB300)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ballot_outlined, size: 14, color: Color(0xFFF57F17)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Imagen de referencia — Cédula de votación 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _navy, width: 2),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(6)),
            child: Image.asset(
              'assets/assets/CedulaVotacion.png',
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ballot_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Cédula de Votación',
                          style: TextStyle(color: Colors.grey)),
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
              fontSize: 12,
              color: Color(0xFF666666),
              fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ── Intro page (before simulation starts) ─────────────────────────────────

  Widget _buildIntroPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBrandHeader(),
          // What is this
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _navy.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.how_to_vote_rounded, color: _navy, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'El Simulador de Cédula te explica cómo votar correctamente '
                    'en cada una de las 5 secciones de la cédula de votación '
                    'de las Elecciones Generales Perú 2026. '
                    'Practica antes del 12 de abril.',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade800,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          // Cedula reference
          _cedulaImage(),
          const SizedBox(height: 16),
          // Rules
          _rulesCard(),
          const SizedBox(height: 8),
          // Sections overview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.list_alt_rounded, size: 16, color: _navy),
                  const SizedBox(width: 8),
                  Text('Las 5 secciones de tu cédula',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _navy)),
                ]),
                const SizedBox(height: 10),
                ..._kSections.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: s.color, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${s.number}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(s.title,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ]),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // COMENZAR button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _started = true),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'COMENZAR VOTACIÓN',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CreditsFooter(),
        ],
      ),
    );
  }

  // ── Page 0: Sección 1 — Presidente ────────────────────────────────────────

  Widget _buildPage0() {
    final def = _kSections[0];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: _webSafe(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _secCard(def),
          _cedulaImage(),
          const SizedBox(height: 16),
          _rulesCard(),
          _buildPresSection(def.color),
        ],
      )),
    );
  }

  Widget _buildPresSection(Color color) {
    final async = ref.watch(
        candidatosConHVProcesoProvider(ProcesoElectoral.presidentes));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error al cargar: $e',
            style: const TextStyle(color: Colors.red)),
      ),
      data: (candidatos) {
        final Map<String, CandidatoConHV> byParty = {};
        for (final c in candidatos) {
          final upper = c.cargo.toUpperCase();
          if (upper.contains('PRESIDENTE') &&
              !upper.contains('VICE') &&
              !upper.contains('1') &&
              !upper.contains('2') &&
              !upper.contains('PRIMER') &&
              !upper.contains('SEGUNDO')) {
            byParty.putIfAbsent(c.hv.partido, () => c);
          }
        }
        for (final c in candidatos) {
          byParty.putIfAbsent(c.hv.partido, () => c);
        }
        // Sort by mandatory _kPartyOrder (alias-aware via _kPartyIdx)
        final parties = byParty.entries.toList()
          ..sort((a, b) {
            final ai = _kPartyIdx(a.key);
            final bi = _kPartyIdx(b.key);
            if (ai < 0 && bi < 0) return a.key.compareTo(b.key);
            if (ai < 0) return 1;
            if (bi < 0) return -1;
            return ai.compareTo(bi);
          });

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                color: color,
                child: Row(children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle),
                    child: const Center(
                        child: Text('1',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Selecciona la plancha presidencial',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ]),
              ),
              // All rows
              ...parties.asMap().entries.map((e) {
                return _presRow(e.key, e.value.key, e.value.value,
                    _presIdx == e.key, color);
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _presRow(int idx, String partyName, CandidatoConHV c,
      bool selected, Color color) {
    return InkWell(
      onTap: () => setState(() {
        _presIdx = selected ? null : idx;
        _presPartySelected = selected ? null : partyName;
        _presNameSelected = selected ? null : c.hv.nombre;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : null,
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(children: [
          // Party logo
          Stack(alignment: Alignment.center, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: selected ? color : Colors.grey.shade300,
                      width: selected ? 2.5 : 1),
                  color: Colors.white),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: PartyLogo(partyName: partyName, size: 38),
                ),
              ),
            ),
            if (selected)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: const Text('✗',
                    style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        height: 1.0)),
              ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(partyName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 6),
          // Candidate photo
          Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(alignment: Alignment.center, children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? color : Colors.grey.shade300,
                        width: selected ? 2 : 1),
                    color: Colors.grey.shade100),
                child: ClipOval(
                  child: (c.fotoUrl != null && c.fotoUrl!.isNotEmpty)
                      ? Image.network(c.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoFallback(c))
                      : _photoFallback(c),
                ),
              ),
              if (selected)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('✗',
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          height: 1.0)),
                ),
            ]),
            const SizedBox(height: 2),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3)),
              child: const Text('PRES',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _photoFallback(CandidatoConHV c) {
    final l = c.hv.nombre.isNotEmpty ? c.hv.nombre[0].toUpperCase() : '?';
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Text(l,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      ),
    );
  }

  // ── Pages 1–4: Party section pages ────────────────────────────────────────

  // ── Region picker card (Senadores Múltiple / Diputados) ──────────────────
  Widget _regionPicker({
    required String label,
    required String? current,
    required ValueChanged<String?> onChanged,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.location_on_rounded, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color)),
          ]),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            initialValue: current,
            decoration: InputDecoration(
              labelText: 'Selecciona tu región',
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— No especificar —',
                      style: TextStyle(fontSize: 12, color: Colors.grey))),
              ..._kRegiones.map((r) => DropdownMenuItem<String?>(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 12)),
                  )),
            ],
            onChanged: onChanged,
          ),
          if (current != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.check_circle_rounded,
                  size: 14, color: color),
              const SizedBox(width: 6),
              Text('Tu voto es por candidatos de: $current',
                  style: TextStyle(fontSize: 11, color: color,
                      fontWeight: FontWeight.w500)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildPartyPage(int pageIdx) {
    // pageIdx: 1=Sec2, 2=Sec3, 3=Sec4, 4=Sec5
    final def = _kSections[pageIdx];
    final ctrlIdx = pageIdx - 1; // maps to _ctrl[0..3]
    final boxes = _ctrl[ctrlIdx][0].length;

    // Region picker for Sec3 (Senadores Múltiple) and Sec4 (Diputados)
    final showRegion = pageIdx == 2 || pageIdx == 3;
    final regionLabel = pageIdx == 2
        ? '¿En qué región votarás a Senadores Regionales?'
        : '¿En qué región votarás a Diputados?';
    final regionCurrent = pageIdx == 2 ? _regionSenMultiple : _regionDiputados;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: _webSafe(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _secCard(def),
          if (showRegion)
            _regionPicker(
              label: regionLabel,
              current: regionCurrent,
              color: def.color,
              onChanged: (v) => setState(() {
                if (pageIdx == 2) { _regionSenMultiple = v; }
                else { _regionDiputados = v; }
              }),
            ),
          _rulesCard(),
          // Ballot card
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  color: def.color,
                  child: Row(children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('${def.number}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(def.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          maxLines: 2),
                    ),
                  ]),
                ),
                // Party rows — mandatory order from _kPartyOrder
                ..._kPartyOrder.asMap().entries.map((entry) {
                  final partyIdx = entry.key;
                  final name = entry.value;
                  final controllers = _ctrl[ctrlIdx][partyIdx];
                  final selected = _selParty[ctrlIdx] == partyIdx;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? def.color.withValues(alpha: 0.07)
                          : null,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => setState(() =>
                            _selParty[ctrlIdx] =
                                selected ? null : partyIdx),
                        child: Stack(alignment: Alignment.center, children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? def.color
                                    : Colors.grey.shade300,
                                width: selected ? 2 : 1,
                              ),
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: PartyLogo(partyName: name, size: 32),
                              ),
                            ),
                          ),
                          if (selected)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withValues(alpha: 0.12),
                              ),
                              alignment: Alignment.center,
                              child: const Text('✗',
                                  style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      height: 1.0)),
                            ),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(boxes, (bi) => Padding(
                          padding: EdgeInsets.only(left: bi == 0 ? 0 : 6),
                          child: _PrefBox(
                            controller: controllers[bi],
                            onChanged: () => _checkDuplicatePref(ctrlIdx, partyIdx, bi),
                          ),
                        )),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      )),
    );
  }

  // ── Page 5: Results summary ───────────────────────────────────────────────

  Widget _buildResultsPage() {
    // Load candidate data for preference lookup (read once when page is shown)
    final senadoresAll = ref
            .read(candidatosConHVProcesoProvider(ProcesoElectoral.senadores))
            .asData
            ?.value ??
        [];
    final diputados = ref
            .read(candidatosConHVProcesoProvider(ProcesoElectoral.diputados))
            .asData
            ?.value ??
        [];
    final parlAnd = ref
            .read(candidatosConHVProcesoProvider(
                ProcesoElectoral.parlamentoAndino))
            .asData
            ?.value ??
        [];
    final sectionCandidates = [
      senadoresAll.where((c) => c.tipoDistrito == 'ÚNICO').toList(),
      senadoresAll.where((c) =>
        c.tipoDistrito == 'MÚLTIPLE' &&
        (_regionSenMultiple == null || c.departamento == _regionSenMultiple)
      ).toList(),
      _regionDiputados == null
          ? diputados
          : diputados.where((c) => c.departamento == _regionDiputados).toList(),
      parlAnd,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: _webSafe(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, Color(0xFF0D2540)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              const Icon(Icons.how_to_vote_rounded,
                  color: Colors.white, size: 36),
              const SizedBox(height: 8),
              const Text(
                'Resumen de tu Voto Simulado',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Elecciones Generales Perú 2026 — 12 de abril',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          _buildVoteResult(
            sectionNum: 1,
            title: 'Presidente y Vicepresidentes',
            color: _kSections[0].color,
            partyName: _presPartySelected,
            candidateName: _presNameSelected,
            prefs: const [],
            isSelected: _presIdx != null,
          ),
          const SizedBox(height: 10),

          ...[0, 1, 2, 3].map((ctrlIdx) {
            final pageIdx = ctrlIdx + 1;
            final def = _kSections[pageIdx];
            final selIdx = _selParty[ctrlIdx];
            final partyName =
                selIdx != null ? _kPartyOrder[selIdx] : null;
            final prefs = selIdx != null
                ? _ctrl[ctrlIdx][selIdx]
                    .map((c) => c.text)
                    .where((t) => t.isNotEmpty)
                    .toList()
                : <String>[];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildVoteResult(
                sectionNum: pageIdx + 1,
                title: def.title,
                color: def.color,
                partyName: partyName,
                candidateName: null,
                prefs: prefs,
                isSelected: selIdx != null,
                sectionCandidates: sectionCandidates[ctrlIdx],
                region: ctrlIdx == 1 ? _regionSenMultiple
                       : ctrlIdx == 2 ? _regionDiputados
                       : null,
              ),
            );
          }),

          const SizedBox(height: 4),
          _buildOverallSummary(),
          const SizedBox(height: 10),
          _buildIntegrityWarnings(),
          const SizedBox(height: 10),

          // Motivational message
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDA4AF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.how_to_vote_rounded,
                    color: Color(0xFFBE123C), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Tu voto es tu voz — no la desperdicies!',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE123C)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No votar es, indirectamente, favorecer a quienes rechazas. '
                        'Los partidos que han llevado al Perú a la corrupción '
                        'cuentan con el ausentismo: mientras menos ciudadanos íntegros '
                        'voten, más fácil es para ellos ganar con su base cautiva.\n\n'
                        'Cada voto a un candidato honesto suma. Lleva a esta app '
                        'a tus amigos y familia para que también voten informados '
                        'el 12 de abril de 2026.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.red.shade900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const CreditsFooter(),
        ],
      )),
    );
  }

  Widget _buildVoteResult({
    required int sectionNum,
    required String title,
    required Color color,
    required String? partyName,
    required String? candidateName,
    required List<String> prefs,
    required bool isSelected,
    List<CandidatoConHV>? sectionCandidates,
    String? region,
  }) {
    final bool hasPref = prefs.isNotEmpty;
    final String statusText;
    final Color statusColor;
    final IconData statusIcon;

    if (isSelected) {
      statusText = 'VOTO VÁLIDO';
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_rounded;
    } else if (hasPref) {
      statusText = 'ADVERTENCIA — Preferencia sin partido marcado';
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.warning_rounded;
    } else {
      statusText = 'EN BLANCO / SIN MARCAR';
      statusColor = Colors.grey.shade500;
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? color.withValues(alpha: 0.4) : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
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
              width: 26,
              height: 26,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Text('$sectionNum',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color)),
            ),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (region != null) ...[
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 13, color: Colors.teal),
              const SizedBox(width: 4),
              Text('Región: $region',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.teal,
                      fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 8),
          ],
          if (partyName != null) ...[
            Row(children: [
              PartyLogo(partyName: partyName, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partyName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (candidateName != null)
                      Text(candidateName,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ]),
            if (prefs.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...prefs.asMap().entries.map((e) {
                final cand = _findCand(
                    sectionCandidates ?? [], partyName, e.value);
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: cand != null
                      ? () => showCandidatoHV(context, cand)
                      : null,
                  child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: color.withValues(alpha: 0.30)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pref. ${e.key + 1}: #${e.value}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (cand != null) ...[
                      if (cand.fotoUrl != null)
                        ClipOval(
                          child: Image.network(
                            cand.fotoUrl!,
                            width: 26,
                            height: 26,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox(),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cand.hv.nombre,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else if (sectionCandidates != null) ...[
                      Expanded(
                        child: Text(
                          'Número #${e.value} no encontrado en la lista del partido',
                          style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange.shade700),
                        ),
                      ),
                    ] else
                      const Expanded(child: SizedBox()),
                  ]),
                ),
                );
              }),
            ],
          ] else if (hasPref) ...[
            Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Escribiste número(s) de preferencia pero no marcaste ningún partido.',
                  style:
                      TextStyle(fontSize: 11, color: Colors.orange.shade700),
                ),
              ),
            ]),
          ] else ...[
            Text(
              'No marcaste ningún partido en esta sección.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 10),
          Row(children: [
            Icon(statusIcon, size: 14, color: statusColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(statusText,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildOverallSummary() {
    final totalMarked = (_presIdx != null ? 1 : 0) +
        _selParty.where((s) => s != null).length;
    final allMarked =
        _presIdx != null && _selParty.every((s) => s != null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: allMarked ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: allMarked
                ? Colors.green.shade300
                : Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            allMarked ? Icons.check_circle_rounded : Icons.info_rounded,
            color: allMarked
                ? Colors.green.shade700
                : Colors.amber.shade700,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allMarked
                      ? '¡Voto completo! Marcaste las 5 secciones.'
                      : 'Marcaste $totalMarked de 5 secciones.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: allMarked
                        ? Colors.green.shade800
                        : Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allMarked
                      ? 'Simulación completa. Puedes votar por distintos partidos en cada sección — todos son válidos.'
                      : 'Las secciones sin marcar cuentan como votos en blanco. Votar en blanco es tu derecho.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: allMarked
                        ? Colors.green.shade700
                        : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Integrity warnings for selected parties ───────────────────────────────

  Widget _buildIntegrityWarnings() {
    // Gather all selected party names across all sections
    final allSelected = <String>[];
    if (_presPartySelected != null) allSelected.add(_presPartySelected!);
    for (final idx in _selParty) {
      if (idx != null) allSelected.add(_kPartyOrder[idx]);
    }
    if (allSelected.isEmpty) return const SizedBox.shrink();

    // Data sources — use asData so we don't block rendering
    final proCrimenPartido =
        ref.read(proCrimenPartidoProvider).asData?.value ?? {};

    // Normalize helper
    String norm(String s) => s
        .toUpperCase()
        .replaceAll(',', ' ')
        .replaceAll('Á', 'A').replaceAll('É', 'E')
        .replaceAll('Í', 'I').replaceAll('Ó', 'O').replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Resolve display name → JNE partido name for party data lookup
    String resolveParty(String displayName) {
      final mapped = _kPartyDataName[displayName];
      return mapped ?? displayName;
    }

    final warnings = <_SimWarning>[];

    for (final display in allSelected.toSet()) {
      final jneName = resolveParty(display);
      final normDisplay = norm(display);
      final normJne = norm(jneName);

      // Pro-crimen: busca coincidencia parcial en el mapa
      int pcCount = 0;
      for (final entry in proCrimenPartido.entries) {
        final k = entry.key; // already normalized uppercase
        if (k == normDisplay || k == normJne ||
            normDisplay.contains(k) || normJne.contains(k) ||
            k.contains(normDisplay) || k.contains(normJne)) {
          if (entry.value > pcCount) pcCount = entry.value;
        }
      }
      if (pcCount > 0) {
        warnings.add(_SimWarning(
          party: display,
          icon: Icons.dangerous_rounded,
          color: Colors.deepOrange,
          message:
              'Su bancada anterior apoyó $pcCount ley(es) pro-crimen '
              'que facilitaron la corrupción y debilitaron la justicia.',
        ));
      }
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem_rounded,
                  color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡Atención! Alertas sobre tu voto simulado',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Gracias a partidos y candidatos como estos es que el Perú '
            'sigue en la misma situación. Considera elegir mejor.',
            style: TextStyle(
                fontSize: 11, color: Colors.red.shade700, height: 1.4),
          ),
          const SizedBox(height: 10),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PartyLogo(partyName: w.party, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(w.icon, size: 13, color: w.color),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  w.party,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: w.color),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(w.message,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade800,
                                  height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Bottom navigation bar ─────────────────────────────────────────────────

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(children: [
        if (_currentPage > 0) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _goTo(_currentPage - 1),
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Anterior'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _navy),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: _currentPage < 5
              ? Builder(builder: (_) {
                  // Region is required on page 2 (Sec3) and page 3 (Sec4)
                  final needsRegion =
                      (_currentPage == 2 && _regionSenMultiple == null) ||
                      (_currentPage == 3 && _regionDiputados == null);
                  return FilledButton(
                    onPressed: needsRegion
                        ? null
                        : () => _goTo(_currentPage + 1),
                    style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: needsRegion
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 6),
                              Text('Selecciona tu región',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Siguiente'),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            ],
                          ),
                  );
                })
              : OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Limpiar todo'),
                      content: const Text(
                          '¿Deseas borrar todas tus marcas y preferencias?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar')),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade700),
                          onPressed: () {
                            Navigator.pop(context);
                            _clearAll();
                            _goTo(0);
                          },
                          child: const Text('Limpiar todo'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.red, size: 16),
                  label: const Text('Limpiar todo',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
        ),
      ]),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        title: const Text('Simulador de Cédula',
            style: TextStyle(
                color: _navy, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navy),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _started
          ? Column(
              children: [
                _StepBar(current: _currentPage),
                Expanded(
                  child: PageView(
                    controller: _pc,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildPage0(),
                      _buildPartyPage(1),
                      _buildPartyPage(2),
                      _buildPartyPage(3),
                      _buildPartyPage(4),
                      _buildResultsPage(),
                    ],
                  ),
                ),
                _buildNavBar(),
              ],
            )
          : _buildIntroPage(),
    );
  }
}
