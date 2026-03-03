import 'package:flutter/material.dart';

// ─── Scoring constants ────────────────────────────────────────────────────────

const int _kMaxEdu   = 40;
const int _kMaxPenal = 35;
const int _kMaxOblig = 25;
// Total max = 100

// ─── HojaVida model ───────────────────────────────────────────────────────────

class HojaVida {
  final String dni;
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
  final int    numInmuebles;
  final double valorInmuebles;
  final List<String> renuncioA;

  const HojaVida({
    required this.dni,
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
    required this.numInmuebles,
    required this.valorInmuebles,
    required this.renuncioA,
  });

  factory HojaVida.fromJson(String dni, Map<String, dynamic> j) {
    return HojaVida(
      dni:    dni,
      nombre: j['nombre'] as String? ?? '',
      partido: j['partido'] as String? ?? '',
      idOrg:  (j['idOrg'] as num?)?.toInt() ?? 0,
      nivelEducacion: j['nivelEducacion'] as String? ?? 'SIN_DATOS',
      esDoctor:  j['esDoctor'] as bool? ?? false,
      esMaestro: j['esMaestro'] as bool? ?? false,
      tieneUniversitaria: j['tieneUniversitaria'] as bool? ?? false,
      tieneTecnica: j['tieneTecnica'] as bool? ?? false,
      universidades: (j['universidades'] as List? ?? []).cast<String>(),
      posgrados:     (j['posgrados']     as List? ?? []).cast<String>(),
      totalSentenciasPenales:
          (j['totalSentenciasPenales'] as num?)?.toInt() ?? 0,
      totalSentenciasObligaciones:
          (j['totalSentenciasObligaciones'] as num?)?.toInt() ?? 0,
      ingresoTotal:   (j['ingresoTotal']   as num?)?.toDouble() ?? 0,
      numInmuebles:   (j['numInmuebles']   as num?)?.toInt() ?? 0,
      valorInmuebles: (j['valorInmuebles'] as num?)?.toDouble() ?? 0,
      renuncioA: (j['renuncioA'] as List? ?? []).cast<String>(),
    );
  }

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

  int get scoreFinal =>
      scoreEducacion + scoreIntegridadPenal + scoreIntegridadOblig;

  // 0–100 normalizado
  double get scoreNormalizado => scoreFinal.toDouble();

  // ── Labels y colores ───────────────────────────────────────────────────────

  Color get scoreColor {
    if (scoreFinal >= 70) return const Color(0xFF2E7D32); // verde oscuro
    if (scoreFinal >= 45) return const Color(0xFFF57F17); // ámbar
    return const Color(0xFFC62828);                        // rojo
  }

  Color get scoreBgColor {
    if (scoreFinal >= 70) return const Color(0xFFE8F5E9);
    if (scoreFinal >= 45) return const Color(0xFFFFF8E1);
    return const Color(0xFFFFEBEE);
  }

  String get scoreLabel {
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

    // Educación
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

    // Integridad
    if (totalSentenciasPenales == 0 && totalSentenciasObligaciones == 0) {
      partes.add('Sin antecedentes judiciales');
    } else {
      if (totalSentenciasPenales > 0) {
        partes.add('$totalSentenciasPenales sentencia${totalSentenciasPenales > 1 ? "s" : ""} penal${totalSentenciasPenales > 1 ? "es" : ""}');
      }
      if (totalSentenciasObligaciones > 0) {
        partes.add('$totalSentenciasObligaciones sentencia${totalSentenciasObligaciones > 1 ? "s" : ""} de obligación');
      }
    }

    return partes.join(' · ');
  }
}

// ─── CandidatoConHV: HojaVida + info regional ─────────────────────────────────

class CandidatoConHV {
  final HojaVida hv;
  final String   tipoDistrito; // 'ÚNICO' | 'MÚLTIPLE'
  final String   departamento;
  final int      posicion;
  final String?  fotoUrl;
  final String?  strNombre; // guid.jpg para construir fotoUrl

  const CandidatoConHV({
    required this.hv,
    required this.tipoDistrito,
    required this.departamento,
    required this.posicion,
    required this.fotoUrl,
    required this.strNombre,
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
