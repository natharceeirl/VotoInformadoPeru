import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';

/// Muestra la foto oficial del JNE para un candidato dado su [dni].
///
/// - Si hay foto disponible, carga la imagen desde la API del JNE.
/// - Si no hay match o falla la carga, muestra un avatar con iniciales o ícono.
/// - [size] controla el diámetro del círculo.
class CandidatePhoto extends ConsumerWidget {
  final String dni;
  final double size;
  final String? nombreFallback; // para las iniciales si no hay foto

  const CandidatePhoto({
    super.key,
    required this.dni,
    this.size = 36,
    this.nombreFallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senadoAsync = ref.watch(senadoMapProvider);

    return senadoAsync.when(
      data: (mapa) {
        final candidato = mapa[dni];
        final url = candidato?.fotoUrl;

        return _PhotoCircle(
          url: url,
          size: size,
          nombre: nombreFallback ?? candidato?.nombreCompleto,
        );
      },
      // Mientras carga el mapa → avatar genérico sin spinner para no distraer
      loading: () => _PhotoCircle(url: null, size: size, nombre: nombreFallback),
      error: (_, __) => _PhotoCircle(url: null, size: size, nombre: nombreFallback),
    );
  }
}

class _PhotoCircle extends StatelessWidget {
  final String? url;
  final double size;
  final String? nombre;

  const _PhotoCircle({this.url, required this.size, this.nombre});

  String _initials() {
    if (nombre == null || nombre!.isEmpty) return '?';
    final parts = nombre!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = size / 2;

    if (url != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: NetworkImage(url!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // Sin URL → círculo con iniciales
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initials(),
        style: TextStyle(
          fontSize: size * 0.33,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
