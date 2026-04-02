import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../widgets/party_logo.dart';

/// Pantalla de candidatos en REINFO filtrada por proceso electoral.
/// Usa [candidatosConHVProcesoProvider] y filtra por [c.hv.esReinfo].
class ReinfoProcesoScreen extends ConsumerStatefulWidget {
  final ProcesoElectoral proceso;
  const ReinfoProcesoScreen({super.key, required this.proceso});

  @override
  ConsumerState<ReinfoProcesoScreen> createState() =>
      _ReinfoProcesoScreenState();
}

class _ReinfoProcesoScreenState extends ConsumerState<ReinfoProcesoScreen> {
  String? _selectedParty;

  @override
  Widget build(BuildContext context) {
    final candidatosAsync =
        ref.watch(candidatosConHVProcesoProvider(widget.proceso));

    return Scaffold(
      appBar: AppBar(
        title: Text('REINFO — ${widget.proceso.displayName}'),
        centerTitle: true,
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: candidatosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (candidatos) {
          // Filter to only REINFO candidates
          final reinfo = candidatos
              .where((c) => c.hv.esReinfo)
              .toList();

          if (reinfo.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.terrain_rounded,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Ningún candidato de este proceso está registrado en REINFO.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }

          final parties =
              reinfo.map((c) => c.hv.partido).toSet().toList()..sort();

          final filtered = _selectedParty == null
              ? reinfo
              : reinfo.where((c) => c.hv.partido == _selectedParty).toList();

          // Summary counts
          final totalMineras =
              reinfo.fold<int>(0, (s, c) => s + c.hv.cantidadMineras);
          final conMuchas = reinfo.where((c) => c.hv.cantidadMineras >= 5).length;

          return Column(
            children: [
              // ── REINFO explanation banner ──────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terrain_rounded,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '¿Qué es el REINFO?',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'El Registro Integral de Formalización Minera (REINFO) es el '
                      'padrón oficial de mineros informales. Un candidato vinculado '
                      'a este registro puede tener actividad en minería informal o ilegal. '
                      'Fuente: Ministerio de Energía y Minas del Perú.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Summary stats ──────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      icon: Icons.person,
                      value: reinfo.length.toString(),
                      label: 'Candidatos',
                      color: Colors.orange,
                    ),
                    _StatBox(
                      icon: Icons.terrain_rounded,
                      value: totalMineras.toString(),
                      label: 'Concesiones',
                      color: Colors.brown,
                    ),
                    _StatBox(
                      icon: Icons.warning_amber_rounded,
                      value: conMuchas.toString(),
                      label: '5+ concesiones',
                      color: Colors.red,
                    ),
                    _StatBox(
                      icon: Icons.groups,
                      value: parties.length.toString(),
                      label: 'Partidos',
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),

              // ── Party filter ───────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedParty,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por partido',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    suffixIcon: _selectedParty != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _selectedParty = null),
                          )
                        : null,
                  ),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Todos los partidos')),
                    ...parties.map((p) => DropdownMenuItem<String?>(
                        value: p, child: Text(p, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) => setState(() => _selectedParty = val),
                ),
              ),

              // ── Count bar ─────────────────────────────────────────────
              if (_selectedParty != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        '${filtered.length} candidato(s) en $_selectedParty',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.orange),
                      ),
                    ],
                  ),
                ),

              // ── Candidate list ─────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                                'No hay candidatos REINFO en este partido.'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  setState(() => _selectedParty = null),
                              child: const Text('Ver todos'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return _CandidatoCard(c: c);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Candidate card ───────────────────────────────────────────────────────────
class _CandidatoCard extends StatelessWidget {
  final CandidatoConHV c;
  const _CandidatoCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final h = c.hv;
    final mineColor = h.cantidadMineras >= 5
        ? Colors.red
        : h.cantidadMineras >= 3
            ? Colors.deepOrange
            : Colors.amber.shade700;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.orange.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo or party logo fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: c.fotoUrl != null
                  ? Image.network(
                      c.fotoUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          PartyLogo(partyName: h.partido, size: 52, withBorder: true),
                    )
                  : PartyLogo(partyName: h.partido, size: 52, withBorder: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  // Party chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.indigo.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      h.partido,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Ballot position
                      if (c.posicion > 0)
                        _Chip(
                          icon: Icons.format_list_numbered,
                          label: 'N° ${c.posicion}',
                          color: Colors.blue,
                        ),
                      // Department
                      if (c.departamento.isNotEmpty)
                        _Chip(
                          icon: Icons.location_on_outlined,
                          label: c.departamento,
                          color: Colors.teal,
                        ),
                      // Mining concessions
                      _Chip(
                        icon: Icons.terrain_rounded,
                        label: '${h.cantidadMineras} concesión(es)',
                        color: mineColor,
                      ),
                      // Sentencias
                      if (h.totalSentenciasPenales > 0)
                        _Chip(
                          icon: Icons.gavel,
                          label:
                              '${h.totalSentenciasPenales} sentencia(s) penal',
                          color: Colors.red,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary stat box ─────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
