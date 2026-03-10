import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hoja_vida_models.dart';
import '../providers/new_providers.dart';

class VoteSimulatorScreen extends ConsumerStatefulWidget {
  const VoteSimulatorScreen({super.key});

  @override
  ConsumerState<VoteSimulatorScreen> createState() =>
      _VoteSimulatorScreenState();
}

class _VoteSimulatorScreenState extends ConsumerState<VoteSimulatorScreen> {
  int _step = 0;

  // Step 1 — Presidencial
  String? _partidoPresidente;

  // Step 2 — Senadores Distrito Único
  String? _partidoSenadoresUnico;
  final TextEditingController _pref1UnicoCtrl = TextEditingController();
  final TextEditingController _pref2UnicoCtrl = TextEditingController();

  // Step 3 — Senadores Distrito Múltiple
  String? _partidoSenadoresMultiple;
  final TextEditingController _prefMultipleCtrl = TextEditingController();

  // Step 4 — Diputados
  String? _partidoDiputados;
  final TextEditingController _pref1DipCtrl = TextEditingController();
  final TextEditingController _pref2DipCtrl = TextEditingController();

  // Step 5 — Parlamento Andino
  String? _partidoAndino;
  final TextEditingController _prefAndinoCtrl = TextEditingController();

  @override
  void dispose() {
    _pref1UnicoCtrl.dispose();
    _pref2UnicoCtrl.dispose();
    _prefMultipleCtrl.dispose();
    _pref1DipCtrl.dispose();
    _pref2DipCtrl.dispose();
    _prefAndinoCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _stepColor(int step) {
    switch (step) {
      case 1:
        return const Color(0xFF7B1FA2);
      case 2:
      case 3:
        return const Color(0xFF00695C);
      case 4:
        return const Color(0xFF1565C0);
      case 5:
        return const Color(0xFFBF360C);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String? _getSelectedPartido(int step) {
    switch (step) {
      case 1:
        return _partidoPresidente;
      case 2:
        return _partidoSenadoresUnico;
      case 3:
        return _partidoSenadoresMultiple;
      case 4:
        return _partidoDiputados;
      case 5:
        return _partidoAndino;
      default:
        return null;
    }
  }

  void _setSelectedPartido(int step, String? partido) {
    setState(() {
      switch (step) {
        case 1:
          _partidoPresidente = partido;
          break;
        case 2:
          _partidoSenadoresUnico = partido;
          break;
        case 3:
          _partidoSenadoresMultiple = partido;
          break;
        case 4:
          _partidoDiputados = partido;
          break;
        case 5:
          _partidoAndino = partido;
          break;
      }
    });
  }

  void _resetAll() {
    setState(() {
      _step = 0;
      _partidoPresidente = null;
      _partidoSenadoresUnico = null;
      _pref1UnicoCtrl.clear();
      _pref2UnicoCtrl.clear();
      _partidoSenadoresMultiple = null;
      _prefMultipleCtrl.clear();
      _partidoDiputados = null;
      _pref1DipCtrl.clear();
      _pref2DipCtrl.clear();
      _partidoAndino = null;
      _prefAndinoCtrl.clear();
    });
  }

  ProcesoElectoral _procesoForStep(int step) {
    switch (step) {
      case 1:
        return ProcesoElectoral.presidentes;
      case 2:
        return ProcesoElectoral.senadores;
      case 3:
        return ProcesoElectoral.senadores;
      case 4:
        return ProcesoElectoral.diputados;
      case 5:
        return ProcesoElectoral.parlamentoAndino;
      default:
        return ProcesoElectoral.presidentes;
    }
  }

  // ── Step metadata ──────────────────────────────────────────────────────────

  String _stepTitle(int step) {
    switch (step) {
      case 1:
        return 'Fórmula Presidencial';
      case 2:
        return 'Senadores — Distrito Único';
      case 3:
        return 'Senadores — Distrito Múltiple';
      case 4:
        return 'Diputados';
      case 5:
        return 'Parlamento Andino';
      default:
        return '';
    }
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 1:
        return 'Elige una fórmula presidencial (1 voto)';
      case 2:
        return 'Voto a nivel nacional (1 voto + hasta 2 votos preferenciales)';
      case 3:
        return 'Voto regional (1 voto + 1 voto preferencial)';
      case 4:
        return 'Cámara de Diputados (1 voto + hasta 2 votos preferenciales)';
      case 5:
        return 'Representación andina (1 voto + 1 voto preferencial)';
      default:
        return '';
    }
  }

  String _stepDescription(int step) {
    switch (step) {
      case 1:
        return 'Marca con una X la fórmula presidencial de tu preferencia. '
            'Esta cédula NO tiene voto preferencial.';
      case 2:
        return 'Marca con una X el partido de tu elección. '
            'Opcionalmente, escribe el número de posición (1-2 candidatos) de los senadores que prefieres dentro de ese partido.';
      case 3:
        return 'Marca con una X el partido de tu elección. '
            'Opcionalmente, escribe el número de posición del candidato que prefieres en tu región.';
      case 4:
        return 'Marca con una X el partido de tu elección. '
            'Opcionalmente, escribe el número de posición de hasta 2 diputados preferidos.';
      case 5:
        return 'Marca con una X el partido de tu elección. '
            'Opcionalmente, escribe el número de posición de tu candidato preferido.';
      default:
        return '';
    }
  }

  IconData _stepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.star_rounded;
      case 2:
      case 3:
        return Icons.gavel_rounded;
      case 4:
        return Icons.account_balance_rounded;
      case 5:
        return Icons.public_rounded;
      default:
        return Icons.how_to_vote_rounded;
    }
  }

  bool _stepTienePreferencial(int step) => step >= 2;
  int _stepNumPreferencial(int step) {
    switch (step) {
      case 2:
        return 2;
      case 3:
        return 1;
      case 4:
        return 2;
      case 5:
        return 1;
      default:
        return 0;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appBarColor = _stepColor(_step);

    String appBarTitle;
    if (_step == 0 || _step == 6) {
      appBarTitle = 'Simulador de Voto';
    } else {
      appBarTitle = 'Cédula $_step de 5';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _buildIntro();
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        return _buildVotingStep(_step);
      case 6:
        return _buildResumen();
      default:
        return _buildIntro();
    }
  }

  // ── Step 0: Intro ──────────────────────────────────────────────────────────

  Widget _buildIntro() {
    final color = _stepColor(0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.how_to_vote_rounded,
                size: 64,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Simulador de Voto 2026',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Practica cómo llenar correctamente tu cédula de votación',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(
              'En las elecciones del 2026, deberás votar en 5 cédulas distintas. Este simulador te guía paso a paso.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Las 5 cédulas:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildStepListItem(1, 'Fórmula Presidencial', const Color(0xFF7B1FA2)),
          _buildStepListItem(2, 'Senadores — Distrito Único (Nacional)', const Color(0xFF00695C)),
          _buildStepListItem(3, 'Senadores — Distrito Múltiple (Regional)', const Color(0xFF00695C)),
          _buildStepListItem(4, 'Diputados', const Color(0xFF1565C0)),
          _buildStepListItem(5, 'Parlamento Andino', const Color(0xFFBF360C)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => setState(() => _step = 1),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Comenzar práctica',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepListItem(int num, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ── Steps 1-5: Voting ──────────────────────────────────────────────────────

  Widget _buildVotingStep(int step) {
    final stepColor = _stepColor(step);
    final proceso = _procesoForStep(step);
    final candidatosAsync = ref.watch(candidatosConHVProcesoProvider(proceso));

    // For senadores, filter by tipoDistrito
    List<String> partidos = [];
    candidatosAsync.whenData((candidatos) {
      List filtered = candidatos;
      if (step == 2) {
        filtered = candidatos.where((c) => c.tipoDistrito == 'ÚNICO').toList();
      } else if (step == 3) {
        filtered = candidatos.where((c) => c.tipoDistrito == 'MÚLTIPLE').toList();
      }
      partidos = filtered
          .map((c) => (c as dynamic).hv.partido as String)
          .toSet()
          .toList()
        ..sort();
    });

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: step / 5,
          backgroundColor: Colors.grey.shade200,
          color: stepColor,
          minHeight: 6,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step header
                _buildStepHeader(step, stepColor),
                const SizedBox(height: 16),
                // Ballot card
                _buildBallotCard(step, stepColor, candidatosAsync, partidos),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Navigation
        _buildNavBar(step, stepColor),
      ],
    );
  }

  Widget _buildStepHeader(int step, Color stepColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: stepColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_stepIcon(step), color: stepColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _stepTitle(step),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stepColor,
                    ),
              ),
              Text(
                _stepSubtitle(step),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBallotCard(
    int step,
    Color stepColor,
    AsyncValue<List<CandidatoConHV>> candidatosAsync,
    List<String> partidos,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ballot header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'REPÚBLICA DEL PERÚ — ONPE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'ELECCIONES GENERALES 2026',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Instructions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: stepColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: stepColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                _stepDescription(step),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
                    ),
              ),
            ),
          ),
          // Party grid
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: candidatosAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error al cargar partidos',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              data: (_) => _buildPartyGrid(step, stepColor, partidos),
            ),
          ),
          // Preferential fields
          if (_stepTienePreferencial(step) &&
              _getSelectedPartido(step) != null)
            _buildPreferentialFields(step, stepColor),
        ],
      ),
    );
  }

  Widget _buildPartyGrid(int step, Color stepColor, List<String> partidos) {
    if (partidos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No hay partidos disponibles',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: partidos.length,
      itemBuilder: (context, index) {
        final partido = partidos[index];
        final isSelected = _getSelectedPartido(step) == partido;
        return GestureDetector(
          onTap: () {
            _setSelectedPartido(step, isSelected ? null : partido);
          },
          child: isSelected
              ? Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: stepColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: stepColor.withValues(alpha: 0.05),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            partido,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stepColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '✗',
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        partido,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPreferentialFields(int step, Color stepColor) {
    final numPref = _stepNumPreferencial(step);

    List<Widget> fields = [];

    if (step == 2) {
      fields.add(_prefField('Voto preferencial N°1', _pref1UnicoCtrl, stepColor));
      if (numPref >= 2) {
        fields.add(const SizedBox(height: 10));
        fields.add(_prefField('Voto preferencial N°2', _pref2UnicoCtrl, stepColor));
      }
    } else if (step == 3) {
      fields.add(_prefField('Voto preferencial N°1', _prefMultipleCtrl, stepColor));
    } else if (step == 4) {
      fields.add(_prefField('Voto preferencial N°1', _pref1DipCtrl, stepColor));
      if (numPref >= 2) {
        fields.add(const SizedBox(height: 10));
        fields.add(_prefField('Voto preferencial N°2', _pref2DipCtrl, stepColor));
      }
    } else if (step == 5) {
      fields.add(_prefField('Voto preferencial N°1', _prefAndinoCtrl, stepColor));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Card(
        color: stepColor.withValues(alpha: 0.04),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: stepColor.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Voto preferencial (opcional)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stepColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Escribe el número de posición del candidato en la lista.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 10),
              ...fields,
            ],
          ),
        ),
      ),
    );
  }

  Widget _prefField(
      String label, TextEditingController ctrl, Color stepColor) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 3,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: stepColor, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: stepColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        counterText: '',
        isDense: true,
      ),
    );
  }

  Widget _buildNavBar(int step, Color stepColor) {
    final isLast = step == 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _step = step - 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Atrás'),
              style: OutlinedButton.styleFrom(
                foregroundColor: stepColor,
                side: BorderSide(color: stepColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () => setState(() => _step = step + 1),
              icon: Icon(
                isLast
                    ? Icons.check_circle_outline_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(isLast ? 'Ver Resumen' : 'Siguiente'),
              style: FilledButton.styleFrom(
                backgroundColor: stepColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 6: Resumen ────────────────────────────────────────────────────────

  Widget _buildResumen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Cédula Virtual — Resumen',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                    ),
                    Text(
                      'Revisa tus selecciones de práctica',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Summary cards
          _buildResumenItem(
            step: 1,
            title: _stepTitle(1),
            partido: _partidoPresidente,
            prefs: [],
          ),
          const SizedBox(height: 8),
          _buildResumenItem(
            step: 2,
            title: _stepTitle(2),
            partido: _partidoSenadoresUnico,
            prefs: [_pref1UnicoCtrl.text, _pref2UnicoCtrl.text],
          ),
          const SizedBox(height: 8),
          _buildResumenItem(
            step: 3,
            title: _stepTitle(3),
            partido: _partidoSenadoresMultiple,
            prefs: [_prefMultipleCtrl.text],
          ),
          const SizedBox(height: 8),
          _buildResumenItem(
            step: 4,
            title: _stepTitle(4),
            partido: _partidoDiputados,
            prefs: [_pref1DipCtrl.text, _pref2DipCtrl.text],
          ),
          const SizedBox(height: 8),
          _buildResumenItem(
            step: 5,
            title: _stepTitle(5),
            partido: _partidoAndino,
            prefs: [_prefAndinoCtrl.text],
          ),
          const SizedBox(height: 20),
          // Educational note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Este es un simulacro educativo. Tu voto real es secreto y se realiza en la mesa de sufragio el día de las elecciones.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade900,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Buttons
          FilledButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Volver a practicar'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Salir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResumenItem({
    required int step,
    required String title,
    required String? partido,
    required List<String> prefs,
  }) {
    final stepColor = _stepColor(step);
    final hasPartido = partido != null && partido.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: stepColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: stepColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: stepColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasPartido
                      ? Icons.how_to_vote_rounded
                      : Icons.do_not_disturb_rounded,
                  size: 16,
                  color: hasPartido ? stepColor : Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasPartido ? partido : 'No seleccionado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              hasPartido ? FontWeight.w600 : FontWeight.normal,
                          color: hasPartido
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey.shade500,
                          fontStyle: hasPartido
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
            if (prefs.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...List.generate(prefs.length, (i) {
                final val = prefs[i].trim();
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const SizedBox(width: 22),
                      Text(
                        'Pref. N°${i + 1}: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      Text(
                        val.isEmpty ? '—' : val,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: val.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: val.isEmpty
                                  ? Colors.grey.shade400
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
