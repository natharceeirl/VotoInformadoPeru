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
};

/// Returns the asset path for the party logo, or null if not found.
String? partyLogoPath(String partyName) {
  final file = _partyLogoFiles[partyName];
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
