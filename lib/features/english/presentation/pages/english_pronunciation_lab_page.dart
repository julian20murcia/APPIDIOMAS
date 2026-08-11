import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/theme/brand.dart';
import '../../data/english_level_1_curriculum.dart';
import '../../models/english_lesson.dart';
import '../../services/english_pronunciation_progress_service.dart';
import '../../services/english_speech_service.dart';

class EnglishPronunciationLabPage extends StatefulWidget {
  final EnglishLesson lesson;

  const EnglishPronunciationLabPage({
    super.key,
    required this.lesson,
  });

  @override
  State<EnglishPronunciationLabPage> createState() =>
      _EnglishPronunciationLabPageState();
}

class _EnglishPronunciationLabPageState
    extends State<EnglishPronunciationLabPage>
    with SingleTickerProviderStateMixin {
  final _speech = EnglishSpeechService.instance;
  final _tts = FlutterTts();
  final _progressService = EnglishPronunciationProgressService();

  late final AnimationController _pulse;
  late final List<dynamic> _targets;

  int _index = 0;
  int _attemptCount = 0;
  bool _initializing = true;
  bool _available = false;
  bool _listening = false;
  bool _playing = false;
  bool _completed = false;
  String _transcript = '';
  double _confidence = 0;
  EnglishSpeechAttempt? _attempt;
  final Map<int, int> _bestScores = <int, int>{};
  Timer? _finishTimer;

  dynamic get current => _targets[_index];

  int get average {
    if (_bestScores.isEmpty) return 0;
    return (_bestScores.values.reduce((a, b) => a + b) / _bestScores.length)
        .round();
  }

  int get practicedCount => _bestScores.length;

  @override
  void initState() {
    super.initState();
    final vocabulary = englishLevel1Vocabulary[widget.lesson.number] ?? const [];
    _targets = vocabulary.take(5).toList();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat(reverse: true);
    _configure();
  }

  Future<void> _configure() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(.38);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _playing = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _playing = false);
    });

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        final active = status == 'listening';
        if (_listening != active) setState(() => _listening = active);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _listening = false);
      },
    );

    if (!mounted) return;
    setState(() {
      _available = available;
      _initializing = false;
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _speech.stop();
    _tts.stop();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _playReference() async {
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(current.english as String);
  }

  Future<void> _toggleListening() async {
    if (!_available) {
      _showMessage(
        'El reconocimiento de voz no está disponible. Revisa el permiso del micrófono o prueba en un dispositivo físico.',
      );
      return;
    }

    if (_speech.isListening || _listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      _finalizeAttempt();
      return;
    }

    await _tts.stop();
    setState(() {
      _attempt = null;
      _transcript = '';
      _confidence = 0;
      _listening = true;
    });

    await _speech.listen(
      localeId: 'en_US',
      onResult: (words, finalResult, confidence) {
        if (!mounted) return;
        setState(() {
          _transcript = words;
          _confidence = confidence;
        });
        if (finalResult) {
          setState(() => _listening = false);
          _finalizeAttempt();
        }
      },
    );
  }

  void _finalizeAttempt() {
    if (_transcript.trim().isEmpty) return;
    final evaluated = _speech.evaluate(
      target: current.english as String,
      transcript: _transcript,
      recognitionConfidence: _confidence,
    );
    setState(() {
      _attemptCount += 1;
      _attempt = evaluated;
      final previous = _bestScores[_index] ?? 0;
      if (evaluated.score > previous) _bestScores[_index] = evaluated.score;
    });
  }

  Future<void> _next() async {
    if (_attempt == null) {
      _showMessage('Primero intenta decir la frase en voz alta.');
      return;
    }
    if (_index < _targets.length - 1) {
      setState(() {
        _index += 1;
        _attempt = null;
        _transcript = '';
        _confidence = 0;
      });
      return;
    }

    final saved = await _progressService.save(
      lessonNumber: widget.lesson.number,
      average: average,
      attempts: _attemptCount,
      completed: true,
    );

    if (!mounted) return;
    setState(() => _completed = true);
    _finishTimer = Timer(const Duration(milliseconds: 250), () {});

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PronunciationResultSheet(
        average: saved.bestAverage,
        attempts: _attemptCount,
        onFinish: () {
          Navigator.of(context).pop();
          Navigator.of(this.context).pop(<String, dynamic>{
            'completed': true,
            'score': saved.bestAverage,
            'attempts': _attemptCount,
          });
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF11263D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targets.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF07182A),
        body: SafeArea(
          child: Center(
            child: Text(
              'Esta lección no tiene frases disponibles para pronunciación.',
              style: TextStyle(color: Brand.white.withOpacity(.8)),
            ),
          ),
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).height < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF07182A),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, compact ? 10 : 16, 18, 30),
                children: [
                  _hero(compact),
                  const SizedBox(height: 14),
                  _targetCard(compact),
                  const SizedBox(height: 14),
                  _microphoneCard(compact),
                  if (_attempt != null) ...[
                    const SizedBox(height: 14),
                    _feedbackCard(_attempt!),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _attempt == null || _completed ? null : _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: Brand.mint,
                        foregroundColor: Brand.bgDeep,
                        disabledBackgroundColor: Brand.white.withOpacity(.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: Icon(
                        _index == _targets.length - 1
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _index == _targets.length - 1
                            ? 'Terminar laboratorio oral'
                            : 'Siguiente frase',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (_index + 1) / _targets.length,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(Brand.mint),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_index + 1}/${_targets.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15314A), Color(0xFF0D2136)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.mint.withOpacity(.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Brand.mint,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: Brand.bgDeep,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SPEAK LAB',
                  style: TextStyle(
                    color: Brand.mint,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escucha. Repite. Mejora.',
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: compact ? 20 : 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La app escucha lo que dices y te ayuda a hacer la frase más clara.',
                  style: TextStyle(
                    color: Brand.white.withOpacity(.58),
                    fontSize: 12.4,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetCard(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 22),
      decoration: BoxDecoration(
        color: const Color(0xFF10263D),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            'DI ESTA FRASE',
            style: TextStyle(
              color: Brand.white.withOpacity(.40),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            current.english as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white,
              fontSize: compact ? 25 : 30,
              height: 1.17,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            current.spanish as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _playing ? null : _playReference,
            style: OutlinedButton.styleFrom(
              foregroundColor: Brand.white,
              side: BorderSide(color: Brand.mint.withOpacity(.34)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(_playing ? Icons.graphic_eq_rounded : Icons.volume_up_rounded),
            label: Text(_playing ? 'Escuchando ejemplo...' : 'Escuchar pronunciación'),
          ),
        ],
      ),
    );
  }

  Widget _microphoneCard(bool compact) {
    final disabled = _initializing;
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2136),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _listening ? Brand.mint.withOpacity(.55) : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Text(
            _initializing
                ? 'Preparando micrófono...'
                : _listening
                    ? 'Te estoy escuchando...'
                    : _available
                        ? 'Toca el micrófono y repite la frase'
                        : 'Micrófono no disponible',
            style: TextStyle(
              color: Brand.white.withOpacity(.72),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              final scale = _listening ? 1 + .09 * _pulse.value : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: disabled ? null : _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _listening ? const Color(0xFFFF6B6B) : Brand.mint,
                  boxShadow: [
                    BoxShadow(
                      color: (_listening ? const Color(0xFFFF6B6B) : Brand.mint)
                          .withOpacity(.24),
                      blurRadius: _listening ? 30 : 20,
                      spreadRadius: _listening ? 7 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  _listening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Brand.bgDeep,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.035),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _transcript.isEmpty
                  ? 'Aquí aparecerá lo que entendió el teléfono.'
                  : 'Entendí: “$_transcript”',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _transcript.isEmpty
                    ? Brand.white.withOpacity(.35)
                    : Brand.white.withOpacity(.82),
                fontSize: 12.7,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(EnglishSpeechAttempt attempt) {
    final color = attempt.score >= 82
        ? const Color(0xFF4ADE80)
        : attempt.score >= 65
            ? const Color(0xFFF7CC69)
            : const Color(0xFFFF8B8B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(.28)),
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
                decoration: BoxDecoration(
                  color: color.withOpacity(.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${attempt.score}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  attempt.feedback,
                  style: const TextStyle(
                    color: Brand.white,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (attempt.missedWords.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              'Pon atención a:',
              style: TextStyle(
                color: Brand.white.withOpacity(.48),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: attempt.missedWords
                  .map(
                    (word) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _toggleListening,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Intentarlo otra vez'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PronunciationResultSheet extends StatelessWidget {
  final int average;
  final int attempts;
  final VoidCallback onFinish;

  const _PronunciationResultSheet({
    required this.average,
    required this.attempts,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final color = average >= 82
        ? const Color(0xFF4ADE80)
        : average >= 65
            ? const Color(0xFFF7CC69)
            : const Color(0xFFFF8B8B);
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        MediaQuery.paddingOf(context).bottom + 22,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D2136),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.record_voice_over_rounded, color: color, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'Laboratorio oral completado',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Mejor claridad promedio: $average/100 · $attempts intentos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Brand.white.withOpacity(.60), height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Esta puntuación mide qué tan bien pudo reconocer tu frase el dispositivo. No intenta juzgar tu acento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white.withOpacity(.42),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onFinish,
              style: FilledButton.styleFrom(
                backgroundColor: Brand.mint,
                foregroundColor: Brand.bgDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Continuar',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
