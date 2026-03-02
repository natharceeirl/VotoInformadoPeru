import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/models/new_models.dart';
import '../../domain/models/reinfo_models.dart';

class DataRepository {
  Future<IndexMetadata> loadMetadata() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/01_metadata.json',
    );
    return compute(_parseMetadata, jsonString);
  }

  Future<List<PartyRanking>> loadRanking35() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/02_ranking_partidos_35.json',
    );
    return compute(_parseRankingList, jsonString);
  }

  Future<List<PartyRanking>> loadRanking100() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/03_ranking_partidos_100.json',
    );
    return compute(_parseRankingList, jsonString);
  }

  Future<List<PartyStats>> loadPartyStats() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/04_estadisticas_por_partido.json',
    );
    return compute(_parsePartyStatsList, jsonString);
  }

  /// Loads 05_candidatos_reinfo.json using the correct ReinfoCandidate model
  Future<List<ReinfoCandidate>> loadReinfoCandidatesRaw() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/05_candidatos_reinfo.json',
    );
    return compute(_parseReinfoCandidateList, jsonString);
  }

  Future<List<CandidateDetailed>> loadAllCandidates() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/06_candidatos_individuales.json',
    );
    return compute(_parseCandidateList, jsonString);
  }

  Future<DashboardSummary> loadDashboardSummary() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/07_dashboard_resumen.json',
    );
    return compute(_parseDashboard, jsonString);
  }

  Future<List<IndicatorGraphic>> loadIndicatorsGraph() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/08_indicadores_graficas.json',
    );
    return compute(_parseIndicatorGraphicsList, jsonString);
  }

  Future<List<PartyResumenRaw>> loadPartyResumenRaw() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/Dataset_Senado_Nacional_clean_resumenDataset.json',
    );
    return compute(_parsePartyResumenRaw, jsonString);
  }

  /// Loads all 964 candidates from the clean dataset.
  Future<List<CandidateDetailed>> loadAllCandidatesClean() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/Dataset_Senado_Nacional_clean_dataset.json',
    );
    return compute(_parseCandidateListClean, jsonString);
  }
}

// Background Parse Functions (Isolates)
IndexMetadata _parseMetadata(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  return IndexMetadata.fromJson(parsed);
}

List<PartyRanking> _parseRankingList(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<dynamic> list = parsed['partidos'] ?? [];
  return list
      .map((e) => PartyRanking.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<PartyStats> _parsePartyStatsList(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<dynamic> list = parsed['partidos'] ?? [];
  return list
      .map((e) => PartyStats.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<ReinfoCandidate> _parseReinfoCandidateList(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<dynamic> list = parsed['candidatos'] ?? [];
  return list
      .map((e) => ReinfoCandidate.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<CandidateDetailed> _parseCandidateList(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<dynamic> list = parsed['candidatos'] ?? [];
  return list
      .map((e) => CandidateDetailed.fromJson(e as Map<String, dynamic>))
      .toList();
}

DashboardSummary _parseDashboard(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  return DashboardSummary.fromJson(parsed);
}

List<IndicatorGraphic> _parseIndicatorGraphicsList(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<dynamic> list = parsed['partidos'] ?? [];
  return list
      .map((e) => IndicatorGraphic.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<PartyResumenRaw> _parsePartyResumenRaw(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  return parsed.entries
      .where((e) {
        final v = e.value as Map<String, dynamic>;
        final cands = v['# Candidatos'] as List<dynamic>?;
        return cands != null &&
            cands.length >= 2 &&
            (cands[1] as num? ?? 0) > 0;
      })
      .map(
        (e) => PartyResumenRaw.fromEntry(
          e.key,
          e.value as Map<String, dynamic>,
        ),
      )
      .toList();
}

bool _isX(dynamic v) => v is String && v.trim().toUpperCase() == 'X';

/// Parses values like " 1,000.00 " (string with commas/spaces) or a raw num.
double _parseCleanDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final cleaned = v.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }
  return 0.0;
}

CandidateDetailed _buildCandidateFromClean(
    int id, String dni, Map<String, dynamic> r) {
  final ingresos = r['Ingresos'] as List<dynamic>?;
  final monthly = ingresos != null && ingresos.length >= 3
      ? _parseCleanDouble(ingresos[2])
      : 0.0;
  return CandidateDetailed(
    id: id,
    dni: dni,
    partido: r['Partido'] as String? ?? '',
    numeroLista: id,
    educacion: EducationLevel(
      primaria: _isX(r['Primaria']),
      secundaria: _isX(r['Secundaria']),
      tecnico: _isX(r['Tecnicos']),
      noUniv: _isX(r['No Univ']),
      univ: _isX(r['Univ']),
      maestria: _isX(r['Maestria']),
      doctorado: _isX(r['Doctorado']),
    ),
    ingresosTotales: monthly,
    sentencias: (r['Sentencias'] as num?)?.toInt() ?? 0,
    reinfo: _isX(r['REINFO']),                                   // "X" | " X " | ""
    cantidadRegistrosMineros: (r['REINFO #'] as num?)?.toInt() ?? 0,
    congresistaReelecto: r['Congresista de que partido'] != null,
    periodoCongreso: r['Partido o Periodo'] as String? ?? '',
  );
}

List<CandidateDetailed> _parseCandidateListClean(String jsonString) {
  final Map<String, dynamic> parsed = jsonDecode(jsonString);
  final List<CandidateDetailed> result = [];
  int index = 1;
  parsed.forEach((dni, recordListRaw) {
    final recordList = recordListRaw as List<dynamic>;
    if (recordList.isNotEmpty) {
      final record = recordList[0] as Map<String, dynamic>;
      result.add(_buildCandidateFromClean(index, dni, record));
      index++;
    }
  });
  return result;
}
