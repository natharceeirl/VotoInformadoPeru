import 'package:flutter/foundation.dart' show kIsWeb;

/// GUIDs whose stored photo file uses .jpeg extension instead of .jpg.
const _jpegGuids = {
  '251cd1c0-acc7-4338-bd8a-439ccb9238d0',
  '789b7714-8633-4a59-a89b-7fab4646fef1',
  '28a58063-8e4b-4dc5-b418-b84defcc0946',
};

/// Builds the photo URL: Netlify redirect proxy on web (avoids CORS), direct on native.
String _jneFotoUrl(String guid) {
  final suffix =
      _jpegGuids.contains(guid.toLowerCase()) ? '.jpeg' : '';
  return kIsWeb
      ? '/foto-proxy/$guid$suffix'
      : 'https://votoinformado.jne.gob.pe/VotoInformado/Informacion/GetFoto?guidFoto=$guid$suffix';
}

/// Modelo ligero de senadoNacional.json — solo los campos útiles para la app.
class SenadoCandidato {
  final String dni;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String partido;
  final int posicion;
  final String sexo;
  final String fechaNacimiento;
  final String estado; // INSCRITO, IMPROCEDENTE, EXCLUSION, RENUNCIA…
  final String guidFoto;

  const SenadoCandidato({
    required this.dni,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.partido,
    required this.posicion,
    required this.sexo,
    required this.fechaNacimiento,
    required this.estado,
    required this.guidFoto,
  });

  factory SenadoCandidato.fromJson(Map<String, dynamic> j) =>
      SenadoCandidato(
        dni: j['strDocumentoIdentidad'] as String? ?? '',
        nombres: j['strNombres'] as String? ?? '',
        apellidoPaterno: j['strApellidoPaterno'] as String? ?? '',
        apellidoMaterno: j['strApellidoMaterno'] as String? ?? '',
        partido: j['strOrganizacionPolitica'] as String? ?? '',
        posicion: j['intPosicion'] as int? ?? 0,
        sexo: j['strSexo'] as String? ?? '',
        fechaNacimiento: j['strFechaNacimiento'] as String? ?? '',
        estado: j['strEstadoCandidato'] as String? ?? '',
        guidFoto: j['strGuidFoto'] as String? ?? '',
      );

  String get nombreCompleto =>
      '$nombres $apellidoPaterno $apellidoMaterno'.trim();

  /// URL de la foto: proxy Netlify en web (evita CORS), directo en nativo.
  String? get fotoUrl =>
      guidFoto.isNotEmpty ? _jneFotoUrl(guidFoto) : null;

  bool get isInscrito => estado == 'INSCRITO';
}
