import 'package:flutter/foundation.dart' show kIsWeb;

/// Builds the photo URL: proxy on web (avoids CORS), direct on native.
String _jneFotoUrl(String guid) => kIsWeb
    ? '/.netlify/functions/foto-proxy?guidFoto=$guid'
    : 'https://votoinformado.jne.gob.pe/VotoInformado/Informacion/GetFoto?guidFoto=$guid';

/// Maps JNE uppercase party names → standard names used in party_logo.dart assets.
/// Includes both short names and full legal names as they appear in JNE JSON data.
const _jneToStandardParty = <String, String>{
  // Ahora Nación
  'AHORA NACION': 'Ahora Nación',
  'AHORA NACION - AN': 'Ahora Nación',
  // Alianza para el Progreso
  'ALIANZA PARA EL PROGRESO': 'Alianza para el Progreso',
  // Alianza Electoral Venceremos
  'ALIANZA ELECTORAL VENCEREMOS': 'Venceremos',
  'VENCEREMOS': 'Venceremos',
  // APRA
  'APRA': 'APRA',
  'PARTIDO APRISTA PERUANO': 'APRA',
  // Avanza País
  'AVANZA PAIS': 'Avanza País',
  'AVANZA PAÍS': 'Avanza País',
  'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL': 'Avanza País',
  // Buen Gobierno
  'BUEN GOBIERNO': 'Buen Gobierno',
  'PARTIDO DEL BUEN GOBIERNO': 'Buen Gobierno',
  // Cooperación Popular
  'COOPERACION POPULAR': 'Cooperación Popular',
  'PARTIDO POLITICO COOPERACION POPULAR': 'Cooperación Popular',
  // Fe en el Perú
  'FE EN EL PERU': 'Fe en el Perú',
  // Frente de la Esperanza
  'FRENTE DE LA ESPERANZA': 'Frente de la Esperanza',
  'PARTIDO FRENTE DE LA ESPERANZA 2021': 'Frente de la Esperanza',
  // FREPAP
  'FREPAP': 'FREPAP',
  // Fuerza Popular
  'FUERZA POPULAR': 'Fuerza Popular',
  // Fuerza y Libertad
  'FUERZA Y LIBERTAD': 'Fuerza y Libertad',
  // Integridad Democrática
  'INTEGRIDAD DEMOCRATICA': 'Integridad Democrática',
  'PARTIDO POLITICO INTEGRIDAD DEMOCRATICA': 'Integridad Democrática',
  // Juntos por el Perú
  'JUNTOS POR EL PERU': 'Juntos por el Perú',
  // Libertad Popular
  'LIBERTAD POPULAR': 'Libertad Popular',
  // Obras
  'OBRAS': 'Obras',
  'PARTIDO CIVICO OBRAS': 'Obras',
  // País para Todos
  'PAIS PARA TODOS': 'País para Todos',
  'PARTIDO PAIS PARA TODOS': 'País para Todos',
  // Partido Morado
  'PARTIDO MORADO': 'Partido Morado',
  // Perú Acción
  'PERU ACCION': 'Perú Acción',
  'PARTIDO POLITICO PERU ACCION': 'Perú Acción',
  // Perú Federal
  'PERU FEDERAL': 'Perú Federal',
  'PARTIDO DEMOCRATICO FEDERAL': 'Perú Federal',
  // Perú Libre
  'PERU LIBRE': 'Perú Libre',
  'PARTIDO POLITICO NACIONAL PERU LIBRE': 'Perú Libre',
  // Perú Moderno
  'PERU MODERNO': 'Perú Moderno',
  // Perú Primero
  'PERU PRIMERO': 'Perú Primero',
  'PARTIDO POLITICO PERU PRIMERO': 'Perú Primero',
  // Podemos Perú
  'PODEMOS PERU': 'Podemos Perú',
  // PPP
  'PPP': 'PPP',
  // Primero La Gente
  'PRIMERO LA GENTE': 'Primero La Gente',
  'PRIMERO LA GENTE - COMUNIDAD, ECOLOGIA, LIBERTAD Y PROGRESO': 'Primero La Gente',
  // PRIN
  'PRIN': 'PRIN',
  'PARTIDO POLITICO PRIN': 'PRIN',
  // Progresemos
  'PROGRESEMOS': 'Progresemos',
  // PTE
  'PTE': 'PTE',
  'PARTIDO DE LOS TRABAJADORES Y EMPRENDEDORES PTE - PERU': 'PTE',
  // Renovación Popular
  'RENOVACION POPULAR': 'Renovación Popular',
  // Salvemos al Perú
  'SALVEMOS AL PERU': 'Salvemos al Perú',
  // Sí Creo
  'SI CREO': 'Sí Creo',
  'SÍ CREO': 'Sí Creo',
  'PARTIDO SICREO': 'Sí Creo',
  // Somos Perú
  'PARTIDO DEMOCRATICO SOMOS PERU': 'Somos Perú',
  'SOMOS PERU': 'Somos Perú',
  // Un Camino Diferente
  'UN CAMINO DIFERENTE': 'Un Camino Diferente',
  // Unidad Nacional
  'UNIDAD NACIONAL': 'Unidad Nacional',
  // Unido Perú
  'UNIDO PERU': 'Unido Perú',
  'PARTIDO DEMOCRATA UNIDO PERU': 'Unido Perú',
  // Verde
  'VERDE': 'Verde',
  'PARTIDO DEMOCRATA VERDE': 'Verde',
};

class RegionCandidato {
  final int ubigeo;
  final String departamento;
  final int idOrganizacionPolitica;
  final String organizacionPolitica;
  final int posicion;
  final String dni;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String sexo;
  final String fechaNacimiento;
  final String estadoCandidato;
  final String strNombre; // UUID.jpg — for photo URL

  const RegionCandidato({
    required this.ubigeo,
    required this.departamento,
    required this.idOrganizacionPolitica,
    required this.organizacionPolitica,
    required this.posicion,
    required this.dni,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.sexo,
    required this.fechaNacimiento,
    required this.estadoCandidato,
    required this.strNombre,
  });

  factory RegionCandidato.fromJson(Map<String, dynamic> j) {
    return RegionCandidato(
      ubigeo: (j['strUbigeo'] as num?)?.toInt() ?? 0,
      departamento: j['strDepartamento'] as String? ?? '',
      idOrganizacionPolitica:
          (j['idOrganizacionPolitica'] as num?)?.toInt() ?? 0,
      organizacionPolitica: j['strOrganizacionPolitica'] as String? ?? '',
      posicion: (j['intPosicion'] as num?)?.toInt() ?? 0,
      dni: (j['strDocumentoIdentidad'] ?? '').toString(),
      nombres: j['strNombres'] as String? ?? '',
      apellidoPaterno: j['strApellidoPaterno'] as String? ?? '',
      apellidoMaterno: j['strApellidoMaterno'] as String? ?? '',
      sexo: j['strSexo'] as String? ?? '',
      fechaNacimiento: j['strFechaNacimiento'] as String? ?? '',
      estadoCandidato: j['strEstadoCandidato'] as String? ?? '',
      strNombre: j['strNombre'] as String? ?? '',
    );
  }

  String get nombreCompleto =>
      '$nombres $apellidoPaterno $apellidoMaterno'.trim();

  /// Normalized party name matching assets in party_logo.dart.
  String get standardPartyName =>
      _jneToStandardParty[organizacionPolitica.toUpperCase()] ??
      organizacionPolitica;

  /// Photo via proxy (web) or direct JNE URL (native).
  /// strNombre = "uuid.jpg" → extract guid.
  String? get fotoUrl {
    if (strNombre.isEmpty) return null;
    final guid = strNombre.contains('.')
        ? strNombre.substring(0, strNombre.lastIndexOf('.'))
        : strNombre;
    if (guid.isEmpty) return null;
    return _jneFotoUrl(guid);
  }

  /// DNI padded to 8 digits with leading zeros for display and URLs.
  /// e.g. "123456" → "00123456"
  String get paddedDni => dni.padLeft(8, '0');

  /// URL to the JNE hoja de vida (public web page, open externally).
  String get hojaVidaUrl =>
      'https://votoinformado.jne.gob.pe/hoja-vida/$idOrganizacionPolitica/$paddedDni';

  bool get isInscrito => estadoCandidato == 'INSCRITO';
}

class RegionesData {
  final List<RegionCandidato> distritoMultiple;
  final List<RegionCandidato> distritoUnico;

  const RegionesData({
    required this.distritoMultiple,
    required this.distritoUnico,
  });

  List<String> get departamentosMultiple {
    final deps = distritoMultiple
        .map((c) => c.departamento)
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return deps;
  }
}
