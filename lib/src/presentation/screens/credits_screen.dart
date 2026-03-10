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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo ────────────────────────────────────────────────────────
            Image.asset(
              'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
              height: 200,
              errorBuilder: (_, __, ___) => Icon(
                Icons.how_to_vote,
                size: 100,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // ── Badge ────────────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Por Estos Sí',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Elecciones Perú 2026',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'NATHARCE: Desarrollo de Software',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // ── Iniciativa ───────────────────────────────────────────────────
            _SectionTitle('Iniciativa'),
            _InfoCard(
              icon: Icons.groups,
              title: 'LA PELOTA EN NUESTRA CANCHA',
              subtitle: 'Promotor: Andrés Sotil',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.tiktok,
                      size: 16, color: Colors.black87),
                  label: 'TikTok',
                  handle: '@andressotil',
                  color: Colors.black87,
                  url: 'https://www.tiktok.com/@andressotil',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.instagram,
                      size: 16, color: Color(0xFFE1306C)),
                  label: 'Instagram',
                  handle: '@andressotil',
                  color: const Color(0xFFE1306C),
                  url: 'https://www.instagram.com/andressotil',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp,
                      size: 16, color: Color(0xFF25D366)),
                  label: 'WhatsApp',
                  handle: '+51 933 879 803',
                  color: const Color(0xFF25D366),
                  url: 'https://wa.me/51994894379',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.xTwitter,
                      size: 16, color: Colors.black87),
                  label: 'X',
                  handle: '@andressotil',
                  color: Colors.black87,
                  url: 'https://x.com/andressotil',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.globe,
                      size: 16, color: Colors.blue),
                  label: 'Web',
                  handle: 'lapelotaennuestracancha.com',
                  color: Colors.blue,
                  url: 'https://www.lapelotaennuestracancha.com',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.envelope,
                      size: 16, color: Colors.teal),
                  label: 'Email',
                  handle: 'profandressotil@hotmail.com',
                  color: Colors.teal,
                  url: 'mailto:profandressotil@hotmail.com',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── NATHARCE ─────────────────────────────────────────────────────
            _InfoCard(
              icon: Icons.code_rounded,
              title: 'NATHARCE: Desarrollo de Software web y móvil. Automatizaciones y despliegues en producción/nube. Soluciones a la medida de cada cliente.',
              subtitle: 'CEO: Patrick Harvey',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.tiktok,
                      size: 16, color: Colors.black87),
                  label: 'TikTok',
                  handle: '@natharce',
                  color: Colors.black87,
                  url: 'https://www.tiktok.com/@natharce',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp,
                      size: 16, color: Color(0xFF25D366)),
                  label: 'WhatsApp',
                  handle: '+51 994 894 379',
                  color: const Color(0xFF25D366),
                  url: 'https://wa.me/51994894379',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.globe,
                      size: 16, color: Colors.blue),
                  label: 'Web',
                  handle: 'natharce.netlify.app',
                  color: Colors.blue,
                  url: 'https://natharce.netlify.app/',
                ),
                _SocialChip(
                  icon: const FaIcon(FontAwesomeIcons.envelope,
                      size: 16, color: Colors.teal),
                  label: 'Email',
                  handle: 'natharce.eirl@gmail.com',
                  color: Colors.teal,
                  url: 'mailto:natharce.eirl@gmail.com',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Misión ───────────────────────────────────────────────────────
            _SectionTitle('Misión'),
            Card(
              elevation: 0,
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Por Estos Sí es una iniciativa de transparencia electoral que analiza '
                  'todos los partidos políticos y sus candidatos '
                  'para las elecciones generales del 2026 en Perú. '
                  'Se evaluaron sentencias judiciales, preparación académica,'
                  'vínculos con minería informal (REINFO) y otros indicadores de integridad pública.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // ── Footer ───────────────────────────────────────────────────────
            Text(
              '© 2026 Por Estos Sí — Todos los derechos reservados\n'
              'Datos con fines de transparencia electoral y educación cívica.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'NATHARCE: Desarrollo de Software',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

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

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

/// Chip de red social clicable.
/// [icon] acepta tanto [Icon] como [FaIcon].
/// [url] puede ser https://, mailto:, tel:, https://wa.me/...
class _SocialChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final String handle;
  final Color color;
  final String url;

  const _SocialChip({
    required this.icon,
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 8),
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
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded,
                  size: 12, color: color.withValues(alpha: 0.55)),
            ],
          ),
        ),
      ),
    );
  }
}
