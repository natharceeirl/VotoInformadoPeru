// 05_candidatos_reinfo.json
// This file has a DIFFERENT structure from 06_candidatos_individuales.json.
// It uses candidate full names (not DNI) and mining-specific fields.
class ReinfoCandidate {
  final String partido;
  final String candidato; // full name
  final String tipoEleccion;
  final int? numeroEnLista;
  final int cantidadMineras;

  ReinfoCandidate({
    required this.partido,
    required this.candidato,
    required this.tipoEleccion,
    this.numeroEnLista,
    required this.cantidadMineras,
  });

  factory ReinfoCandidate.fromJson(Map<String, dynamic> json) {
    return ReinfoCandidate(
      partido: json['partido'] as String? ?? '',
      candidato: json['candidato'] as String? ?? '',
      tipoEleccion: json['tipo_eleccion'] as String? ?? '',
      numeroEnLista: json['numero_en_lista'] as int?,
      cantidadMineras: json['cantidad_mineras'] as int? ?? 0,
    );
  }
}
