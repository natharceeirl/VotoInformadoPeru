import 'package:flutter/material.dart';
import 'dashboard_summary_screen.dart';
import 'ranking_screen.dart';
import 'candidates_directory_screen.dart';
import 'regiones_screen.dart';
import 'reinfo_alert_screen.dart';
import 'compare_parties_screen.dart';
import 'charts_hub_screen.dart';
import 'data_sources_screen.dart';
import 'conoce_candidatos_screen.dart';
import '../../domain/models/hoja_vida_models.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('#PORESTOSSI: SENADO NACIONAL'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/assets/Logo_Icono_Nombre_Subtitulo.png',
                  height: 200,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.how_to_vote,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Índice de Transparencia y Riesgo de Corrupción',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Senado Nacional Perú • Elecciones 2026',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'NATHARCE: Desarrollo de Software',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Stats banner ───────────────────────────────────────────────
              //_StatsBanner(),
              //const SizedBox(height: 24),

              // ── Section: Análisis ─────────────────────────────────────────
              _SectionHeader(
                label: 'ANÁLISIS Y COMPARACIÓN',
                icon: Icons.analytics_outlined,
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Dashboard General',
                subtitle: 'Resumen macro del Senado 2026',
                detail: 'Top 5 · Últimos 5 · KPIs nacionales',
                icon: Icons.dashboard_rounded,
                color: Colors.blue,
                badge: null,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DashboardSummaryScreen())),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                title: 'Ranking de Partidos',
                subtitle: 'Posiciones finales de los 35 partidos',
                detail: 'Tasa de corrupción · Puntaje global',
                icon: Icons.format_list_numbered_rounded,
                color: Colors.indigo,
                badge: '35',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RankingScreen())),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                title: 'Comparador de Partidos',
                subtitle: 'Enfrenta 2 partidos en 8 indicadores',
                detail: 'Gráfico de barras · Tabla comparativa',
                icon: Icons.compare_arrows_rounded,
                color: Colors.green,
                badge: null,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ComparePartiesScreen())),
              ),
              const SizedBox(height: 20),

              // ── Section: Gráficos ─────────────────────────────────────────
              _SectionHeader(
                label: 'GRÁFICOS INTERACTIVOS',
                icon: Icons.bar_chart_rounded,
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Indicadores Interactivos',
                subtitle: 'Gráficos ordenables por partido',
                detail: 'Sentencias · REINFO · Ingresos S/. · Preparación · Reelección · Radar',
                icon: Icons.insert_chart_rounded,
                color: Colors.deepPurple,
                badge: '11',
                isHighlighted: true,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChartsHubScreen())),
              ),
              const SizedBox(height: 20),

              // ── Section: Conoce a tus Candidatos ─────────────────────────
              _SectionHeader(
                label: 'CONOCE A TUS CANDIDATOS',
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Conoce a tus Candidatos',
                subtitle: 'Perfil de integridad de los senadores 2026',
                detail: 'Educación · Sentencias · Puntaje 0–100',
                icon: Icons.people_alt_rounded,
                color: Colors.green,
                badge: 'NUEVO',
                isHighlighted: true,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const ConoceCandidatosScreen(
                        proceso: ProcesoElectoral.senadores,
                      ),
                    )),
              ),
              const SizedBox(height: 20),

              // ── Section: Datos ────────────────────────────────────────────
              _SectionHeader(
                label: 'DATOS DE CANDIDATOS',
                icon: Icons.people_alt_outlined,
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Directorio de Candidatos',
                subtitle: 'Busca entre 963+ candidatos al Senado Nacional',
                detail: 'Filtro por partido · DNI · Nivel educativo',
                icon: Icons.manage_search_rounded,
                color: Colors.teal,
                badge: '963',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CandidatesDirectoryScreen())),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                title: 'Senadores por Región',
                subtitle: 'Candidatos por departamento y distrito',
                detail: 'Distrito Múltiple · Distrito Único · Fotos y logos',
                icon: Icons.map_rounded,
                color: Colors.cyan,
                badge: null,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegionesScreen())),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                title: 'Candidatos Mineros (REINFO)',
                subtitle: 'Alertas de minería informal',
                detail: 'Filtro por partido · Cantidad registros',
                icon: Icons.warning_amber_rounded,
                color: Colors.orange,
                badge: null,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReinfoAlertScreen())),
              ),
              const SizedBox(height: 20),

              // ── Section: Info ─────────────────────────────────────────────
              _SectionHeader(
                label: 'INFORMACIÓN',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Fuente de los Datos',
                subtitle: 'Indicadores, fórmulas y fuentes oficiales',
                detail: 'REINFO · Sentencias · Ingresos S/. · ONPE · JNE',
                icon: Icons.description_rounded,
                color: Colors.deepOrange,
                badge: null,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DataSourcesScreen())),
              ),

              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                '#PORESTOSSI — Datos: ONPE - JNE · 35 partidos · 963 candidatos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.80),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'NATHARCE: Desarrollo de Software',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.80),
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stats Banner ─────────────────────────────────────────────────────────────
/*class _StatsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem('35', 'Partidos', Icons.groups_3_rounded),
          _Divider(key: ValueKey('d1')),
          _StatItem('963', 'Candidatos', Icons.person_rounded),
          _Divider(key: ValueKey('d2')),
          _StatItem('8', 'Indicadores', Icons.analytics_rounded),
          _Divider(key: ValueKey('d3')),
          _StatItem('56', 'Con sentencia', Icons.gavel_rounded),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                )),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}*/

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ─── Menu Card ────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
  final Color color;
  final String? badge;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    required this.color,
    required this.badge,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHighlighted
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.2),
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isHighlighted ? 0.08 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: color.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
