import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'vote_simulator_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo ──────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 160,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.how_to_vote,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Senado Nacional Perú • Elecciones 2026',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // ── Title ─────────────────────────────────────────────────
              Text(
                '¿Qué deseas hacer?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige una opción para comenzar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── Card: Senadores ───────────────────────────────────────
              _SelectionCard(
                icon: Icons.account_balance_rounded,
                title: 'Senadores 2026',
                subtitle:
                    'Explora el perfil de los 963 candidatos al Senado Nacional',
                details: const [
                  '35 partidos · Transparencia · Riesgo',
                  'Educación · Ingresos · Sentencias · REINFO',
                ],
                gradient: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                borderColor: const Color(0xFF42A5F5),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── Card: Simulador de Voto ───────────────────────────────
              _SelectionCard(
                icon: Icons.how_to_vote_rounded,
                title: 'Simulador de Voto',
                subtitle:
                    'Aprende cómo votar correctamente el día de las elecciones',
                details: const [
                  'Guía paso a paso · Cédula virtual',
                  'Practica antes de ir a votar',
                ],
                gradient: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                borderColor: const Color(0xFF66BB6A),
                badge: 'PRÓXIMAMENTE',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const VoteSimulatorScreen()),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              const Text(
                '#PORESTOSSI — Datos: ONPE · JNE\nNATHARCE: Desarrollo de Software',
                style: TextStyle(
                  color: Colors.white30,
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

// ─── Selection Card ────────────────────────────────────────────────────────────
class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> details;
  final List<Color> gradient;
  final Color borderColor;
  final String? badge;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  badge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              ...details.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: Colors.white),
                    ],
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
