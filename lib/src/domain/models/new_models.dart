// 01_metadata.json
class IndexMetadata {
  final String titulo;
  final String eleccion;
  final String descripcion;
  final List<IndicatorWeight> indicadores;

  IndexMetadata({
    required this.titulo,
    required this.eleccion,
    required this.descripcion,
    required this.indicadores,
  });

  factory IndexMetadata.fromJson(Map<String, dynamic> json) {
    return IndexMetadata(
      titulo: json['titulo'] as String? ?? '',
      eleccion: json['eleccion'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      indicadores:
          (json['indicadores'] as List<dynamic>?)
              ?.map((e) => IndicatorWeight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class IndicatorWeight {
  final String nombre;
  final double peso;

  IndicatorWeight({required this.nombre, required this.peso});

  factory IndicatorWeight.fromJson(Map<String, dynamic> json) {
    return IndicatorWeight(
      nombre: json['nombre'] as String? ?? '',
      peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 02 and 03_ranking_partidos
class PartyRanking {
  final int posicion;
  final String partido;
  final double score;
  final double? tasaCorrupcion; // Only in 100

  PartyRanking({
    required this.posicion,
    required this.partido,
    required this.score,
    this.tasaCorrupcion,
  });

  factory PartyRanking.fromJson(Map<String, dynamic> json) {
    return PartyRanking(
      posicion: json['posicion'] as int? ?? 0,
      partido: json['partido'] as String? ?? '',
      score: (json['score_total'] as num?)?.toDouble() ??
             (json['valor_compuesto_final'] as num?)?.toDouble() ?? 0.0,
      tasaCorrupcion: (json['tasa_corrupcion'] as num?)?.toDouble() ??
                      (json['valor_compuesto'] as num?)?.toDouble(),
    );
  }
}

// 04_estadisticas_por_partido.json
class PartyStats {
  final String partido;
  final double ingresosAvg;
  final int ingresosCero;
  final double preparacionAvg;
  final int sentenciasTotal;
  final double tk1;
  final double tk2;
  final double tk3;
  final int congReel;
  final int reinfoCount;

  PartyStats({
    required this.partido,
    required this.ingresosAvg,
    required this.ingresosCero,
    required this.preparacionAvg,
    required this.sentenciasTotal,
    required this.tk1,
    required this.tk2,
    required this.tk3,
    required this.congReel,
    required this.reinfoCount,
  });

  factory PartyStats.fromJson(Map<String, dynamic> json) {
    return PartyStats(
      partido: json['partido'] as String? ?? '',
      ingresosAvg:
          (json['ingresos_mensuales_totales']?['promedio'] as num?)
              ?.toDouble() ??
          0.0,
      ingresosCero:
          json['ingresos_mensuales_totales']?['num_con_cero'] as int? ?? 0,
      preparacionAvg:
          (json['preparacion_academica']?['promedio'] as num?)?.toDouble() ??
          0.0,
      sentenciasTotal: json['sentencias_judiciales']?['total'] as int? ?? 0,
      tk1: (json['tasa_korrupcion']?['tk1'] as num?)?.toDouble() ?? 0.0,
      tk2: (json['tasa_korrupcion']?['tk2'] as num?)?.toDouble() ?? 0.0,
      tk3: (json['tasa_korrupcion']?['tk3'] as num?)?.toDouble() ?? 0.0,
      congReel: json['congresistas_reelegidos'] as int? ?? 0,
      reinfoCount: (json['candidatos_reinfo'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Handles sentencias field that can be null, the String "X", or an int.
int _parseSentencias(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return value.trim().isEmpty ? 0 : 1;
  return 0;
}

// 05_candidatos_reinfo.json & 06_candidatos_individuales.json
class CandidateDetailed {
  final int id;
  final String dni;
  final String partido;
  final int numeroLista;
  final EducationLevel educacion;
  final double ingresosTotales;
  final int sentencias;
  final bool reinfo;
  final int cantidadRegistrosMineros;
  final bool congresistaReelecto;
  final String periodoCongreso;

  CandidateDetailed({
    required this.id,
    required this.dni,
    required this.partido,
    required this.numeroLista,
    required this.educacion,
    required this.ingresosTotales,
    required this.sentencias,
    required this.reinfo,
    required this.cantidadRegistrosMineros,
    required this.congresistaReelecto,
    required this.periodoCongreso,
  });

  factory CandidateDetailed.fromJson(Map<String, dynamic> json) {
    return CandidateDetailed(
      id: json['numero'] as int? ?? 0,
      dni: json['dni']?.toString() ?? '',
      partido: json['partido'] as String? ?? '',
      numeroLista: json['numero'] as int? ?? 0,
      educacion: EducationLevel.fromJson(
        json['nivel_educativo'] as Map<String, dynamic>? ?? {},
      ),
      ingresosTotales:
          (json['ingreso_mensual_total'] as num?)?.toDouble() ?? 0.0,
      sentencias: _parseSentencias(json['sentencias']),
      reinfo: json['reinfo'] as bool? ?? false,
      cantidadRegistrosMineros: json['cantidad_mineras'] as int? ?? 0,
      congresistaReelecto: json['ex_congresista_partido'] != null,
      periodoCongreso: json['ex_congresista_periodo'] as String? ?? '',
    );
  }
}

class EducationLevel {
  final bool primaria;
  final bool secundaria;
  final bool tecnico;
  final bool noUniv;
  final bool univ;
  final bool maestria;
  final bool doctorado;

  EducationLevel({
    required this.primaria,
    required this.secundaria,
    required this.tecnico,
    required this.noUniv,
    required this.univ,
    required this.maestria,
    required this.doctorado,
  });

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    return EducationLevel(
      primaria: json['primaria'] as bool? ?? false,
      secundaria: json['secundaria'] as bool? ?? false,
      tecnico: json['tecnico'] as bool? ?? false,
      noUniv: json['no_universitario'] as bool? ?? false,
      univ: json['universitario'] as bool? ?? false,
      maestria: json['maestria'] as bool? ?? false,
      doctorado: json['doctorado'] as bool? ?? false,
    );
  }

  String get maxLevel {
    if (doctorado) return "Doctorado";
    if (maestria) return "Maestría";
    if (univ) return "Universitario";
    if (noUniv) return "No Universitario";
    if (tecnico) return "Técnico";
    if (secundaria) return "Secundaria";
    if (primaria) return "Primaria";
    return "Ninguno";
  }
}

// 07_dashboard_resumen.json
class DashboardSummary {
  final List<PartyRanking> top5;
  final List<PartyRanking> bottom5;
  final int totalPartidos;
  final int totalCandidatos;
  final int alertasReinfo;
  final int candidatosConSentencias;
  final int partidosEquipoCompleto;

  DashboardSummary({
    required this.top5,
    required this.bottom5,
    required this.totalPartidos,
    required this.totalCandidatos,
    required this.alertasReinfo,
    required this.candidatosConSentencias,
    required this.partidosEquipoCompleto,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      top5:
          (json['mejores_partidos_escala35'] as List<dynamic>?)
              ?.map((e) => PartyRanking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bottom5:
          (json['peores_partidos_escala35'] as List<dynamic>?)
              ?.map((e) => PartyRanking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPartidos: json['resumen']?['total_partidos'] as int? ?? 0,
      totalCandidatos:
          json['resumen']?['total_candidatos_evaluados'] as int? ?? 0,
      alertasReinfo: json['resumen']?['candidatos_en_reinfo'] as int? ?? 0,
      candidatosConSentencias:
          json['resumen']?['candidatos_con_sentencias'] as int? ?? 0,
      partidosEquipoCompleto:
          json['resumen']?['partidos_con_equipo_completo_30'] as int? ?? 0,
    );
  }
}

// 08_indicadores_graficas.json — all indicators normalized 0-100
class IndicatorGraphic {
  final String partido;
  final int posicion;
  final double tasaCorrupcion;
  final double sentencias;
  final double preparacion;
  final double ingresosNoDeclarados;
  final double ingresosEfectivos;
  final double librePacto;
  final double reeleccion;
  final double equipoCompleto;
  final double reinfo;
  final double scoreFinal;

  IndicatorGraphic({
    required this.partido,
    required this.posicion,
    required this.tasaCorrupcion,
    required this.sentencias,
    required this.preparacion,
    required this.ingresosNoDeclarados,
    required this.ingresosEfectivos,
    required this.librePacto,
    required this.reeleccion,
    required this.equipoCompleto,
    required this.reinfo,
    required this.scoreFinal,
  });

  factory IndicatorGraphic.fromJson(Map<String, dynamic> json) {
    final ind = json['indicadores'] as Map<String, dynamic>? ?? {};
    return IndicatorGraphic(
      partido: json['partido'] as String? ?? '',
      posicion: json['posicion'] as int? ?? 0,
      tasaCorrupcion: (json['tasa_corrupcion'] as num?)?.toDouble() ?? 0.0,
      sentencias: (ind['sentencias'] as num?)?.toDouble() ?? 0.0,
      preparacion: (ind['preparacion'] as num?)?.toDouble() ?? 0.0,
      ingresosNoDeclarados:
          (ind['ingresos_no_declarados'] as num?)?.toDouble() ?? 0.0,
      ingresosEfectivos:
          (ind['ingresos_efectivos'] as num?)?.toDouble() ?? 0.0,
      librePacto: (ind['libre_pacto'] as num?)?.toDouble() ?? 0.0,
      reeleccion: (ind['reeleccion'] as num?)?.toDouble() ?? 0.0,
      equipoCompleto: (ind['equipo_completo'] as num?)?.toDouble() ?? 0.0,
      reinfo: (ind['reinfo'] as num?)?.toDouble() ?? 0.0,
      scoreFinal: (ind['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Mapa de indicador → valor normalizado (0-100)
  Map<String, double> get allIndicators => {
    'sentencias': sentencias,
    'preparacion': preparacion,
    'ingresos_no_declarados': ingresosNoDeclarados,
    'ingresos_efectivos': ingresosEfectivos,
    'libre_pacto': librePacto,
    'reeleccion': reeleccion,
    'equipo_completo': equipoCompleto,
    'reinfo': reinfo,
  };
}

// Dataset_Senado_Nacional_clean_resumenDataset.json — aggregated raw stats per party
class PartyResumenRaw {
  final String partido;
  final int totalSentencias;
  final double porcentajeSentencias;
  final double promedioPreparacion;
  final double promedioIngresosMensualesTotales;
  final double promedioIngresosMensualesEfectivos;
  final int numConCero;
  final int totalCandidatos;
  final int candidatosEfectivos;
  final double tk3;
  final int reeleccionCongresistas;
  final double reinfoIndex;

  PartyResumenRaw({
    required this.partido,
    required this.totalSentencias,
    required this.porcentajeSentencias,
    required this.promedioPreparacion,
    required this.promedioIngresosMensualesTotales,
    required this.promedioIngresosMensualesEfectivos,
    required this.numConCero,
    required this.totalCandidatos,
    required this.candidatosEfectivos,
    required this.tk3,
    required this.reeleccionCongresistas,
    required this.reinfoIndex,
  });

  double get promedioIngresosAnuales => promedioIngresosMensualesTotales * 12;

  factory PartyResumenRaw.fromEntry(
    String partido,
    Map<String, dynamic> json,
  ) {
    final candidatos = json['# Candidatos'] as List<dynamic>?;
    final total = candidatos != null && candidatos.length >= 2
        ? (candidatos[1] as num?)?.toInt() ?? 0
        : 0;
    return PartyResumenRaw(
      partido: partido,
      totalSentencias: json['Total Sentencias'] as int? ?? 0,
      porcentajeSentencias:
          (json['Porcentaje Sentencias'] as num?)?.toDouble() ?? 0.0,
      promedioPreparacion:
          (json['Promedio Preparación'] as num?)?.toDouble() ?? 0.0,
      promedioIngresosMensualesTotales:
          (json['Promedio Ingresos Mensuales Totales'] as num?)?.toDouble() ??
          0.0,
      promedioIngresosMensualesEfectivos:
          (json['Promedio Ingresos Mensuales Efectivos'] as num?)?.toDouble() ??
          0.0,
      numConCero: json['# con Cero'] as int? ?? 0,
      totalCandidatos: total,
      candidatosEfectivos: json['# Cand Efec'] as int? ?? 0,
      tk3: (json['TK3'] as num?)?.toDouble() ?? 0.0,
      reeleccionCongresistas: json['Reelección Congresistas'] as int? ?? 0,
      reinfoIndex: (json['REINFO'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EducationStats {
  final int primaria;
  final int secundaria;
  final int tecnico;
  final int noUniv;
  final int univ;
  final int maestria;
  final int doctorado;

  EducationStats({
    required this.primaria,
    required this.secundaria,
    required this.tecnico,
    required this.noUniv,
    required this.univ,
    required this.maestria,
    required this.doctorado,
  });

  factory EducationStats.zero() => EducationStats(
    primaria: 0,
    secundaria: 0,
    tecnico: 0,
    noUniv: 0,
    univ: 0,
    maestria: 0,
    doctorado: 0,
  );

  factory EducationStats.fromCandidates(List<CandidateDetailed> candidates) {
    int primaria = 0,
        secundaria = 0,
        tecnico = 0,
        noUniv = 0,
        univ = 0,
        maestria = 0,
        doctorado = 0;
    for (var c in candidates) {
      final edu = c.educacion;
      if (edu.doctorado) {
        doctorado++;
      } else if (edu.maestria)
        maestria++;
      else if (edu.univ)
        univ++;
      else if (edu.noUniv)
        noUniv++;
      else if (edu.tecnico)
        tecnico++;
      else if (edu.secundaria)
        secundaria++;
      else if (edu.primaria)
        primaria++;
    }
    return EducationStats(
      primaria: primaria,
      secundaria: secundaria,
      tecnico: tecnico,
      noUniv: noUniv,
      univ: univ,
      maestria: maestria,
      doctorado: doctorado,
    );
  }
}
