import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

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
            // ── Logo ────────────────────────────────────────────────────────
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

            // ── Version badge ────────────────────────────────────────────────
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

            // Card NATHARCE
            _TeamCard(
              icon: Icons.code_rounded,
              iconBgColor: const Color(0xFF1D4ED8),
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
            const Divider(height: 1),
            const SizedBox(height: 20),

            // ── Footer ───────────────────────────────────────────────────────
            Text(
              '© 2026 Por Estos Sí + NATHARCE',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Todos los derechos reservados\n'
              'Datos con fines de transparencia electoral y educación cívica.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    height: 1.6,
                  ),
            ),
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
  final String name;
  final String role;
  final String person;
  final String description;
  final List<_SocialChipData> chips;

  const _TeamCard({
    required this.icon,
    required this.iconBgColor,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
          // Score categories
          const _ScoreRow(
            label: 'Educación',
            max: 'máx 40 pts',
            color: Color(0xFF0D47A1),
            icon: Icons.school_rounded,
            fraction: 0.40,
          ),
          const SizedBox(height: 10),
          const _ScoreRow(
            label: 'Integridad Penal',
            max: 'máx 35 pts',
            color: Color(0xFFB71C1C),
            icon: Icons.gavel_rounded,
            fraction: 0.35,
          ),
          const SizedBox(height: 10),
          const _ScoreRow(
            label: 'Cumplimiento',
            max: 'máx 25 pts',
            color: Color(0xFF1B5E20),
            icon: Icons.verified_rounded,
            fraction: 0.25,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Penalizaciones
          Text(
            'Penalizaciones',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          _PenalizationItem(
              text: 'Sentencia condenatoria firme: −15 pts por condena'),
          _PenalizationItem(
              text: 'Proceso penal activo relevante: −8 pts por proceso'),
          _PenalizationItem(
              text: 'Registro activo en REINFO (minería informal): −10 pts'),
          _PenalizationItem(
              text: 'Incumplimiento de declaración jurada de bienes: −5 pts'),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Bonus
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bonus universidad élite (top 500 QS o SUNEDU acreditada): +5 pts',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
          const Text('•  ',
              style: TextStyle(color: Color(0xFFB71C1C), fontSize: 13)),
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
          'Cada candidato recibe hasta 100 puntos distribuidos en tres categorías: '
          'Educación (40 pts), Integridad Penal (35 pts) y Cumplimiento (25 pts). '
          'Se aplican penalizaciones por condenas, procesos activos y vínculos con '
          'minería informal. Un bonus de +5 pts premia estudios en universidades élite.',
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(iconData, size: 14, color: color),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    handle,
                    style: TextStyle(fontSize: 10, color: color),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Icon(Icons.open_in_new_rounded,
                  size: 11, color: color.withValues(alpha: 0.55)),
            ],
          ),
        ),
      ),
    );
  }
}
