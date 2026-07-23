import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../models/competitive_models.dart';
import '../../services/competition_service.dart';
import 'global_leaderboard_page.dart';

class CompetitiveChallengePage extends StatefulWidget {
  final int lessonNumber;

  const CompetitiveChallengePage({
    super.key,
    required this.lessonNumber,
  });

  @override
  State<CompetitiveChallengePage> createState() =>
      _CompetitiveChallengePageState();
}

class _CompetitiveChallengePageState
    extends State<CompetitiveChallengePage> {
  final CompetitionService _service = CompetitionService();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  CompetitiveSession? _session;
  CompetitiveResult? _result;
  Timer? _timer;
  DateTime? _questionStartedAt;

  bool _loading = true;
  bool _submitting = false;
  int _index = 0;
  int _seconds = 0;
  String? _selectedOption;
  List<String> _availableWords = [];
  List<String> _selectedWords = [];
  final List<CompetitiveAnswer> _answers = [];

  CompetitiveQuestion get question => _session!.questions[_index];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.42);
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final session = await _service.startSession(
        lessonNumber: widget.lessonNumber,
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _loading = false;
      });
      _prepareQuestion();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('$error');
    }
  }

  void _prepareQuestion() {
    _timer?.cancel();
    _controller.clear();

    setState(() {
      _selectedOption = null;
      _selectedWords = [];
      _availableWords = List<String>.from(question.words);
      _seconds = question.seconds;
      _questionStartedAt = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _result != null) {
        timer.cancel();
        return;
      }

      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
        _saveAndContinue(forceEmpty: true);
        return;
      }

      setState(() => _seconds -= 1);
    });
  }

  Future<void> _playAudio() async {
    final text = question.speechText;
    if (text == null || text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  String _response() {
    switch (question.type) {
      case 'multipleChoice':
      case 'trueFalse':
      case 'listenChoice':
        return _selectedOption ?? '';
      case 'orderWords':
        return _selectedWords.join(' ');
      case 'fillBlank':
      case 'writeAnswer':
      default:
        return _controller.text.trim();
    }
  }

  Future<void> _saveAndContinue({bool forceEmpty = false}) async {
    if (_submitting) return;

    final response = forceEmpty ? '' : _response();
    if (!forceEmpty && response.isEmpty) {
      _showError('Responde antes de continuar.');
      return;
    }

    _timer?.cancel();
    final startedAt = _questionStartedAt ?? DateTime.now();

    _answers.add(
      CompetitiveAnswer(
        questionId: question.id,
        response: response,
        responseMilliseconds: DateTime.now()
            .difference(startedAt)
            .inMilliseconds
            .clamp(0, 180000)
            .toInt(),
      ),
    );

    if (_index >= _session!.questions.length - 1) {
      await _submit();
      return;
    }

    setState(() => _index += 1);
    _prepareQuestion();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    try {
      final result = await _service.submitSession(
        sessionId: _session!.sessionId,
        answers: _answers,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showError('$error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Brand.bgPanel,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(
            color: Brand.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LearningBackground(),
          SafeArea(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading || _submitting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Brand.mint),
            const SizedBox(height: 16),
            Text(
              _submitting
                  ? 'El servidor está calificando tu duelo...'
                  : 'Buscando un reto mundial...',
              style: const TextStyle(
                color: Brand.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    if (_result != null) {
      return _resultView();
    }

    if (_session == null) {
      return Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Brand.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (_index + 1) / _session!.questions.length,
                    color: Brand.mint,
                    backgroundColor: Brand.white.withOpacity(0.12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_index + 1}/${_session!.questions.length}',
                style: const TextStyle(
                  color: Brand.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              _Pill(
                icon: Icons.public_rounded,
                label: 'Mundial',
                color: Brand.cyan,
              ),
              const SizedBox(width: 8),
              _Pill(
                icon: Icons.timer_rounded,
                label: '${_seconds}s',
                color: _seconds <= 7
                    ? Colors.redAccent
                    : Brand.mint,
              ),
              const Spacer(),
              Text(
                _session!.seasonId,
                style: TextStyle(
                  color: Brand.white.withOpacity(0.50),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Brand.bgPanel.withOpacity(0.62),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Brand.white.withOpacity(0.10),
                  ),
                  boxShadow: Brand.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.skill.toUpperCase(),
                      style: const TextStyle(
                        color: Brand.mint,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (question.type == 'listenChoice') ...[
                      Center(
                        child: IconButton.filled(
                          onPressed: _playAudio,
                          style: IconButton.styleFrom(
                            backgroundColor: Brand.mint,
                            foregroundColor: Brand.bgDeep,
                            fixedSize: const Size(72, 72),
                          ),
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Text(
                      question.prompt,
                      style: const TextStyle(
                        color: Brand.white,
                        fontSize: 23,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (question.instruction.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        question.instruction,
                        style: TextStyle(
                          color: Brand.white.withOpacity(0.56),
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _interaction(),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveAndContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    _index == _session!.questions.length - 1
                        ? 'Enviar al servidor'
                        : 'Siguiente',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.mint,
                    foregroundColor: Brand.bgDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _interaction() {
    if (question.type == 'multipleChoice' ||
        question.type == 'trueFalse' ||
        question.type == 'listenChoice') {
      return Column(
        children: question.options.map((option) {
          final selected = _selectedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedOption = option),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? Brand.mint.withOpacity(0.14)
                      : Brand.bgDeep.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? Brand.mint
                        : Brand.white.withOpacity(0.10),
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    color: Brand.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (question.type == 'orderWords') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Brand.bgDeep.withOpacity(0.38),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Brand.white.withOpacity(0.10)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedWords
                  .map(
                    (word) => _WordButton(
                      word: word,
                      active: true,
                      onTap: () {
                        setState(() {
                          _selectedWords.remove(word);
                          _availableWords.add(word);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableWords
                .map(
                  (word) => _WordButton(
                    word: word,
                    active: false,
                    onTap: () {
                      setState(() {
                        _availableWords.remove(word);
                        _selectedWords.add(word);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    return TextField(
      controller: _controller,
      autocorrect: false,
      style: const TextStyle(
        color: Brand.white,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Brand.bgDeep.withOpacity(0.38),
        hintText: 'Escribe tu respuesta',
        hintStyle: TextStyle(color: Brand.white.withOpacity(0.34)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _resultView() {
    final result = _result!;
    final passed = result.score >= 70;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        IconButton(
          alignment: Alignment.centerLeft,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Brand.white,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Brand.bgPanel.withOpacity(0.62),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Brand.white.withOpacity(0.10)),
            boxShadow: Brand.cardShadow,
          ),
          child: Column(
            children: [
              Icon(
                passed
                    ? Icons.emoji_events_rounded
                    : Icons.sports_esports_rounded,
                color: passed ? const Color(0xFFFFC94D) : Brand.mint,
                size: 66,
              ),
              const SizedBox(height: 14),
              Text(
                passed ? '¡Reto mundial superado!' : 'Reto completado',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Brand.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${result.score}',
                style: const TextStyle(
                  color: Brand.mint,
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                alignment: WrapAlignment.center,
                children: [
                  _Pill(
                    icon: Icons.auto_awesome_rounded,
                    label: '+${result.xp} XP',
                    color: Brand.mint,
                  ),
                  _Pill(
                    icon: Icons.public_rounded,
                    label: 'Puesto #${result.globalRank}',
                    color: Brand.cyan,
                  ),
                  _Pill(
                    icon: Icons.check_circle_rounded,
                    label:
                        '${result.correctAnswers}/${result.totalQuestions}',
                    color: const Color(0xFFFFC94D),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const GlobalLeaderboardPage(),
                ),
              );
            },
            icon: const Icon(Icons.leaderboard_rounded),
            label: const Text(
              'Ver ranking mundial',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Brand.mint,
              foregroundColor: Brand.bgDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Brand.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordButton extends StatelessWidget {
  final String word;
  final bool active;
  final VoidCallback onTap;

  const _WordButton({
    required this.word,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? Brand.mint.withOpacity(0.14)
              : Brand.bgPanel.withOpacity(0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? Brand.mint
                : Brand.white.withOpacity(0.10),
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            color: active ? Brand.mint : Brand.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
