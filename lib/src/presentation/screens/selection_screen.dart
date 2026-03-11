import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'vote_simulator_screen.dart';
import 'proceso_menu_screen.dart';
import 'credits_screen.dart';
import 'resumen_general_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  static const _navy = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo ────────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 120,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.how_to_vote,
                    size: 80,
                    color: _navy,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Stats bar ───────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '+2,000 candidatos · 35 partidos · 4 procesos electorales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Sección: Procesos Electorales ────────────────────────────────
              _SectionHeader(
                label: 'PROCESOS ELECTORALES 2026',
                icon: Icons.how_to_vote_rounded,
              ),
              const SizedBox(height: 12),

              // 2-column grid for electoral process cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  _ElectionCard(
                    icon: Image.asset(
                      'assets/assets/Presidente.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.star_rounded,
                        size: 56,
                        color: Colors.white70,
                      ),
                    ),
                    title: 'Presidente y Vicepresidentes',
                    subtitle: 'Candidatos a la Presidencia y Vicepresidencias',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProcesoMenuScreen(
                        proceso: ProcesoElectoral.presidentes,
                      ),
                    )),
                  ),
                  _ElectionCard(
                    icon: Image.asset(
                      'assets/assets/Diputados.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.account_balance_rounded,
                        size: 56,
                        color: Colors.white70,
                      ),
                    ),
                    title: 'Diputados',
                    subtitle: 'Cámara de Diputados del Congreso de la República',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProcesoMenuScreen(
                        proceso: ProcesoElectoral.diputados,
                      ),
                    )),
                  ),
                  _ElectionCard(
                    icon: Image.asset(
                      'assets/assets/Senadores.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.gavel_rounded,
                        size: 56,
                        color: Colors.white70,
                      ),
                    ),
                    title: 'Senadores',
                    subtitle: 'Senado Nacional — análisis completo de transparencia',
                    badge: 'COMPLETO',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    ),
                  ),
                  _ElectionCard(
                    icon: Image.asset(
                      'assets/assets/ParlamentoAndino.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.public_rounded,
                        size: 56,
                        color: Colors.white70,
                      ),
                    ),
                    title: 'Parlamento Andino',
                    subtitle: 'Representación regional de Perú ante el Parlamento Andino',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProcesoMenuScreen(
                        proceso: ProcesoElectoral.parlamentoAndino,
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Sección: Herramientas ─────────────────────────────────────────
              _SectionHeader(
                label: 'HERRAMIENTAS',
                icon: Icons.build_rounded,
              ),
              const SizedBox(height: 12),

              // Tools: 2+1 layout
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.how_to_vote_rounded,
                      title: 'Simulador de Voto',
                      subtitle: 'Aprende a votar correctamente',
                      badge: 'INTERACTIVO',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const VoteSimulatorScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.analytics_rounded,
                      title: 'Resumen General',
                      subtitle: 'Top candidatos por integridad',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ResumenGeneralScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _ToolCard(
                  icon: Icons.info_rounded,
                  title: 'Créditos y Fuentes',
                  subtitle:
                      'Equipo de desarrollo · Fuentes oficiales de datos (NATHARCE: Desarrollo de Software · JNE · ONPE)',
                  horizontal: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreditsScreen()),
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────────────────────
              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text(
                '#PORESTOSSI — Datos: JNE · ONPE · NATHARCE',
                style: TextStyle(
                  color: Color(0xFF9EAABB),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
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

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E3A5F),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

// ─── Electoral process card (grid item) ──────────────────────────────────────

class _ElectionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ElectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF154360)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PNG image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: icon,
              ),
              const SizedBox(height: 12),
              // Badge
              if (badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tool card ────────────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool horizontal;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: horizontal
              ? Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: const Color(0xFF1E3A5F), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1E3A5F),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF1E3A5F),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: const Color(0xFF1E3A5F), size: 22),
                    ),
                    const SizedBox(height: 10),
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Color(0xFF1E3A5F),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
