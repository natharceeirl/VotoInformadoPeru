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
      backgroundColor: const Color(0xFF1C1C2E),
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
                      const Icon(Icons.how_to_vote, size: 100, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        '#PORESTOSSI',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Senado Nacional Perú • Elecciones 2026',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
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
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SplashSection(
                      icon: Icons.waving_hand_rounded,
                      iconColor: Colors.amber,
                      title: 'Bienvenido',
                      body: 'Esta herramienta permite conocer el perfil de '
                          'transparencia de los 35 partidos políticos y sus +963 '
                          'candidatos al Senado Nacional del Perú para las '
                          'Elecciones 2026 del Perú.',
                    ),
                    SizedBox(height: 20),
                    _SplashSection(
                      icon: Icons.people_rounded,
                      iconColor: Colors.lightBlue,
                      title: '¿Quiénes somos?',
                      body: 'Somos una iniciativa ciudadana multidisciplinaria '
                          'independiente que construye indicadores a partir de '
                          'datos abiertos del JNE, ONPE, Poder Judicial y el '
                          'Ministerio de Energía y Minas.',
                    ),
                    SizedBox(height: 20),
                    _SplashSection(
                      icon: Icons.lightbulb_rounded,
                      iconColor: Colors.yellow,
                      title: '¿Por qué lo hacemos?',
                      body: 'Porque el voto informado es la mejor herramienta '
                          'contra la corrupción. Los ciudadanos merecemos conocer '
                          'el historial, los ingresos, la educación y los vínculos '
                          'con minería informal de quienes buscan representarnos.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Disclaimer ────────────────────────────────────────────────
              const Text(
                '⚠ Herramienta informativa basada en datos públicos. No '
                'representa acusación formal ni obligatoriedad de voto. '
                '⚠ Herramienta no financiada por ningún partido político. '
                'Esta aplicación no representa a ninguna entidad gubernamental ni está afiliada a ninguna institución pública. La información proporcionada se obtiene de fuentes oficiales disponibles públicamente.',
                style: TextStyle(
                  color: Colors.white54,
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
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
      ],
    );
  }
}
