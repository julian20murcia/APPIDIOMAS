import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/theme/brand.dart';
import '../../data/english_level_1_curriculum.dart';
import '../../services/english_spaced_review_service.dart';

class EnglishDailyReviewPage extends StatefulWidget {
  final int completedLessons;

  const EnglishDailyReviewPage({
    super.key,
    required this.completedLessons,
  });

  @override
  State<EnglishDailyReviewPage> createState() => _EnglishDailyReviewPageState();
}

class _EnglishDailyReviewPageState extends State<EnglishDailyReviewPage> {
  final _service = EnglishSpacedReviewService();
  final _tts = FlutterTts();
  final _rng = math.Random();

  bool loading = true;
  bool answered = false;
  int index = 0;
  int correctCount = 0;
  String? selected;
  List<EnglishReviewCardState> cards = const [];
  List<String> options = const [];

  EnglishReviewCardState get card => cards[index];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(.42);
    _load();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final vocabulary = <({int lessonNumber, String english, String spanish})>[];
    for (var lesson = 1; lesson <= widget.completedLessons; lesson++) {
      final items = englishLevel1Vocabulary[lesson] ?? const [];
      for (final item in items) {
        vocabulary.add((
          lessonNumber: lesson,
          english: item.english as String,
          spanish: item.spanish as String,
        ));
      }
    }

    final due = await _service.syncAndGetDue(vocabulary: vocabulary);
    if (!mounted) return;
    setState(() {
      cards = due;
      loading = false;
    });
    if (due.isNotEmpty) _prepare();
  }

  void _prepare() {
    final distractors = cards
        .where((e) => e.id != card.id && e.spanish != card.spanish)
        .map((e) => e.spanish)
        .toList()
      ..shuffle(_rng);

    final fallback = <String>[];
    for (var lesson = 1; lesson <= widget.completedLessons; lesson++) {
      for (final item in englishLevel1Vocabulary[lesson] ?? const []) {
        final spanish = item.spanish as String;
        if (spanish != card.spanish && !fallback.contains(spanish)) fallback.add(spanish);
      }
    }
    fallback.shuffle(_rng);

    final pool = <String>{...distractors, ...fallback}.take(3).toList();
    options = <String>[card.spanish, ...pool]..shuffle(_rng);
    answered = false;
    selected = null;
  }

  Future<void> _answer(String value) async {
    if (answered) return;
    final correct = value == card.spanish;
    await _service.record(card, correct: correct);
    if (!mounted) return;
    setState(() {
      answered = true;
      selected = value;
      if (correct) correctCount += 1;
    });
  }

  void _next() {
    if (index >= cards.length - 1) {
      _showResult();
      return;
    }
    setState(() {
      index += 1;
      _prepare();
    });
  }

  Future<void> _showResult() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(22, 24, 22, MediaQuery.paddingOf(context).bottom + 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0D2136),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_alt_rounded, color: Brand.mint, size: 48),
            const SizedBox(height: 12),
            const Text('Repaso del día completado', style: TextStyle(color: Brand.white, fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text('$correctCount de ${cards.length} correctas. Las palabras se programaron automáticamente para volver cuando toque repasarlas.', textAlign: TextAlign.center, style: TextStyle(color: Brand.white.withOpacity(.58), height: 1.4)),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: () { Navigator.pop(context); Navigator.pop(this.context, true); }, style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep), child: const Text('Volver al curso', style: TextStyle(fontWeight: FontWeight.w900)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(backgroundColor: Color(0xFF07182A), body: Center(child: CircularProgressIndicator(color: Brand.mint)));
    }
    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF07182A),
        appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Brand.white, title: const Text('Repaso inteligente')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 58),
              const SizedBox(height: 14),
              const Text('Estás al día', style: TextStyle(color: Brand.white, fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('No tienes tarjetas pendientes ahora. El sistema las traerá de vuelta cuando sea buen momento para reforzarlas.', textAlign: TextAlign.center, style: TextStyle(color: Brand.white.withOpacity(.55), height: 1.4)),
            ]),
          ),
        ),
      );
    }

    final isListeningRound = index.isOdd;
    return Scaffold(
      backgroundColor: const Color(0xFF07182A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 16, 8),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white70)),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: (index + 1) / cards.length, minHeight: 8, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation(Brand.mint)))),
                const SizedBox(width: 12),
                Text('${index + 1}/${cards.length}', style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w900)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF17324B), Color(0xFF0E2135)]), borderRadius: BorderRadius.circular(26), border: Border.all(color: Brand.mint.withOpacity(.22))),
                    child: Column(children: [
                      Text('REPASO ESPACIADO · LECCIÓN ${card.lessonNumber}', style: const TextStyle(color: Brand.mint, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: .9)),
                      const SizedBox(height: 14),
                      if (isListeningRound) ...[
                        const Icon(Icons.headphones_rounded, color: Brand.white, size: 42),
                        const SizedBox(height: 12),
                        FilledButton.icon(onPressed: () => _tts.speak(card.english), style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep), icon: const Icon(Icons.volume_up_rounded), label: const Text('Escuchar frase')),
                        const SizedBox(height: 8),
                        Text('¿Qué significa lo que escuchaste?', textAlign: TextAlign.center, style: TextStyle(color: Brand.white.withOpacity(.65), fontWeight: FontWeight.w700)),
                      ] else ...[
                        Text(card.english, textAlign: TextAlign.center, style: const TextStyle(color: Brand.white, fontSize: 27, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('Selecciona el significado correcto', style: TextStyle(color: Brand.white.withOpacity(.52), fontSize: 12.5)),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((option) {
                    final isSelected = selected == option;
                    final isCorrect = option == card.spanish;
                    Color border = Colors.white12;
                    Color bg = Colors.white.withOpacity(.035);
                    if (answered && isCorrect) { border = const Color(0xFF4ADE80); bg = const Color(0xFF4ADE80).withOpacity(.10); }
                    else if (answered && isSelected) { border = const Color(0xFFFF8B8B); bg = const Color(0xFFFF8B8B).withOpacity(.09); }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: answered ? null : () => _answer(option),
                        child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)), child: Text(option, style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w800, height: 1.3))),
                      ),
                    );
                  }),
                  if (answered) ...[
                    const SizedBox(height: 8),
                    SizedBox(height: 54, child: FilledButton.icon(onPressed: _next, style: FilledButton.styleFrom(backgroundColor: Brand.mint, foregroundColor: Brand.bgDeep), icon: Icon(index == cards.length - 1 ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded), label: Text(index == cards.length - 1 ? 'Terminar repaso' : 'Siguiente', style: const TextStyle(fontWeight: FontWeight.w900)))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
