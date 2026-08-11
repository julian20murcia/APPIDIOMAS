import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../data/english_level_1_curriculum.dart';
import '../../data/english_level_1_profiles.dart';
import '../../data/english_level_1_games.dart';
import '../../engine/english_adaptive_engine.dart';
import '../../models/english_activity.dart';
import '../../models/english_learning_session.dart';
import '../../models/english_lesson.dart';
import '../../services/english_question_history_service.dart';
import '../../services/english_speech_service.dart';
import 'english_lesson_game_page.dart';
import 'english_premium_game_page.dart';

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
  final EnglishSpeechService _speech = EnglishSpeechService.instance;

  late final EnglishAdaptiveEngine _engine;

  EnglishLearningSession? _session;
  Timer? _timer;
  DateTime? _activityStartedAt;

  bool _loading = false;
  bool _started = false;
  bool _practiceMode = false;
  bool _practiceCompleted = false;
  bool _gameCompleted = false;
  int _learningStage = 0;
  int _learningCardIndex = 0;
  final Set<int> _revealedVocabulary = <int>{};
  bool _finished = false;
  bool _finishing = false;
  bool _answered = false;
  bool _answerWasCorrect = false;
  bool _hintUsed = false;
  bool _audioPlaying = false;
  bool _speechAvailable = false;
  bool _speechListening = false;
  String _speechTranscript = '';
  double _speechConfidence = 0;
  EnglishSpeechAttempt? _speechAttempt;

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

  Map<EnglishSkill, int> get _accuracyBySkill {
    final totals = <EnglishSkill, int>{};
    final correct = <EnglishSkill, int>{};
    for (final outcome in _outcomes) {
      totals[outcome.skill] = (totals[outcome.skill] ?? 0) + 1;
      if (outcome.correct) {
        correct[outcome.skill] = (correct[outcome.skill] ?? 0) + 1;
      }
    }
    return {
      for (final entry in totals.entries)
        entry.key: (((correct[entry.key] ?? 0) / entry.value) * 100).round(),
    };
  }

  List<String> get _strengthLabels => _accuracyBySkill.entries
      .where((entry) => entry.value >= 80)
      .map((entry) => _skillLabel(entry.key))
      .toList();

  List<String> get _weaknessLabels => _accuracyBySkill.entries
      .where((entry) => entry.value < 80)
      .map((entry) => _skillLabel(entry.key))
      .toList();

  String _skillLabel(EnglishSkill skill) {
    switch (skill) {
      case EnglishSkill.vocabulary:
        return 'Vocabulario';
      case EnglishSkill.grammar:
        return 'Gramática';
      case EnglishSkill.reading:
        return 'Comprensión';
      case EnglishSkill.listening:
        return 'Listening';
      case EnglishSkill.writing:
        return 'Escritura';
      case EnglishSkill.conversation:
        return 'Conversación';
      case EnglishSkill.speaking:
        return 'Pronunciación';
    }
  }

  int get _averageResponseMilliseconds {
    if (_outcomes.isEmpty) return 0;

    final total = _outcomes.fold<int>(
      0,
      (sum, outcome) => sum + outcome.responseMilliseconds,
    );

    return total ~/ _outcomes.length;
  }

  bool get _passed => _score >= 80;

  @override
  void initState() {
    super.initState();
    _engine = EnglishAdaptiveEngine(historyService: _historyService);
    _configureTts();
    _configureSpeech();
  }

  Future<void> _configureSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() => _speechListening = status == 'listening');
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _speechListening = false);
      },
    );
    if (!mounted) return;
    setState(() => _speechAvailable = available);
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
    _speech.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startLesson({bool retry = false, bool practice = false}) async {
    _timer?.cancel();
    await _tts.stop();

    setState(() {
      _loading = true;
      _started = true;
      _practiceMode = practice;
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
        activityCount: practice
            ? math.min(
                18,
                math.max(
                  englishLevel1ActivityProfiles[lesson.number]?.minimumPracticeItems ?? 10,
                  math.min(18, englishLevel1Vocabulary[lesson.number]?.length ?? 10),
                ),
              ).toInt()
            : 10,
        practice: practice,
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
      _speechTranscript = '';
      _speechConfidence = 0;
      _speechAttempt = null;
      _speechListening = false;
      _activityStartedAt = DateTime.now();
    });

    if (!_practiceMode) {
      _startTimer();
    }

    if (activity.type == EnglishActivityType.listenChoice ||
        activity.type == EnglishActivityType.speakAnswer) {
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

  Future<void> _toggleSpeechActivity() async {
    if (_answered) return;
    if (!_speechAvailable) {
      _showMessage('No pude activar el reconocimiento de voz. Puedes continuar con las demás actividades y volver a intentarlo en un dispositivo compatible.');
      return;
    }

    if (_speech.isListening || _speechListening) {
      await _speech.stop();
      if (mounted) setState(() => _speechListening = false);
      return;
    }

    await _tts.stop();
    setState(() {
      _speechTranscript = '';
      _speechConfidence = 0;
      _speechAttempt = null;
      _speechListening = true;
    });

    await _speech.listen(
      localeId: 'en_US',
      onResult: (words, finalResult, confidence) {
        if (!mounted) return;
        setState(() {
          _speechTranscript = words;
          _speechConfidence = confidence;
          if (words.trim().isNotEmpty) {
            _speechAttempt = _speech.evaluate(
              target: activity.answer,
              transcript: words,
              recognitionConfidence: confidence,
            );
          }
          if (finalResult) _speechListening = false;
        });
      },
    );
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
      case EnglishActivityType.speakAnswer:
        if (_speechAttempt == null) {
          _showMessage('Escucha la frase y luego tócala para decirla en voz alta.');
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
        if (!_practiceMode) {
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
        }
      } else if (!_practiceMode) {
        _combo = 0;
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
      case EnglishActivityType.speakAnswer:
        return _speechTranscript;
      case EnglishActivityType.orderWords:
        return _selectedWords.join(' ');
    }
  }

  bool _isCorrect(String response) {
    if (activity.type == EnglishActivityType.speakAnswer) {
      return (_speechAttempt?.score ?? 0) >= 70;
    }
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

    const noHearts = false;
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

    if (_practiceMode) {
      if (!mounted) return;
      setState(() {
        _finishing = false;
        _started = false;
        _finished = false;
        _practiceCompleted = true;
        _session = null;
        _outcomes.clear();
        _earnedPoints = 0;
        _xp = 0;
        _combo = 0;
        _maxCombo = 0;
      });
      return;
    }

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
    if (_score >= 90) return '¡Dominio excelente!';
    if (_score >= 80) return '¡Lección aprobada!';
    return 'Sigue entrenando';
  }

  String get _resultMessage {
    if (_score >= 95) {
      return 'Respondiste con precisión, velocidad y consistencia sobresalientes.';
    }
    if (_score >= 90) {
      return 'Dominas la mayor parte del tema y estás listo para avanzar.';
    }
    if (_score >= 80) {
      return 'Aprobaste la evaluación. La siguiente lección quedará desbloqueada en el mapa.';
    }
    if (_hearts <= 0) {
      return 'La evaluación terminó. Revisa tus puntos a reforzar antes de volver a intentarlo.';
    }
    return 'Necesitas mínimo 80 puntos. Revisa tus puntos a reforzar y vuelve a intentarlo cuando estés listo.';
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
    final vocabulary = englishLevel1Vocabulary[lesson.number] ?? const [];
    final game = englishLevel1Games[lesson.number];

    Future<void> openGame() async {
      if (game == null) return;

      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PremiumLessonGamePage.supports(lesson.number)
                      ? PremiumLessonGamePage(lesson: lesson)
                      : EnglishLessonGamePage(lesson: lesson),
        ),
      );

      if (!mounted) return;

      if (completed == true) {
        setState(() {
          _gameCompleted = true;
          if (_learningStage < 3) _learningStage = 3;
        });
      }
    }

    final progress = _practiceCompleted
        ? .86
        : _gameCompleted
            ? .62
            : _learningStage >= 3
                ? .36
                : (_learningStage + 1) * .09;

    return ListView(
      key: ValueKey(
        'learning-${lesson.number}-$_practiceCompleted-$_gameCompleted-$_learningStage',
      ),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 10 : 14,
        18,
        bottom + 26,
      ),
      children: [
        _LessonTopBar(lesson: lesson, compact: compact),
        SizedBox(height: compact ? 12 : 16),

        _LessonCompactHeader(
          lesson: lesson,
          compact: compact,
          progress: progress.clamp(0.0, 1.0),
          vocabularyCount: vocabulary.length,
          gameTitle: game?.title,
          practiceCompleted: _practiceCompleted,
        ),

        const SizedBox(height: 12),

        _LessonStepper(
          learningStage: _learningStage,
          gameCompleted: _gameCompleted,
          practiceCompleted: _practiceCompleted,
        ),

        const SizedBox(height: 12),

        _LearningStudioV4(
          lesson: lesson,
          items: vocabulary,
          compact: compact,
          stage: _learningStage,
          activeIndex: _learningCardIndex,
          revealed: _revealedVocabulary,
          onStageChanged: (value) {
            setState(() => _learningStage = value.clamp(0, 3));
          },
          onIndexChanged: (index) {
            setState(() => _learningCardIndex = index);
          },
          onReveal: (index) {
            setState(() => _revealedVocabulary.add(index));
          },
          onSpeak: (value) async {
            await _tts.stop();
            await _tts.speak(value);
          },
        ),

        if (game != null) ...[
          const SizedBox(height: 12),
          _LessonChallengePreview(
            config: game,
            compact: compact,
            completed: _gameCompleted,
          ),
        ],

        const SizedBox(height: 14),

        if (!_gameCompleted)
          _PrimaryButton(
            label: 'Comenzar reto · ${game?.title ?? 'Juego'}',
            icon: Icons.play_arrow_rounded,
            onTap: game == null
                ? () => _showMessage('Esta lección no tiene un reto disponible.')
                : openGame,
          )
        else if (!_practiceCompleted)
          _PrimaryButton(
            label: 'Continuar a práctica guiada',
            icon: Icons.school_rounded,
            onTap: () => _startLesson(practice: true),
          )
        else
          _PrimaryButton(
            label: 'Comenzar evaluación · 10 preguntas',
            icon: Icons.verified_rounded,
            onTap: () => _startLesson(practice: false),
          ),

        if (_practiceCompleted) ...[
          const SizedBox(height: 9),
          _SecondaryButton(
            label: 'Practicar otra vez',
            icon: Icons.refresh_rounded,
            onTap: () => _startLesson(practice: true),
          ),
        ],
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
            practiceMode: _practiceMode,
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
            speechAvailable: _speechAvailable,
            speechListening: _speechListening,
            speechTranscript: _speechTranscript,
            speechAttempt: _speechAttempt,
            onSpeak: _toggleSpeechActivity,
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
                        ? (_practiceMode ? 'Terminar práctica' : 'Ver resultado')
                        : (_practiceMode ? 'Siguiente ejercicio' : 'Siguiente pregunta'))
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
        const SizedBox(height: 14),
        _LearningDiagnosisCard(
          strengths: _strengthLabels,
          weaknesses: _weaknessLabels,
          compact: compact,
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
            label: 'Repasar antes de reintentar',
            icon: Icons.menu_book_rounded,
            onTap: () {
              setState(() {
                _finished = false;
                _started = false;
                _practiceCompleted = false;
                _gameCompleted = false;
                _session = null;
              });
            },
          ),
        if (_passed) ...[
          const SizedBox(height: 12),
          _SecondaryButton(
            label: 'Repetir evaluación con preguntas diferentes',
            icon: Icons.replay_rounded,
            onTap: () => _startLesson(retry: true),
          ),
        ],
      ],
    );
  }
}


class _LearningDiagnosisCard extends StatelessWidget {
  final List<String> strengths;
  final List<String> weaknesses;
  final bool compact;

  const _LearningDiagnosisCard({
    required this.strengths,
    required this.weaknesses,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Diagnóstico de aprendizaje',
      icon: Icons.insights_rounded,
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DiagnosisSection(
            title: 'Fortalezas',
            icon: Icons.check_circle_rounded,
            color: Brand.mint,
            items: strengths.isEmpty ? const ['Aún no hay una habilidad consolidada.'] : strengths,
          ),
          const SizedBox(height: 14),
          _DiagnosisSection(
            title: 'Debes reforzar',
            icon: Icons.refresh_rounded,
            color: const Color(0xFFFFC94D),
            items: weaknesses.isEmpty ? const ['No se detectaron puntos débiles en este intento.'] : weaknesses,
          ),
        ],
      ),
    );
  }
}

class _DiagnosisSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _DiagnosisSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Text(title, style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Text(item, style: TextStyle(color: Brand.white.withOpacity(0.78), fontSize: 11.7, fontWeight: FontWeight.w700)),
          )).toList(),
        ),
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
                      'Aprende · practica · evaluación final al 80%',
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



class _InteractiveLessonHero extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;
  final int stage;
  final bool pronunciationCompleted;
  final bool gameCompleted;
  final bool practiceCompleted;

  const _InteractiveLessonHero({
    required this.lesson,
    required this.compact,
    required this.stage,
    required this.pronunciationCompleted,
    required this.gameCompleted,
    required this.practiceCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final progress = practiceCompleted ? 1.0 : gameCompleted ? .72 : stage > 0 ? .38 : .16;
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12233E), Color(0xFF0B1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Brand.mint.withOpacity(.24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.16), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Brand.mint, borderRadius: BorderRadius.circular(16)),
                child: Text(lesson.paddedNumber, style: const TextStyle(color: Brand.bgDeep, fontWeight: FontWeight.w900, fontSize: 17)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MISIÓN DE APRENDIZAJE', style: TextStyle(color: Brand.mint.withOpacity(.92), fontSize: 10.8, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                    const SizedBox(height: 4),
                    Text(lesson.title, style: TextStyle(color: Brand.white, fontSize: compact ? 22 : 26, fontWeight: FontWeight.w900, letterSpacing: -.65)),
                  ],
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, color: Brand.mint),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            lesson.summary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Brand.white.withOpacity(.70), fontSize: 13.1, height: 1.4, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Brand.white.withOpacity(.07),
                    valueColor: const AlwaysStoppedAnimation(Brand.mint),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Text('${(progress * 100).round()}%', style: const TextStyle(color: Brand.white, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionStrip extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;
  final int stage;
  final ValueChanged<int> onStageChanged;

  const _MissionStrip({
    required this.lesson,
    required this.compact,
    required this.stage,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final goals = lesson.learningGoals.isEmpty
        ? const ['Descubrir el tema', 'Escuchar y reconocer', 'Usarlo en contexto']
        : lesson.learningGoals.take(3).toList();
    const icons = [Icons.explore_rounded, Icons.hearing_rounded, Icons.chat_bubble_rounded];
    return _PanelCard(
      title: 'Tu misión',
      icon: Icons.flag_rounded,
      compact: compact,
      child: Column(
        children: [
          Text('No tienes que memorizar un texto. Avanza por pequeñas misiones y prueba lo que vas entendiendo.', style: TextStyle(color: Brand.white.withOpacity(.61), fontSize: 12.6, height: 1.4)),
          const SizedBox(height: 13),
          for (int i = 0; i < goals.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onStageChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stage == i ? Brand.mint.withOpacity(.11) : Brand.white.withOpacity(.025),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: stage == i ? Brand.mint.withOpacity(.30) : Brand.white.withOpacity(.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: stage >= i ? Brand.mint : Brand.white.withOpacity(.07), borderRadius: BorderRadius.circular(12)),
                      child: Icon(stage > i ? Icons.check_rounded : icons[i], color: stage >= i ? Brand.bgDeep : Brand.white.withOpacity(.50), size: 19),
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(goals[i], style: TextStyle(color: stage == i ? Brand.white : Brand.white.withOpacity(.67), fontSize: 13, fontWeight: FontWeight.w800, height: 1.25))),
                    Icon(Icons.chevron_right_rounded, color: stage == i ? Brand.mint : Brand.white.withOpacity(.25)),
                  ],
                ),
              ),
            ),
            if (i != goals.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _InteractiveVocabularyDeck extends StatelessWidget {
  final List<dynamic> items;
  final bool compact;
  final int activeIndex;
  final Set<int> revealed;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<int> onReveal;
  final Future<void> Function(String text) onSpeak;

  const _InteractiveVocabularyDeck({
    required this.items,
    required this.compact,
    required this.activeIndex,
    required this.revealed,
    required this.onIndexChanged,
    required this.onReveal,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final safeIndex = activeIndex.clamp(0, items.length - 1).toInt();
    final item = items[safeIndex];
    final isRevealed = revealed.contains(safeIndex);
    return _PanelCard(
      title: 'Descubre las palabras',
      icon: Icons.style_rounded,
      compact: compact,
      child: Column(
        children: [
          Row(
            children: [
              Text('${safeIndex + 1} / ${items.length}', style: TextStyle(color: Brand.mint.withOpacity(.9), fontWeight: FontWeight.w900, fontSize: 11.5)),
              const Spacer(),
              Text('${revealed.length} descubiertas', style: TextStyle(color: Brand.white.withOpacity(.45), fontSize: 10.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onReveal(safeIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: compact ? 22 : 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Brand.mint.withOpacity(.12), Brand.mint.withOpacity(.055)]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isRevealed ? Brand.mint.withOpacity(.34) : Brand.white.withOpacity(.08)),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onSpeak(item.english as String),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Brand.mint.withOpacity(.15)),
                      child: const Icon(Icons.volume_up_rounded, color: Brand.mint),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(item.english as String, textAlign: TextAlign.center, style: TextStyle(color: Brand.white, fontSize: compact ? 22 : 26, fontWeight: FontWeight.w900, letterSpacing: -.4)),
                  const SizedBox(height: 9),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isRevealed
                        ? Text(item.spanish as String, key: const ValueKey('translation'), textAlign: TextAlign.center, style: TextStyle(color: Brand.mint, fontSize: 15, fontWeight: FontWeight.w800))
                        : Row(
                            key: const ValueKey('hint'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_rounded, color: Brand.white.withOpacity(.38), size: 16),
                              const SizedBox(width: 6),
                              Text('Toca para revelar', style: TextStyle(color: Brand.white.withOpacity(.42), fontSize: 12.5, fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: safeIndex > 0 ? () => onIndexChanged(safeIndex - 1) : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep),
                  onPressed: safeIndex < items.length - 1 ? () => onIndexChanged(safeIndex + 1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Siguiente', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogueMissionCard extends StatefulWidget {
  final String dialogue;
  final bool compact;
  final Future<void> Function(String text) onSpeak;

  const _DialogueMissionCard({required this.dialogue, required this.compact, required this.onSpeak});

  @override
  State<_DialogueMissionCard> createState() => _DialogueMissionCardState();
}

class _DialogueMissionCardState extends State<_DialogueMissionCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.dialogue.split('\n').where((line) => line.trim().isNotEmpty).take(expanded ? 18 : 5).toList();
    return _PanelCard(
      title: 'Escena interactiva',
      icon: Icons.theater_comedy_rounded,
      compact: widget.compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Escucha el diálogo como una escena, identifica frases conocidas y luego entra al juego.', style: TextStyle(color: Brand.white.withOpacity(.58), fontSize: 12.5, height: 1.4)),
          const SizedBox(height: 12),
          for (int i = 0; i < lines.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: (i.isEven ? Brand.mint : Brand.mint).withOpacity(.07), borderRadius: BorderRadius.circular(14)),
              child: Text(lines[i], style: TextStyle(color: Brand.white.withOpacity(.77), fontSize: 12.8, height: 1.35, fontWeight: i < 2 ? FontWeight.w800 : FontWeight.w600)),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(onPressed: () => widget.onSpeak(widget.dialogue), icon: const Icon(Icons.play_circle_fill_rounded), label: const Text('Escuchar escena')),
              const Spacer(),
              TextButton(onPressed: () => setState(() => expanded = !expanded), child: Text(expanded ? 'Ver menos' : 'Ver más')),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonGameLauncherCard extends StatelessWidget {
  final EnglishLessonGameConfig config;
  final bool compact;
  final bool completed;
  final VoidCallback onTap;

  const _LessonGameLauncherCard({required this.config, required this.compact, required this.completed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [config.accent.withOpacity(.20), const Color(0xFF111D31)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: config.accent.withOpacity(.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: config.accent, borderRadius: BorderRadius.circular(18)), child: Icon(config.icon, color: const Color(0xFF07111F), size: 27)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(completed ? 'JUEGO COMPLETADO' : 'JUEGO DE ESTA LECCIÓN', style: TextStyle(color: config.accent, fontSize: 10.7, fontWeight: FontWeight.w900, letterSpacing: .9)),
                  const SizedBox(height: 4),
                  Text(config.title, style: const TextStyle(color: Brand.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ]),
              ),
              if (completed) const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 27),
            ],
          ),
          const SizedBox(height: 13),
          Text(config.mission, style: TextStyle(color: Brand.white.withOpacity(.65), fontSize: 12.9, height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: config.accent, foregroundColor: const Color(0xFF07111F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
              onPressed: onTap,
              icon: Icon(completed ? Icons.replay_rounded : Icons.play_arrow_rounded),
              label: Text(completed ? 'Jugar otra vez' : 'Jugar ahora', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  final bool compact;
  final bool pronunciationCompleted;
  final bool gameCompleted;
  final bool practiceCompleted;

  const _LearningPathCard({
    required this.compact,
    required this.pronunciationCompleted,
    required this.gameCompleted,
    required this.practiceCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final steps = <(String, String, IconData, bool)>[
      ('1', 'Aprender', Icons.auto_awesome_rounded, true),
      ('2', 'Juego', Icons.sports_esports_rounded, gameCompleted),
      ('3', 'Práctica', Icons.school_rounded, practiceCompleted),
      ('4', 'Evaluar', Icons.verified_rounded, practiceCompleted),
    ];

    return _PanelCard(
      title: 'Ruta de la lección',
      icon: Icons.route_rounded,
      compact: compact,
      child: Row(
        children: steps.map((step) {
          final active = step.$4;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
              decoration: BoxDecoration(
                color: active ? Brand.mint.withOpacity(0.12) : Brand.white.withOpacity(0.035),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: active ? Brand.mint.withOpacity(0.32) : Brand.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                children: [
                  Icon(step.$3, color: active ? Brand.mint : Brand.white.withOpacity(0.45), size: 20),
                  const SizedBox(height: 6),
                  Text(
                    step.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? Brand.white : Brand.white.withOpacity(0.58),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VocabularyLearningCard extends StatelessWidget {
  final List<dynamic> items;
  final bool compact;
  final Future<void> Function(String text) onSpeak;

  const _VocabularyLearningCard({
    required this.items,
    required this.compact,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Vocabulario esencial',
      icon: Icons.translate_rounded,
      compact: compact,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _VocabularyLearningRow(
              english: items[index].english as String,
              spanish: items[index].spanish as String,
              onSpeak: onSpeak,
            ),
            if (index != items.length - 1)
              Divider(color: Brand.white.withOpacity(0.07), height: 18),
          ],
        ],
      ),
    );
  }
}

class _VocabularyLearningRow extends StatelessWidget {
  final String english;
  final String spanish;
  final Future<void> Function(String text) onSpeak;

  const _VocabularyLearningRow({
    required this.english,
    required this.spanish,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSpeak(english),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Brand.mint.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.volume_up_rounded, color: Brand.mint, size: 19),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                english,
                style: const TextStyle(color: Brand.white, fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                spanish,
                style: TextStyle(color: Brand.white.withOpacity(0.60), fontSize: 13.2, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogueLearningCard extends StatelessWidget {
  final String dialogue;
  final bool compact;

  const _DialogueLearningCard({
    required this.dialogue,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Diálogo en contexto',
      icon: Icons.forum_rounded,
      compact: compact,
      child: Text(
        dialogue,
        style: TextStyle(
          color: Brand.white.withOpacity(0.74),
          fontSize: 13.2,
          height: 1.52,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class _LearningCoachCard extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;
  const _LearningCoachCard({required this.lesson, required this.compact});

  @override
  Widget build(BuildContext context) {
    final goals = lesson.learningGoals.take(3).toList();
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF132B42), Color(0xFF0E2237)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.mint.withOpacity(.20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42,height:42,decoration:BoxDecoration(color:Brand.mint.withOpacity(.12),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.psychology_alt_rounded,color:Brand.mint)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Lo que vas a dominar', style: TextStyle(color: Brand.white, fontWeight: FontWeight.w900, fontSize: 15)),
            SizedBox(height: 2),
            Text('Tres objetivos. Sin párrafos eternos.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
        ]),
        const SizedBox(height: 14),
        for (var i=0;i<goals.length;i++) Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 25,height:25,alignment:Alignment.center,decoration:BoxDecoration(color:Brand.mint.withOpacity(.12),shape:BoxShape.circle),child:Text('${i+1}',style:const TextStyle(color:Brand.mint,fontWeight:FontWeight.w900,fontSize:11))),
            const SizedBox(width:10),
            Expanded(child:Text(goals[i],style:const TextStyle(color:Colors.white70,fontSize:13.1,height:1.3,fontWeight:FontWeight.w600))),
          ]),
        ),
      ]),
    );
  }
}

class _SpeakChallengeCard extends StatefulWidget {
  final EnglishLesson lesson;
  final bool compact;
  final Future<void> Function(String text) onSpeak;
  const _SpeakChallengeCard({required this.lesson, required this.compact, required this.onSpeak});
  @override
  State<_SpeakChallengeCard> createState()=>_SpeakChallengeCardState();
}

class _SpeakChallengeCardState extends State<_SpeakChallengeCard> {
  int index=0;
  bool revealed=false;
  @override
  Widget build(BuildContext context) {
    final vocab=englishLevel1Vocabulary[widget.lesson.number] ?? const [];
    if(vocab.isEmpty) return const SizedBox.shrink();
    final item=vocab[index%vocab.length];
    return Container(
      padding: EdgeInsets.all(widget.compact ? 16 : 19),
      decoration: BoxDecoration(color:const Color(0xFF10283F),borderRadius:BorderRadius.circular(24),border:Border.all(color:Brand.mint.withOpacity(.20))),
      child: Column(children:[
        Row(children:[const Icon(Icons.mic_rounded,color:Brand.mint),const SizedBox(width:9),const Expanded(child:Text('Escucha · repite · descubre',style:TextStyle(color:Brand.white,fontWeight:FontWeight.w900,fontSize:15))),Text('${index+1}/${vocab.length}',style:const TextStyle(color:Colors.white38,fontWeight:FontWeight.w800))]),
        const SizedBox(height:18),
        GestureDetector(onTap:()=>widget.onSpeak(item.english as String),child:Container(width:76,height:76,decoration:BoxDecoration(shape:BoxShape.circle,color:Brand.mint.withOpacity(.12),border:Border.all(color:Brand.mint.withOpacity(.4),width:2)),child:const Icon(Icons.volume_up_rounded,color:Brand.mint,size:34))),
        const SizedBox(height:12),
        Text(item.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Brand.white,fontSize:23,fontWeight:FontWeight.w900)),
        const SizedBox(height:10),
        AnimatedSwitcher(duration:const Duration(milliseconds:180),child:revealed?Text(item.spanish as String,key:ValueKey(index),textAlign:TextAlign.center,style:const TextStyle(color:Brand.mint,fontSize:15,fontWeight:FontWeight.w800)):TextButton.icon(onPressed:()=>setState(()=>revealed=true),icon:const Icon(Icons.visibility_rounded),label:const Text('Mostrar significado'))),
        const SizedBox(height:8),
        Row(children:[
          Expanded(child:OutlinedButton.icon(onPressed:()=>widget.onSpeak(item.english as String),icon:const Icon(Icons.replay_rounded),label:const Text('Escuchar'))),
          const SizedBox(width:8),
          Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:Brand.mint,foregroundColor:const Color(0xFF07182A)),onPressed:(){setState((){index=(index+1)%vocab.length;revealed=false;});},icon:const Icon(Icons.arrow_forward_rounded),label:const Text('Siguiente'))),
        ])
      ]),
    );
  }
}

class _OfficialMaterialCard extends StatelessWidget {
  final String content;
  final bool compact;

  const _OfficialMaterialCard({
    required this.content,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          iconColor: Brand.mint,
          collapsedIconColor: Brand.mint,
          title: const Row(
            children: [
              Icon(Icons.library_books_rounded, color: Brand.mint, size: 20),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Material oficial completo',
                  style: TextStyle(color: Brand.white, fontWeight: FontWeight.w900, fontSize: 14.5),
                ),
              ),
            ],
          ),
          subtitle: Text(
            'Consulta aquí el contenido íntegro de la lección usado como fuente.',
            style: TextStyle(color: Brand.white.withOpacity(0.52), fontSize: 12.2),
          ),
          children: [
            SelectableText(
              content.trim(),
              style: TextStyle(
                color: Brand.white.withOpacity(0.70),
                fontSize: 12.5,
                height: 1.50,
              ),
            ),
          ],
        ),
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
            'Superar la evaluación final con mínimo 80 puntos.',
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
  final bool practiceMode;
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
    required this.practiceMode,
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
          children: practiceMode
              ? const [
                  _GamePill(
                    icon: Icons.school_rounded,
                    value: 'Práctica guiada · sin nota',
                    color: Brand.mint,
                  ),
                ]
              : [
                  const _GamePill(
                    icon: Icons.verified_rounded,
                    value: 'Evaluación final',
                    color: Brand.mint,
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
  final bool speechAvailable;
  final bool speechListening;
  final String speechTranscript;
  final EnglishSpeechAttempt? speechAttempt;
  final VoidCallback onSpeak;

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
    required this.speechAvailable,
    required this.speechListening,
    required this.speechTranscript,
    required this.speechAttempt,
    required this.onSpeak,
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
          if (activity.type == EnglishActivityType.listenChoice ||
              activity.type == EnglishActivityType.speakAnswer) ...[
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

      case EnglishActivityType.speakAnswer:
        final attempt = speechAttempt;
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Brand.bgDeep.withOpacity(.42),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Brand.mint.withOpacity(.18)),
              ),
              child: Column(
                children: [
                  Text(
                    activity.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Brand.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Escucha, repite y busca que la frase se entienda con claridad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Brand.white.withOpacity(.56),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPlayAudio,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Escuchar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: answered || !speechAvailable ? null : onSpeak,
                    style: FilledButton.styleFrom(
                      backgroundColor: speechListening ? Colors.redAccent : Brand.mint,
                      foregroundColor: Brand.bgDeep,
                    ),
                    icon: Icon(speechListening ? Icons.stop_rounded : Icons.mic_rounded),
                    label: Text(speechListening ? 'Detener' : 'Hablar'),
                  ),
                ),
              ],
            ),
            if (!speechAvailable) ...[
              const SizedBox(height: 10),
              Text(
                'El reconocimiento de voz no está disponible en este dispositivo. Esta actividad no bloqueará tu práctica.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Brand.white.withOpacity(.46),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (speechTranscript.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Brand.bgDeep.withOpacity(.38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EL TELÉFONO ENTENDIÓ', style: TextStyle(color: Brand.white.withOpacity(.42), fontSize: 10, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(speechTranscript, style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w900)),
                    if (attempt != null) ...[
                      const SizedBox(height: 9),
                      Text('Claridad ${attempt.score}/100', style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900)),
                      if (attempt.missedWords.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Repite: ${attempt.missedWords.join(', ')}', style: TextStyle(color: Brand.white.withOpacity(.58), fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ],
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
      EnglishSkill.speaking => 'Pronunciación',
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

// -----------------------------------------------------------------------------
// Learning Studio V3
// Convierte el contenido curricular en micro-experiencias. El PDF nunca se
// muestra como texto crudo: funciona únicamente como fuente editorial.
// -----------------------------------------------------------------------------
class _LearningStudioV3 extends StatefulWidget {
  final EnglishLesson lesson;
  final List<dynamic> items;
  final bool compact;
  final int stage;
  final int activeIndex;
  final Set<int> revealed;
  final ValueChanged<int> onStageChanged;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<int> onReveal;
  final Future<void> Function(String text) onSpeak;

  const _LearningStudioV3({
    required this.lesson,
    required this.items,
    required this.compact,
    required this.stage,
    required this.activeIndex,
    required this.revealed,
    required this.onStageChanged,
    required this.onIndexChanged,
    required this.onReveal,
    required this.onSpeak,
  });

  @override
  State<_LearningStudioV3> createState() => _LearningStudioV3State();
}

class _LearningStudioV3State extends State<_LearningStudioV3> {
  int _heard = 0;
  int _sceneStep = 0;

  dynamic get _current => widget.items.isEmpty
      ? null
      : widget.items[widget.activeIndex.clamp(0, widget.items.length - 1).toInt()];

  @override
  Widget build(BuildContext context) {
    final stages = <(String, IconData)>[
      ('Descubre', Icons.visibility_rounded),
      ('Escucha', Icons.headphones_rounded),
      ('Interactúa', Icons.touch_app_rounded),
      ('Úsalo', Icons.forum_rounded),
    ];

    return Container(
      padding: EdgeInsets.all(widget.compact ? 15 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2237),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Brand.mint.withOpacity(.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Brand.mint.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Brand.mint),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STUDIO DE APRENDIZAJE', style: TextStyle(color: Brand.mint, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    SizedBox(height: 3),
                    Text('Aprende haciendo, no leyendo', style: TextStyle(color: Brand.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: List.generate(stages.length, (index) {
              final active = widget.stage == index;
              final done = widget.stage > index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == stages.length - 1 ? 0 : 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => widget.onStageChanged(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        color: active ? Brand.mint.withOpacity(.15) : Brand.white.withOpacity(.035),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: active ? Brand.mint.withOpacity(.42) : Brand.white.withOpacity(.06)),
                      ),
                      child: Column(
                        children: [
                          Icon(done ? Icons.check_circle_rounded : stages[index].$2, color: active || done ? Brand.mint : Brand.white.withOpacity(.38), size: 18),
                          const SizedBox(height: 5),
                          Text(stages[index].$1, textAlign: TextAlign.center, style: TextStyle(color: active ? Brand.white : Brand.white.withOpacity(.48), fontSize: 10.4, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: switch (widget.stage) {
              0 => _discover(),
              1 => _listen(),
              2 => _interactiveScene(),
              _ => _useIt(),
            },
          ),
        ],
      ),
    );
  }

  Widget _discover() {
    if (_current == null) return _empty();
    final idx = widget.activeIndex.clamp(0, widget.items.length - 1).toInt();
    final revealed = widget.revealed.contains(idx);
    return Column(
      key: const ValueKey('discover'),
      children: [
        Text('Descubre una expresión a la vez', style: TextStyle(color: Brand.white.withOpacity(.62), fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => widget.onReveal(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: widget.compact ? 24 : 31),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Brand.mint.withOpacity(.13), const Color(0xFF132C45)]),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: revealed ? Brand.mint.withOpacity(.45) : Brand.white.withOpacity(.08)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => widget.onSpeak(_current.english as String),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(width: 52, height: 52, decoration: BoxDecoration(color: Brand.mint.withOpacity(.14), shape: BoxShape.circle), child: const Icon(Icons.volume_up_rounded, color: Brand.mint)),
                ),
                const SizedBox(height: 13),
                Text(_current.english as String, textAlign: TextAlign.center, style: TextStyle(color: Brand.white, fontSize: widget.compact ? 24 : 28, fontWeight: FontWeight.w900, letterSpacing: -.5)),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: revealed
                      ? Text(_current.spanish as String, key: const ValueKey('revealed'), textAlign: TextAlign.center, style: const TextStyle(color: Brand.mint, fontSize: 15, fontWeight: FontWeight.w800))
                      : Row(key: const ValueKey('hidden'), mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.touch_app_rounded, size: 16, color: Brand.white.withOpacity(.42)), const SizedBox(width: 6), Text('Toca para descubrir el significado', style: TextStyle(color: Brand.white.withOpacity(.45), fontSize: 12.2, fontWeight: FontWeight.w700))]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: idx > 0 ? () => widget.onIndexChanged(idx - 1) : null, child: const Text('Anterior'))),
            const SizedBox(width: 9),
            Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep), onPressed: idx < widget.items.length - 1 ? () => widget.onIndexChanged(idx + 1) : () => widget.onStageChanged(1), child: Text(idx < widget.items.length - 1 ? 'Siguiente' : 'Ir a escuchar', style: const TextStyle(fontWeight: FontWeight.w900)))),
          ],
        ),
      ],
    );
  }

  Widget _listen() {
    final samples = widget.items.take(4).toList();
    return Column(
      key: const ValueKey('listen'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Entrena el oído', style: TextStyle(color: Brand.white.withOpacity(.62), fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (int i = 0; i < samples.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () async {
                await widget.onSpeak(samples[i].english as String);
                if (mounted) setState(() => _heard = math.max(_heard, i + 1));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(color: Brand.white.withOpacity(.04), borderRadius: BorderRadius.circular(17), border: Border.all(color: i < _heard ? Brand.mint.withOpacity(.34) : Brand.white.withOpacity(.07))),
                child: Row(children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(color: Brand.mint.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(i < _heard ? Icons.check_rounded : Icons.play_arrow_rounded, color: Brand.mint)),
                  const SizedBox(width: 11),
                  Expanded(child: Text(i < _heard ? samples[i].english as String : 'Escuchar expresión ${i + 1}', style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w800, fontSize: 13.5))),
                  if (i < _heard) Text(samples[i].spanish as String, style: TextStyle(color: Brand.white.withOpacity(.43), fontSize: 11.5)),
                ]),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _heard >= math.min(3, samples.length) ? Brand.mint : Brand.white.withOpacity(.08), foregroundColor: _heard >= math.min(3, samples.length) ? Brand.bgDeep : Brand.white.withOpacity(.45)),
            onPressed: _heard >= math.min(3, samples.length) ? () => widget.onStageChanged(2) : null,
            icon: const Icon(Icons.touch_app_rounded),
            label: const Text('Pasar a interactuar', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  Widget _interactiveScene() {
    return Column(
      key: const ValueKey('interactive'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Toca, mueve y relaciona', style: TextStyle(color: Brand.white.withOpacity(.62), fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _lessonVisual(widget.lesson.number),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep), onPressed: () => widget.onStageChanged(3), icon: const Icon(Icons.forum_rounded), label: const Text('Verlo en contexto', style: TextStyle(fontWeight: FontWeight.w900)))),
      ],
    );
  }

  Widget _useIt() {
    final prompts = widget.lesson.practicePrompts.isNotEmpty
        ? widget.lesson.practicePrompts.take(4).toList()
        : widget.lesson.learningGoals.take(4).toList();
    return Column(
      key: const ValueKey('use'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ahora úsalo en una situación', style: TextStyle(color: Brand.white.withOpacity(.62), fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFF132C45), borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              Row(children: [CircleAvatar(backgroundColor: Brand.mint.withOpacity(.15), child: const Icon(Icons.person_rounded, color: Brand.mint)), const SizedBox(width: 10), Expanded(child: Text(widget.lesson.title, style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w900, fontSize: 15)))]),
              const SizedBox(height: 13),
              for (int i = 0; i < prompts.length; i++)
                Align(
                  alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _sceneStep = math.max(_sceneStep, i + 1)),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 240),
                      opacity: i <= _sceneStep ? 1 : .28,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 285),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                        decoration: BoxDecoration(color: i.isEven ? Brand.mint.withOpacity(.12) : Brand.white.withOpacity(.06), borderRadius: BorderRadius.circular(15)),
                        child: Text(prompts[i], style: TextStyle(color: Brand.white.withOpacity(.83), fontSize: 12.4, height: 1.35, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('El juego de la lección viene ahora: ahí usarás estas ideas sin ver el material como una lista.', style: TextStyle(color: Brand.white.withOpacity(.46), fontSize: 11.8, height: 1.35)),
      ],
    );
  }

  Widget _lessonVisual(int lesson) {
    Widget card(Widget child) => Container(height: widget.compact ? 170 : 195, width: double.infinity, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF142E48), Color(0xFF10263B)]), borderRadius: BorderRadius.circular(23), border: Border.all(color: Brand.mint.withOpacity(.14))), child: child);
    final accent = Brand.mint;
    switch (lesson) {
      case 1: return card(Stack(children: [const Positioned(left: 28, top: 28, child: _MiniPerson(icon: Icons.person_rounded)), const Positioned(right: 28, bottom: 28, child: _MiniPerson(icon: Icons.person_outline_rounded)), Positioned(left: 90, top: 35, child: _SpeechBubble(text: 'Hello! 👋', accent: accent)), Positioned(right: 78, bottom: 38, child: _SpeechBubble(text: 'Nice to meet you!', accent: accent))]));
      case 2: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Text('😄', style: TextStyle(fontSize: 48)), Text('😴', style: TextStyle(fontSize: 48)), Text('😟', style: TextStyle(fontSize: 48)), Text('😡', style: TextStyle(fontSize: 48))]));
      case 3: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['I','YOU','HE','SHE','IT'].map((e) => _TokenPill(text: e)).toList()));
      case 4: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icons.person_rounded, Icons.groups_2_rounded, Icons.groups_rounded].map((e) => Icon(e, color: accent, size: 56)).toList()));
      case 5: return card(Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('I   •   SHE   •   THEY', style: TextStyle(color: Brand.white, fontWeight: FontWeight.w900)), const SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.center, children: ['AM','IS','ARE'].map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: _TokenPill(text: e))).toList())]));
      case 6: return card(Center(child: Icon(Icons.fingerprint_rounded, color: accent, size: 96)));
      case 7: return card(GridView.count(padding: const EdgeInsets.all(20), physics: const NeverScrollableScrollPhysics(), crossAxisCount: 5, children: List.generate(10, (i) => Center(child: Text('${i+1}', style: TextStyle(color: i.isEven ? accent : Brand.white, fontSize: 22, fontWeight: FontWeight.w900))))));
      case 8: return card(Center(child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(18)), child: const Text('21 · 35 · 54 · 87', style: TextStyle(color: Brand.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 3)))));
      case 9: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple].map((c) => Container(width: 43, height: 43, decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(.25), blurRadius: 16)]))).toList()));
      case 10: return card(Center(child: Icon(Icons.account_tree_rounded, color: accent, size: 110)));
      case 11: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [_DoorVisual(label: 'A'), _DoorVisual(label: 'AN')]));
      case 12: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icons.pets_rounded, Icons.directions_car_rounded, Icons.menu_book_rounded].map((i) => Container(width: 64, height: 64, decoration: BoxDecoration(color: Brand.mint.withOpacity(.1), borderRadius: BorderRadius.circular(18)), child: Icon(i, color: accent, size: 34))).toList()));
      case 13: return card(Center(child: Icon(Icons.face_retouching_natural_rounded, color: accent, size: 110)));
      case 14: return card(Center(child: Stack(alignment: Alignment.center, children: [Icon(Icons.accessibility_new_rounded, color: Brand.white.withOpacity(.45), size: 130), Positioned(top: 26, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: accent.withOpacity(.55), shape: BoxShape.circle))) ])));
      case 15: return card(Center(child: Stack(alignment: Alignment.center, children: [Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 5))), const Icon(Icons.schedule_rounded, color: Brand.white, size: 88)])));
      case 16: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icons.sports_soccer_rounded, Icons.sports_tennis_rounded, Icons.pool_rounded].map((i) => Icon(i, color: accent, size: 50)).toList()));
      case 17: return card(Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 28), child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [40.0,70.0,105.0].map((h) => Container(width: 50,height:h,margin:const EdgeInsets.symmetric(horizontal:6),decoration:BoxDecoration(color:accent.withOpacity(.18+h/800),borderRadius:BorderRadius.circular(12)))).toList()))));
      case 18: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icons.shopping_basket_rounded, Icons.water_drop_rounded].map((i) => Icon(i, color: accent, size: 72)).toList()));
      case 19: return card(Center(child: Icon(Icons.celebration_rounded, color: accent, size: 100)));
      case 20: return card(const Center(child: Text('🐶  🐱  🐰  🐦', style: TextStyle(fontSize: 47))));
      case 21: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Text('🌅', style: TextStyle(fontSize: 40)), Icon(Icons.arrow_forward_rounded, color: Brand.white), Text('🏫', style: TextStyle(fontSize: 40)), Icon(Icons.arrow_forward_rounded, color: Brand.white), Text('🌙', style: TextStyle(fontSize: 40))]));
      case 22: return card(Center(child: Icon(Icons.airplane_ticket_rounded, color: accent, size: 110)));
      case 23: return card(const Center(child: Text('☕  🥛  🍞  🍳', style: TextStyle(fontSize: 44))));
      case 24: return card(const Center(child: Text('🍎  🍓  🍌  🍊', style: TextStyle(fontSize: 47))));
      case 25: return card(const Center(child: Text('🥕  🥦  🌽  🍅', style: TextStyle(fontSize: 47))));
      case 26: return card(Center(child: Icon(Icons.shopping_cart_checkout_rounded, color: accent, size: 110)));
      case 27: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icons.medical_services_rounded, Icons.engineering_rounded, Icons.school_rounded].map((i) => Icon(i, color: accent, size: 50)).toList()));
      case 28: return card(Center(child: Icon(Icons.public_rounded, color: accent, size: 115)));
      case 29: return card(GridView.count(padding: const EdgeInsets.all(25), physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, children: [Icons.local_hospital,Icons.park,Icons.school,Icons.home,Icons.store,Icons.directions_bus].map((i)=>Icon(i,color:accent.withOpacity(.8),size:34)).toList()));
      case 30: return card(Stack(children: [Positioned(left:25,bottom:25,child:Icon(Icons.bed_rounded,color:accent,size:60)),const Positioned(right:25,bottom:25,child:Icon(Icons.chair_rounded,color:Brand.white,size:48)),const Positioned(right:80,top:25,child:Icon(Icons.light_rounded,color:Brand.white,size:34))]));
      case 31: return card(Center(child: Icon(Icons.directions_run_rounded, color: accent, size: 110)));
      case 32: return card(Stack(children:[const Positioned(left:30,bottom:25,child:Icon(Icons.chair_alt_rounded,color:Brand.white,size:60)),Positioned(left:50,bottom:78,child:Icon(Icons.circle,color:accent,size:24)),const Positioned(right:30,bottom:25,child:Icon(Icons.table_restaurant_rounded,color:Brand.white,size:66))]));
      case 33: return card(Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius:34,backgroundColor:accent.withOpacity(.13),child:Icon(Icons.person,color:accent,size:38)),const SizedBox(width:18),Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Brand.white.withOpacity(.06),borderRadius:BorderRadius.circular(17)),child:const Text('What is your job?',style:TextStyle(color:Brand.white,fontWeight:FontWeight.w800))) ]));
      case 34: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:['MY','YOUR','HIS','HER'].map((e)=>_TokenPill(text:e)).toList()));
      case 35: return card(Row(crossAxisAlignment:CrossAxisAlignment.end,mainAxisAlignment:MainAxisAlignment.center,children:[32.0,52.0,78.0,104.0].map((s)=>Container(width:s/1.5,height:s,margin:const EdgeInsets.symmetric(horizontal:5),decoration:BoxDecoration(color:accent.withOpacity(.18+s/180),borderRadius:BorderRadius.circular(10)))).toList()));
      case 36: return card(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:['MON','TUE','WED','THU','FRI'].map((d)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:14),decoration:BoxDecoration(color:accent.withOpacity(.1),borderRadius:BorderRadius.circular(12)),child:Text(d,style:const TextStyle(color:Brand.white,fontSize:10,fontWeight:FontWeight.w900)))).toList()));
      default: return card(Center(child: Icon(Icons.auto_awesome_rounded, color: accent, size: 90)));
    }
  }

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Contenido interactivo en preparación.', style: TextStyle(color: Brand.white.withOpacity(.6)))));
}

class _MiniPerson extends StatelessWidget {
  final IconData icon;
  const _MiniPerson({required this.icon});
  @override
  Widget build(BuildContext context) => Container(width: 66, height: 66, decoration: BoxDecoration(color: Brand.mint.withOpacity(.12), shape: BoxShape.circle), child: Icon(icon, color: Brand.mint, size: 38));
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  final Color accent;
  const _SpeechBubble({required this.text, required this.accent});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withOpacity(.18))), child: Text(text, style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w800, fontSize: 11.5)));
}

class _TokenPill extends StatelessWidget {
  final String text;
  const _TokenPill({required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10), decoration: BoxDecoration(color: Brand.mint.withOpacity(.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: Brand.mint.withOpacity(.22))), child: Text(text, style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900, fontSize: 11)));
}

class _DoorVisual extends StatelessWidget {
  final String label;
  const _DoorVisual({required this.label});
  @override
  Widget build(BuildContext context) => Container(width: 82, height: 120, decoration: BoxDecoration(color: Brand.mint.withOpacity(.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(42)), border: Border.all(color: Brand.mint.withOpacity(.35), width: 2)), alignment: Alignment.center, child: Text(label, style: const TextStyle(color: Brand.mint, fontSize: 27, fontWeight: FontWeight.w900)));
}


// =============================================================================
// LESSON OVERVIEW V4 — compact, premium, interactive
// =============================================================================

class _LessonCompactHeader extends StatelessWidget {
  final EnglishLesson lesson;
  final bool compact;
  final double progress;
  final int vocabularyCount;
  final String? gameTitle;
  final bool practiceCompleted;

  const _LessonCompactHeader({
    required this.lesson,
    required this.compact,
    required this.progress,
    required this.vocabularyCount,
    required this.gameTitle,
    required this.practiceCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = lesson.learningGoals.isNotEmpty
        ? lesson.learningGoals.first
        : lesson.summary;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132B43), Color(0xFF0D1F33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.mint.withOpacity(.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 46 : 50,
                height: compact ? 46 : 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Brand.mint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  lesson.paddedNumber,
                  style: const TextStyle(
                    color: Brand.bgDeep,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LECCIÓN ${lesson.paddedNumber}',
                      style: TextStyle(
                        color: Brand.mint.withOpacity(.90),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .9,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Brand.white,
                        fontSize: compact ? 21 : 24,
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                        letterSpacing: -.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Brand.white.withOpacity(.66),
              fontSize: compact ? 12.5 : 13.2,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ProgressLine(value: progress),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Brand.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _HeaderMetaChip(
                icon: Icons.translate_rounded,
                label: '$vocabularyCount conceptos',
              ),
              if (gameTitle != null)
                _HeaderMetaChip(
                  icon: Icons.sports_esports_rounded,
                  label: gameTitle!,
                ),
              _HeaderMetaChip(
                icon: practiceCompleted
                    ? Icons.check_circle_rounded
                    : Icons.verified_rounded,
                label: practiceCompleted
                    ? 'Práctica lista'
                    : 'Evaluación 80%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Brand.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Brand.white.withOpacity(.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Brand.mint, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Brand.white.withOpacity(.72),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonStepper extends StatelessWidget {
  final int learningStage;
  final bool gameCompleted;
  final bool practiceCompleted;

  const _LessonStepper({
    required this.learningStage,
    required this.gameCompleted,
    required this.practiceCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final current = practiceCompleted
        ? 3
        : gameCompleted
            ? 2
            : 0;

    const labels = ['Aprender', 'Jugar', 'Practicar', 'Evaluar'];
    const icons = [
      Icons.auto_awesome_rounded,
      Icons.sports_esports_rounded,
      Icons.school_rounded,
      Icons.verified_rounded,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2034).withOpacity(.92),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Brand.white.withOpacity(.07)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final complete = index < current;
          final active = index == current;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: active || complete
                              ? Brand.mint
                              : Brand.white.withOpacity(.055),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active || complete
                                ? Brand.mint
                                : Brand.white.withOpacity(.08),
                          ),
                        ),
                        child: Icon(
                          complete ? Icons.check_rounded : icons[index],
                          size: 17,
                          color: active || complete
                              ? Brand.bgDeep
                              : Brand.white.withOpacity(.35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: active
                              ? Brand.white
                              : Brand.white.withOpacity(.44),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != labels.length - 1)
                  Container(
                    width: 12,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 22),
                    color: index < current
                        ? Brand.mint.withOpacity(.70)
                        : Brand.white.withOpacity(.07),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LessonChallengePreview extends StatelessWidget {
  final EnglishLessonGameConfig config;
  final bool compact;
  final bool completed;

  const _LessonChallengePreview({
    required this.config,
    required this.compact,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 15 : 17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.accent.withOpacity(.16),
            const Color(0xFF102337),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: config.accent.withOpacity(.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              completed ? Icons.check_rounded : config.icon,
              color: const Color(0xFF07111F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed ? 'RETO COMPLETADO' : 'RETO DE LA LECCIÓN',
                  style: TextStyle(
                    color: config.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  config.title,
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  config.mission,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white.withOpacity(.55),
                    fontSize: 11.7,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
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

class _LearningStudioV4 extends StatefulWidget {
  final EnglishLesson lesson;
  final List<dynamic> items;
  final bool compact;
  final int stage;
  final int activeIndex;
  final Set<int> revealed;
  final ValueChanged<int> onStageChanged;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<int> onReveal;
  final Future<void> Function(String text) onSpeak;

  const _LearningStudioV4({
    required this.lesson,
    required this.items,
    required this.compact,
    required this.stage,
    required this.activeIndex,
    required this.revealed,
    required this.onStageChanged,
    required this.onIndexChanged,
    required this.onReveal,
    required this.onSpeak,
  });

  @override
  State<_LearningStudioV4> createState() => _LearningStudioV4State();
}

class _LearningStudioV4State extends State<_LearningStudioV4> {
  String? _selectedMeaning;
  int _listeningIndex = 0;
  bool _listeningRevealed = false;

  dynamic get _current {
    if (widget.items.isEmpty) return null;
    final safe = widget.activeIndex.clamp(0, widget.items.length - 1).toInt();
    return widget.items[safe];
  }

  @override
  Widget build(BuildContext context) {
    const tabs = <(String, IconData)>[
      ('Descubre', Icons.visibility_rounded),
      ('Escucha', Icons.headphones_rounded),
      ('Interactúa', Icons.touch_app_rounded),
      ('Úsalo', Icons.chat_bubble_rounded),
    ];

    return Container(
      padding: EdgeInsets.all(widget.compact ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2136),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.mint.withOpacity(.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Brand.mint.withOpacity(.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Brand.mint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNING STUDIO',
                      style: TextStyle(
                        color: Brand.mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .9,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Una idea. Una acción. Una recompensa.',
                      style: TextStyle(
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
          const SizedBox(height: 13),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final active = widget.stage == index;
                final done = widget.stage > index;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == tabs.length - 1 ? 0 : 7,
                  ),
                  child: InkWell(
                    onTap: () => widget.onStageChanged(index),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Brand.mint
                            : Brand.white.withOpacity(.045),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? Brand.mint
                              : Brand.white.withOpacity(.07),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            done ? Icons.check_rounded : tabs[index].$2,
                            size: 15,
                            color: active
                                ? Brand.bgDeep
                                : done
                                    ? Brand.mint
                                    : Brand.white.withOpacity(.44),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[index].$1,
                            style: TextStyle(
                              color: active
                                  ? Brand.bgDeep
                                  : Brand.white.withOpacity(.64),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (widget.stage) {
              0 => _discover(),
              1 => _listen(),
              2 => _interact(),
              _ => _context(),
            },
          ),
        ],
      ),
    );
  }

  Widget _discover() {
    if (_current == null) return _empty();

    final safe = widget.activeIndex
        .clamp(0, widget.items.length - 1)
        .toInt();
    final revealed = widget.revealed.contains(safe);

    return Column(
      key: const ValueKey('v4-discover'),
      children: [
        Row(
          children: [
            Text(
              'Expresión ${safe + 1} de ${widget.items.length}',
              style: TextStyle(
                color: Brand.white.withOpacity(.48),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.revealed.length} descubiertas',
              style: const TextStyle(
                color: Brand.mint,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => widget.onReveal(safe),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: widget.compact ? 23 : 28,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Brand.mint.withOpacity(.11),
                  const Color(0xFF132B43),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: revealed
                    ? Brand.mint.withOpacity(.38)
                    : Brand.white.withOpacity(.07),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => widget.onSpeak(_current.english as String),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Brand.mint.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Brand.mint,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _current.english as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: widget.compact ? 23 : 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.45,
                  ),
                ),
                const SizedBox(height: 9),
                if (revealed)
                  Text(
                    _current.spanish as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Brand.mint,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Brand.white.withOpacity(.34),
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Toca para descubrir',
                        style: TextStyle(
                          color: Brand.white.withOpacity(.38),
                          fontSize: 11.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: safe > 0
                    ? () => widget.onIndexChanged(safe - 1)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: const Text('Anterior'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Brand.mint,
                  foregroundColor: Brand.bgDeep,
                ),
                onPressed: safe < widget.items.length - 1
                    ? () => widget.onIndexChanged(safe + 1)
                    : () => widget.onStageChanged(1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: Text(
                  safe < widget.items.length - 1
                      ? 'Siguiente'
                      : 'Escuchar',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _listen() {
    if (widget.items.isEmpty) return _empty();

    final safe = _listeningIndex
        .clamp(0, widget.items.length - 1)
        .toInt();
    final item = widget.items[safe];

    return Column(
      key: const ValueKey('v4-listen'),
      children: [
        Text(
          'Escucha antes de leer',
          style: TextStyle(
            color: Brand.white.withOpacity(.55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        InkWell(
          onTap: () async {
            await widget.onSpeak(item.english as String);
            if (mounted) {
              setState(() => _listeningRevealed = true);
            }
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Brand.mint,
              shape: BoxShape.circle,
              boxShadow: Brand.glowMint,
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Brand.bgDeep,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: 13),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _listeningRevealed
              ? Column(
                  key: ValueKey('heard-$safe'),
                  children: [
                    Text(
                      item.english as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Brand.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.spanish as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Brand.mint,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Toca el audio y trata de reconocer la expresión.',
                  key: const ValueKey('listen-hidden'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Brand.white.withOpacity(.46),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Brand.mint,
              foregroundColor: Brand.bgDeep,
            ),
            onPressed: () {
              if (safe < widget.items.length - 1) {
                setState(() {
                  _listeningIndex = safe + 1;
                  _listeningRevealed = false;
                });
              } else {
                widget.onStageChanged(2);
              }
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              safe < widget.items.length - 1
                  ? 'Otra expresión'
                  : 'Pasar a interactuar',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _interact() {
    if (_current == null) return _empty();

    final correct = _current.spanish as String;
    final pool = <String>[
      correct,
      ...widget.items
          .where((e) => e.spanish != correct)
          .map((e) => e.spanish as String)
          .take(3),
    ]..shuffle();

    final chosen = _selectedMeaning;

    return Column(
      key: const ValueKey('v4-interact'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprueba la idea',
          style: TextStyle(
            color: Brand.white.withOpacity(.55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '¿Qué significa “${_current.english}”?',
          style: const TextStyle(
            color: Brand.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 13),

        for (final option in pool)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedMeaning = option),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: chosen == option
                      ? Brand.mint.withOpacity(.13)
                      : Brand.white.withOpacity(.035),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chosen == option
                        ? Brand.mint.withOpacity(.55)
                        : Brand.white.withOpacity(.06),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      chosen == option
                          ? Icons.radio_button_checked_rounded
                          : Icons.circle_outlined,
                      color: chosen == option
                          ? Brand.mint
                          : Brand.white.withOpacity(.28),
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          color: Brand.white,
                          fontSize: 12.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (chosen != null) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (chosen == correct ? Brand.mint : Colors.redAccent)
                  .withOpacity(.09),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: (chosen == correct ? Brand.mint : Colors.redAccent)
                    .withOpacity(.30),
              ),
            ),
            child: Text(
              chosen == correct
                  ? '¡Exacto! Ya reconoces esta expresión.'
                  : 'Casi. La respuesta correcta es: $correct',
              style: const TextStyle(
                color: Brand.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Brand.mint,
              foregroundColor: Brand.bgDeep,
            ),
            onPressed: chosen == correct
                ? () => widget.onStageChanged(3)
                : null,
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text(
              'Usarlo en contexto',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _context() {
    final prompts = widget.lesson.practicePrompts.isNotEmpty
        ? widget.lesson.practicePrompts.take(3).toList()
        : widget.lesson.learningGoals.take(3).toList();

    return Column(
      key: const ValueKey('v4-context'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Úsalo en contexto',
          style: TextStyle(
            color: Brand.white.withOpacity(.55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF132B43),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Brand.white.withOpacity(.06)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Brand.mint.withOpacity(.14),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Brand.mint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      widget.lesson.title,
                      style: const TextStyle(
                        color: Brand.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < prompts.length; i++)
                Align(
                  alignment:
                      i.isEven ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? Brand.mint.withOpacity(.11)
                          : Brand.white.withOpacity(.055),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      prompts[i],
                      style: TextStyle(
                        color: Brand.white.withOpacity(.82),
                        fontSize: 11.8,
                        height: 1.32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Cuando estés listo, entra al reto de la lección y usa lo aprendido.',
          style: TextStyle(
            color: Brand.white.withOpacity(.43),
            fontSize: 11.4,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Text(
          'Contenido interactivo en preparación.',
          style: TextStyle(
            color: Brand.white.withOpacity(.50),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

