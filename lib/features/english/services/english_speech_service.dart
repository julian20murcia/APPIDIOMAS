import 'dart:math' as math;

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class EnglishSpeechAttempt {
  final String target;
  final String transcript;
  final int score;
  final double recognitionConfidence;
  final List<String> missedWords;
  final String feedback;

  const EnglishSpeechAttempt({
    required this.target,
    required this.transcript,
    required this.score,
    required this.recognitionConfidence,
    required this.missedWords,
    required this.feedback,
  });
}

/// Singleton wrapper because speech_to_text recommends initializing a single
/// SpeechToText instance once per application session.
class EnglishSpeechService {
  EnglishSpeechService._();

  static final EnglishSpeechService instance = EnglishSpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  bool _available = false;
  String? _lastError;
  void Function(String status)? _statusCallback;
  void Function(String error)? _errorCallback;

  bool get isListening => _speech.isListening;
  bool get available => _available;
  String? get lastError => _lastError;

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    _statusCallback = onStatus;
    _errorCallback = onError;
    if (_initialized) return _available;

    _available = await _speech.initialize(
      onStatus: (status) => _statusCallback?.call(status),
      onError: (SpeechRecognitionError error) {
        _lastError = error.errorMsg;
        _errorCallback?.call(error.errorMsg);
      },
    );
    _initialized = true;
    return _available;
  }

  Future<void> listen({
    required void Function(String words, bool finalResult, double confidence)
        onResult,
    String localeId = 'en_US',
  }) async {
    _lastError = null;
    if (!_initialized) {
      await initialize();
    }
    if (!_available) return;

    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 7),
      pauseFor: const Duration(seconds: 3),
      onResult: (SpeechRecognitionResult result) {
        onResult(
          result.recognizedWords,
          result.finalResult,
          result.confidence,
        );
      },
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();

  EnglishSpeechAttempt evaluate({
    required String target,
    required String transcript,
    double recognitionConfidence = 0,
  }) {
    final expected = _normalize(target);
    final heard = _normalize(transcript);

    if (heard.isEmpty) {
      return EnglishSpeechAttempt(
        target: target,
        transcript: transcript,
        score: 0,
        recognitionConfidence: recognitionConfidence,
        missedWords: expected.split(' ').where((e) => e.isNotEmpty).toList(),
        feedback: 'No pude reconocer la frase. Acércate al micrófono y prueba otra vez.',
      );
    }

    final charSimilarity = _similarity(expected, heard);
    final expectedWords = expected.split(' ').where((e) => e.isNotEmpty).toList();
    final heardWords = heard.split(' ').where((e) => e.isNotEmpty).toList();

    final missed = <String>[];
    var matchedWords = 0;
    for (final word in expectedWords) {
      final best = heardWords.fold<double>(
        0,
        (value, candidate) => math.max(value, _similarity(word, candidate)),
      );
      if (best >= .72) {
        matchedWords += 1;
      } else {
        missed.add(word);
      }
    }

    final wordCoverage = expectedWords.isEmpty ? 1.0 : matchedWords / expectedWords.length;
    final confidence = recognitionConfidence > 0 ? recognitionConfidence.clamp(0.0, 1.0) : charSimilarity;

    final score = ((charSimilarity * .58 + wordCoverage * .32 + confidence * .10) * 100)
        .round()
        .clamp(0, 100)
        .toInt();

    final feedback = switch (score) {
      >= 92 => 'Excelente claridad. La frase se entendió casi completa.',
      >= 82 => 'Muy bien. Suena clara; intenta una vez más buscando mayor fluidez.',
      >= 70 => 'Bien encaminado. Repite con calma y marca mejor las palabras señaladas.',
      >= 55 => 'Se entiende parte de la frase. Escúchala otra vez y repite por bloques.',
      _ => 'Vamos otra vez. Escucha primero y después repite sin correr.',
    };

    return EnglishSpeechAttempt(
      target: target,
      transcript: transcript,
      score: score,
      recognitionConfidence: recognitionConfidence,
      missedWords: missed,
      feedback: feedback,
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double _similarity(String a, String b) {
    if (a == b) return 1;
    if (a.isEmpty || b.isEmpty) return 0;
    final distance = _levenshtein(a, b);
    final longest = math.max(a.length, b.length);
    return (1 - distance / longest).clamp(0.0, 1.0);
  }

  int _levenshtein(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      var diagonal = previous[0];
      previous[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final upper = previous[j];
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        previous[j] = math.min(
          math.min(previous[j] + 1, previous[j - 1] + 1),
          diagonal + cost,
        );
        diagonal = upper;
      }
    }
    return previous[b.length];
  }
}
