class CompetitiveQuestion {
  final String id;
  final String type;
  final String skill;
  final String difficulty;
  final String prompt;
  final String instruction;
  final List<String> options;
  final List<String> words;
  final String? speechText;
  final int seconds;

  const CompetitiveQuestion({
    required this.id,
    required this.type,
    required this.skill,
    required this.difficulty,
    required this.prompt,
    required this.instruction,
    required this.options,
    required this.words,
    required this.speechText,
    required this.seconds,
  });

  factory CompetitiveQuestion.fromJson(Map<String, dynamic> json) {
    return CompetitiveQuestion(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'multipleChoice',
      skill: json['skill'] as String? ?? 'vocabulary',
      difficulty: json['difficulty'] as String? ?? 'easy',
      prompt: json['prompt'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      options: (json['options'] as List?)?.whereType<String>().toList() ??
          const [],
      words: (json['words'] as List?)?.whereType<String>().toList() ??
          const [],
      speechText: json['speechText'] as String?,
      seconds: (json['seconds'] as num?)?.toInt() ?? 30,
    );
  }
}

class CompetitiveSession {
  final String sessionId;
  final String seasonId;
  final int lessonNumber;
  final DateTime expiresAt;
  final List<CompetitiveQuestion> questions;

  const CompetitiveSession({
    required this.sessionId,
    required this.seasonId,
    required this.lessonNumber,
    required this.expiresAt,
    required this.questions,
  });

  factory CompetitiveSession.fromJson(Map<String, dynamic> json) {
    return CompetitiveSession(
      sessionId: json['sessionId'] as String? ?? '',
      seasonId: json['seasonId'] as String? ?? '',
      lessonNumber: (json['lessonNumber'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      questions: (json['questions'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => CompetitiveQuestion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class CompetitiveAnswer {
  final String questionId;
  final String response;
  final int responseMilliseconds;

  const CompetitiveAnswer({
    required this.questionId,
    required this.response,
    required this.responseMilliseconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'response': response,
      'responseMilliseconds': responseMilliseconds,
    };
  }
}

class CompetitiveResult {
  final int score;
  final int xp;
  final int correctAnswers;
  final int totalQuestions;
  final int globalRank;
  final String seasonId;

  const CompetitiveResult({
    required this.score,
    required this.xp,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.globalRank,
    required this.seasonId,
  });

  factory CompetitiveResult.fromJson(Map<String, dynamic> json) {
    return CompetitiveResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      globalRank: (json['globalRank'] as num?)?.toInt() ?? 0,
      seasonId: json['seasonId'] as String? ?? '',
    );
  }
}

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String countryCode;
  final int xp;
  final int wins;
  final int sessions;
  final int bestScore;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.countryCode,
    required this.xp,
    required this.wins,
    required this.sessions,
    required this.bestScore,
  });

  factory LeaderboardEntry.fromJson(
    String uid,
    Map<String, dynamic> json,
  ) {
    return LeaderboardEntry(
      uid: uid,
      displayName: json['displayName'] as String? ?? 'Jugador',
      countryCode: json['countryCode'] as String? ?? 'CO',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      sessions: (json['sessions'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
    );
  }
}
