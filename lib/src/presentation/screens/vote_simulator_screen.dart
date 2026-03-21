import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import 'credits_screen.dart';

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
  'SíCreo',
  'País Para Todos',
  'Frente de la Esperanza 2021',
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
  'Partido de los Trabajadores y Emprendedores',
  'Unidad Nacional',
  'Partido Morado',
];

// ── Colors ────────────────────────────────────────────────────────────────────

const _navy = Color(0xFF1E3A5F);

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
        children: List.generate(5, (i) {
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

  // Section 1 state
  int? _presIdx;
  bool _presShowAll = false;

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
      _presShowAll = false;
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
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _ruleImg('assets/assets/MarcaCruz.png', 'Marca Cruz')),
            const SizedBox(width: 8),
            Expanded(child: _ruleImg('assets/assets/MarcaX.png', 'Marca X')),
          ]),
          const SizedBox(height: 10),

          // Regla 2
          _ruleText('Votar por MÁS DE 1 PARTIDO en una sección ANULA ese voto.'),
          const SizedBox(height: 8),
          _ruleImg('assets/assets/VotoInv\u00e1lido.png', 'Voto Inválido'),
          const SizedBox(height: 10),

          // Regla 3
          _ruleText('PUEDES votar por partidos DISTINTOS en cada sección sin anular ningún voto.'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _ruleImg('assets/assets/VotoPreferencial.png', 'Voto Preferencial')),
            const SizedBox(width: 8),
            Expanded(child: _ruleImg('assets/assets/VotoV\u00e1lido.png', 'Voto Válido')),
          ]),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: 56,
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
      ),
    );
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
              Icon(Icons.zoom_in, size: 14, color: Color(0xFFF57F17)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Imagen de referencia · Pellizca para hacer zoom',
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
          constraints: const BoxConstraints(maxHeight: 320),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(6)),
            child: InteractiveViewer(
              maxScale: 6.0,
              minScale: 0.5,
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

  // ── Page 0: Sección 1 — Presidente ────────────────────────────────────────

  Widget _buildPage0() {
    final def = _kSections[0];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBrandHeader(),
          _secCard(def),
          _cedulaImage(),
          const SizedBox(height: 16),
          _rulesCard(),
          _buildPresSection(def.color),
        ],
      ),
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
        final parties = byParty.entries.toList();
        final showCount =
            _presShowAll ? parties.length : (parties.length > 6 ? 6 : parties.length);

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
              // Rows
              ...parties.sublist(0, showCount).asMap().entries.map((e) {
                return _presRow(e.key, e.value.key, e.value.value,
                    _presIdx == e.key, color);
              }),
              if (parties.length > 6)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _presShowAll = !_presShowAll),
                    icon: Icon(
                        _presShowAll
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18),
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
          ),
        );
      },
    );
  }

  Widget _presRow(int idx, String partyName, CandidatoConHV c,
      bool selected, Color color) {
    return InkWell(
      onTap: () =>
          setState(() => _presIdx = selected ? null : idx),
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
              Text('✗',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color.withValues(alpha: 0.85))),
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
                Text('✗',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color.withValues(alpha: 0.85))),
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

  Widget _buildPartyPage(int pageIdx) {
    // pageIdx: 1=Sec2, 2=Sec3, 3=Sec4, 4=Sec5
    final def = _kSections[pageIdx];
    final ctrlIdx = pageIdx - 1; // maps to _ctrl[0..3]
    final isLast = pageIdx == 4;
    final boxes = _ctrl[ctrlIdx][0].length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _secCard(def),
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
                // Party rows
                ..._kPartyOrder.asMap().entries.map((entry) {
                  final partyIdx = entry.key;
                  final name = entry.value;
                  final controllers = _ctrl[ctrlIdx][partyIdx];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.grey.shade200))),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: PartyLogo(partyName: name, size: 32),
                          ),
                        ),
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
                            onChanged: () => setState(() {}),
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
          if (isLast) ...[
            const SizedBox(height: 24),
            const CreditsFooter(),
          ],
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
          child: _currentPage < 4
              ? FilledButton(
                  onPressed: () => _goTo(_currentPage + 1),
                  style: FilledButton.styleFrom(
                      backgroundColor: _navy,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Siguiente'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                )
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
      body: Column(
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
              ],
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }
}
