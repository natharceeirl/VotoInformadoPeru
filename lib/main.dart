import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/screens/selection_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Por Estos Sí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 300,
                  errorBuilder: (_, __, ___) => Column(
                    children: [
                      Icon(Icons.how_to_vote,
                          size: 100, color: AppTheme.primaryColor),
                      const SizedBox(height: 12),
                      Text(
                        '#PORESTOSSI',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Perú',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Elecciones Generales 2026',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                    value: '+2,000',
                    label: 'candidatos\nanalizados',
                    color: AppTheme.primaryColor,
                    icon: Icons.people,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    value: '38',
                    label: 'partidos\npolíticos',
                    color: const Color(0xFF2563EB),
                    icon: Icons.account_balance_rounded,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    value: '4',
                    label: 'procesos\nelectorales',
                    color: const Color(0xFF1D4ED8),
                    icon: Icons.how_to_vote_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // ── Bienvenida card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDE4FF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SplashSection(
                      icon: Icons.waving_hand_rounded,
                      iconColor: Color(0xFFFF8F00),
                      title: 'Bienvenido',
                      body: 'Esta herramienta permite conocer el perfil de '
                          'transparencia de los candidatos a Presidente, Vicepresidentes, '
                          'Diputados, Senadores y Parlamento Andino del Perú '
                          'para las Elecciones 2026.',
                    ),
                    SizedBox(height: 16),
                    Divider(height: 1),
                    SizedBox(height: 16),
                    _SplashSection(
                      icon: Icons.people_rounded,
                      iconColor: Color(0xFF1565C0),
                      title: '¿Quiénes somos?',
                      body: 'Somos una iniciativa ciudadana multidisciplinaria '
                          'independiente que construye indicadores a partir de '
                          'datos abiertos del JNE, ONPE, Poder Judicial y el '
                          'Ministerio de Energía y Minas.',
                    ),
                    SizedBox(height: 16),
                    Divider(height: 1),
                    SizedBox(height: 16),
                    _SplashSection(
                      icon: Icons.lightbulb_rounded,
                      iconColor: Color(0xFFF9A825),
                      title: '¿Por qué lo hacemos?',
                      body: 'Porque el voto informado es la mejor herramienta '
                          'contra la corrupción. Los ciudadanos merecemos conocer '
                          'el historial, los ingresos, la educación y los vínculos '
                          'con minería informal de quienes buscan representarnos.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // ── Cobertura de datos ────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Datos que analizamos',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.school_rounded,
                    label: 'Educación',
                    color: Color(0xFF0D47A1),
                  )),
                  SizedBox(width: 8),
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.gavel_rounded,
                    label: 'Integridad Penal',
                    color: Color(0xFFB71C1C),
                  )),
                  SizedBox(width: 8),
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.verified_rounded,
                    label: 'Cumplimiento',
                    color: Color(0xFF1B5E20),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.account_balance_rounded,
                    label: 'Univ. de Prestigio',
                    color: Color(0xFF6A1B9A),
                  )),
                  SizedBox(width: 8),
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.how_to_vote_rounded,
                    label: 'Cargos Previos',
                    color: Color(0xFFE65100),
                  )),
                  SizedBox(width: 8),
                  Expanded(child: _DataCoverageCard(
                    icon: Icons.warning_rounded,
                    label: 'Partido Pro-Crimen',
                    color: Color(0xFF880E4F),
                  )),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // ── ¿Cómo funciona? ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '¿Cómo funciona?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDE4FF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    _HowItWorksStep(
                      step: 1,
                      text: 'Elige el proceso electoral que te interesa',
                    ),
                    _HowItWorksStep(
                      step: 2,
                      text: 'Conoce el perfil y puntuación de cada candidato',
                    ),
                    _HowItWorksStep(
                      step: 3,
                      text: 'Compara partidos por categorías de integridad',
                    ),
                    _HowItWorksStep(
                      step: 4,
                      text: 'Vota informado el 12 de abril de 2026',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // ── Disclaimer box ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFD97706), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Herramienta informativa basada en datos públicos. '
                        'No representa acusación formal ni obligatoriedad de voto. '
                        'No financiada por ningún partido político ni afiliada a '
                        'ninguna institución pública.',
                        style: TextStyle(
                          color: const Color(0xFF92400E),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── INGRESAR button ───────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    label: const Text(
                      'INGRESAR',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const SelectionScreen()),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Footer ────────────────────────────────────────────────────
              const Divider(height: 1),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  children: [
                    const TextSpan(text: 'Desarrollado por '),
                    TextSpan(
                      text: 'NATHARCE',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const TextSpan(text: ' · Desarrollo de Software'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
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

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCoverageCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DataCoverageCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final int step;
  final String text;
  final bool isLast;

  const _HowItWorksStep({
    required this.step,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _SplashSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }
}
