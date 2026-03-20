import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

// ── Shared App Brand Header ───────────────────────────────────────────────────
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
          height: 190,
          errorBuilder: (_, __, ___) => Icon(
            Icons.how_to_vote,
            size: 100,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Por Estos Sí · v1.0',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Elecciones Generales Perú 2026',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'NATHARCE: Desarrollo de Software',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 28),
        const Divider(height: 1),
        const SizedBox(height: 24),
      ],
    );
  }
}

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
         child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppBrandHeader(),

            // ── Misión ───────────────────────────────────────────────────────
            _SectionTitle('Misión'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: [
                  Icon(Icons.flag_rounded,
                      color: AppTheme.primaryColor, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    'Por Estos Sí es una iniciativa ciudadana de transparencia electoral '
                    'que analiza partidos y candidatos para las Elecciones Generales 2026 del Perú. '
                    'Evaluamos sentencias judiciales, preparación académica, vínculos con minería '
                    'informal (REINFO), cumplimiento de obligaciones públicas y otros indicadores '
                    'de integridad para que cada peruano ejerza su voto con información real.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.65, color: Colors.grey.shade800),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // ── Equipo ───────────────────────────────────────────────────────
            _SectionTitle('Equipo', highlight: true),

            // Card Andrés Sotil
            _TeamCard(
                icon: Icons.sports_soccer_rounded,
                iconBgColor: const Color(0xFF1E3A8A),
                bgColor: const Color(0xFFF0F4FF),
                borderColor: const Color(0xFF1E3A8A),
                name: 'LA PELOTA EN NUESTRA CANCHA',
                role: 'Promotor & Contenido',
                person: 'Andrés Sotil',
                description:
                    'Iniciativa ciudadana de educación cívica y transparencia política. '
                    'Responsable del análisis de datos, contenido editorial y difusión.',
                chips: const [
                  _SocialChipData(
                    platform: 'TikTok',
                    handle: '@andressotil',
                    iconData: FontAwesomeIcons.tiktok,
                    color: Colors.black87,
                    url: 'https://www.tiktok.com/@andressotil',
                  ),
                  _SocialChipData(
                    platform: 'Instagram',
                    handle: '@andressotil',
                    iconData: FontAwesomeIcons.instagram,
                    color: Color(0xFFE1306C),
                    url: 'https://www.instagram.com/andressotil',
                  ),
                  _SocialChipData(
                    platform: 'WhatsApp',
                    handle: '+51 933 879 803',
                    iconData: FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366),
                    url: 'https://wa.me/51933879803',
                  ),
                  _SocialChipData(
                    platform: 'X',
                    handle: '@andressotil',
                    iconData: FontAwesomeIcons.xTwitter,
                    color: Colors.black87,
                    url: 'https://x.com/andressotil',
                  ),
                  _SocialChipData(
                    platform: 'Web',
                    handle: 'lapelotaennuestracancha.com',
                    iconData: FontAwesomeIcons.globe,
                    color: Color(0xFF2563EB),
                    url: 'https://www.lapelotaennuestracancha.com',
                  ),
                  _SocialChipData(
                    platform: 'Email',
                    handle: 'profandressotil@hotmail.com',
                    iconData: FontAwesomeIcons.envelope,
                    color: Color(0xFF0D9488),
                    url: 'mailto:profandressotil@hotmail.com',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _TeamCard(
                icon: Icons.code_rounded,
                iconBgColor: const Color(0xFF1D4ED8),
                bgColor: const Color(0xFFEBF3FF),
                borderColor: const Color(0xFF1D4ED8),
                name: 'NATHARCE',
                role: 'Desarrollo de Software',
                person: 'Patrick Harvey',
                description:
                    'Desarrollo web y móvil. Automatizaciones y despliegues en producción/nube. '
                    'Soluciones tecnológicas a la medida de cada cliente.',
                chips: const [
                  _SocialChipData(
                    platform: 'TikTok',
                    handle: '@natharce',
                    iconData: FontAwesomeIcons.tiktok,
                    color: Colors.black87,
                    url: 'https://www.tiktok.com/@natharce',
                  ),
                  _SocialChipData(
                    platform: 'WhatsApp',
                    handle: '+51 994 894 379',
                    iconData: FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366),
                    url: 'https://wa.me/51994894379',
                  ),
                  _SocialChipData(
                    platform: 'Web',
                    handle: 'natharce.netlify.app',
                    iconData: FontAwesomeIcons.globe,
                    color: Color(0xFF2563EB),
                    url: 'https://natharce.netlify.app/',
                  ),
                  _SocialChipData(
                    platform: 'Email',
                    handle: 'natharce.eirl@gmail.com',
                    iconData: FontAwesomeIcons.envelope,
                    color: Color(0xFF0D9488),
                    url: 'mailto:natharce.eirl@gmail.com',
                  ),
                ],
              ),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // ── Fuentes de Datos ─────────────────────────────────────────────
            _SectionTitle('Fuentes de Datos'),
            _DataSourcesGrid(),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // ── Metodología ──────────────────────────────────────────────────
            _SectionTitle('Metodología de Puntuación'),
            _MetodologiaCard(),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // ── Preguntas Frecuentes ─────────────────────────────────────────
            _SectionTitle('Preguntas Frecuentes'),
            _FaqSection(),

            const SizedBox(height: 28),

            // ── Metodología de Ranking de Partidos ──────────────────────────
            _SectionTitle('Metodología de Ranking de Partidos'),
            _PartyRankingSection(),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // ── Footer ───────────────────────────────────────────────────────
            const CreditsFooter(),
            const SizedBox(height: 32),
          ],
         ),
        ),
       ),
      ),
    );
  }
}

// ── Data model for social chips ────────────────────────────────────────────────

class _SocialChipData {
  final String platform;
  final String handle;
  final IconData iconData;
  final Color color;
  final String url;

  const _SocialChipData({
    required this.platform,
    required this.handle,
    required this.iconData,
    required this.color,
    required this.url,
  });
}

// ── Team Card ──────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color bgColor;
  final Color borderColor;
  final String name;
  final String role;
  final String person;
  final String description;
  final List<_SocialChipData> chips;

  const _TeamCard({
    required this.icon,
    required this.iconBgColor,
    required this.bgColor,
    required this.borderColor,
    required this.name,
    required this.role,
    required this.person,
    required this.description,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: iconBgColor.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      person,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((c) => _SocialChip(
                      iconData: c.iconData,
                      label: c.platform,
                      handle: c.handle,
                      color: c.color,
                      url: c.url,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Data Sources Grid ──────────────────────────────────────────────────────────

class _DataSourcesGrid extends StatelessWidget {
  final List<_DataSource> sources = const [
    _DataSource(
      label: 'JNE',
      sublabel: 'Jurado Nacional\nde Elecciones',
      icon: Icons.how_to_vote_rounded,
      color: Color(0xFF1E3A8A),
    ),
    _DataSource(
      label: 'ONPE',
      sublabel: 'Oficina Nacional\nde Procesos Electorales',
      icon: Icons.ballot_rounded,
      color: Color(0xFF1D4ED8),
    ),
    _DataSource(
      label: 'Poder Judicial',
      sublabel: 'Sentencias y\nantecedentes penales',
      icon: Icons.gavel_rounded,
      color: Color(0xFF7C3AED),
    ),
    _DataSource(
      label: 'SUNEDU',
      sublabel: 'Superintendencia\nUniversitaria',
      icon: Icons.school_rounded,
      color: Color(0xFF0891B2),
    ),
    _DataSource(
      label: 'MINEM / REINFO',
      sublabel: 'Registro minería\ninformal',
      icon: Icons.terrain_rounded,
      color: Color(0xFF065F46),
    ),
  ];

  const _DataSourcesGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sources.map((s) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.color.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(s.icon, color: s.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.label,
                        style: TextStyle(
                          color: s.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        s.sublabel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DataSource {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;

  const _DataSource({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
  });
}

// ── Metodología Card ───────────────────────────────────────────────────────────

class _MetodologiaCard extends StatelessWidget {
  const _MetodologiaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Puntaje base ──────────────────────────────────────────────────
          _MetLabel('Puntaje Base (máx 100 pts)'),
          const SizedBox(height: 10),
          const _ScoreRow(
            label: 'Educación',
            max: 'máx 40 pts',
            color: Color(0xFF0D47A1),
            icon: Icons.school_rounded,
            fraction: 0.40,
          ),
          const SizedBox(height: 8),
          const _ScoreRow(
            label: 'Integridad Penal',
            max: 'máx 35 pts',
            color: Color(0xFFB71C1C),
            icon: Icons.gavel_rounded,
            fraction: 0.35,
          ),
          const SizedBox(height: 8),
          const _ScoreRow(
            label: 'Cumplimiento de Obligaciones',
            max: 'máx 25 pts',
            color: Color(0xFF1B5E20),
            icon: Icons.verified_rounded,
            fraction: 0.25,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Bono ──────────────────────────────────────────────────────────
          _MetLabel('Bonificación'),
          const SizedBox(height: 8),
          _BonusItem(
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF6A1B9A),
            text: 'Universidad de élite reconocida (top 500 QS o SUNEDU acreditada): +5 pts',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Penalizaciones ────────────────────────────────────────────────
          _MetLabel('Penalizaciones'),
          const SizedBox(height: 8),
          _PenalizationItem(
              text: 'Sentencia penal: −23 pts (1 condena) ó −35 pts (2+ condenas)'),
          _PenalizationItem(
              text: 'Sentencia de obligaciones: −15 pts (1), −21 pts (2), −25 pts (3+)'),
          _PenalizationItem(
              text: 'Vinculado a REINFO (minería informal): −10 pts; −15 pts si 5+ licencias'),
          _PenalizationItem(
              text: 'Universidad con licencia denegada o cuestionada: −5 pts'),
          _PenalizationItem(
              text: 'Cargo público previo de riesgo (congresista −5, alcalde −3, ministro −3, gobernador −3, asesor −2; máx −15)'),
          _PenalizationItem(
              text: 'Investigaciones o controversias graves conocidas: −10 pts'),
          _PenalizationItem(
              text: 'Partido apoyó leyes pro-crimen: −8 pts por ley apoyada (máx −25 pts)'),
          _PenalizationItem(
              text: 'Candidato votó a favor de leyes pro-crimen: −5 pts por ley (máx −20 pts)'),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Fórmula ───────────────────────────────────────────────────────
          _MetLabel('Fórmula del Score Final'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF1E3A5F).withValues(alpha: 0.18)),
            ),
            child: const Text(
              'Score = Educación + Integridad Penal + Cumplimiento\n'
              '      + BonusUniversidadÉlite\n'
              '      − PenaltyReinfo − PenaltyUniversidadCuestionada\n'
              '      − PenaltyCargosPublicos − PenaltyInvestigaciones\n'
              '      − PenaltyProCrimenPersonal − PenaltyProCrimenPartido\n\n'
              'Rango teórico: 0 – 105 pts (sin límite superior)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                height: 1.6,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String max;
  final Color color;
  final IconData icon;
  final double fraction;

  const _ScoreRow({
    required this.label,
    required this.max,
    required this.color,
    required this.icon,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              max,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PenalizationItem extends StatelessWidget {
  final String text;

  const _PenalizationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('−  ',
              style: TextStyle(color: Color(0xFFB71C1C), fontSize: 13,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetLabel extends StatelessWidget {
  final String text;
  const _MetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}

class _BonusItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _BonusItem({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ── FAQ Section ────────────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: '¿Los datos son oficiales?',
      answer:
          'Sí. Todos los datos provienen de fuentes públicas oficiales: JNE, ONPE, '
          'Poder Judicial, SUNEDU y MINEM/REINFO. No utilizamos información de terceros '
          'no verificados ni redes sociales.',
    ),
    _FaqItem(
      question: '¿Esta app apoya a algún partido político?',
      answer:
          'No. Por Estos Sí es una iniciativa ciudadana completamente independiente. '
          'No está financiada ni afiliada a ningún partido político, candidato o '
          'institución pública o privada.',
    ),
    _FaqItem(
      question: '¿Cómo se calcula la puntuación?',
      answer:
          'Cada candidato recibe hasta 105 puntos distribuidos en tres categorías: '
          'Educación (40 pts), Integridad Penal (35 pts) y Cumplimiento (25 pts). '
          'Se aplican penalizaciones por condenas, procesos activos y vínculos con '
          'minería informal. Un bonus premia estudios en universidades élite (5 pts).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _faqs
          .map(
            (faq) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE4FF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  leading: const Icon(Icons.help_outline_rounded,
                      color: AppTheme.primaryColor, size: 20),
                  title: Text(
                    faq.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  children: [
                    Text(
                      faq.answer,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Future<void> _launchSocial(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }
}

// ── Reusable Widgets ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool highlight;

  const _SectionTitle(this.text, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: highlight
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData iconData;
  final String label;
  final String handle;
  final Color color;
  final String url;

  const _SocialChip({
    required this.iconData,
    required this.label,
    required this.handle,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchSocial(context, url),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(iconData, size: 14, color: Colors.white),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    handle,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              const Icon(Icons.open_in_new_rounded,
                  size: 11, color: Colors.white60),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Party Ranking Methodology Section ─────────────────────────────────────────

class _PartyRankingSection extends StatelessWidget {
  const _PartyRankingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Intro
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Índice de Transparencia y Riesgo de Corrupción',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                'Este índice evalúa a los 38 partidos políticos con candidatos al '
                'Senado Nacional del Perú para las Elecciones 2026. Combina 8 '
                'indicadores normalizados (0–100) ponderados para producir un '
                'Score Final de Transparencia por partido.',
                style: TextStyle(fontSize: 12.5, height: 1.55, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 6),
              Text(
                'Fuente: Datos públicos de ONPE, JNE, Ministerio de Energía y Minas '
                '(REINFO) y Congreso de la República.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fuentes oficiales
        _CrSectionHeader(label: 'FUENTES OFICIALES', icon: Icons.source_outlined, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        _CrSourceTile(icon: Icons.gavel_rounded, color: Colors.red, title: 'Sentencias Judiciales',
            subtitle: 'Poder Judicial del Perú',
            detail: 'Candidatos con sentencias condenatorias firmes. Se contabiliza el número total por candidato.'),
        _CrSourceTile(icon: Icons.terrain_rounded, color: Colors.orange, title: 'REINFO — Registro Integral de Formalización Minera',
            subtitle: 'Ministerio de Energía y Minas',
            detail: 'Candidatos vinculados al registro de minería informal/ilegal. Incluye titulares, socios o representantes.'),
        _CrSourceTile(icon: Icons.receipt_long_rounded, color: Colors.green, title: 'Declaración Jurada de Ingresos',
            subtitle: 'JNE — Jurado Nacional de Elecciones',
            detail: 'Ingresos declarados al momento de inscripción. Incluye ingresos totales y efectivos.'),
        _CrSourceTile(icon: Icons.school_rounded, color: Colors.blue, title: 'Nivel Educativo',
            subtitle: 'JNE — Hoja de vida del candidato',
            detail: 'Grado de instrucción declarado: primaria, secundaria, técnico, universitario, maestría o doctorado.'),
        _CrSourceTile(icon: Icons.how_to_vote_rounded, color: Colors.indigo, title: 'Historial Congresal',
            subtitle: 'Congreso de la República del Perú',
            detail: 'Candidatos que fueron congresistas en períodos anteriores (reelección).'),
        const SizedBox(height: 16),

        // Indicadores
        _CrSectionHeader(label: 'INDICADORES I1 – I8', icon: Icons.bar_chart_rounded, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        _CrIndicatorTile(number: 'I1', color: Colors.red, title: 'Sentencias Judiciales',
            description: '% de candidatos del partido con al menos una sentencia condenatoria firme sobre el total.',
            formula: 'I1 = 1 − (candidatos_con_sentencias / total_candidatos)',
            note: 'Normalizado 0–100. Ponderación: 25%'),
        _CrIndicatorTile(number: 'I2', color: Colors.deepOrange, title: 'Preparación Académica',
            description: 'Promedio del nivel educativo (escala 1–7: primaria→doctorado).',
            formula: 'I2 = Σ(nivel_educativo_i) / n  →  normalizado 0–100',
            note: 'Ponderación: 10%'),
        _CrIndicatorTile(number: 'I3', color: const Color(0xFFB45309), title: 'Ingresos No Declarados',
            description: '% de candidatos que declararon ingresos de S/0. Un % alto sugiere falta de transparencia.',
            formula: 'I3 = 1 − (candidatos_con_ingreso_0 / total_candidatos)',
            note: 'Normalizado 0–100. Ponderación: 15%'),
        _CrIndicatorTile(number: 'I4', color: Colors.green, title: 'Ingresos Efectivos Declarados',
            description: 'Promedio de ingresos efectivos declarados. Refleja la capacidad económica real.',
            formula: 'I4 = promedio(ingreso_mensual_efectivo_i)  →  normalizado 0–100',
            note: 'Ponderación: 10%'),
        _CrIndicatorTile(number: 'I5', color: Colors.teal, title: 'Libre de Pacto con la Corrupción (TK3)',
            description: 'Indicador compuesto: libre de candidatos con antecedentes documentados de corrupción (sentencias + REINFO + congresistas sancionados).',
            formula: 'TK3 = TK1×peso_sentencias + TK2×peso_reinfo\nI5 = 1 − TK3  →  normalizado 0–100',
            note: 'Ponderación: 20%'),
        _CrIndicatorTile(number: 'I6', color: Colors.blue, title: 'REINFO — Minería Informal',
            description: '% de candidatos del partido vinculados al Registro de Minería Informal.',
            formula: 'I6 = 1 − (candidatos_reinfo / total_candidatos)',
            note: 'Normalizado 0–100. Ponderación: 15%'),
        _CrIndicatorTile(number: 'I7', color: Colors.indigo, title: 'Reelección de Congresistas',
            description: 'Nº de candidatos que fueron congresistas anteriormente. Penaliza perpetuación de élites.',
            formula: 'I7 = 1 − (ex_congresistas / total_candidatos)',
            note: 'Normalizado 0–100. Ponderación: 5%'),
        _CrIndicatorTile(number: 'I8', color: Colors.purple, title: 'Equipo Completo',
            description: 'Si el partido presentó al menos 30 candidatos al Senado Nacional.',
            formula: 'I8 = (candidatos ≥ 30) ? 100 : (candidatos / 30) × 100',
            note: 'Ponderación: 0% (informativo)'),
        const SizedBox(height: 16),

        // Score final
        _CrSectionHeader(label: 'SCORE FINAL', icon: Icons.calculate_outlined, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE4FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Score Final de Transparencia (Partidos)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800)),
              const SizedBox(height: 10),
              _CrFormulaBox(
                formula: 'Score = Σ(Ii × wi) / Σ(wi)\n\n'
                    'Pesos por defecto:\n'
                    '  I1 Sentencias          25%\n'
                    '  I2 Preparación         10%\n'
                    '  I3 Ing. No Declarados  15%\n'
                    '  I4 Ing. Efectivos      10%\n'
                    '  I5 Libre de Pacto      20%\n'
                    '  I6 REINFO              15%\n'
                    '  I7 Reelección           5%\n'
                    '  I8 Equipo Completo      0%\n'
                    '  ────────────────────────\n'
                    '  Total                 100%',
              ),
              const SizedBox(height: 8),
              Text(
                'Score 0 = mayor riesgo · Score 100 = máxima transparencia. '
                'El usuario puede personalizar los pesos desde "Configurar Indicadores".',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Escala
        _CrSectionHeader(label: 'ESCALA DE EVALUACIÓN', icon: Icons.leaderboard_outlined, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE4FF)),
          ),
          child: Column(children: [
            _CrRangeTile(label: '80 – 105', desc: 'Transparencia alta', color: Colors.green),
            _CrRangeTile(label: '60 – 79', desc: 'Transparencia media-alta', color: Colors.lightGreen),
            _CrRangeTile(label: '40 – 59', desc: 'Riesgo moderado', color: Colors.amber),
            _CrRangeTile(label: '20 – 39', desc: 'Riesgo elevado', color: Colors.orange),
            _CrRangeTile(label: '0 – 19', desc: 'Riesgo muy alto', color: Colors.red, isLast: true),
          ]),
        ),
        const SizedBox(height: 16),

        // Nota legal
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Esta herramienta es informativa y no vinculante. Los datos provienen '
                  'de fuentes públicas oficiales y pueden contener imprecisiones. '
                  'No representa una acusación formal ni una recomendación de voto. '
                  'Consulta siempre las fuentes originales antes de tomar una decisión electoral.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF92400E),
                    height: 1.55,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Credits Footer (public so other screens can reuse it) ─────────────────────

class CreditsFooter extends StatelessWidget {
  const CreditsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF0D2540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
            height: 70,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.how_to_vote,
              size: 48,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '#PORESTOSSI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.6),
              children: [
                const TextSpan(text: 'Desarrollado por '),
                const TextSpan(
                  text: 'NATHARCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const TextSpan(text: ' · Desarrollo de Software\n'),
                TextSpan(
                  text: 'Patrick Harvey · natharce.eirl@gmail.com',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '© 2026 Por Estos Sí · Elecciones Generales Perú',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.50),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Herramienta informativa · Datos con fines de transparencia electoral',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.40),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Party Ranking Helper Widgets ──────────────────────────────────────────────

class _CrSectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CrSectionHeader({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha: 0.3), thickness: 1)),
      ],
    );
  }
}

class _CrSourceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String detail;

  const _CrSourceTile({
    required this.icon, required this.color, required this.title,
    required this.subtitle, required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrIndicatorTile extends StatelessWidget {
  final String number;
  final Color color;
  final String title;
  final String description;
  final String formula;
  final String note;

  const _CrIndicatorTile({
    required this.number, required this.color, required this.title,
    required this.description, required this.formula, required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: Text(number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                  Text(description,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.45)),
                  const SizedBox(height: 8),
                  _CrFormulaBox(formula: formula),
                  const SizedBox(height: 6),
                  Text(note,
                      style: TextStyle(fontSize: 11, color: color,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrFormulaBox extends StatelessWidget {
  final String formula;
  const _CrFormulaBox({required this.formula});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        formula,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.55),
      ),
    );
  }
}

class _CrRangeTile extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;
  final bool isLast;

  const _CrRangeTile({
    required this.label, required this.desc, required this.color, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(desc,
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
