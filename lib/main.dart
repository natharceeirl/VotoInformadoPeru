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
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 180,
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
              const SizedBox(height: 12),
              Text(
                'Perú • Elecciones 2026',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

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
                          'transparencia de los candidatos a Presidente, '
                          'Diputados, Senadores y Parlamento Andino del Perú '
                          'para las Elecciones 2026.',
                    ),
                    SizedBox(height: 20),
                    _SplashSection(
                      icon: Icons.people_rounded,
                      iconColor: Color(0xFF1565C0),
                      title: '¿Quiénes somos?',
                      body: 'Somos una iniciativa ciudadana multidisciplinaria '
                          'independiente que construye indicadores a partir de '
                          'datos abiertos del JNE, ONPE, Poder Judicial y el '
                          'Ministerio de Energía y Minas.',
                    ),
                    SizedBox(height: 20),
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

              // ── Disclaimer ────────────────────────────────────────────────
              Text(
                '⚠ Herramienta informativa basada en datos públicos. No '
                'representa acusación formal ni obligatoriedad de voto. '
                'No financiada por ningún partido político ni afiliada a '
                'ninguna institución pública.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // ── INGRESAR button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  label: const Text(
                    'INGRESAR',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SelectionScreen()),
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
