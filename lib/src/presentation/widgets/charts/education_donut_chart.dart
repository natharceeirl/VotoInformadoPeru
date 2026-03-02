import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/new_providers.dart';

class EducationDonutChart extends ConsumerStatefulWidget {
  final void Function(String? levelName)? onSectionChanged;
  const EducationDonutChart({super.key, this.onSectionChanged});

  @override
  ConsumerState<EducationDonutChart> createState() =>
      _EducationDonutChartState();
}

class _EducationDonutChartState
    extends ConsumerState<EducationDonutChart> {
  int _touchedIndex = -1;

  static const _labels = [
    'Primaria', 'Secundaria', 'Técnico',
    'No Univ.', 'Universitario', 'Maestría', 'Doctorado',
  ];
  static const _maxLevels = [
    'Primaria', 'Secundaria', 'Técnico',
    'No Universitario', 'Universitario', 'Maestría', 'Doctorado',
  ];
  static const _colors = [
    Colors.blueAccent, Colors.orange, Colors.purple,
    Colors.redAccent, Colors.green, Colors.teal, Colors.amber,
  ];
  static const _descriptions = [
    'Candidatos cuyo máximo nivel de estudios es primaria.',
    'Candidatos cuyo máximo nivel de estudios es secundaria.',
    'Candidatos con formación técnica o tecnológica.',
    'Candidatos con estudios universitarios incompletos.',
    'Candidatos con título universitario completo.',
    'Candidatos con grado de maestría.',
    'Candidatos con grado de doctorado.',
  ];

  // ── Sticky selection: toggle on same section, select on new ───────────────
  void _handleTap(
    int rawIdx,
    List<({int idx, String label, int value, Color color, String description})>
        indexed,
  ) {
    final newIdx =
        rawIdx >= 0 && rawIdx < indexed.length ? indexed[rawIdx].idx : -1;
    setState(() {
      _touchedIndex = (_touchedIndex == newIdx) ? -1 : newIdx;
      widget.onSectionChanged
          ?.call(_touchedIndex >= 0 ? _maxLevels[_touchedIndex] : null);
    });
  }

  void _clearSelection() {
    setState(() {
      _touchedIndex = -1;
      widget.onSectionChanged?.call(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eduStatsAsync = ref.watch(educationStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.school_rounded,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Distribución Educativa de Candidatos',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_touchedIndex >= 0)
                  GestureDetector(
                    onTap: _clearSelection,
                    child: Tooltip(
                      message: 'Limpiar selección',
                      child: Icon(Icons.close_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                    ),
                  )
                else
                  Tooltip(
                    message: 'Toca un sector para seleccionarlo',
                    child: Icon(Icons.touch_app_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Content ──────────────────────────────────────────────────────
            eduStatsAsync.when(
              data: (data) {
                final values = [
                  data.primaria, data.secundaria, data.tecnico,
                  data.noUniv, data.univ, data.maestria, data.doctorado,
                ];
                final total = values.fold(0, (a, b) => a + b);

                final indexed = <({
                  int idx,
                  String label,
                  int value,
                  Color color,
                  String description
                })>[];
                for (int i = 0; i < values.length; i++) {
                  if (values[i] > 0) {
                    indexed.add((
                      idx: i,
                      label: _labels[i],
                      value: values[i],
                      color: _colors[i],
                      description: _descriptions[i],
                    ));
                  }
                }

                final found = indexed.where((e) => e.idx == _touchedIndex);
                final touchedEntry = found.isNotEmpty ? found.first : null;

                return LayoutBuilder(builder: (ctx, constraints) {
                  final wide = constraints.maxWidth > 420;

                  // ── Build pie sections ─────────────────────────────────
                  List<PieChartSectionData> buildSections(bool isWide) =>
                      indexed.map((e) {
                        final isTouched = _touchedIndex == e.idx;
                        final pct =
                            total > 0 ? (e.value / total * 100) : 0.0;
                        return PieChartSectionData(
                          color: e.color,
                          value: e.value.toDouble(),
                          title: isTouched
                              ? '${pct.toStringAsFixed(1)}%'
                              : '',
                          radius: isTouched
                              ? (isWide ? 65 : 50)
                              : (isWide ? 48 : 36),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();

                  // ── Sticky touch data ──────────────────────────────────
                  PieTouchData buildTouchData() => PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {
                          // Only act on tap-up → sticky selection
                          if (event is! FlTapUpEvent) return;
                          if (pieTouchResponse?.touchedSection == null) {
                            return;
                          }
                          _handleTap(
                            pieTouchResponse!
                                .touchedSection!.touchedSectionIndex,
                            indexed,
                          );
                        },
                      );

                  // ── Detail panel ───────────────────────────────────────
                  Widget detailPanel = touchedEntry != null
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                touchedEntry.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: touchedEntry.color
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: touchedEntry.color,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  touchedEntry.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: touchedEntry.color,
                                    fontSize: 13,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(
                                '${touchedEntry.value} candidatos',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900),
                              ),
                              Text(
                                total > 0
                                    ? '${(touchedEntry.value / total * 100).toStringAsFixed(1)}% del total'
                                    : '',
                                style: TextStyle(
                                  color: touchedEntry.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                touchedEntry.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Toca un sector\npara ver el detalle',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );

                  // ── Legend chips ───────────────────────────────────────
                  Widget legendChips = Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: indexed.map((e) {
                      final pct =
                          total > 0 ? (e.value / total * 100) : 0.0;
                      final isSelected = _touchedIndex == e.idx;
                      return GestureDetector(
                        onTap: () {
                          final newIdx = isSelected ? -1 : e.idx;
                          setState(() {
                            _touchedIndex = newIdx;
                            widget.onSectionChanged?.call(
                              newIdx >= 0 ? _maxLevels[newIdx] : null,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? e.color.withValues(alpha: 0.2)
                                : e.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? e.color
                                  : e.color.withValues(alpha: 0.25),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: e.color,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${e.label} ${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? e.color
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );

                  if (wide) {
                    // ── Desktop: pie izquierda, panel+leyenda derecha ──────
                    return SizedBox(
                      height: 290,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: PieChart(PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 52,
                              sections: buildSections(true),
                              pieTouchData: buildTouchData(),
                            )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  detailPanel,
                                  legendChips,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ── Móvil: pie arriba, detalle+leyenda abajo ────────────
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 38,
                          sections: buildSections(false),
                          pieTouchData: buildTouchData(),
                        )),
                      ),
                      const SizedBox(height: 12),
                      detailPanel,
                      legendChips,
                    ],
                  );
                });
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) =>
                  const Center(child: Text('Error cargando datos')),
            ),
          ],
        ),
      ),
    );
  }
}
