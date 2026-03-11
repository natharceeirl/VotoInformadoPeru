import 'package:flutter/material.dart';

/// Maps party name → PNG filename in assets/logoPartido/
const Map<String, String> _partyLogoFiles = {
  'Ahora Nación': 'Ahora_Nacion.png',
  'Alianza para el Progreso': 'Alianza_Para_El_Progreso.png',
  'APRA': 'APRA.png',
  'Avanza País': 'Avanza_Pais.png',
  'Buen Gobierno': 'Buen_Gobierno.png',
  'Cooperación Popular': 'Cooperacion_Popular.png',
  'Fe en el Perú': 'Fe_En_El_Peru.png',
  'Frente de la Esperanza': 'Frente_De_La_Esperanza.png',
  'FREPAP': 'Frepap.png',
  'Fuerza Popular': 'Fuerza_Popular.png',
  'Fuerza y Libertad': 'Fuerza_Y_Libertad.png',
  'Integridad Democrática': 'Integridad_Democratica.png',
  'Juntos por el Perú': 'Juntos_Por_El_Peru.png',
  'Libertad Popular': 'Libertad_Popular.png',
  'Obras': 'Obras.png',
  'País para Todos': 'Pais_Para_Todos.png',
  'Partido Morado': 'Partido_Morado.png',
  'Perú Acción': 'Peru_Accion.png',
  'Perú Federal': 'Peru_Federal.png',
  'Perú Libre': 'Peru_Libre.png',
  'Perú Primero': 'Peru_Primero.png',
  'Podemos Perú': 'Podemos_Peru.png',
  'PPP': 'PPP.png',
  'Primero La Gente': 'Primero_La_Gente.png',
  'PRIN': 'PRIN.png',
  'Progresemos': 'Progresemos.png',
  'PTE': 'PTE.png',
  'Renovación Popular': 'Renovacion_Popular.png',
  'Sí Creo': 'Si_Creo.png',
  'Somos Perú': 'Somos_Peru.png',
  'Un Camino Diferente': 'Un_Camino_Diferente.png',
  'Unidad Nacional': 'Unidad_Nacional.png',
  'Unido Perú': 'Unido_Peru.png',
  'Venceremos': 'Venceremos.png',
  'Verde': 'Verde.png',
  'Salvemos al Perú': 'Salvemos_al_Peru.png',
  'Perú Moderno': 'Peru_Moderno.png',
};

/// Maps JNE all-caps party names to the standard names used in [_partyLogoFiles].
const Map<String, String> _jneToStandard = {
  'AHORA NACION': 'Ahora Nación',
  'AHORA NACION - AN': 'Ahora Nación',
  'ALIANZA PARA EL PROGRESO': 'Alianza para el Progreso',
  'ALIANZA ELECTORAL VENCEREMOS': 'Venceremos',
  'VENCEREMOS': 'Venceremos',
  'APRA': 'APRA',
  'PARTIDO APRISTA PERUANO': 'APRA',
  'AVANZA PAIS': 'Avanza País',
  'AVANZA PAÍS': 'Avanza País',
  'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL': 'Avanza País',
  'BUEN GOBIERNO': 'Buen Gobierno',
  'PARTIDO DEL BUEN GOBIERNO': 'Buen Gobierno',
  'COOPERACION POPULAR': 'Cooperación Popular',
  'PARTIDO POLITICO COOPERACION POPULAR': 'Cooperación Popular',
  'FE EN EL PERU': 'Fe en el Perú',
  'FRENTE DE LA ESPERANZA': 'Frente de la Esperanza',
  'PARTIDO FRENTE DE LA ESPERANZA 2021': 'Frente de la Esperanza',
  'FREPAP': 'FREPAP',
  'FRENTE POPULAR AGRICOLA FIA DEL PERU': 'FREPAP',
  'FRENTE POPULAR AGRÍCOLA FIA DEL PERÚ': 'FREPAP',
  'FUERZA POPULAR': 'Fuerza Popular',
  'FUERZA Y LIBERTAD': 'Fuerza y Libertad',
  'INTEGRIDAD DEMOCRATICA': 'Integridad Democrática',
  'PARTIDO POLITICO INTEGRIDAD DEMOCRATICA': 'Integridad Democrática',
  'JUNTOS POR EL PERU': 'Juntos por el Perú',
  'LIBERTAD POPULAR': 'Libertad Popular',
  'OBRAS': 'Obras',
  'PARTIDO CIVICO OBRAS': 'Obras',
  'PAIS PARA TODOS': 'País para Todos',
  'PARTIDO PAIS PARA TODOS': 'País para Todos',
  'PARTIDO MORADO': 'Partido Morado',
  'PERU ACCION': 'Perú Acción',
  'PARTIDO POLITICO PERU ACCION': 'Perú Acción',
  'PERU FEDERAL': 'Perú Federal',
  'PARTIDO DEMOCRATICO FEDERAL': 'Perú Federal',
  'PERU LIBRE': 'Perú Libre',
  'PARTIDO POLITICO NACIONAL PERU LIBRE': 'Perú Libre',
  'PERU PRIMERO': 'Perú Primero',
  'PARTIDO POLITICO PERU PRIMERO': 'Perú Primero',
  'PODEMOS PERU': 'Podemos Perú',
  'PPP': 'PPP',
  'PRIMERO LA GENTE': 'Primero La Gente',
  'PRIMERO LA GENTE - COMUNIDAD, ECOLOGIA, LIBERTAD Y PROGRESO': 'Primero La Gente',
  'PRIN': 'PRIN',
  'PARTIDO POLITICO PRIN': 'PRIN',
  'PROGRESEMOS': 'Progresemos',
  'PTE': 'PTE',
  'PARTIDO DE LOS TRABAJADORES Y EMPRENDEDORES PTE - PERU': 'PTE',
  'RENOVACION POPULAR': 'Renovación Popular',
  'SI CREO': 'Sí Creo',
  'SÍ CREO': 'Sí Creo',
  'PARTIDO SICREO': 'Sí Creo',
  'PARTIDO DEMOCRATICO SOMOS PERU': 'Somos Perú',
  'SOMOS PERU': 'Somos Perú',
  'UN CAMINO DIFERENTE': 'Un Camino Diferente',
  'UNIDAD NACIONAL': 'Unidad Nacional',
  'UNIDO PERU': 'Unido Perú',
  'PARTIDO DEMOCRATA UNIDO PERU': 'Unido Perú',
  'VERDE': 'Verde',
  'PARTIDO DEMOCRATA VERDE': 'Verde',
  'SALVEMOS AL PERU': 'Salvemos al Perú',
  'PERU MODERNO': 'Perú Moderno',
  'PARTIDO POLITICO PERU MODERNO': 'Perú Moderno',
  'PARTIDO PATRIOTICO DEL PERU': 'PPP',
  'PARTIDO PATRIÓTICO DEL PERÚ': 'PPP',
};

/// Normalizes a raw JNE party name to the standard name used in logo assets.
/// Falls back to the original name if no mapping is found.
String normalizePartyName(String jneName) =>
    _jneToStandard[jneName.toUpperCase()] ?? jneName;

/// Returns the asset path for the party logo, or null if not found.
/// Accepts both standard names and raw JNE uppercase names.
String? partyLogoPath(String partyName) {
  final normalized = _jneToStandard[partyName.toUpperCase()] ?? partyName;
  final file = _partyLogoFiles[normalized];
  if (file == null) return null;
  return 'assets/logoPartido/$file';
}

/// A widget that shows a party logo image with a circular fallback.
/// [size] controls both width and height.
class PartyLogo extends StatelessWidget {
  final String partyName;
  final double size;
  final BoxShape shape;
  final bool withBorder;

  const PartyLogo({
    super.key,
    required this.partyName,
    this.size = 36,
    this.shape = BoxShape.circle,
    this.withBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = partyLogoPath(partyName);
    final cs = Theme.of(context).colorScheme;

    Widget imageWidget;
    if (path != null) {
      imageWidget = Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(context, cs),
      );
    } else {
      imageWidget = _fallback(context, cs);
    }

    if (!withBorder) return imageWidget;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: cs.surface,
        border: Border.all(
          color: cs.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _fallback(BuildContext context, ColorScheme cs) {
    final letter = partyName.isNotEmpty ? partyName[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: cs.primaryContainer,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
