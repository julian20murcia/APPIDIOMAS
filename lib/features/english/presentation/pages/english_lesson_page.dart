import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../engine/english_adaptive_engine.dart';
import '../../models/english_activity.dart';
import '../../models/english_learning_session.dart';
import '../../models/english_lesson.dart';
import '../../services/english_question_history_service.dart';

class EnglishLessonPage extends StatefulWidget {
  final EnglishLesson lesson;

  const EnglishLessonPage({
    super.key,
    required this.lesson,
  });

  @override
  State<EnglishLessonPage> createState() => _EnglishLessonPageState();
}

class _EnglishLessonPageState extends State<EnglishLessonPage> {
  final EnglishQuestionHistoryService _historyService =
      EnglishQuestionHistoryService();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  late final EnglishAdaptiveEngine _engine;

  EnglishLearningSession? _session;
  Timer? _timer;
  DateTime? _activityStartedAt;

  bool _loading = false;
  bool _started = false;
  bool _finished = false;
  bool _finishing = false;
  bool _answered = false;
  bool _answerWasCorrect = false;
  bool _hintUsed = false;
  bool _audioPlaying = false;

  int _attempts = 1;
  int _currentIndex = 0;
  int _hearts = 3;
  int _combo = 0;
  int _maxCombo = 0;
  int _earnedPoints = 0;
  int _xp = 0;
  int _secondsRemaining = 0;

  String? _selectedOption;
  final Set<String> _hiddenOptions = {};
  List<String> _availableWords = [];
  List<String> _selectedWords = [];
  final List<EnglishActivityOutcome> _outcomes = [];

  EnglishLesson get lesson => widget.lesson;

  EnglishLearningSession get session {
    final value = _session;
    if (value == null) {
      throw StateError('La sesión todavía no está disponible.');
    }
    return value;
  }

  EnglishActivity get activity => session.activities[_currentIndex];

  int get _possiblePoints => _session?.totalBasePoints ?? 0;

  int get _score {
    if (_possiblePoints <= 0) return 0;
    return ((_earnedPoints / _possiblePoints) * 100)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  int get _correctAnswers =>
      _outcomes.where((outcome) => outcome.correct).length;

  int get _averageResponseMilliseconds {
    if (_outcomes.isEmpty) return 0;

    final total = _outcomes.fold<int>(
      0,
      (sum, outcome) => sum + outcome.responseMilliseconds,
    );

    return total ~/ _outcomes.length;
  }

  bool get _passed => _score >= 70;

  @override
  void initState() {
    super.initState();
    _engine = EnglishAdaptiveEngine(historyService: _historyService);
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _audioPlaying = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _audioPlaying = false);
    });

    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _audioPlaying = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startLesson({bool retry = false}) async {
    _timer?.cancel();
    await _tts.stop();

    setState(() {
      _loading = true;
      _started = true;
      _finished = false;
      _finishing = false;
      _answered = false;
      _answerWasCorrect = false;

      if (retry) {
        _attempts += 1;
      }

      _currentIndex = 0;
      _hearts = 3;
      _combo = 0;
      _maxCombo = 0;
      _earnedPoints = 0;
      _xp = 0;
      _outcomes.clear();
    });

    try {
      final createdSession = await _engine.createSession(
        lesson: lesson,
        attempt: _attempts,
        activityCount: 12,
      );

      if (!mounted) return;

      setState(() {
        _session = createdSession;
        _loading = false;
      });

      _prepareActivity();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _started = false;
      });

      _showMessage(
        'No fue posible preparar esta lección. $error',
      );
    }
  }

  void _prepareActivity() {
    _timer?.cancel();
    _textController.clear();

    setState(() {
      _answered = false;
      _answerWasCorrect = false;
      _hintUsed = false;
      _selectedOption = null;
      _hiddenOptions.clear();
      _selectedWords = [];
      _availableWords = List<String>.from(activity.words);
      _secondsRemaining = activity.seconds;
      _activityStartedAt = DateTime.now();
    });

    _startTimer();

    if (activity.type == EnglishActivityType.listenChoice) {
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_answered) {
          _playAudio();
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _answered || _finished) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        _evaluateAnswer(forceIncorrect: true);
        return;
      }

      setState(() => _secondsRemaining -= 1);
    });
  }

  Future<void> _playAudio() async {
    final text = activity.speechText ?? activity.answer;
    if (text.trim().isEmpty) return;

    await _tts.stop();
    await _tts.speak(text);
  }

  void _selectOption(String value) {
    if (_answered || _hiddenOptions.contains(value)) return;
    setState(() => _selectedOption = value);
  }

  void _selectWord(String value) {
    if (_answered) return;

    setState(() {
      final index = _availableWords.indexOf(value);
      if (index >= 0) {
        _availableWords.removeAt(index);
        _selectedWords.add(value);
      }
    });
  }

  void _removeSelectedWord(String value) {
    if (_answered) return;

    setState(() {
      final index = _selectedWords.lastIndexOf(value);
      if (index >= 0) {
        _selectedWords.removeAt(index);
        _availableWords.add(value);
      }
    });
  }

  void _useHint() {
    if (_answered || _hintUsed) return;

    setState(() {
      _hintUsed = true;

      if (activity.isChoice) {
        final wrongOptions = activity.options
            .where((option) => option != activity.answer)
            .toList()
          ..shuffle(math.Random.secure());

        _hiddenOptions.addAll(wrongOptions.take(2));
      } else if (activity.needsKeyboard) {
        final answer = activity.answer.trim();
        if (answer.isNotEmpty && _textController.text.trim().isEmpty) {
          _textController.text = answer.substring(0, 1);
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        }
      }
    });
  }

  void _submitAnswer() {
    if (_answered) return;

    switch (activity.type) {
      case EnglishActivityType.multipleChoice:
      case EnglishActivityType.trueFalse:
      case EnglishActivityType.listenChoice:
        if (_selectedOption == null) {
          _showMessage('Selecciona una respuesta.');
          return;
        }
        break;
      case EnglishActivityType.fillBlank:
      case EnglishActivityType.writeAnswer:
        if (_textController.text.trim().isEmpty) {
          _showMessage('Escribe una respuesta antes de continuar.');
          return;
        }
        break;
      case EnglishActivityType.orderWords:
        if (_selectedWords.isEmpty) {
          _showMessage('Ordena las palabras antes de continuar.');
          return;
        }
        break;
    }

    _evaluateAnswer();
  }

  void _evaluateAnswer({bool forceIncorrect = false}) {
    if (_answered) return;

    _timer?.cancel();

    final response = _currentResponse();
    final correct = !forceIncorrect && _isCorrect(response);
    final startedAt = _activityStartedAt ?? DateTime.now();
    final responseMilliseconds = DateTime.now()
        .difference(startedAt)
        .inMilliseconds
        .clamp(0, 180000)
        .toInt();

    var earnedXp = 0;

    setState(() {
      _answered = true;
      _answerWasCorrect = correct;

      if (correct) {
        _earnedPoints += activity.basePoints;
        _combo += 1;
        _maxCombo = math.max(_maxCombo, _combo);

        final speedBonus = (_secondsRemaining / 4)
            .floor()
            .clamp(0, 8)
            .toInt();
        final comboBonus = math.min(_combo * 2, 14);
        final hintPenalty = _hintUsed ? 5 : 0;

        earnedXp = math.max(
          4,
          activity.basePoints + speedBonus + comboBonus - hintPenalty,
        ).toInt();

        _xp += earnedXp;
      } else {
        _combo = 0;
        _hearts = math.max(0, _hearts - 1);
      }

      _outcomes.add(
        EnglishActivityOutcome(
          activityId: activity.id,
          skill: activity.skill,
          difficulty: activity.difficulty,
          correct: correct,
          responseMilliseconds: responseMilliseconds,
          usedHint: _hintUsed,
        ),
      );
    });
  }

  String _currentResponse() {
    switch (activity.type) {
      case EnglishActivityType.multipleChoice:
      case EnglishActivityType.trueFalse:
      case EnglishActivityType.listenChoice:
        return _selectedOption ?? '';
      case EnglishActivityType.fillBlank:
      case EnglishActivityType.writeAnswer:
        return _textController.text;
      case EnglishActivityType.orderWords:
        return _selectedWords.join(' ');
    }
  }

  bool _isCorrect(String response) {
    final normalizedResponse = _normalize(response);

    return activity.allAcceptedAnswers.any(
      (answer) => _normalize(answer) == normalizedResponse,
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[^a-z0-9áéíóúüñ ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _nextActivity() async {
    if (!_answered || _finishing) return;

    final noHearts = _hearts <= 0;
    final lastActivity = _currentIndex >= session.activities.length - 1;

    if (noHearts || lastActivity) {
      await _finishSession();
      return;
    }

    setState(() => _currentIndex += 1);
    _prepareActivity();
  }

  Future<void> _finishSession() async {
    if (_finishing) return;

    _timer?.cancel();
    await _tts.stop();

    setState(() => _finishing = true);

    await _historyService.recordSession(
      lessonNumber: lesson.number,
      outcomes: _outcomes,
    );

    if (!mounted) return;

    setState(() {
      _finishing = false;
      _finished = true;
    });
  }

  void _returnResult() {
    final result = EnglishSessionResult(
      sessionId: session.id,
      lessonNumber: lesson.number,
      score: _score,
      xp: _xp,
      correctAnswers: _correctAnswers,
      totalActivities: session.activities.length,
      attempts: _attempts,
      maxCombo: _maxCombo,
      averageResponseMilliseconds: _averageResponseMilliseconds,
      passed: _passed,
      outcomes: List<EnglishActivityOutcome>.unmodifiable(_outcomes),
    );

    Navigator.of(context).pop(result.toNavigationResult());
  }

  String get _resultTitle {
    if (_score >= 95) return '¡Nivel maestro!';
    if (_score >= 85) return '¡Dominio excelente!';
    if (_score >= 70) return '¡Lección aprobada!';
    return 'Sigue entrenando';
  }

  String get _resultMessage {
    if (_score >= 95) {
      return 'Respondiste con precisión, velocidad y consistencia sobresalientes.';
    }
    if (_score >= 85) {
      return 'Dominas la mayor parte del tema y estás listo para avanzar.';
    }
    if (_score >= 70) {
      return 'Aprobaste. La siguiente lección quedará desbloqueada en el mapa.';
    }
    if (_hearts <= 0) {
      return 'Perdiste tus tres vidas. La próxima sesión tendrá preguntas diferentes y reforzará tus errores.';
    }
    return 'Necesitas mínimo 70 puntos. La próxima sesión priorizará las habilidades que debes reforzar.';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Brand.bgPanel,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: Text(
          text,
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
    final media = MediaQuery.of(context);
    final compact = media.size.height < 820;
    final bottom = media.padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const LearningBackground(),
          Positioned.fill(
            child: CustomPaint(
              painter: const LearningMotifPainter(t: 0.35),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _buildCurrentView(compact, bottom),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(bool compact, double bottom) {
    if (_loading) {
      return _LoadingView(
        key: const ValueKey('loading'),
        lesson: lesson,
      );
    }

    if (_finished) {
      return _buildResult(compact, bottom);
    }

    if (_started && _session != null) {
      return _buildActivity(compact, bottom);
    }

    return _buildOverview(compact, bottom);
  }

  Widget _buildOverview(bool compact, double bottom) {
    return ListView(
      key: const ValueKey('overview'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 12 : 16,
        18,
        bottom + 24,
      ),
      children: [
        _LessonTopBar(lesson: lesson, compact: compact),
        SizedBox(height: compact ? 16 : 18),
        _LessonHeroCard(lesson: lesson, compact: compact),
        const SizedBox(height: 14),
        _AdaptiveModeCard(compact: compact),
        const SizedBox(height: 14),
        _GoalsCard(goals: lesson.learningGoals, compact: compact),
        const SizedBox(height: 18),
        _PrimaryButton(
          label: 'Generar mi reto',
          icon: Icons.bolt_rounded,
          onTap: () => _startLesson(),
        ),
      ],
    );
  }

  Widget _buildActivity(bool compact, double bottom) {
    final progress = (_currentIndex + 1) / session.activities.length;

    return Column(
      key: ValueKey('activity-${session.id}-$_currentIndex'),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            compact ? 12 : 16,
            18,
            0,
          ),
          child: _GameHeader(
            compact: compact,
            current: _currentIndex + 1,
            total: session.activities.length,
            progress: progress,
            hearts: _hearts,
            combo: _combo,
            seconds: _secondsRemaining,
            xp: _xp,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18, 0, 18, bottom + 24),
            children: [
              _ActivityCard(
                activity: activity,
                compact: compact,
                answered: _answered,
                answerWasCorrect: _answerWasCorrect,
                selectedOption: _selectedOption,
                hiddenOptions: _hiddenOptions,
                textController: _textController,
                availableWords: _availableWords,
                selectedWords: _selectedWords,
                audioPlaying: _audioPlaying,
                onOptionTap: _selectOption,
                onAvailableWordTap: _selectWord,
                onSelectedWordTap: _removeSelectedWord,
                onPlayAudio: _playAudio,
              ),
              const SizedBox(height: 12),
              _HintButton(
                enabled: !_answered && !_hintUsed,
                used: _hintUsed,
                hint: activity.hint,
                onTap: _useHint,
              ),
              if (_answered) ...[
                const SizedBox(height: 14),
                _FeedbackCard(
                  correct: _answerWasCorrect,
                  answer: activity.answer,
                  explanation: activity.explanation,
                  timedOut: _secondsRemaining == 0,
                ),
              ],
              const SizedBox(height: 18),
              _PrimaryButton(
                label: _answered
                    ? (_hearts <= 0 ||
                            _currentIndex == session.activities.length - 1
                        ? 'Ver resultado'
                        : 'Siguiente reto')
                    : 'Comprobar',
                icon: _answered
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                onTap: _answered ? _nextActivity : _submitAnswer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult(bool compact, double bottom) {
    return ListView(
      key: const ValueKey('result'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 12 : 16,
        18,
        bottom + 24,
      ),
      children: [
        _LessonTopBar(lesson: lesson, compact: compact),
        SizedBox(height: compact ? 18 : 22),
        _ResultCard(
          score: _score,
          title: _resultTitle,
          message: _resultMessage,
          passed: _passed,
          xp: _xp,
        ),
        const SizedBox(height: 14),
        _ResultStats(
          correct: _correctAnswers,
          total: session.activities.length,
          attempts: _attempts,
          maxCombo: _maxCombo,
          averageMilliseconds: _averageResponseMilliseconds,
        ),
        const SizedBox(height: 18),
        if (_passed)
          _PrimaryButton(
            label: 'Finalizar y volver al mapa',
            icon: Icons.map_rounded,
            onTap: _returnResult,
          )
        else
          _PrimaryButton(
            label: 'Generar un nuevo intento',
            icon: Icons.shuffle_rounded,
            onTap: () => _startLesson(retry: true),
          ),
        if (_passed) ...[
          const SizedBox(height: 12),
          _SecondaryButton(
            label: 'Repetir con preguntas diferentes',
            icon: Icons.replay_rounded,
            onTap: () => _startLesson(retry: true),
          ),
        ],
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  final EnglishLesson lesson;

  const _LoadingView({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Brand.mint.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Brand.mint.withOpacity(0.38),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: Brand.mint,
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Preparando un reto diferente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Brand.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Seleccionando preguntas nuevas y reforzando tus puntos débiles en “${lesson.title}”.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Brand.white.withOpacity(0.62),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTopBar extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;

  const _LessonTopBar({
    required this.lesson,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
          size: compact ? 44 : 48,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inglés Nivel 1',
                style: TextStyle(
                  color: Brand.white.withOpacity(0.58),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                lesson.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Brand.white,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonHeroCard extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;

  const _LessonHeroCard({
    required this.lesson,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 56 : 62,
                height: compact ? 56 : 62,
                decoration: BoxDecoration(
                  color: Brand.mint,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: Brand.glowMint,
                ),
                child: Center(
                  child: Text(
                    lesson.paddedNumber,
                    style: const TextStyle(
                      color: Brand.bgDeep,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Brand.white,
                        fontSize: compact ? 25 : 28,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -0.75,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '12 retos · 3 vidas · dificultad adaptativa',
                      style: TextStyle(
                        color: Brand.mint,
                        fontSize: compact ? 12.3 : 13.3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            lesson.summary,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Brand.white.withOpacity(0.74),
              fontSize: compact ? 13.5 : 14.5,
              height: 1.34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveModeCard extends StatelessWidget {
  final bool compact;

  const _AdaptiveModeCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Preguntas distintas', Icons.shuffle_rounded),
      ('Errores reforzados', Icons.psychology_rounded),
      ('Reto contrarreloj', Icons.timer_rounded),
      ('Audio en inglés', Icons.volume_up_rounded),
    ];

    return _PanelCard(
      title: 'Modo adaptativo',
      icon: Icons.auto_awesome_rounded,
      compact: compact,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Brand.mint.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Brand.mint.withOpacity(0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$2, color: Brand.mint, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: Brand.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  final List<String> goals;
  final bool compact;

  const _GoalsCard({
    required this.goals,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final visibleGoals = goals.isEmpty
        ? const [
            'Comprender el vocabulario principal del tema.',
            'Aplicar el contenido en frases y situaciones reales.',
            'Superar la evaluación con mínimo 70 puntos.',
          ]
        : goals;

    return _PanelCard(
      title: 'Lo que vas a dominar',
      icon: Icons.flag_rounded,
      compact: compact,
      child: Column(
        children: visibleGoals
            .map((goal) => _BulletLine(text: goal))
            .toList(),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final bool compact;
  final int current;
  final int total;
  final double progress;
  final int hearts;
  final int combo;
  final int seconds;
  final int xp;
  final VoidCallback onClose;

  const _GameHeader({
    required this.compact,
    required this.current,
    required this.total,
    required this.progress,
    required this.hearts,
    required this.combo,
    required this.seconds,
    required this.xp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final timerColor = seconds <= 7
        ? Colors.redAccent
        : seconds <= 14
            ? const Color(0xFFFFC94D)
            : Brand.mint;

    return Column(
      children: [
        Row(
          children: [
            _SquareIconButton(
              icon: Icons.close_rounded,
              onTap: onClose,
              size: compact ? 42 : 46,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProgressLine(value: progress),
            ),
            const SizedBox(width: 10),
            Text(
              '$current/$total',
              style: const TextStyle(
                color: Brand.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _GamePill(
              icon: Icons.favorite_rounded,
              value: '$hearts',
              color: Colors.redAccent,
            ),
            const SizedBox(width: 7),
            _GamePill(
              icon: Icons.local_fire_department_rounded,
              value: 'x$combo',
              color: const Color(0xFFFFC94D),
            ),
            const SizedBox(width: 7),
            _GamePill(
              icon: Icons.timer_rounded,
              value: '${seconds}s',
              color: timerColor,
            ),
            const Spacer(),
            _GamePill(
              icon: Icons.auto_awesome_rounded,
              value: '$xp XP',
              color: Brand.mint,
            ),
          ],
        ),
      ],
    );
  }
}

class _GamePill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _GamePill({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            value,
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

class _ActivityCard extends StatelessWidget {
  final EnglishActivity activity;
  final bool compact;
  final bool answered;
  final bool answerWasCorrect;
  final String? selectedOption;
  final Set<String> hiddenOptions;
  final TextEditingController textController;
  final List<String> availableWords;
  final List<String> selectedWords;
  final bool audioPlaying;
  final ValueChanged<String> onOptionTap;
  final ValueChanged<String> onAvailableWordTap;
  final ValueChanged<String> onSelectedWordTap;
  final VoidCallback onPlayAudio;

  const _ActivityCard({
    required this.activity,
    required this.compact,
    required this.answered,
    required this.answerWasCorrect,
    required this.selectedOption,
    required this.hiddenOptions,
    required this.textController,
    required this.availableWords,
    required this.selectedWords,
    required this.audioPlaying,
    required this.onOptionTap,
    required this.onAvailableWordTap,
    required this.onSelectedWordTap,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkillBadge(skill: activity.skill),
              const SizedBox(width: 8),
              _DifficultyBadge(difficulty: activity.difficulty),
              const Spacer(),
              Text(
                '+${activity.basePoints} pts',
                style: TextStyle(
                  color: Brand.white.withOpacity(0.48),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 18 : 22),
          if (activity.type == EnglishActivityType.listenChoice) ...[
            Center(
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPlayAudio,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Brand.mint,
                      shape: BoxShape.circle,
                      boxShadow: Brand.glowMint,
                    ),
                    child: Icon(
                      audioPlaying
                          ? Icons.graphic_eq_rounded
                          : Icons.volume_up_rounded,
                      color: Brand.bgDeep,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            activity.prompt,
            style: TextStyle(
              color: Brand.white,
              fontSize: compact ? 21 : 24,
              height: 1.14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
            ),
          ),
          if (activity.instruction.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              activity.instruction,
              style: TextStyle(
                color: Brand.white.withOpacity(0.58),
                fontSize: compact ? 12.5 : 13.2,
                height: 1.28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          SizedBox(height: compact ? 20 : 24),
          _buildInteraction(),
        ],
      ),
    );
  }

  Widget _buildInteraction() {
    switch (activity.type) {
      case EnglishActivityType.multipleChoice:
      case EnglishActivityType.trueFalse:
      case EnglishActivityType.listenChoice:
        return Column(
          children: activity.options.map((option) {
            final hidden = hiddenOptions.contains(option);
            if (hidden) return const SizedBox.shrink();

            final selected = selectedOption == option;
            final correctOption = answered && option == activity.answer;
            final wrongSelection =
                answered && selected && option != activity.answer;

            var background = Brand.bgDeep.withOpacity(0.38);
            var border = Brand.white.withOpacity(0.10);
            var iconColor = Brand.white.withOpacity(0.44);
            var icon = Icons.circle_outlined;

            if (selected && !answered) {
              background = Brand.mint.withOpacity(0.12);
              border = Brand.mint.withOpacity(0.72);
              iconColor = Brand.mint;
              icon = Icons.radio_button_checked_rounded;
            }

            if (correctOption) {
              background = Brand.mint.withOpacity(0.14);
              border = Brand.mint.withOpacity(0.80);
              iconColor = Brand.mint;
              icon = Icons.check_circle_rounded;
            }

            if (wrongSelection) {
              background = Colors.redAccent.withOpacity(0.10);
              border = Colors.redAccent.withOpacity(0.72);
              iconColor = Colors.redAccent;
              icon = Icons.cancel_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: answered ? null : () => onOptionTap(option),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 21),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Brand.white.withOpacity(0.90),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case EnglishActivityType.fillBlank:
      case EnglishActivityType.writeAnswer:
        return TextField(
          controller: textController,
          enabled: !answered,
          autocorrect: false,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            color: Brand.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta',
            hintStyle: TextStyle(
              color: Brand.white.withOpacity(0.34),
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: Brand.bgDeep.withOpacity(0.45),
            prefixIcon: const Icon(
              Icons.edit_rounded,
              color: Brand.mint,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: _inputBorder(Brand.white.withOpacity(0.10)),
            enabledBorder: _inputBorder(Brand.white.withOpacity(0.10)),
            focusedBorder: _inputBorder(
              Brand.mint.withOpacity(0.72),
              1.4,
            ),
            disabledBorder: _inputBorder(
              answerWasCorrect
                  ? Brand.mint.withOpacity(0.72)
                  : Colors.redAccent.withOpacity(0.62),
              1.3,
            ),
          ),
        );

      case EnglishActivityType.orderWords:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 82),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Brand.bgDeep.withOpacity(0.38),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: answered
                      ? (answerWasCorrect
                          ? Brand.mint.withOpacity(0.66)
                          : Colors.redAccent.withOpacity(0.62))
                      : Brand.white.withOpacity(0.10),
                ),
              ),
              child: selectedWords.isEmpty
                  ? Center(
                      child: Text(
                        'Toca las palabras en el orden correcto',
                        style: TextStyle(
                          color: Brand.white.withOpacity(0.36),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedWords
                          .map(
                            (word) => _WordChip(
                              word: word,
                              active: true,
                              enabled: !answered,
                              onTap: () => onSelectedWordTap(word),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableWords
                  .map(
                    (word) => _WordChip(
                      word: word,
                      active: false,
                      enabled: !answered,
                      onTap: () => onAvailableWordTap(word),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
    }
  }

  OutlineInputBorder _inputBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SkillBadge extends StatelessWidget {
  final EnglishSkill skill;

  const _SkillBadge({required this.skill});

  @override
  Widget build(BuildContext context) {
    final label = switch (skill) {
      EnglishSkill.vocabulary => 'Vocabulario',
      EnglishSkill.grammar => 'Gramática',
      EnglishSkill.reading => 'Lectura',
      EnglishSkill.listening => 'Escucha',
      EnglishSkill.writing => 'Escritura',
      EnglishSkill.conversation => 'Conversación',
    };

    return _SmallBadge(
      label: label,
      color: Brand.mint,
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final EnglishDifficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final label = switch (difficulty) {
      EnglishDifficulty.easy => 'Inicial',
      EnglishDifficulty.medium => 'Intermedio',
      EnglishDifficulty.hard => 'Avanzado',
    };

    final color = switch (difficulty) {
      EnglishDifficulty.easy => Brand.cyan,
      EnglishDifficulty.medium => const Color(0xFFFFC94D),
      EnglishDifficulty.hard => Colors.redAccent,
    };

    return _SmallBadge(label: label, color: color);
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final bool enabled;
  final bool used;
  final String hint;
  final VoidCallback onTap;

  const _HintButton({
    required this.enabled,
    required this.used,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Brand.bgPanel.withOpacity(0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: used
                  ? const Color(0xFFFFC94D).withOpacity(0.35)
                  : Brand.white.withOpacity(0.09),
            ),
          ),
          child: Row(
            children: [
              Icon(
                used ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                color: used
                    ? const Color(0xFFFFC94D)
                    : Brand.white.withOpacity(0.60),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  used
                      ? (hint.isEmpty ? 'Pista utilizada' : hint)
                      : 'Usar una pista · reduce el XP',
                  style: TextStyle(
                    color: Brand.white.withOpacity(used ? 0.80 : 0.58),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool correct;
  final String answer;
  final String explanation;
  final bool timedOut;

  const _FeedbackCard({
    required this.correct,
    required this.answer,
    required this.explanation,
    required this.timedOut,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? Brand.mint : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.46)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct
                ? Icons.check_circle_rounded
                : timedOut
                    ? Icons.timer_off_rounded
                    : Icons.cancel_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct
                      ? '¡Correcto!'
                      : timedOut
                          ? 'Se terminó el tiempo'
                          : 'Respuesta incorrecta',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Respuesta: $answer',
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  explanation,
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.65),
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
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

class _ResultCard extends StatelessWidget {
  final int score;
  final String title;
  final String message;
  final bool passed;
  final int xp;

  const _ResultCard({
    required this.score,
    required this.title,
    required this.message,
    required this.passed,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final color = passed ? Brand.mint : Colors.redAccent;

    return _GlassCard(
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.52), width: 3),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white.withOpacity(0.65),
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Brand.mint.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Brand.mint.withOpacity(0.30)),
            ),
            child: Text(
              '+$xp XP',
              style: const TextStyle(
                color: Brand.mint,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStats extends StatelessWidget {
  final int correct;
  final int total;
  final int attempts;
  final int maxCombo;
  final int averageMilliseconds;

  const _ResultStats({
    required this.correct,
    required this.total,
    required this.attempts,
    required this.maxCombo,
    required this.averageMilliseconds,
  });

  @override
  Widget build(BuildContext context) {
    final seconds = averageMilliseconds <= 0
        ? 0
        : (averageMilliseconds / 1000).round();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.15,
      children: [
        _StatTile(
          icon: Icons.check_circle_rounded,
          label: 'Aciertos',
          value: '$correct/$total',
        ),
        _StatTile(
          icon: Icons.local_fire_department_rounded,
          label: 'Combo máximo',
          value: 'x$maxCombo',
        ),
        _StatTile(
          icon: Icons.timer_rounded,
          label: 'Tiempo medio',
          value: '${seconds}s',
        ),
        _StatTile(
          icon: Icons.replay_rounded,
          label: 'Intento',
          value: '$attempts',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.52),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.white.withOpacity(0.09)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Brand.mint, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.50),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Brand.bgPanel.withOpacity(0.62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Brand.white.withOpacity(0.10)),
          ),
          child: Icon(icon, color: Brand.white),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? Brand.mint.withOpacity(0.15)
                : Brand.bgPanel.withOpacity(0.74),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? Brand.mint.withOpacity(0.58)
                  : Brand.white.withOpacity(0.11),
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              color: active ? Brand.mint : Brand.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.62),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Brand.white.withOpacity(0.11)),
        boxShadow: Brand.cardShadow,
      ),
      child: child,
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool compact;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.icon,
    required this.compact,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 15 : 17),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.52),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Brand.mint, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: compact ? 17 : 18.5,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Brand.mint,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Brand.white.withOpacity(0.72),
                fontSize: 13.4,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 23),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.mint,
          foregroundColor: Brand.bgDeep,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 21),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Brand.white,
          side: BorderSide(color: Brand.white.withOpacity(0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double value;

  const _ProgressLine({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Brand.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Brand.mint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
