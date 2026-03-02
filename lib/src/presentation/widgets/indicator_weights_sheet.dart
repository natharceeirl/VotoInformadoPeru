import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';

// Official default weights (from 01_metadata.json)
const Map<String, double> kDefaultWeights = {
  'sentencias': 0.20,
  'preparacion': 0.20,
  'ingresos_no_declarados': 0.10,
  'ingresos_efectivos': 0.05,
  'libre_pacto': 0.25,
  'reeleccion': 0.10,
  'equipo_completo': 0.05,
  'reinfo': 0.05,
};

const Map<String, String> kIndicatorLabels = {
  'sentencias': 'Sentencias Judiciales',
  'preparacion': 'Preparación Académica',
  'ingresos_no_declarados': 'Ingresos No Declarados',
  'ingresos_efectivos': 'Ingresos Efectivos',
  'libre_pacto': 'Libre de Pacto Corrupto',
  'reeleccion': 'No Reelección',
  'equipo_completo': 'Equipo Completo (30)',
  'reinfo': 'Sin Registros Mineros',
};

const Map<String, String> kIndicatorDescriptions = {
  'sentencias': 'Porcentaje de candidatos del partido con sentencias judiciales en su contra. A mayor peso, penaliza más a partidos con candidatos condenados.',
  'preparacion': 'Nivel académico promedio de los candidatos (Primaria=0 a Doctorado=20). A mayor peso, favorece a partidos con candidatos más preparados.',
  'ingresos_no_declarados': 'Candidatos que declaran ingresos en cero o valores atípicamente bajos. Puede indicar ocultamiento de bienes.',
  'ingresos_efectivos': 'Ingresos mensuales efectivos promedio de los candidatos. Indica el nivel económico real del equipo.',
  'libre_pacto': 'Ausencia de vínculos con el "Pacto de Corrupción #PorEstosNo". Es el indicador de mayor peso por defecto (25%). Penaliza fuertemente la infiltración corrupta.',
  'reeleccion': 'Candidatos que fueron congresistas anteriores. Permite identificar cuántos veteranos del congreso buscan regresar.',
  'equipo_completo': 'Si el partido presentó los 30 candidatos reglamentarios al Senado Nacional. Indica seriedad en la participación.',
  'reinfo': 'Candidatos vinculados al Registro Integral de Formalización Minera (minería informal o ilegal).',
};

/// Shows a bottom sheet for customizing indicator weights.
void showIndicatorWeightsSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _IndicatorWeightsSheet(ref: ref),
  );
}

class _IndicatorWeightsSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _IndicatorWeightsSheet({required this.ref});

  @override
  ConsumerState<_IndicatorWeightsSheet> createState() =>
      _IndicatorWeightsSheetState();
}

class _IndicatorWeightsSheetState
    extends ConsumerState<_IndicatorWeightsSheet> {
  late Map<String, double> _localWeights;

  @override
  void initState() {
    super.initState();
    _localWeights = Map.from(ref.read(customWeightsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = _localWeights.values.fold(0.0, (a, b) => a + b);
    final isDefault = _localWeights.entries.every(
      (e) => (e.value - (kDefaultWeights[e.key] ?? 0.0)).abs() < 0.001,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.tune),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Configura tus indicadores',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isDefault)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _localWeights = Map.from(kDefaultWeights);
                        });
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('Restablecer'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Ajusta qué tanto importa cada indicador para personalizar el ranking. '
                'Peso total: ${(totalWeight * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: kDefaultWeights.keys.map((key) {
                  final label = kIndicatorLabels[key] ?? key;
                  final description = kIndicatorDescriptions[key] ?? '';
                  final value = _localWeights[key] ?? 0.0;
                  return _WeightSlider(
                    label: label,
                    description: description,
                    value: value,
                    onChanged: (v) {
                      setState(() {
                        _localWeights[key] = v;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(customWeightsProvider.notifier)
                        .update(_localWeights);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Aplicar y recalcular ranking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;

  const _WeightSlider({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          Slider(
            value: value,
            min: 0.0,
            max: 0.50,
            divisions: 50,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
