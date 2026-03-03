import 'package:flutter/material.dart';
import '../../domain/models/hoja_vida_models.dart';
import 'conoce_candidatos_screen.dart';

// Re-export ProcesoElectoral so selection_screen.dart only needs to import this file
export '../../domain/models/hoja_vida_models.dart' show ProcesoElectoral;

/// Menú principal para cada proceso electoral.
/// Muestra el encabezado del proceso + tarjetas de opciones.
class ProcesoMenuScreen extends StatelessWidget {
  final ProcesoElectoral proceso;

  const ProcesoMenuScreen({super.key, required this.proceso});

  @override
  Widget build(BuildContext context) {
    final color = proceso.color;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(proceso.displayName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado ─────────────────────────────────────────────────
              _ProcessHeader(proceso: proceso),
              const SizedBox(height: 24),

              // ── Disclaimer ────────────────────────────────────────────────
              _DisclaimerBox(),
              const SizedBox(height: 24),

              // ── Opciones ──────────────────────────────────────────────────
              _MenuOption(
                icon: Icons.people_alt_rounded,
                title: 'Conoce a tus Candidatos',
                subtitle: 'Perfil de integridad · Educación · Antecedentes',
                detail: 'Candidatos ordenados por puntaje de transparencia 0–100',
                color: color,
                isHighlighted: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConoceCandidatosScreen(proceso: proceso),
                  ),
                ),
              ),

              // Placeholder para futuras secciones
              const SizedBox(height: 10),
              _MenuOption(
                icon: Icons.bar_chart_rounded,
                title: 'Estadísticas por Partido',
                subtitle: 'Próximamente disponible',
                detail: 'Comparación de partidos en este proceso electoral',
                color: Colors.blueGrey,
                isHighlighted: false,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente disponible')),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              const Text(
                '#PORESTOSSI — Solo información pública\nDatos: JNE · ONPE · NATHARCE',
                style: TextStyle(color: Colors.white30, fontSize: 11, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header del proceso ───────────────────────────────────────────────────────

class _ProcessHeader extends StatelessWidget {
  final ProcesoElectoral proceso;
  const _ProcessHeader({required this.proceso});

  @override
  Widget build(BuildContext context) {
    final color = proceso.color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(proceso.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  proceso.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Elecciones Perú 2026',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String get _description {
    switch (proceso) {
      case ProcesoElectoral.presidentes:
        return 'Candidatos a la Presidencia y Vicepresidencias de la República del Perú.';
      case ProcesoElectoral.diputados:
        return 'Candidatos a la Cámara de Diputados del Congreso de la República.';
      case ProcesoElectoral.senadores:
        return 'Candidatos al Senado Nacional — Distrito Único y Múltiple.';
      case ProcesoElectoral.parlamentoAndino:
        return 'Candidatos al Parlamento Andino — representación regional de Perú.';
    }
  }
}

// ─── Caja de disclaimer ───────────────────────────────────────────────────────

class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Esta aplicación tiene como único objetivo informar a la ciudadanía. '
              'No representa, promueve ni tiene afiliación con ningún partido político. '
              'Todos los datos provienen de fuentes públicas oficiales (JNE · ONPE). '
              'La información es de carácter orientativo y no constituye una '
              'recomendación de voto ni una acusación formal.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Opción del menú ──────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final Color color;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.color,
    required this.isHighlighted,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHighlighted
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: isHighlighted ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isHighlighted ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isHighlighted ? Colors.white : Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withValues(alpha: isHighlighted ? 0.9 : 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withValues(alpha: isHighlighted ? 0.7 : 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
