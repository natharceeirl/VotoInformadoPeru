import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/new_models.dart';
import '../../domain/models/reinfo_models.dart';
import '../../domain/models/senado_models.dart';
import '../../domain/models/regiones_models.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../../data/repositories/data_repository.dart';
import '../widgets/indicator_weights_sheet.dart';

// Repository Provider
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository();
});

// JSON Loaders
final metadataProvider = FutureProvider<IndexMetadata>((ref) async {
  return ref.read(dataRepositoryProvider).loadMetadata();
});

final ranking35Provider = FutureProvider<List<PartyRanking>>((ref) async {
  return ref.read(dataRepositoryProvider).loadRanking35();
});

final ranking100Provider = FutureProvider<List<PartyRanking>>((ref) async {
  return ref.read(dataRepositoryProvider).loadRanking100();
});

final partyStatsProvider = FutureProvider<List<PartyStats>>((ref) async {
  return ref.read(dataRepositoryProvider).loadPartyStats();
});

/// REINFO candidates using the correct ReinfoCandidate model (file 05)
final reinfoCandidatesRawProvider = FutureProvider<List<ReinfoCandidate>>((
  ref,
) async {
  return ref.read(dataRepositoryProvider).loadReinfoCandidatesRaw();
});

final allCandidatesProvider = FutureProvider<List<CandidateDetailed>>((
  ref,
) async {
  return ref.read(dataRepositoryProvider).loadAllCandidatesClean();
});

final educationStatsProvider = FutureProvider<EducationStats>((ref) async {
  final candidates = await ref.watch(allCandidatesProvider.future);
  return EducationStats.fromCandidates(candidates);
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  return ref.read(dataRepositoryProvider).loadDashboardSummary();
});

final indicatorsGraphProvider = FutureProvider<List<IndicatorGraphic>>((
  ref,
) async {
  return ref.read(dataRepositoryProvider).loadIndicatorsGraph();
});

final partyResumenRawProvider = FutureProvider<List<PartyResumenRaw>>((
  ref,
) async {
  return ref.read(dataRepositoryProvider).loadPartyResumenRaw();
});

/// Carga senadoNacionalDatosPersonales.json con candidatos por región.
final regionesDataProvider = FutureProvider<RegionesData>((ref) async {
  final raw = await rootBundle.loadString(
    'assets/baseDatos/senadoNacionalDatosPersonales.json',
  );
  final map = jsonDecode(raw) as Map<String, dynamic>;

  List<RegionCandidato> parse(String key) {
    final list = (map[key] as List? ?? []).cast<Map<String, dynamic>>();
    return list.map(RegionCandidato.fromJson).toList();
  }

  return RegionesData(
    distritoMultiple: parse('SENADORES DISTRITO MÚLTIPLE'),
    distritoUnico: parse('SENADORES DISTRITO ÚNICO'),
  );
});

/// Carga hojas_vida.json — mapa DNI → HojaVida con scoring de integridad.
final hojasVidaProvider =
    FutureProvider<Map<String, HojaVida>>((ref) async {
      final raw = await rootBundle.loadString(
        'assets/baseDatos/hojas_vida.json',
      );
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final result = <String, HojaVida>{};
      for (final entry in map.entries) {
        final j = entry.value as Map<String, dynamic>?;
        if (j == null || !j.containsKey('nivelEducacion')) continue;
        try {
          result[entry.key] = HojaVida.fromJson(entry.key, j);
        } catch (_) {}
      }
      return result;
    });

/// Candidatos con hoja de vida — une regionesData + hojasVida.
/// Filtrables por tipo de distrito (ÚNICO / MÚLTIPLE) y departamento.
final candidatosConHVProvider =
    FutureProvider<List<CandidatoConHV>>((ref) async {
      final regiones = await ref.watch(regionesDataProvider.future);
      final hojas   = await ref.watch(hojasVidaProvider.future);

      final result = <CandidatoConHV>[];

      for (final c in regiones.distritoUnico) {
        final hv = hojas[c.dni];
        if (hv == null) continue;
        result.add(CandidatoConHV(
          hv:            hv,
          tipoDistrito:  'ÚNICO',
          departamento:  c.departamento,
          posicion:      c.posicion,
          fotoUrl:       c.fotoUrl,
          strNombre:     c.strNombre,
        ));
      }

      for (final c in regiones.distritoMultiple) {
        final hv = hojas[c.dni];
        if (hv == null) continue;
        result.add(CandidatoConHV(
          hv:            hv,
          tipoDistrito:  'MÚLTIPLE',
          departamento:  c.departamento,
          posicion:      c.posicion,
          fotoUrl:       c.fotoUrl,
          strNombre:     c.strNombre,
        ));
      }

      return result;
    });

/// Carga senadoNacional.json y lo indexa por DNI → SenadoCandidato.
/// Permite acceder a la foto oficial del JNE y al estado del candidato.
final senadoMapProvider =
    FutureProvider<Map<String, SenadoCandidato>>((ref) async {
      final raw = await rootBundle.loadString(
        'assets/baseDatos/senadoNacional.json',
      );
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return {
        for (final j in list)
          (j['strDocumentoIdentidad'] as String): SenadoCandidato.fromJson(j),
      };
    });

// ─── Custom Weights (Indicator Configurator) ─────────────────────────────────

class CustomWeightsNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => Map.from(kDefaultWeights);

  void update(Map<String, double> newWeights) {
    state = Map.from(newWeights);
  }

  void reset() {
    state = Map.from(kDefaultWeights);
  }

  bool get isDefault => state.entries.every(
    (e) => (e.value - (kDefaultWeights[e.key] ?? 0.0)).abs() < 0.001,
  );
}

final customWeightsProvider =
    NotifierProvider<CustomWeightsNotifier, Map<String, double>>(
      CustomWeightsNotifier.new,
    );

/// Derives a custom-ranked party list based on user-configured weights.
/// Score = Σ(indicator_score_i * weight_i) / Σ(weight_i)
final customRankedPartiesProvider =
    FutureProvider<List<_ScoredParty>>((ref) async {
      final graphs = await ref.watch(indicatorsGraphProvider.future);
      final weights = ref.watch(customWeightsProvider);

      final totalWeight = weights.values.fold(0.0, (a, b) => a + b);

      final scored = graphs.map((g) {
        final ind = g.allIndicators;
        double customScore = 0;
        if (totalWeight > 0) {
          weights.forEach((key, w) {
            customScore += (ind[key] ?? 0.0) * w;
          });
          customScore = customScore / totalWeight;
        } else {
          customScore = g.scoreFinal;
        }
        return _ScoredParty(graph: g, customScore: customScore);
      }).toList();

      scored.sort((a, b) => b.customScore.compareTo(a.customScore));
      return scored;
    });

class _ScoredParty {
  final IndicatorGraphic graph;
  final double customScore;
  _ScoredParty({required this.graph, required this.customScore});
}

// ─── State Management for Filtering Candidates ───────────────────────────────

class SearchCandidateNotifier extends Notifier<String> {
  @override
  String build() => "";

  void update(String query) {
    state = query;
  }
}

final searchCandidateProvider =
    NotifierProvider<SearchCandidateNotifier, String>(
      SearchCandidateNotifier.new,
    );

class SelectedCandidatePartyNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? party) {
    state = party;
  }
}

final selectedCandidatePartyProvider =
    NotifierProvider<SelectedCandidatePartyNotifier, String?>(
      SelectedCandidatePartyNotifier.new,
    );

class SelectedEducationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? level) {
    state = level;
  }
}

final selectedEducationProvider =
    NotifierProvider<SelectedEducationNotifier, String?>(
      SelectedEducationNotifier.new,
    );

// Filtered Candidates Combiner
final filteredDetailedCandidatesProvider =
    FutureProvider<List<CandidateDetailed>>((ref) async {
      final candidates = await ref.watch(allCandidatesProvider.future);
      final query = ref.watch(searchCandidateProvider).toLowerCase().trim();
      final selectedParty = ref.watch(selectedCandidatePartyProvider);
      final selectedEducation = ref.watch(selectedEducationProvider);

      return candidates.where((c) {
        final matchQuery = query.isEmpty ||
            c.dni.contains(query) ||
            c.partido.toLowerCase().contains(query);
        final matchParty = selectedParty == null || c.partido == selectedParty;
        final matchEdu =
            selectedEducation == null ||
            c.educacion.maxLevel == selectedEducation;

        return matchQuery && matchParty && matchEdu;
      }).toList();
    });
