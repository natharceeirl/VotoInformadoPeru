import 'package:flutter/material.dart';

// ─── Proceso Electoral enum ───────────────────────────────────────────────────

enum ProcesoElectoral {
  presidentes,
  diputados,
  senadores,
  parlamentoAndino;

  String get displayName {
    switch (this) {
      case ProcesoElectoral.presidentes:    return 'Presidente y Vicepresidentes';
      case ProcesoElectoral.diputados:      return 'Diputados';
      case ProcesoElectoral.senadores:      return 'Senadores';
      case ProcesoElectoral.parlamentoAndino: return 'Parlamento Andino';
    }
  }

  String get bdFile {
    switch (this) {
      case ProcesoElectoral.presidentes:    return 'assets/baseDatos/bdActualizada_presidentes.json';
      case ProcesoElectoral.diputados:      return 'assets/baseDatos/bdActualizada_diputados.json';
      case ProcesoElectoral.senadores:      return 'assets/baseDatos/bdActualizada_senadores_distritoUnico.json';
      case ProcesoElectoral.parlamentoAndino: return 'assets/baseDatos/bdActualizada_parlamentoAndino.json';
    }
  }

  String get bdFileExtra {
    if (this == ProcesoElectoral.senadores) {
      return 'assets/baseDatos/bdActualizada_senadores_distritoMultiple.json';
    }
    return '';
  }

  // bdTopKey no longer used (new BD files are flat lists, not keyed maps).
  // Kept for backwards compatibility if any old code references it.
  String get bdTopKey {
    switch (this) {
      case ProcesoElectoral.presidentes:    return 'PRESIDENCIAL';
      case ProcesoElectoral.diputados:      return 'DIPUTADOS';
      case ProcesoElectoral.senadores:      return 'SENADORES DISTRITO ÚNICO';
      case ProcesoElectoral.parlamentoAndino: return 'PARLAMENTO ANDINO';
    }
  }

  String get hvFile {
    switch (this) {
      case ProcesoElectoral.presidentes:    return 'assets/baseDatos/hojas_vida_presidentes.json';
      case ProcesoElectoral.diputados:      return 'assets/baseDatos/hojas_vida_diputados.json';
      case ProcesoElectoral.senadores:      return 'assets/baseDatos/hojas_vida.json';
      case ProcesoElectoral.parlamentoAndino: return 'assets/baseDatos/hojas_vida_parlamento_andino.json';
    }
  }

  IconData get icon {
    switch (this) {
      case ProcesoElectoral.presidentes:    return Icons.star_rounded;
      case ProcesoElectoral.diputados:      return Icons.account_balance_rounded;
      case ProcesoElectoral.senadores:      return Icons.gavel_rounded;
      case ProcesoElectoral.parlamentoAndino: return Icons.public_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProcesoElectoral.presidentes:    return const Color(0xFF1E3A5F);
      case ProcesoElectoral.diputados:      return const Color(0xFF1B4F72);
      case ProcesoElectoral.senadores:      return const Color(0xFF154360);
      case ProcesoElectoral.parlamentoAndino: return const Color(0xFF1A5276);
    }
  }

  /// Asset PNG image for use as icon in screens.
  String get imagePath {
    switch (this) {
      case ProcesoElectoral.presidentes:    return 'assets/assets/Presidente.png';
      case ProcesoElectoral.diputados:      return 'assets/assets/Diputados.png';
      case ProcesoElectoral.senadores:      return 'assets/assets/Senadores.png';
      case ProcesoElectoral.parlamentoAndino: return 'assets/assets/ParlamentoAndino.png';
    }
  }

  String get jnePortalUrl =>
      'https://votoinformado.jne.gob.pe/home';
}

// ─── Experiencia Laboral ──────────────────────────────────────────────────────

class ExpLaboral {
  final String cargo;
  final String institucion;
  final String fechaInicio;
  final String fechaFin;
  final String funcion;

  const ExpLaboral({
    required this.cargo,
    required this.institucion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.funcion,
  });

  factory ExpLaboral.fromJson(Map<String, dynamic> j) => ExpLaboral(
        cargo:       j['cargo']        as String? ?? '',
        // v3 JSON uses 'centroTrabajo'; old senadores JSON uses 'institucion'
        institucion: j['centroTrabajo'] as String? ?? j['institucion'] as String? ?? '',
        fechaInicio: j['desde']        as String? ?? j['fechaInicio'] as String? ?? '',
        fechaFin:    j['hasta']        as String? ?? j['fechaFin']    as String? ?? '',
        funcion:     j['comentario']   as String? ?? j['funcion']     as String? ?? '',
      );

  String get resumen {
    final parts = <String>[];
    if (cargo.isNotEmpty) parts.add(cargo);
    if (institucion.isNotEmpty) parts.add(institucion);
    if (fechaInicio.isNotEmpty || fechaFin.isNotEmpty) {
      parts.add('(${fechaInicio.isNotEmpty ? fechaInicio : '?'} – ${fechaFin.isNotEmpty ? fechaFin : 'actual'})');
    }
    return parts.join(' · ');
  }
}

// ─── Cargo Político ───────────────────────────────────────────────────────────

class CargoPolitico {
  final String cargo;
  final String entidad; // partido or elected entity
  final String periodo;
  final String tipo; // 'partidario' | 'popular'

  const CargoPolitico({
    required this.cargo,
    required this.entidad,
    required this.periodo,
    required this.tipo,
  });

  factory CargoPolitico.fromJson(Map<String, dynamic> j, String tipo) {
    // v3 JSON uses 'organizacion'; old senadores JSON uses 'partido'/'entidad'
    final entidad = j['organizacion'] as String? ??
                    j['partido']      as String? ??
                    j['entidad']      as String? ?? '';
    // v3 JSON uses 'desde'/'hasta'; old uses 'periodo'/'anio'
    final desde   = j['desde']   as String? ?? '';
    final hasta   = j['hasta']   as String? ?? '';
    final periodo = desde.isNotEmpty
        ? (hasta.isNotEmpty && hasta != desde ? '$desde–$hasta' : desde)
        : (j['periodo'] as String? ?? j['anio'] as String? ?? '');
    return CargoPolitico(
      cargo:   j['cargo'] as String? ?? '',
      entidad: entidad,
      periodo: periodo,
      tipo:    tipo,
    );
  }
}

// ─── Scoring constants ────────────────────────────────────────────────────────

const int _kMaxEdu   = 40;
const int _kMaxPenal = 35;
const int _kMaxOblig = 25;
// Total max = 100

// ─── HojaVida model ───────────────────────────────────────────────────────────

class HojaVida {
  final String dni;
  final int?   idHojaVida;
  final String nombre;
  final String partido;
  final int    idOrg;
  final String nivelEducacion;
  final bool   esDoctor;
  final bool   esMaestro;
  final bool   tieneUniversitaria;
  final bool   tieneTecnica;
  final List<String> universidades;
  final List<String> posgrados;
  final int    totalSentenciasPenales;
  final int    totalSentenciasObligaciones;
  final double ingresoTotal;
  final double ingresoPublico;
  final double ingresoPrivado;
  final String anioIngresos;
  final int    numInmuebles;
  final double valorInmuebles;
  final int    numVehiculos;
  final List<String>      renuncioA;
  final List<ExpLaboral>  experienciaLaboral;
  final List<CargoPolitico> cargosPartidarios;
  final List<CargoPolitico> cargosEleccionPopular;
  final String notaAdicional;
  final int    numLeyesProCrimen;         // nº de leyes pro-crimen apoyadas personalmente (0 = ninguna)
  final int    numLeyesProCrimenPartido;  // nº de leyes pro-crimen apoyadas por su partido (0 = ninguna)
  final String investigacionesConocidas;  // texto de investigaciones/controversias conocidas
  final bool   esReinfo;                  // candidato aparece en base de datos REINFO
  final int    cantidadMineras;           // número de licencias mineras (0 = ninguna)
  final bool   universidadCuestionada;    // estudió en una universidad con licencia denegada o cuestionada
  final bool   universidadElite;          // estudió en una universidad de élite reconocida
  final String departamentoHv;            // departamento extraído de la primera exp. laboral (fallback para Parlamento Andino)

  const HojaVida({
    required this.dni,
    this.idHojaVida,
    required this.nombre,
    required this.partido,
    required this.idOrg,
    required this.nivelEducacion,
    required this.esDoctor,
    required this.esMaestro,
    required this.tieneUniversitaria,
    required this.tieneTecnica,
    required this.universidades,
    required this.posgrados,
    required this.totalSentenciasPenales,
    required this.totalSentenciasObligaciones,
    required this.ingresoTotal,
    this.ingresoPublico = 0,
    this.ingresoPrivado = 0,
    this.anioIngresos = '',
    required this.numInmuebles,
    required this.valorInmuebles,
    this.numVehiculos = 0,
    required this.renuncioA,
    this.experienciaLaboral = const [],
    this.cargosPartidarios  = const [],
    this.cargosEleccionPopular = const [],
    this.notaAdicional = '',
    this.numLeyesProCrimen = 0,
    this.numLeyesProCrimenPartido = 0,
    this.investigacionesConocidas = '',
    this.esReinfo = false,
    this.cantidadMineras = 0,
    this.universidadCuestionada = false,
    this.universidadElite = false,
    this.departamentoHv = '',
  });

  factory HojaVida.fromJson(String dni, Map<String, dynamic> j) {
    List<ExpLaboral> parseExp(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(ExpLaboral.fromJson)
          .toList();
    }

    List<CargoPolitico> parseCargos(dynamic raw, String tipo) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((m) => CargoPolitico.fromJson(m, tipo))
          .toList();
    }

    // v3 JSON: universidades = [{universidad, carrera, concluido}]
    // old JSON: universidades = [String]
    List<String> parseEduList(dynamic raw) {
      if (raw is! List) return [];
      return raw.map<String>((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) {
          final carrera    = e['carrera']    as String? ?? '';
          final universidad = e['universidad'] as String? ?? '';
          if (carrera.isNotEmpty && universidad.isNotEmpty) {
            return '$carrera — $universidad';
          }
          return carrera.isNotEmpty ? carrera : universidad;
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    // v3 JSON: posgrados = [{centro, especialidad, esMaestro, esDoctor, anio}]
    List<String> parsePosgradoList(dynamic raw) {
      if (raw is! List) return [];
      return raw.map<String>((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) {
          final especialidad = e['especialidad'] as String? ?? '';
          final centro       = e['centro']       as String? ?? '';
          final anio         = e['anio']         as String? ?? '';
          final parts = <String>[];
          if (especialidad.isNotEmpty) parts.add(especialidad);
          if (centro.isNotEmpty) parts.add(centro);
          if (anio.isNotEmpty) parts.add('($anio)');
          return parts.join(' — ');
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    // v3 JSON: renuncioA = [{orgPolRenunciaOp, anioRenunciaOp}]
    // old JSON: renuncioA = [String]
    List<String> parseRenuncioA(dynamic raw) {
      if (raw is! List) return [];
      return raw.map<String>((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) {
          final org  = e['orgPolRenunciaOp'] as String? ?? '';
          final anio = e['anioRenunciaOp']   as String? ?? '';
          if (org.isNotEmpty && anio.isNotEmpty) return '$org ($anio)';
          return org.isNotEmpty ? org : anio;
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return HojaVida(
      dni:    dni,
      idHojaVida: (j['idHojaVida'] as num?)?.toInt(),
      nombre: j['nombre'] as String? ?? '',
      partido: j['partido'] as String? ?? '',
      idOrg:  (j['idOrg'] as num?)?.toInt() ?? 0,
      nivelEducacion: j['nivelEducacion'] as String? ?? 'SIN_DATOS',
      esDoctor:  j['esDoctor'] as bool? ?? false,
      esMaestro: j['esMaestro'] as bool? ?? false,
      tieneUniversitaria: j['tieneUniversitaria'] as bool? ?? false,
      tieneTecnica: j['tieneTecnica'] as bool? ?? false,
      universidades: parseEduList(j['universidades']),
      posgrados:     parsePosgradoList(j['posgrados']),
      totalSentenciasPenales:
          (j['totalSentenciasPenales'] as num?)?.toInt() ?? 0,
      totalSentenciasObligaciones:
          (j['totalSentenciasObligaciones'] as num?)?.toInt() ?? 0,
      ingresoTotal:   (j['ingresoTotal']   as num?)?.toDouble() ?? 0,
      ingresoPublico: (j['ingresoPublico'] as num?)?.toDouble() ?? 0,
      ingresoPrivado: (j['ingresoPrivado'] as num?)?.toDouble() ?? 0,
      anioIngresos:   j['anioIngresos']    as String? ?? '',
      numInmuebles:   (j['numInmuebles']   as num?)?.toInt() ?? 0,
      valorInmuebles: (j['valorInmuebles'] as num?)?.toDouble() ?? 0,
      numVehiculos:   (j['numVehiculos']   as num?)?.toInt() ?? 0,
      renuncioA: parseRenuncioA(j['renuncioA']),
      experienciaLaboral:    parseExp(j['experienciaLaboral']),
      cargosPartidarios:     parseCargos(j['cargosPartidarios'], 'partidario'),
      cargosEleccionPopular: parseCargos(j['cargosEleccionPopular'], 'popular'),
      notaAdicional: j['notaAdicional'] as String? ?? '',
      departamentoHv: () {
        final expList = j['experienciaLaboral'];
        if (expList is List && expList.isNotEmpty) {
          final first = expList.first;
          if (first is Map<String, dynamic>) {
            return (first['departamento'] as String? ?? '').toUpperCase();
          }
        }
        return '';
      }(),
    );
  }

  // ── Copy with pro-crime count ──────────────────────────────────────────────

  HojaVida copyWith({
    String? partido,
    int?    idOrg,
    int?    numLeyesProCrimen,
    int?    numLeyesProCrimenPartido,
    String? investigacionesConocidas,
    bool?   esReinfo,
    int?    cantidadMineras,
    bool?   universidadCuestionada,
    bool?   universidadElite,
  }) => HojaVida(
    dni:    dni,
    idHojaVida: idHojaVida,
    nombre: nombre,
    partido: partido ?? this.partido,
    idOrg:  idOrg   ?? this.idOrg,
    nivelEducacion: nivelEducacion,
    esDoctor:  esDoctor,
    esMaestro: esMaestro,
    tieneUniversitaria: tieneUniversitaria,
    tieneTecnica: tieneTecnica,
    universidades: universidades,
    posgrados:     posgrados,
    totalSentenciasPenales:      totalSentenciasPenales,
    totalSentenciasObligaciones: totalSentenciasObligaciones,
    ingresoTotal:   ingresoTotal,
    ingresoPublico: ingresoPublico,
    ingresoPrivado: ingresoPrivado,
    anioIngresos:   anioIngresos,
    numInmuebles:   numInmuebles,
    valorInmuebles: valorInmuebles,
    numVehiculos:   numVehiculos,
    renuncioA: renuncioA,
    experienciaLaboral:    experienciaLaboral,
    cargosPartidarios:     cargosPartidarios,
    cargosEleccionPopular: cargosEleccionPopular,
    notaAdicional: notaAdicional,
    numLeyesProCrimen:        numLeyesProCrimen        ?? this.numLeyesProCrimen,
    numLeyesProCrimenPartido: numLeyesProCrimenPartido ?? this.numLeyesProCrimenPartido,
    investigacionesConocidas: investigacionesConocidas ?? this.investigacionesConocidas,
    esReinfo:               esReinfo               ?? this.esReinfo,
    cantidadMineras:        cantidadMineras        ?? this.cantidadMineras,
    universidadCuestionada: universidadCuestionada ?? this.universidadCuestionada,
    universidadElite:       universidadElite       ?? this.universidadElite,
    departamentoHv:         departamentoHv,
  );

  // ── Scoring ────────────────────────────────────────────────────────────────

  int get scoreEducacion {
    switch (nivelEducacion) {
      case 'DOCTORADO':               return _kMaxEdu;      // 40
      case 'MAESTRIA':                return 35;
      case 'POSGRADO':                return 25;
      case 'UNIVERSITARIA':           return 15;
      case 'UNIVERSITARIA_INCOMPLETA': return 8;
      case 'TECNICA':                 return 8;
      case 'NO_UNIVERSITARIA':        return 3;
      case 'SECUNDARIA':              return 3;
      case 'PRIMARIA':                return 1;
      default:                        return 0;
    }
  }

  int get scoreIntegridadPenal {
    if (totalSentenciasPenales == 0) return _kMaxPenal;   // 35
    if (totalSentenciasPenales == 1) return 12;
    return 0;
  }

  int get scoreIntegridadOblig {
    if (totalSentenciasObligaciones == 0) return _kMaxOblig; // 25
    if (totalSentenciasObligaciones == 1) return 10;
    if (totalSentenciasObligaciones == 2) return 4;
    return 0;
  }

  // ── Penalizaciones ─────────────────────────────────────────────────────────

  /// -5 pts por cada ley pro-crimen apoyada personalmente, máximo -20
  int get penaltyProCrimen => (numLeyesProCrimen * 5).clamp(0, 20);

  /// -8 pts por cada ley pro-crimen que su partido apoyó, máximo -25
  int get penaltyProCrimenPartido => (numLeyesProCrimenPartido * 8).clamp(0, 25);

  // Texto unificado de todos los cargos para búsqueda de keywords
  String get _allCargosText {
    final parts = [
      ...cargosEleccionPopular.map((c) => '${c.cargo} ${c.entidad}'),
      ...cargosPartidarios.map((c) => '${c.cargo} ${c.entidad}'),
      ...experienciaLaboral.map((e) => '${e.cargo} ${e.institucion}'),
    ];
    return parts.join(' ').toUpperCase();
  }

  /// Penalización por cargos públicos de riesgo previos:
  /// Congresista/Parlamentario (−5), Alcalde/Regidor (−3),
  /// Ministro/a (−3), Gobernador (−3), Asesor (−2). Máximo −15.
  int get penaltyCargosPublicos {
    final t = _allCargosText;
    var p = 0;
    if (t.contains('CONGRES') || t.contains('PARLAMENT') ||
        t.contains('SENADOR') || t.contains('DIPUTADO')) { p += 5; }
    if (t.contains('ALCALDE') || t.contains('ALCALDESA') ||
        t.contains('REGIDOR')) { p += 3; }
    if (t.contains('MINISTRO') || t.contains('MINISTRA') ||
        t.contains('VICEMINISTRO')) { p += 3; }
    if (t.contains('GOBERNADOR') || t.contains('GOBERNADORA') ||
        t.contains('PRESIDENTE REGIONAL')) { p += 3; }
    if (t.contains('ASESOR') || t.contains('ASESORA')) { p += 2; }
    return p.clamp(0, 15);
  }

  /// -10 pts si tiene investigaciones o controversias conocidas graves
  int get penaltyInvestigaciones => investigacionesConocidas.isNotEmpty ? 10 : 0;

  /// -10 pts si está en REINFO, -5 pts adicionales si tiene 5+ mineras. Máximo -15.
  int get penaltyReinfo {
    if (!esReinfo) return 0;
    return cantidadMineras >= 5 ? 15 : 10;
  }

  /// +5 pts si estudió en una universidad de élite reconocida
  int get bonusUniversidadElite => universidadElite ? 5 : 0;

  /// -5 pts si estudió en una universidad con licencia denegada o cuestionada
  int get penaltyUniversidadCuestionada => universidadCuestionada ? 5 : 0;

  int get scoreFinal {
    final raw = scoreEducacion + scoreIntegridadPenal + scoreIntegridadOblig
        + bonusUniversidadElite
        - penaltyProCrimen - penaltyProCrimenPartido
        - penaltyCargosPublicos - penaltyInvestigaciones
        - penaltyReinfo - penaltyUniversidadCuestionada;
    return raw.clamp(0, 9999); // lower bound 0, no upper cap
  }

  double get scoreNormalizado => scoreFinal.toDouble();

  String get jneHvUrl {
    final paddedDni = dni.padLeft(8, '0');
    return 'https://votoinformado.jne.gob.pe/hoja-vida/$idOrg/$paddedDni';
  }

  // ── Labels y colores ───────────────────────────────────────────────────────

  Color get scoreColor {
    if (scoreFinal >= 80) return const Color(0xFF1B5E20); // verde muy oscuro
    if (scoreFinal >= 70) return const Color(0xFF2E7D32); // verde oscuro
    if (scoreFinal >= 45) return const Color(0xFFF57F17); // ámbar
    return const Color(0xFFC62828);                        // rojo
  }

  Color get scoreBgColor {
    if (scoreFinal >= 80) return const Color(0xFFD7F5DC);
    if (scoreFinal >= 70) return const Color(0xFFE8F5E9);
    if (scoreFinal >= 45) return const Color(0xFFFFF8E1);
    return const Color(0xFFFFEBEE);
  }

  String get scoreLabel {
    if (scoreFinal >= 80) return 'Perfil excelente';
    if (scoreFinal >= 70) return 'Perfil sólido';
    if (scoreFinal >= 45) return 'Perfil moderado';
    return 'Perfil con alertas';
  }

  String get educacionLabel {
    switch (nivelEducacion) {
      case 'DOCTORADO':                return 'Doctor/a';
      case 'MAESTRIA':                 return 'Maestría';
      case 'POSGRADO':                 return 'Posgrado';
      case 'UNIVERSITARIA':            return 'Universitario/a';
      case 'UNIVERSITARIA_INCOMPLETA': return 'Univ. incompleta';
      case 'TECNICA':                  return 'Técnico/a';
      case 'NO_UNIVERSITARIA':         return 'No universitario';
      case 'SECUNDARIA':               return 'Secundaria';
      case 'PRIMARIA':                 return 'Primaria';
      default:                         return 'Sin datos';
    }
  }

  IconData get educacionIcon {
    switch (nivelEducacion) {
      case 'DOCTORADO':
      case 'MAESTRIA':
      case 'POSGRADO':   return Icons.school;
      case 'UNIVERSITARIA':
      case 'UNIVERSITARIA_INCOMPLETA': return Icons.account_balance;
      case 'TECNICA':    return Icons.build;
      default:           return Icons.person;
    }
  }

  Color get educacionColor {
    switch (nivelEducacion) {
      case 'DOCTORADO':   return const Color(0xFF1565C0);
      case 'MAESTRIA':    return const Color(0xFF0277BD);
      case 'POSGRADO':    return const Color(0xFF00838F);
      case 'UNIVERSITARIA': return const Color(0xFF2E7D32);
      case 'UNIVERSITARIA_INCOMPLETA':
      case 'TECNICA':     return const Color(0xFFF57F17);
      default:            return const Color(0xFF757575);
    }
  }

  /// Texto explicativo corto para la tarjeta de recomendación.
  String get resumenPerfil {
    final partes = <String>[];

    if (esDoctor && posgrados.isNotEmpty) {
      final spec = posgrados.first.split('—').first.trim();
      partes.add(spec.length > 40 ? 'Doctorado' : spec);
    } else if (esMaestro && posgrados.isNotEmpty) {
      final spec = posgrados.first.split('—').first.trim();
      partes.add(spec.length > 40 ? 'Maestría' : spec);
    } else if (tieneUniversitaria && universidades.isNotEmpty) {
      partes.add(universidades.first);
    } else {
      partes.add(educacionLabel);
    }

    if (totalSentenciasPenales == 0 && totalSentenciasObligaciones == 0) {
      partes.add('Sin antecedentes judiciales');
    } else {
      if (totalSentenciasPenales > 0) {
        partes.add('$totalSentenciasPenales sentencia${totalSentenciasPenales > 1 ? "s" : ""} penal${totalSentenciasPenales > 1 ? "es" : ""}');
      }
      if (totalSentenciasObligaciones > 0) {
        partes.add('$totalSentenciasObligaciones sent. de obligación');
      }
    }

    if (experienciaLaboral.isNotEmpty) {
      partes.add('${experienciaLaboral.length} exp. laboral${experienciaLaboral.length > 1 ? "es" : ""}');
    }

    if (esReinfo) partes.add('⚠ Vinculado a minería informal (REINFO)');
    if (universidadCuestionada) partes.add('⚠ Univ. con licencia denegada');
    if (universidadElite) partes.add('✓ Univ. de élite');

    return partes.isNotEmpty ? partes.join(' · ') : 'Sin observaciones destacadas';
  }
}

// ─── CandidatoConHV: HojaVida + info regional ─────────────────────────────────

class CandidatoConHV {
  final HojaVida hv;
  final String   tipoDistrito; // 'ÚNICO' | 'MÚLTIPLE' | 'NACIONAL' | ''
  final String   departamento;
  final int      posicion;
  final String?  fotoUrl;
  final String?  strNombre;  // guid.jpg
  final String   cargo;       // 'PRESIDENTE', 'DIPUTADO', etc.

  const CandidatoConHV({
    required this.hv,
    required this.tipoDistrito,
    required this.departamento,
    required this.posicion,
    required this.fotoUrl,
    required this.strNombre,
    this.cargo = '',
  });
}

// ─── Estadísticas agregadas ────────────────────────────────────────────────────

class IntegridadStats {
  final int total;
  final Map<String, int> porNivelEducacion;
  final int conSentenciaPenal;
  final int conSentenciaOblig;
  final int sinCualquierSentencia;
  final double ingresoPromedio;
  final Map<String, PartidoStat> porPartido;

  const IntegridadStats({
    required this.total,
    required this.porNivelEducacion,
    required this.conSentenciaPenal,
    required this.conSentenciaOblig,
    required this.sinCualquierSentencia,
    required this.ingresoPromedio,
    required this.porPartido,
  });

  factory IntegridadStats.fromList(List<HojaVida> lista) {
    final Map<String, int> niveles = {};
    final Map<String, PartidoStat> partidos = {};
    int penal = 0, oblig = 0, sinSent = 0;
    double sumIngreso = 0; int cntIngreso = 0;

    for (final h in lista) {
      niveles[h.nivelEducacion] = (niveles[h.nivelEducacion] ?? 0) + 1;
      if (h.totalSentenciasPenales > 0) penal++;
      if (h.totalSentenciasObligaciones > 0) oblig++;
      if (h.totalSentenciasPenales == 0 && h.totalSentenciasObligaciones == 0) sinSent++;
      if (h.ingresoTotal > 0) { sumIngreso += h.ingresoTotal; cntIngreso++; }

      final p = partidos.putIfAbsent(h.partido, () => PartidoStat(h.partido));
      p.total++;
      if (h.esDoctor) p.doctores++;
      if (h.esMaestro || h.esDoctor) p.conPosgrado++;
      if (h.tieneUniversitaria) p.conUniversitaria++;
      if (h.totalSentenciasPenales > 0) p.conSentPenal++;
      if (h.totalSentenciasObligaciones > 0) p.conSentOblig++;
      p.sumaScore += h.scoreFinal;
    }

    return IntegridadStats(
      total: lista.length,
      porNivelEducacion: niveles,
      conSentenciaPenal: penal,
      conSentenciaOblig: oblig,
      sinCualquierSentencia: sinSent,
      ingresoPromedio: cntIngreso > 0 ? sumIngreso / cntIngreso : 0,
      porPartido: partidos,
    );
  }
}

class PartidoStat {
  final String nombre;
  int total = 0;
  int doctores = 0;
  int conPosgrado = 0;
  int conUniversitaria = 0;
  int conSentPenal = 0;
  int conSentOblig = 0;
  int sumaScore = 0;

  PartidoStat(this.nombre);

  double get pctPosgrado => total > 0 ? conPosgrado / total * 100 : 0;
  double get pctSinPenal => total > 0 ? (total - conSentPenal) / total * 100 : 0;
  double get pctSinOblig => total > 0 ? (total - conSentOblig) / total * 100 : 0;
  double get scorePromedio => total > 0 ? sumaScore / total : 0;
}
