import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/competitive_models.dart';

class CompetitionService {
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CompetitionService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'southamerica-east1',
            ),
        firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Future<CompetitiveSession> startSession({
    required int lessonNumber,
  }) async {
    _requireUser();

    final callable = functions.httpsCallable('startCompetitiveSession');
    final response = await callable.call<Map<String, dynamic>>({
      'lessonNumber': lessonNumber,
    });

    return CompetitiveSession.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<CompetitiveResult> submitSession({
    required String sessionId,
    required List<CompetitiveAnswer> answers,
  }) async {
    _requireUser();

    final callable = functions.httpsCallable('submitCompetitiveSession');
    final response = await callable.call<Map<String, dynamic>>({
      'sessionId': sessionId,
      'answers': answers.map((item) => item.toJson()).toList(),
    });

    return CompetitiveResult.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Stream<List<LeaderboardEntry>> watchGlobalLeaderboard({
    required String seasonId,
    int limit = 100,
  }) {
    return firestore
        .collection('seasons')
        .doc(seasonId)
        .collection('players')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LeaderboardEntry.fromJson(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<String> currentSeasonId() async {
    final callable = functions.httpsCallable('getCompetitionSeason');
    final response = await callable.call<Map<String, dynamic>>();
    return response.data['seasonId'] as String? ?? '';
  }

  User _requireUser() {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para competir.');
    }
    return user;
  }
}
