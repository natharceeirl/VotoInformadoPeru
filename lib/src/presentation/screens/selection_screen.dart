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
                  height: 300,
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
                        '+2,000 candidatos · 36 partidos · 4 procesos electorales',
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
                subtitle: 'Senado Nacional — análisis de transparencia',
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

              // Tools: 2+1 layout
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
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  children: const [
                    TextSpan(text: 'Desarrollado por '),
                    TextSpan(
                      text: 'NATHARCE',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(text: ' · Desarrollo de Software'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '#PORESTOSSI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
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
  final bool horizontal;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
