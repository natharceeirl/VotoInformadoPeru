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

// ─── Name normalization for pro-crime matching ─────────────────────────────

String _normName(String s) {
  var r = s.toUpperCase()
      .replaceAll(',', ' ')
      .replaceAll('Á', 'A').replaceAll('É', 'E')
      .replaceAll('Í', 'I').replaceAll('Ó', 'O').replaceAll('Ú', 'U')
      .replaceAll('Ñ', 'N');
  while (r.contains('  ')) { r = r.replaceAll('  ', ' '); }
  return r.trim();
}

/// Builds map: normalizedFullName → number of pro-crime laws voted "A favor".
/// Source: assets/baseDatos/proCrimen_datos_votacion.json
final proCrimenMapProvider =
    FutureProvider<Map<String, int>>((ref) async {
      String raw;
      try {
        raw = await rootBundle.loadString(
          'assets/baseDatos/proCrimen_datos_votacion.json');
      } catch (_) {
        return {};
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final result  = <String, Set<String>>{};

      for (final entry in decoded.entries) {
        final lawId = entry.key;
        final votes = (entry.value as List).cast<Map<String, dynamic>>();
        for (final v in votes) {
          if (v['VOTO'] == 'A favor') {
            final full = '${v['APE_PATERNO'] ?? ''} '
                '${v['APE_MATERNO'] ?? ''} '
                '${v['NOMBRES'] ?? ''}';
            final key = _normName(full);
            (result[key] ??= {}).add(lawId);
          }
        }
      }

      return result.map((k, v) => MapEntry(k, v.length));
    });

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

// ─── Providers genéricos por proceso electoral (family) ──────────────────────

/// Carga el archivo BD del proceso y devuelve la lista de candidatos.
final bdCandidatosProcesoProvider =
    FutureProvider.family<List<RegionCandidato>, ProcesoElectoral>((ref, proceso) async {
      Future<List<RegionCandidato>> loadFile(String path, String topKey) async {
        String raw;
        try {
          raw = await rootBundle.loadString(path);
        } catch (_) {
          return [];
        }
        final map = jsonDecode(raw) as Map<String, dynamic>;
        // Key may have encoding differences — try exact then normalized
        List? items = map[topKey] as List?;
        if (items == null) {
          final normTarget = topKey.toUpperCase()
              .replaceAll('Ú', 'U').replaceAll('Ó', 'O').replaceAll('É', 'E');
          for (final k in map.keys) {
            if (k.toUpperCase().replaceAll('Ú', 'U').replaceAll('Ó', 'O')
                    .replaceAll('É', 'E') == normTarget) {
              items = map[k] as List?;
              break;
            }
          }
        }
        return (items ?? [])
            .cast<Map<String, dynamic>>()
            .map(RegionCandidato.fromJson)
            .toList();
      }

      final candidatos = await loadFile(proceso.bdFile, proceso.bdTopKey);

      // Senadores también tienen el archivo de Distrito Múltiple
      if (proceso == ProcesoElectoral.senadores && proceso.bdFileExtra.isNotEmpty) {
        final extra = await loadFile(proceso.bdFileExtra, 'SENADORES DISTRITO MÚLTIPLE');
        return [...candidatos, ...extra];
      }

      return candidatos;
    });

/// Carga el archivo hojas_vida del proceso y devuelve DNI → HojaVida.
final hojasVidaProcesoProvider =
    FutureProvider.family<Map<String, HojaVida>, ProcesoElectoral>((ref, proceso) async {
      // Senadores usan el archivo original descargado anteriormente
      if (proceso == ProcesoElectoral.senadores) {
        return ref.watch(hojasVidaProvider.future);
      }
      String raw;
      try {
        raw = await rootBundle.loadString(proceso.hvFile);
      } catch (_) {
        return {}; // Datos aún no descargados
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final result = <String, HojaVida>{};
      for (final entry in map.entries) {
        final j = entry.value as Map<String, dynamic>?;
        if (j == null) continue;
        try {
          result[entry.key] = HojaVida.fromJson(entry.key, j);
        } catch (_) {}
      }
      return result;
    });

/// Une BD + HojasVida para un proceso, devuelve lista de CandidatoConHV.
/// Aplica penalización por leyes pro-crimen y ex-congresistas.
final candidatosConHVProcesoProvider =
    FutureProvider.family<List<CandidatoConHV>, ProcesoElectoral>((ref, proceso) async {
      final hojas     = await ref.watch(hojasVidaProcesoProvider(proceso).future);
      final proCrimen = await ref.watch(proCrimenMapProvider.future);
      final result = <CandidatoConHV>[];

      void addCandidatos(List<RegionCandidato> bd, String tipoDistrito) {
        for (final c in bd) {
          HojaVida? hv = hojas[c.dni] ?? hojas[c.paddedDni];
          if (hv == null) continue;
          // Aplicar penalización pro-crimen por nombre
          final normNombre = _normName(hv.nombre);
          final numLeyes   = proCrimen[normNombre] ?? 0;
          if (numLeyes > 0) hv = hv.copyWithNumLeyes(numLeyes);
          result.add(CandidatoConHV(
            hv:           hv,
            tipoDistrito: tipoDistrito,
            departamento: c.departamento,
            posicion:     c.posicion,
            fotoUrl:      c.fotoUrl,
            strNombre:    c.strNombre,
            cargo:        c.cargo,
          ));
        }
      }

      if (proceso == ProcesoElectoral.senadores) {
        // Load the two senadores files separately to correctly tag ÚNICO/MÚLTIPLE.
        // Both files have strCargo="SENADOR" so we can't rely on the cargo field.
        Future<List<RegionCandidato>> loadSen(String path, String topKey) async {
          String raw;
          try {
            raw = await rootBundle.loadString(path);
          } catch (_) {
            return [];
          }
          final map = jsonDecode(raw) as Map<String, dynamic>;
          List? items = map[topKey] as List?;
          if (items == null) {
            final norm = topKey.toUpperCase()
                .replaceAll('Ú', 'U').replaceAll('Ó', 'O').replaceAll('É', 'E');
            for (final k in map.keys) {
              if (k.toUpperCase().replaceAll('Ú', 'U').replaceAll('Ó', 'O')
                      .replaceAll('É', 'E') == norm) {
                items = map[k] as List?;
                break;
              }
            }
          }
          return (items ?? [])
              .cast<Map<String, dynamic>>()
              .map(RegionCandidato.fromJson)
              .toList();
        }

        final unicos    = await loadSen(proceso.bdFile,      'SENADORES DISTRITO ÚNICO');
        final multiples = await loadSen(proceso.bdFileExtra, 'SENADORES DISTRITO MÚLTIPLE');
        addCandidatos(unicos,    'ÚNICO');
        addCandidatos(multiples, 'MÚLTIPLE');
      } else {
        final bd = await ref.watch(bdCandidatosProcesoProvider(proceso).future);
        addCandidatos(bd, '');
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
