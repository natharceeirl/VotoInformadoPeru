import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/hoja_vida_models.dart';
import 'conoce_candidatos_screen.dart';
import 'estadisticas_partido_screen.dart';

// Re-export ProcesoElectoral so selection_screen.dart only needs to import this file
export '../../domain/models/hoja_vida_models.dart' show ProcesoElectoral;

/// Menú principal para cada proceso electoral.
/// Muestra el encabezado del proceso + tarjetas de opciones en grilla 2 columnas.
class ProcesoMenuScreen extends StatelessWidget {
  final ProcesoElectoral proceso;

  const ProcesoMenuScreen({super.key, required this.proceso});

  static const _navy = Color(0xFF1E3A5F);

  Future<void> _launchJne() async {
    final uri = Uri.parse(proceso.jnePortalUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // silently ignore if cannot launch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        title: Text(
          proceso.displayName,
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navy),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado ──────────────────────────────────────────────────
              _ProcessHeader(proceso: proceso),
              const SizedBox(height: 20),

              // ── Opciones ──────────────────────────────────────────────────────
              _ActionRow(
                icon: Icons.people,
                iconColor: const Color(0xFF1565C0),
                title: 'Conoce a los Candidatos',
                subtitle: 'Perfil de integridad · Educación · Antecedentes',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ConoceCandidatosScreen(proceso: proceso))),
              ),
              const SizedBox(height: 10),
              _ActionRow(
                icon: Icons.poll,
                iconColor: const Color(0xFF1B5E20),
                title: 'Estadísticas por Partido',
                subtitle: 'Ranking · Puntaje promedio · Comparación',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EstadisticasPartidoScreen(proceso: proceso))),
              ),
              const SizedBox(height: 16),
              // JNE link (simple text button)
              Center(
                child: TextButton.icon(
                  onPressed: _launchJne,
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Ver candidatos en el portal oficial del JNE'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A5F),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Disclaimer ───────────────────────────────────────────────────
              _DisclaimerBox(),

              // ── Footer ───────────────────────────────────────────────────────
              const SizedBox(height: 28),
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
              const SizedBox(height: 4),
              const Text(
                'NATHARCE - Desarrollo de Software',
                style: TextStyle(
                  color: Color(0xFF2C7BE5), // color más destacado
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
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

// ─── Header del proceso ───────────────────────────────────────────────────────

class _ProcessHeader extends StatelessWidget {
  final ProcesoElectoral proceso;
  const _ProcessHeader({required this.proceso});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PNG image
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                proceso.imagePath,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  proceso.icon,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elecciones Perú 2026',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proceso.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
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

// ─── Action row (horizontal option card) ─────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E3A5F).withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Disclaimer box ───────────────────────────────────────────────────────────

class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta aplicación tiene como único objetivo informar a la ciudadanía. '
              'No representa, promueve ni tiene afiliación con ningún partido político. '
              'Todos los datos provienen de fuentes públicas oficiales (JNE · ONPE). '
              'La información es de carácter orientativo y no constituye una '
              'recomendación de voto ni una acusación formal.',
              style: TextStyle(
                color: Colors.grey.shade600,
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
