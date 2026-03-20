import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'vote_simulator_screen.dart';
import 'proceso_menu_screen.dart';
import 'credits_screen.dart';
import 'resumen_general_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

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
              const AppBrandHeader(),

              // ── Sección: Procesos Electorales ────────────────────────────────
              _SectionHeader(
                label: 'PROCESOS ELECTORALES 2026',
                icon: Icons.how_to_vote_rounded,
              ),
              const SizedBox(height: 12),

              // Horizontal election process rows
              _ElectionRow(
                imagePath: 'assets/assets/Presidente.png',
                title: 'Presidente y Vicepresidentes',
                subtitle: 'Candidatos a la Presidencia y Vicepresidencias de la República',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(proceso: ProcesoElectoral.presidentes),
                )),
              ),
              const SizedBox(height: 8),
              _ElectionRow(
                imagePath: 'assets/assets/Diputados.png',
                title: 'Diputados',
                subtitle: 'Cámara de Diputados del Congreso de la República',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(proceso: ProcesoElectoral.diputados),
                )),
              ),
              const SizedBox(height: 8),
              _ElectionRow(
                imagePath: 'assets/assets/Senadores.png',
                title: 'Senadores',
                subtitle: 'Senado Nacional',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                ),
              ),
              const SizedBox(height: 8),
              _ElectionRow(
                imagePath: 'assets/assets/ParlamentoAndino.png',
                title: 'Parlamento Andino',
                subtitle: 'Representación regional de Perú ante el Parlamento Andino',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProcesoMenuScreen(proceso: ProcesoElectoral.parlamentoAndino),
                )),
              ),
              const SizedBox(height: 28),

              // ── Sección: Herramientas ─────────────────────────────────────────
              _SectionHeader(
                label: 'HERRAMIENTAS',
                icon: Icons.build,
              ),
              const SizedBox(height: 12),

              // Tools: 2 equal columns
              Row(
                children: [
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.how_to_vote_rounded,
                      title: 'Simulador de Voto',
                      subtitle: 'Aprende a votar correctamente',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const VoteSimulatorScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolCard(
                      icon: Icons.grade,
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

              // ── Créditos y Fuentes ────────────────────────────────────────────
              const SizedBox(height: 28),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 20),
              _CreditsCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreditsScreen()),
                ),
              ),

              // ── Footer ───────────────────────────────────────────────────────
              const SizedBox(height: 28),
              const CreditsFooter(),
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

// ─── Election process horizontal row ─────────────────────────────────────────

class _ElectionRow extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ElectionRow({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF154360)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.how_to_vote,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
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
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
          child: Column(
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

// ─── Credits card ─────────────────────────────────────────────────────────────

class _CreditsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreditsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E3A5F),
                const Color(0xFF0D2540),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Créditos y Metodología',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Equipo · Fuentes JNE/ONPE/REINFO · Cómo calculamos los puntajes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NATHARCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '#PORESTOSSI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
