class GlobalStats {
  final int totalCandidatos;
  GlobalStats({required this.totalCandidatos});

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(totalCandidatos: json['total_candidatos'] as int? ?? 0);
  }
}

class IncomeStats {
  final double promedio;
  final double mediana;

  IncomeStats({required this.promedio, required this.mediana});

  factory IncomeStats.fromJson(Map<String, dynamic> json) {
    return IncomeStats(
      promedio: (json['promedio'] as num?)?.toDouble() ?? 0.0,
      mediana: (json['mediana'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LegalStats {
  final int conSentencia;
  final int sinSentencia;
  final int enReinfo;

  LegalStats({
    required this.conSentencia,
    required this.sinSentencia,
    required this.enReinfo,
  });

  factory LegalStats.fromJson(Map<String, dynamic> json) {
    return LegalStats(
      conSentencia: json['con_sentencia'] as int? ?? 0,
      sinSentencia: json['sin_sentencia'] as int? ?? 0,
      enReinfo: json['en_reinfo'] as int? ?? 0,
    );
  }
}

class EducationDistribution {
  final int primaria;
  final int secundaria;
  final int tecnico;
  final int noUniv;
  final int univ;
  final int maestria;
  final int doctorado;

  EducationDistribution({
    required this.primaria,
    required this.secundaria,
    required this.tecnico,
    required this.noUniv,
    required this.univ,
    required this.maestria,
    required this.doctorado,
  });

  factory EducationDistribution.fromJson(Map<String, dynamic> json) {
    return EducationDistribution(
      primaria: json['primaria'] as int? ?? 0,
      secundaria: json['secundaria'] as int? ?? 0,
      tecnico: json['tecnico'] as int? ?? 0,
      noUniv: json['no_univ'] as int? ?? 0,
      univ: json['univ'] as int? ?? 0,
      maestria: json['maestria'] as int? ?? 0,
      doctorado: json['doctorado'] as int? ?? 0,
    );
  }
}

class RankedCandidate {
  final String dni;
  final String partido;
  final double score;

  RankedCandidate({
    required this.dni,
    required this.partido,
    required this.score,
  });

  factory RankedCandidate.fromJson(Map<String, dynamic> json) {
    return RankedCandidate(
      dni: json['dni'] as String? ?? '',
      partido: json['partido'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
