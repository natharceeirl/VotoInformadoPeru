import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataSourcesScreen extends StatelessWidget {
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuente de los Datos'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Intro ────────────────────────────────────────────────────────
              _SectionCard(
                color: cs.primary,
                icon: Icons.analytics_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Índice de Transparencia y Riesgo de Corrupción',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este índice evalúa a los 35 partidos políticos con candidatos al '
                      'Senado Nacional del Perú para las Elecciones 2026. Combina 8 '
                      'indicadores normalizados (0–100) ponderados para producir un '
                      'Score Final de Transparencia por partido.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fuente principal: Elaborado con datos de '
                      'ONPE, JNE y Ministerio de Energía y Minas (REINFO) y el Congreso '
                      'de la República.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Fuentes de datos ─────────────────────────────────────────────
              _SectionHeader(label: 'FUENTES OFICIALES', icon: Icons.source_outlined, color: cs.primary),
              const SizedBox(height: 10),

              _SourceTile(
                icon: Icons.gavel_rounded,
                color: Colors.red,
                title: 'Sentencias Judiciales',
                subtitle: 'Poder Judicial del Perú',
                detail: 'Registro de candidatos con sentencias condenatorias firmes. '
                    'Se contabiliza el número total de sentencias por candidato.',
                url: 'https://www.pj.gob.pe/wps/wcm/connect/CorteSuprema/s_cortes_suprema_home/as_Inicio',
              ),
              _SourceTile(
                icon: Icons.terrain_rounded,
                color: Colors.orange,
                title: 'REINFO — Registro Integral de Formalización Minera',
                subtitle: 'Ministerio de Energía y Minas',
                detail: 'Candidatos vinculados al registro de minería informal/ilegal. '
                    'Incluye titulares, socios o representantes de concesiones en REINFO.',
                url: 'https://pad.minem.gob.pe/REINFO_WEB/Index.aspx',
              ),
              _SourceTile(
                icon: Icons.receipt_long_rounded,
                color: Colors.green,
                title: 'Declaración Jurada de Ingresos',
                subtitle: 'JNE — Jurado Nacional de Elecciones',
                detail: 'Ingresos mensuales declarados por cada candidato al momento '
                    'de la inscripción. Incluye ingresos totales y efectivos.',
                url: 'https://votoinformado.jne.gob.pe/home',
              ),
              _SourceTile(
                icon: Icons.school_rounded,
                color: Colors.blue,
                title: 'Nivel Educativo',
                subtitle: 'JNE — Hoja de vida del candidato',
                detail: 'Grado de instrucción declarado: primaria, secundaria, técnico, '
                    'universitario, maestría o doctorado.',
                url: 'https://votoinformado.jne.gob.pe/home',
              ),
              _SourceTile(
                icon: Icons.how_to_vote_rounded,
                color: Colors.indigo,
                title: 'Historial Congresal',
                subtitle: 'Congreso de la República del Perú',
                detail: 'Registro de candidatos que fueron congresistas en períodos '
                    'anteriores (reelección). Se considera el partido actual.',
                url: 'https://www.congreso.gob.pe/',
              ),
              _SourceTile(
                icon: Icons.groups_rounded,
                color: Colors.teal,
                title: 'Listas y Candidatos Inscritos',
                subtitle: 'ONPE / JNE — Padrón Electoral 2026',
                detail: 'Número total de candidatos inscritos por partido, incluyendo '
                    'candidatos efectivos (que presentaron lista completa).',
                url: 'https://eg2026.onpe.gob.pe/',
              ),

              const SizedBox(height: 16),

              // ── Indicadores I1–I8 ─────────────────────────────────────────────
              _SectionHeader(label: 'INDICADORES I1 – I8', icon: Icons.bar_chart_rounded, color: cs.primary),
              const SizedBox(height: 10),

              _IndicatorTile(
                number: 'I1',
                color: Colors.red,
                title: 'Sentencias Judiciales',
                description: 'Porcentaje de candidatos del partido con al menos una '
                    'sentencia judicial condenatoria firme sobre el total de candidatos '
                    'inscritos. A mayor porcentaje, menor score.',
                formula: 'I1 = 1 − (candidatos_con_sentencias / total_candidatos)',
                note: 'Normalizado 0–100. Ponderación por defecto: 25%',
              ),
              _IndicatorTile(
                number: 'I2',
                color: Colors.deepOrange,
                title: 'Preparación Académica',
                description: 'Promedio del nivel educativo de todos los candidatos del '
                    'partido, valorado en escala 1–7 (primaria=1, secundaria=2, '
                    'técnico=3, no universitario=4, universitario=5, maestría=6, '
                    'doctorado=7). A mayor preparación, mayor score.',
                formula: 'I2 = Σ(nivel_educativo_i) / n  →  normalizado 0–100',
                note: 'Ponderación por defecto: 10%',
              ),
              _IndicatorTile(
                number: 'I3',
                color: Colors.amber.shade700,
                title: 'Ingresos No Declarados (% cero)',
                description: 'Porcentaje de candidatos que declararon ingresos de S/0 '
                    '(sueldo cero). Un porcentaje alto sugiere falta de transparencia '
                    'económica. A mayor porcentaje de ceros, menor score.',
                formula: 'I3 = 1 − (candidatos_con_ingreso_0 / total_candidatos)',
                note: 'Normalizado 0–100. Ponderación por defecto: 15%',
              ),
              _IndicatorTile(
                number: 'I4',
                color: Colors.green,
                title: 'Ingresos Efectivos Declarados',
                description: 'Promedio de ingresos mensuales efectivos declarados por '
                    'los candidatos del partido. Refleja la capacidad económica real '
                    'y evita distorsiones por ceros.',
                formula: 'I4 = promedio(ingreso_mensual_efectivo_i)  →  normalizado 0–100',
                note: 'Ponderación por defecto: 10%',
              ),
              _IndicatorTile(
                number: 'I5',
                color: Colors.teal,
                title: 'Libre de Pacto con la Corrupción (TK3)',
                description: 'Indicador compuesto que evalúa si el partido está libre '
                    'de candidatos con antecedentes de corrupción documentada. '
                    'Combina sentencias, REINFO y reelección de congresistas sancionados.',
                formula: 'TK3 = TK1 × peso_sentencias + TK2 × peso_reinfo\n'
                    'TK1 = tasa_sentencias_ponderada\n'
                    'TK2 = tasa_reinfo_ponderada\n'
                    'I5 = 1 − TK3  →  normalizado 0–100',
                note: 'Ponderación por defecto: 20%',
              ),
              _IndicatorTile(
                number: 'I6',
                color: Colors.blue,
                title: 'REINFO — Minería Informal',
                description: 'Porcentaje de candidatos del partido vinculados al '
                    'Registro de Minería Informal (REINFO). Candidatos con actividad '
                    'en sectores de minería informal o ilegal.',
                formula: 'I6 = 1 − (candidatos_reinfo / total_candidatos)',
                note: 'Normalizado 0–100. Ponderación por defecto: 15%',
              ),
              _IndicatorTile(
                number: 'I7',
                color: Colors.indigo,
                title: 'Reelección de Congresistas',
                description: 'Número de candidatos que fueron congresistas en períodos '
                    'anteriores. Un número elevado puede indicar perpetuación de élites '
                    'políticas. Penaliza la reelección excesiva.',
                formula: 'I7 = 1 − (ex_congresistas / total_candidatos)',
                note: 'Normalizado 0–100. Ponderación por defecto: 5%',
              ),
              _IndicatorTile(
                number: 'I8',
                color: Colors.purple,
                title: 'Equipo Completo',
                description: 'Si el partido presentó lista con al menos 30 candidatos '
                    'al Senado Nacional. Refleja la capacidad organizativa del partido '
                    'y el compromiso con la participación electoral plena.',
                formula: 'I8 = (candidatos_inscritos ≥ 30) ? 100 : (candidatos / 30) × 100',
                note: 'Normalizado 0–100. Ponderación por defecto: 0% (informativo)',
              ),

              const SizedBox(height: 16),

              // ── Fórmula del Score Final ──────────────────────────────────────
              _SectionHeader(label: 'SCORE FINAL', icon: Icons.calculate_outlined, color: cs.primary),
              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score Final de Transparencia',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FormulaBox(
                        formula: 'Score = Σ(Ii × wi) / Σ(wi)\n\n'
                            'Donde:\n'
                            '  Ii = valor normalizado del indicador i (0–100)\n'
                            '  wi = peso asignado al indicador i\n\n'
                            'Pesos por defecto:\n'
                            '  I1 Sentencias        25%\n'
                            '  I2 Preparación       10%\n'
                            '  I3 Ing. No Decl.     15%\n'
                            '  I4 Ing. Efectivos    10%\n'
                            '  I5 Libre de Pacto    20%\n'
                            '  I6 REINFO            15%\n'
                            '  I7 Reelección         5%\n'
                            '  I8 Equipo Completo    0%\n'
                            '  ─────────────────────────\n'
                            '  Total               100%',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'El Score Final va de 0 (mayor riesgo) a 100 (máxima transparencia). '
                        'El usuario puede personalizar los pesos desde la pantalla "Configurar Indicadores".',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Escalas de ranking ───────────────────────────────────────────
              _SectionHeader(label: 'ESCALA DE EVALUACIÓN', icon: Icons.leaderboard_outlined, color: cs.primary),
              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _RangeTile(label: '80 – 100', desc: 'Transparencia alta', color: Colors.green),
                      _RangeTile(label: '60 – 79', desc: 'Transparencia media-alta', color: Colors.lightGreen),
                      _RangeTile(label: '40 – 59', desc: 'Riesgo moderado', color: Colors.amber),
                      _RangeTile(label: '20 – 39', desc: 'Riesgo elevado', color: Colors.orange),
                      _RangeTile(label: '0 – 19', desc: 'Riesgo muy alto', color: Colors.red, isLast: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Metodología — 8 Indicadores ─────────────────────────────────
              _SectionHeader(label: 'METODOLOGÍA — 8 INDICADORES', icon: Icons.science_outlined, color: cs.primary),
              const SizedBox(height: 10),
              Text(
                'El Índice de Transparencia pondera 8 factores. A mayor puntuación, menor riesgo de corrupción.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(
                  color: cs.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1)),
                    children: const [
                      Padding(padding: EdgeInsets.all(8), child: Text('Indicador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Peso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Qué mide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                  ...const [
                    ('Sentencias Judiciales', '20%', '% candidatos con condenas penales'),
                    ('Preparación Académica', '20%', 'Nivel educativo promedio del equipo'),
                    ('Ingresos No Declarados', '10%', 'Candidatos con cero o ingresos sospechosos'),
                    ('Ingresos Efectivos', '5%', 'Nivel económico real declarado'),
                    ('Libre de Pacto Corrupto', '25%', 'Sin vínculos con el #PorEstosNo'),
                    ('Sin Reelección', '10%', 'Candidatos nuevos vs. veteranos del congreso'),
                    ('Equipo Completo', '5%', 'Partido presentó los 30 candidatos'),
                    ('Sin Registros REINFO', '5%', 'Sin vínculos con minería informal'),
                  ].map(
                    (row) => TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(row.$1, style: const TextStyle(fontSize: 12))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(row.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(row.$3, style: const TextStyle(fontSize: 12, color: Colors.black54))),
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Fuente de Datos Principal ────────────────────────────────────
              _SectionHeader(label: 'FUENTE DE DATOS PRINCIPAL', icon: Icons.table_chart_outlined, color: cs.primary),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.table_chart, color: cs.primary, size: 20),
                ),
                title: Text('Datos públicos de ONPE y JNE',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Base de datos compilada con información pública de la ONPE, JNE y registros judiciales del Perú.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.2)),
                ),
                tileColor: cs.primary.withValues(alpha: 0.04),
                isThreeLine: true,
              ),

              const SizedBox(height: 16),

              // ── Nota legal ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: cs.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Esta herramienta es informativa y no vinculante. Los datos '
                        'provienen de fuentes públicas oficiales y pueden contener '
                        'imprecisiones. No representa una acusación formal ni una '
                        'recomendación de voto. Consulta siempre las fuentes originales '
                        'antes de tomar una decisión electoral.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
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
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(color: color.withValues(alpha: 0.3), thickness: 1),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.color, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String detail;
  final String url;

  const _SourceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.url,
  });

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: color.withValues(alpha: 0.6),
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }
}

class _IndicatorTile extends StatelessWidget {
  final String number;
  final Color color;
  final String title;
  final String description;
  final String formula;
  final String note;

  const _IndicatorTile({
    required this.number,
    required this.color,
    required this.title,
    required this.description,
    required this.formula,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                )),
          ),
        ),
        title: Text(title,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.25)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        collapsedBackgroundColor: color.withValues(alpha: 0.04),
        backgroundColor: color.withValues(alpha: 0.06),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: theme.textTheme.bodySmall),
                const SizedBox(height: 10),
                _FormulaBox(formula: formula),
                const SizedBox(height: 8),
                Text(
                  note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaBox extends StatelessWidget {
  final String formula;

  const _FormulaBox({required this.formula});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        formula,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;
  final bool isLast;

  const _RangeTile({
    required this.label,
    required this.desc,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  desc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}
