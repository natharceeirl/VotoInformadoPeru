import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';

class ReinfoAlertScreen extends ConsumerStatefulWidget {
  const ReinfoAlertScreen({super.key});

  @override
  ConsumerState<ReinfoAlertScreen> createState() => _ReinfoAlertScreenState();
}

class _ReinfoAlertScreenState extends ConsumerState<ReinfoAlertScreen> {
  String? _selectedParty;

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(reinfoCandidatesRawProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatos Mineros (REINFO)'),
        centerTitle: true,
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: alertAsync.when(
        data: (candidates) {
          if (candidates.isEmpty) {
            return const Center(
              child: Text('Ningún candidato registrado en REINFO.'),
            );
          }

          // Collect unique parties for filter
          final parties = candidates.map((c) => c.partido).toSet().toList()
            ..sort();

          final filtered = _selectedParty == null
              ? candidates
              : candidates
                  .where((c) => c.partido == _selectedParty)
                  .toList();

          return Column(
            children: [
              // Description banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terrain_rounded, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Text('¿Qué es el REINFO?',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'El Registro Integral de Formalización Minera (REINFO) es el '
                      'padrón oficial de mineros informales. Un candidato vinculado '
                      'a este registro puede tener actividad en minería informal o ilegal. '
                      'Fuente: Ministerio de Energía y Minas del Perú.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Header info bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.orange.withValues(alpha: 0.08),
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${candidates.length} candidatos vinculados al REINFO'
                        '${_selectedParty != null ? ' · ${filtered.length} en $_selectedParty' : ''}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // Party filter
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String?>(
                  decoration: InputDecoration(
                    labelText: 'Filtrar por partido',
                    border: const OutlineInputBorder(),
                    suffixIcon: _selectedParty != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _selectedParty = null),
                          )
                        : null,
                  ),
                  initialValue: _selectedParty,
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Todos los partidos')),
                    ...parties.map((p) =>
                        DropdownMenuItem<String?>(value: p, child: Text(p))),
                  ],
                  onChanged: (val) => setState(() => _selectedParty = val),
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                                'No hay candidatos REINFO en ${_selectedParty ?? "este partido"}'),
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.orange.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PartyLogo(
                                    partyName: c.partido,
                                    size: 44,
                                    withBorder: true,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.candidato,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                            c.partido,
                                            style: const TextStyle(
                                              color: Colors.indigo,
                                              fontSize: 11,
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
                                            if (c.numeroEnLista != null)
                                              _InfoChip(
                                                icon: Icons.format_list_numbered,
                                                label: 'N° ${c.numeroEnLista}',
                                                color: Colors.blue,
                                              ),
                                            _InfoChip(
                                              icon: Icons.how_to_vote,
                                              label: c.tipoEleccion,
                                              color: Colors.blue,
                                            ),
                                            _InfoChip(
                                              icon: Icons.terrain_rounded,
                                              label: '${c.cantidadMineras} concesión(es)',
                                              color: c.cantidadMineras > 3
                                                  ? Colors.red
                                                  : c.cantidadMineras > 1
                                                      ? Colors.orange
                                                      : Colors.amber.shade700,
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
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
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
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
