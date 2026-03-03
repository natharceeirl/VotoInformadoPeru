import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

// ─── Pantalla principal de recomendación ──────────────────────────────────────

class RecomendacionScreen extends ConsumerStatefulWidget {
  const RecomendacionScreen({super.key});

  @override
  ConsumerState<RecomendacionScreen> createState() =>
      _RecomendacionScreenState();
}

class _RecomendacionScreenState extends ConsumerState<RecomendacionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _deptoFilter; // sólo para Múltiple

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCandidatos = ref.watch(candidatosConHVProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Por quién votar?'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.flag_rounded), text: 'Nacional (Único)'),
            Tab(icon: Icon(Icons.map_rounded), text: 'Por Región (Múltiple)'),
          ],
        ),
      ),
      body: asyncCandidatos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar datos: $e')),
        data: (todos) {
          final unicos    = todos.where((c) => c.tipoDistrito == 'ÚNICO').toList()
            ..sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));
          final multiples = todos.where((c) => c.tipoDistrito == 'MÚLTIPLE').toList();

          final deptos = multiples.map((c) => c.departamento).toSet().toList()
            ..sort();

          final filtrados = _deptoFilter == null
              ? multiples
              : multiples.where((c) => c.departamento == _deptoFilter).toList();
          filtrados.sort((a, b) => b.hv.scoreFinal.compareTo(a.hv.scoreFinal));

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _CandidatosList(
                candidatos: unicos,
                headerText: 'Los 30 candidatos al Senado Nacional ordenados por perfil de integridad.',
              ),
              _MultipleTab(
                candidatos: filtrados,
                deptos: deptos,
                deptoSelected: _deptoFilter,
                onDeptoChanged: (d) => setState(() => _deptoFilter = d),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tab Múltiple con filtro por departamento ─────────────────────────────────

class _MultipleTab extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final List<String> deptos;
  final String? deptoSelected;
  final ValueChanged<String?> onDeptoChanged;

  const _MultipleTab({
    required this.candidatos,
    required this.deptos,
    required this.deptoSelected,
    required this.onDeptoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro de departamento
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Builder(builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.place_rounded, size: 18,
                      color: cs.onSurface.withValues(alpha: 0.55)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: deptoSelected,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('Todos los departamentos'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos los departamentos'),
                        ),
                        ...deptos.map(
                          (d) => DropdownMenuItem<String>(
                              value: d, child: Text(d)),
                        ),
                      ],
                      onChanged: onDeptoChanged,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        Expanded(
          child: _CandidatosList(
            candidatos: candidatos,
            headerText: deptoSelected == null
                ? 'Candidatos por región ordenados por perfil de integridad.'
                : 'Candidatos de $deptoSelected ordenados por perfil de integridad.',
          ),
        ),
      ],
    );
  }
}

// ─── Lista de candidatos ──────────────────────────────────────────────────────

class _CandidatosList extends StatelessWidget {
  final List<CandidatoConHV> candidatos;
  final String headerText;

  const _CandidatosList({
    required this.candidatos,
    required this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    if (candidatos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'Sin datos disponibles',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: candidatos.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) return _Header(text: headerText, count: candidatos.length);
        return _CandidatoCard(
          c: candidatos[i - 1],
          rank: i,
        );
      },
    );
  }
}

// ─── Encabezado de sección ────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String text;
  final int count;

  const _Header({required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
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

  const _CandidatoCard({required this.c, required this.rank});

  @override
  Widget build(BuildContext context) {
    final hv    = c.hv;
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hv.scoreColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetalle(context, c),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Rank + score ───────────────────────────────────────────────
              _ScoreBadge(rank: rank, hv: hv),
              const SizedBox(width: 12),

              // ── Foto ───────────────────────────────────────────────────────
              _PhotoOrAvatar(fotoUrl: c.fotoUrl, nombre: hv.nombre),
              const SizedBox(width: 12),

              // ── Info ───────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hv.nombre,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Partido + posición
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: PartyLogo(
                            partyName: hv.partido,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hv.partido,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.65),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '#${c.posicion}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Chips de indicadores
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Chip(
                          icon: hv.educacionIcon,
                          label: hv.educacionLabel,
                          color: hv.educacionColor,
                        ),
                        if (hv.totalSentenciasPenales > 0)
                          _Chip(
                            icon: Icons.gavel_rounded,
                            label: '${hv.totalSentenciasPenales} penal${hv.totalSentenciasPenales > 1 ? "es" : ""}',
                            color: const Color(0xFFC62828),
                          ),
                        if (hv.totalSentenciasObligaciones > 0)
                          _Chip(
                            icon: Icons.warning_amber_rounded,
                            label: '${hv.totalSentenciasObligaciones} oblig.',
                            color: Colors.orange,
                          ),
                        if (hv.totalSentenciasPenales == 0 &&
                            hv.totalSentenciasObligaciones == 0)
                          _Chip(
                            icon: Icons.verified_rounded,
                            label: 'Sin antecedentes',
                            color: const Color(0xFF2E7D32),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Resumen
                    Text(
                      hv.resumenPerfil,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Flecha
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Score badge circular ─────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int rank;
  final HojaVida hv;

  const _ScoreBadge({required this.rank, required this.hv});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rank number
        Text(
          '$rank',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        // Score circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hv.scoreBgColor,
            shape: BoxShape.circle,
            border: Border.all(color: hv.scoreColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${hv.scoreFinal}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hv.scoreColor,
                  height: 1,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontSize: 7,
                  color: hv.scoreColor.withValues(alpha: 0.7),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Foto o avatar ────────────────────────────────────────────────────────────

class _PhotoOrAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String nombre;

  const _PhotoOrAvatar({required this.fotoUrl, required this.nombre});

  String _initials() {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (fotoUrl != null) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: NetworkImage(fotoUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initials(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diálogo de detalle ───────────────────────────────────────────────────────

void _showDetalle(BuildContext context, CandidatoConHV c) {
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
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header con score
            Row(
              children: [
                _PhotoOrAvatar(fotoUrl: c.fotoUrl, nombre: hv.nombre),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hv.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hv.partido,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Score grande
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: hv.scoreBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: hv.scoreColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${hv.scoreFinal}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: hv.scoreColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        hv.scoreLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: hv.scoreColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Región / posición
            _DetailRow(
              Icons.place_rounded,
              '${c.tipoDistrito} · ${c.departamento}',
              'Distrito',
              cs.onSurface.withValues(alpha: 0.5),
            ),
            _DetailRow(
              Icons.format_list_numbered_rounded,
              'Posición #${c.posicion} en la lista',
              'Lista',
              cs.onSurface.withValues(alpha: 0.5),
            ),
            const Divider(height: 24),

            // Educación
            _SectionTitle('Educación', cs.primary),
            _DetailRow(
              hv.educacionIcon,
              hv.educacionLabel,
              'Nivel',
              hv.educacionColor,
            ),
            if (hv.posgrados.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...hv.posgrados.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Text(
                    '• $p',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            ],
            if (hv.universidades.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...hv.universidades.map(
                (u) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 2),
                  child: Text(
                    '• $u',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            ],
            const Divider(height: 24),

            // Integridad
            _SectionTitle('Integridad Judicial', cs.primary),
            _DetailRow(
              hv.totalSentenciasPenales == 0
                  ? Icons.check_circle_rounded
                  : Icons.gavel_rounded,
              hv.totalSentenciasPenales == 0
                  ? 'Sin sentencias penales'
                  : '${hv.totalSentenciasPenales} sentencia(s) penal(es)',
              'Penal',
              hv.totalSentenciasPenales == 0
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
            _DetailRow(
              hv.totalSentenciasObligaciones == 0
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              hv.totalSentenciasObligaciones == 0
                  ? 'Sin sentencias de obligación'
                  : '${hv.totalSentenciasObligaciones} sentencia(s) de obligación',
              'Obligaciones',
              hv.totalSentenciasObligaciones == 0
                  ? const Color(0xFF2E7D32)
                  : Colors.orange,
            ),
            const Divider(height: 24),

            // Score breakdown
            _SectionTitle('Detalle del Puntaje', cs.primary),
            _ScoreRow('Educación', hv.scoreEducacion, 40, hv.educacionColor),
            _ScoreRow('Integridad penal', hv.scoreIntegridadPenal, 35,
                hv.scoreIntegridadPenal >= 30
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828)),
            _ScoreRow('Cumplimiento oblig.', hv.scoreIntegridadOblig, 25,
                hv.scoreIntegridadOblig >= 20
                    ? const Color(0xFF2E7D32)
                    : Colors.orange),
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
                  Text(
                    'Puntaje total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${hv.scoreFinal} / 100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hv.scoreColor,
                    ),
                  ),
                ],
              ),
            ),

            if (hv.renuncioA.isNotEmpty) ...[
              const Divider(height: 24),
              _SectionTitle('Renuncias a partidos', Colors.orange),
              ...hv.renuncioA.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 2),
                  child: Text(
                    '• $r',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // Nota
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Puntaje calculado con datos públicos del JNE (hoja de vida). '
                'Edu. máx. (0–40) + Integ. penal (0–35) + Cumpl. oblig. (0–25).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
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
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _DetailRow(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  fontSize: 10,
                ),
          ),
        ],
      ),
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
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
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
          Text(
            '$score/$maxScore',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
