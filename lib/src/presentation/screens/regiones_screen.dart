import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/new_providers.dart';
import '../widgets/party_logo.dart';
import '../../domain/models/regiones_models.dart';

class RegionesScreen extends ConsumerStatefulWidget {
  const RegionesScreen({super.key});

  @override
  ConsumerState<RegionesScreen> createState() => _RegionesScreenState();
}

class _RegionesScreenState extends ConsumerState<RegionesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(regionesDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senadores por Región'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'DISTRITO MÚLTIPLE'),
            Tab(text: 'DISTRITO ÚNICO'),
          ],
        ),
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _MultipleTab(data: data, key: const ValueKey('multiple')),
            _UnicoTab(data: data, key: const ValueKey('unico')),
          ],
        ),
      ),
    );
  }
}

// ─── DISTRITO MÚLTIPLE tab ────────────────────────────────────────────────────

class _MultipleTab extends StatefulWidget {
  final RegionesData data;
  const _MultipleTab({required this.data, super.key});

  @override
  State<_MultipleTab> createState() => _MultipleTabState();
}

class _MultipleTabState extends State<_MultipleTab> {
  String? _dep;
  String _search = '';
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = widget.data.departamentosMultiple;
    if (deps.isNotEmpty) _dep = deps.first;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.data.departamentosMultiple;

    final candidates = widget.data.distritoMultiple
        .where((c) => c.isInscrito)
        .where((c) => _dep == null || c.departamento == _dep)
        .where((c) =>
            _search.isEmpty ||
            c.nombreCompleto.toLowerCase().contains(_search) ||
            c.organizacionPolitica.toLowerCase().contains(_search) ||
            c.dni.contains(_search))
        .toList()
      ..sort((a, b) {
        final dc = a.departamento.compareTo(b.departamento);
        if (dc != 0) return dc;
        return a.posicion.compareTo(b.posicion);
      });

    return Column(
      children: [
        _InfoBanner(
          icon: Icons.map_rounded,
          color: Colors.blue,
          text: 'Candidatos elegidos por región departamental. '
              'Cada partido presenta un candidato por departamento.',
        ),
        _Filters(
          ctrl: _ctrl,
          search: _search,
          onSearchChanged: (v) => setState(() => _search = v),
          dropdownLabel: 'Departamento',
          dropdownKey: ValueKey(_dep),
          dropdownValue: _dep,
          dropdownItems: [
            const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
            ...deps.map((d) => DropdownMenuItem<String?>(
                value: d, child: Text(d, style: const TextStyle(fontSize: 13)))),
          ],
          onDropdownChanged: (v) => setState(() => _dep = v),
        ),
        _CountRow(
          count: candidates.length,
          suffix: _dep != null ? ' en $_dep' : '',
        ),
        const Divider(height: 1),
        Expanded(
          child: candidates.isEmpty
              ? const Center(child: Text('No se encontraron candidatos'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    final showHeader = _dep == null &&
                        (i == 0 ||
                            candidates[i - 1].departamento != c.departamento);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showHeader) _DepartmentHeader(c.departamento),
                        _CandidateRow(c),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── DISTRITO ÚNICO tab ───────────────────────────────────────────────────────

class _UnicoTab extends StatefulWidget {
  final RegionesData data;
  const _UnicoTab({required this.data, super.key});

  @override
  State<_UnicoTab> createState() => _UnicoTabState();
}

class _UnicoTabState extends State<_UnicoTab> {
  String _search = '';
  String? _selectedParty;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final parties = widget.data.distritoUnico
        .where((c) => c.isInscrito)
        .map((c) => c.organizacionPolitica)
        .toSet()
        .toList()
      ..sort();
    if (parties.isNotEmpty) _selectedParty = parties.first;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parties = widget.data.distritoUnico
        .map((c) => c.organizacionPolitica)
        .toSet()
        .toList()
      ..sort();

    final candidates = widget.data.distritoUnico
        .where((c) => c.isInscrito)
        .where((c) =>
            _selectedParty == null ||
            c.organizacionPolitica == _selectedParty)
        .where((c) =>
            _search.isEmpty ||
            c.nombreCompleto.toLowerCase().contains(_search) ||
            c.organizacionPolitica.toLowerCase().contains(_search) ||
            c.dni.contains(_search))
        .toList()
      ..sort((a, b) {
        final pc = a.organizacionPolitica.compareTo(b.organizacionPolitica);
        if (pc != 0) return pc;
        return a.posicion.compareTo(b.posicion);
      });

    return Column(
      children: [
        _InfoBanner(
          icon: Icons.public_rounded,
          color: Colors.purple,
          text: 'Candidatos elegidos a nivel nacional. '
              'El electorado de todo el país vota por esta lista.',
        ),
        _Filters(
          ctrl: _ctrl,
          search: _search,
          onSearchChanged: (v) => setState(() => _search = v),
          dropdownLabel: 'Partido',
          dropdownKey: ValueKey(_selectedParty),
          dropdownValue: _selectedParty,
          dropdownItems: [
            const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
            ...parties.map((p) => DropdownMenuItem<String?>(
                value: p,
                child: Text(p,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)))),
          ],
          onDropdownChanged: (v) => setState(() => _selectedParty = v),
        ),
        _CountRow(count: candidates.length, suffix: ''),
        const Divider(height: 1),
        Expanded(
          child: candidates.isEmpty
              ? const Center(child: Text('No se encontraron candidatos'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    final showHeader = _selectedParty == null &&
                        (i == 0 ||
                            candidates[i - 1].organizacionPolitica !=
                                c.organizacionPolitica);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showHeader) _PartyHeader(c),
                        _CandidateRow(c),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Shared reusable widgets ──────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBanner(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final TextEditingController ctrl;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final String dropdownLabel;
  final Key dropdownKey;
  final String? dropdownValue;
  final List<DropdownMenuItem<String?>> dropdownItems;
  final ValueChanged<String?> onDropdownChanged;

  const _Filters({
    required this.ctrl,
    required this.search,
    required this.onSearchChanged,
    required this.dropdownLabel,
    required this.dropdownKey,
    required this.dropdownValue,
    required this.dropdownItems,
    required this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'Buscar nombre, partido o DNI',
                prefixIcon: const Icon(Icons.search, size: 18),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          ctrl.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => onSearchChanged(v.toLowerCase().trim()),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String?>(
              key: dropdownKey,
              decoration: InputDecoration(
                labelText: dropdownLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              isExpanded: true,
              initialValue: dropdownValue,
              items: dropdownItems,
              onChanged: onDropdownChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final int count;
  final String suffix;
  const _CountRow({required this.count, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$count candidatos inscritos$suffix',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ),
    );
  }
}

class _DepartmentHeader extends StatelessWidget {
  final String label;
  const _DepartmentHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      color: Colors.blue.withValues(alpha: 0.07),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 14, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.blue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyHeader extends StatelessWidget {
  final RegionCandidato c;
  const _PartyHeader(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      color: Colors.purple.withValues(alpha: 0.07),
      child: Row(
        children: [
          PartyLogo(partyName: c.standardPartyName, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              c.organizacionPolitica,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.purple,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Candidate row (tappable) ─────────────────────────────────────────────────

class _CandidateRow extends StatelessWidget {
  final RegionCandidato c;
  const _CandidateRow(this.c);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () => _showDetail(context, c),
      leading: _CandidateAvatar(c: c),
      title: Text(
        c.nombreCompleto,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          PartyLogo(partyName: c.standardPartyName, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              c.organizacionPolitica,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'N° ${c.posicion}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.sexo == 'FEMENINO' ? '♀' : '♂',
            style: TextStyle(
              fontSize: 12,
              color: c.sexo == 'FEMENINO' ? Colors.pink : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Candidate detail bottom sheet ───────────────────────────────────────────

void _showDetail(BuildContext context, RegionCandidato c) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CandidateDetail(c: c),
  );
}

class _CandidateDetail extends StatelessWidget {
  final RegionCandidato c;
  const _CandidateDetail({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Parse birth date "15/02/1964 00:00" → "15 de febrero de 1964"
    final fecha = _formatDate(c.fechaNacimiento);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header: photo + name ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _CandidateAvatar(c: c, radius: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.nombreCompleto,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          PartyLogo(
                              partyName: c.standardPartyName,
                              size: 18,
                              withBorder: true),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              c.organizacionPolitica,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Details ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailItem(
                  icon: Icons.badge_rounded,
                  label: 'DNI',
                  value: c.paddedDni,
                ),
                _DetailItem(
                  icon: Icons.location_on_rounded,
                  label: 'Circunscripción',
                  value: c.departamento.isNotEmpty
                      ? '${c.departamento} — DISTRITO MÚLTIPLE'
                      : 'DISTRITO ÚNICO (Nacional)',
                  color: c.departamento.isNotEmpty ? Colors.blue : Colors.purple,
                ),
                _DetailItem(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Posición en la lista',
                  value: 'N° ${c.posicion}',
                ),
                _DetailItem(
                  icon: c.sexo == 'FEMENINO'
                      ? Icons.female_rounded
                      : Icons.male_rounded,
                  label: 'Sexo',
                  value: c.sexo == 'FEMENINO' ? 'Femenino' : 'Masculino',
                  color: c.sexo == 'FEMENINO' ? Colors.pink : Colors.blue,
                ),
                if (fecha.isNotEmpty)
                  _DetailItem(
                    icon: Icons.cake_rounded,
                    label: 'Fecha de nacimiento',
                    value: fecha,
                  ),
                _DetailItem(
                  icon: Icons.verified_rounded,
                  label: 'Estado',
                  value: c.estadoCandidato,
                  color: c.isInscrito ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Ver Hoja de Vida en JNE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final uri = Uri.parse(c.hojaVidaUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split(' ').first.split('/');
      if (parts.length != 3) return raw;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = parts[2];
      const months = [
        '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
      ];
      return '$day de ${months[month]} de $year';
    } catch (_) {
      return raw;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Candidate avatar with photo fallback ─────────────────────────────────────

class _CandidateAvatar extends StatelessWidget {
  final RegionCandidato c;
  final double radius;
  const _CandidateAvatar({required this.c, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final url = c.fotoUrl;
    final initials = _initials(c.nombres, c.apellidoPaterno);
    final bg =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    final fg = Theme.of(context).colorScheme.primary;

    if (url == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Text(
          initials,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: radius * 0.55, color: fg),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(
            initials,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: radius * 0.55, color: fg),
          ),
        ),
      ),
    );
  }

  static String _initials(String nombres, String apellido) {
    final n = nombres.trim().isNotEmpty ? nombres.trim()[0] : '';
    final a = apellido.trim().isNotEmpty ? apellido.trim()[0] : '';
    return '$n$a'.toUpperCase();
  }
}
