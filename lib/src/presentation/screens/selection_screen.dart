import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'vote_simulator_screen.dart';
import 'proceso_menu_screen.dart';
import 'credits_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo ────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.how_to_vote,
                    size: 80,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Elecciones Perú 2026',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Esta aplicación tiene como único objetivo informar a la ciudadanía. '
                  'No promueve ni representa a ningún partido político. '
                  'Todos los datos provienen de fuentes públicas oficiales (JNE · ONPE).',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // ── Sección: Procesos Electorales ────────────────────────────
              _SectionLabel('¿QUÉ PROCESO ELECTORAL TE INTERESA?'),
              const SizedBox(height: 12),

              // Presidente y Vicepresidente
              _ElectionCard(
                icon: Icons.star_rounded,
                title: 'Presidente y Vicepresidentes',
                subtitle: 'Candidatos a la Presidencia y Vicepresidencias de la República',
                details: const ['Conoce a los candidatos · Perfil de integridad'],
                accentColor: const Color(0xFF7B1FA2),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(
                    proceso: ProcesoElectoral.presidentes,
                  ),
                )),
              ),
              const SizedBox(height: 10),

              // Diputados
              _ElectionCard(
                icon: Icons.account_balance_rounded,
                title: 'Diputados',
                subtitle: 'Candidatos al Congreso de la República — Cámara de Diputados',
                details: const ['Por departamento · Perfil de integridad'],
                accentColor: const Color(0xFF1565C0),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(
                    proceso: ProcesoElectoral.diputados,
                  ),
                )),
              ),
              const SizedBox(height: 10),

              // Senadores
              _ElectionCard(
                icon: Icons.gavel_rounded,
                title: 'Senadores 2026',
                subtitle: 'Candidatos al Senado Nacional — análisis completo de transparencia',
                details: const [
                  '35 partidos · Índice de transparencia',
                  'Educación · Ingresos · Sentencias · REINFO',
                ],
                accentColor: const Color(0xFF00695C),
                badge: 'COMPLETO',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                ),
              ),
              const SizedBox(height: 10),

              // Parlamento Andino
              _ElectionCard(
                icon: Icons.public_rounded,
                title: 'Parlamento Andino',
                subtitle: 'Candidatos al Parlamento Andino — representación regional',
                details: const ['Conoce a los candidatos · Perfil de integridad'],
                accentColor: const Color(0xFFBF360C),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(
                    proceso: ProcesoElectoral.parlamentoAndino,
                  ),
                )),
              ),
              const SizedBox(height: 20),

              // ── Sección: Herramientas ────────────────────────────────────
              _SectionLabel('HERRAMIENTAS'),
              const SizedBox(height: 12),

              // Simulador de Voto
              _ElectionCard(
                icon: Icons.how_to_vote_rounded,
                title: 'Simulador de Voto',
                subtitle: 'Aprende a votar correctamente el día de las elecciones',
                details: const ['Guía paso a paso · Cédula virtual'],
                accentColor: const Color(0xFF2E7D32),
                badge: 'PRÓXIMAMENTE',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoteSimulatorScreen()),
                ),
              ),
              const SizedBox(height: 10),

              // Créditos
              _ElectionCard(
                icon: Icons.info_rounded,
                title: 'Créditos y Fuentes',
                subtitle: 'Equipo de desarrollo · Fuentes oficiales de datos',
                details: const ['NATHARCE: Desarrollo de Software · JNE · ONPE'],
                accentColor: const Color(0xFF546E7A),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreditsScreen()),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),
              Text(
                '#PORESTOSSI — Solo información pública · Datos: ONPE · JNE\nNATHARCE: Desarrollo de Software',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Label de sección ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

// ─── Tarjeta de proceso electoral (tema claro) ────────────────────────────────

class _ElectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> details;
  final Color accentColor;
  final String? badge;
  final VoidCallback onTap;

  const _ElectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.accentColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...details.map(
                      (d) => Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 12, color: accentColor.withValues(alpha: 0.6)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
