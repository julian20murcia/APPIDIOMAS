"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitCompetitiveSession = exports.startCompetitiveSession = exports.getCompetitionSeason = void 0;
const node_crypto_1 = require("node:crypto");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const REGION = 'southamerica-east1';
const SESSION_MINUTES = 20;
const QUESTION_COUNT = 12;
function requireAuth(request) {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError('unauthenticated', 'Debes iniciar sesión.');
    }
    return uid;
}
function normalize(value) {
    return String(value ?? '')
        .toLowerCase()
        .trim()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9 ]/g, '')
        .replace(/\s+/g, ' ');
}
function seasonId(date = new Date()) {
    const utc = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
    const day = utc.getUTCDay() || 7;
    utc.setUTCDate(utc.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(utc.getUTCFullYear(), 0, 1));
    const week = Math.ceil((((utc.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
    return `${utc.getUTCFullYear()}-W${String(week).padStart(2, '0')}`;
}
function shuffled(items) {
    const copy = [...items];
    for (let index = copy.length - 1; index > 0; index--) {
        const swapIndex = (0, node_crypto_1.randomInt)(index + 1);
        [copy[index], copy[swapIndex]] = [copy[swapIndex], copy[index]];
    }
    return copy;
}
function sanitizeQuestion(question) {
    return {
        id: question.id,
        type: question.type,
        skill: question.skill,
        difficulty: question.difficulty,
        prompt: question.prompt,
        instruction: question.instruction ?? '',
        options: shuffled(question.options ?? []),
        words: shuffled(question.words ?? []),
        speechText: question.speechText ?? null,
        seconds: question.seconds ?? 30,
    };
}
exports.getCompetitionSeason = (0, https_1.onCall)({
    region: REGION,
    enforceAppCheck: true,
}, async () => ({ seasonId: seasonId() }));
exports.startCompetitiveSession = (0, https_1.onCall)({
    region: REGION,
    enforceAppCheck: true,
    timeoutSeconds: 30,
}, async (request) => {
    const uid = requireAuth(request);
    const lessonNumber = Number(request.data?.lessonNumber);
    if (!Number.isInteger(lessonNumber) || lessonNumber < 1 || lessonNumber > 36) {
        throw new https_1.HttpsError('invalid-argument', 'La lección debe estar entre 1 y 36.');
    }
    const questionsSnapshot = await db
        .collection('questionBanks')
        .doc(String(lessonNumber))
        .collection('questions')
        .limit(240)
        .get();
    if (questionsSnapshot.size < QUESTION_COUNT) {
        throw new https_1.HttpsError('failed-precondition', `La lección ${lessonNumber} no tiene suficientes preguntas publicadas.`);
    }
    const allQuestions = questionsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
    }));
    const selected = shuffled(allQuestions).slice(0, QUESTION_COUNT);
    const id = (0, node_crypto_1.randomUUID)();
    const now = Date.now();
    const expiresAt = new Date(now + SESSION_MINUTES * 60 * 1000);
    const currentSeason = seasonId();
    await db.collection('competitiveSessions').doc(id).set({
        uid,
        lessonNumber,
        seasonId: currentSeason,
        status: 'active',
        createdAt: firestore_1.FieldValue.serverTimestamp(),
        expiresAt: firestore_1.Timestamp.fromDate(expiresAt),
        questions: selected,
    });
    return {
        sessionId: id,
        seasonId: currentSeason,
        lessonNumber,
        expiresAt: expiresAt.toISOString(),
        questions: selected.map(sanitizeQuestion),
    };
});
exports.submitCompetitiveSession = (0, https_1.onCall)({
    region: REGION,
    enforceAppCheck: true,
    timeoutSeconds: 30,
}, async (request) => {
    const uid = requireAuth(request);
    const sessionId = String(request.data?.sessionId ?? '').trim();
    const submitted = Array.isArray(request.data?.answers)
        ? request.data.answers
        : [];
    if (!sessionId || submitted.length === 0) {
        throw new https_1.HttpsError('invalid-argument', 'La sesión y las respuestas son obligatorias.');
    }
    const sessionRef = db.collection('competitiveSessions').doc(sessionId);
    const result = await db.runTransaction(async (transaction) => {
        const sessionSnapshot = await transaction.get(sessionRef);
        if (!sessionSnapshot.exists) {
            throw new https_1.HttpsError('not-found', 'La sesión no existe.');
        }
        const session = sessionSnapshot.data();
        if (session.uid !== uid) {
            throw new https_1.HttpsError('permission-denied', 'Esta sesión pertenece a otro jugador.');
        }
        if (session.status !== 'active') {
            throw new https_1.HttpsError('already-exists', 'Esta sesión ya fue calificada.');
        }
        const expiresAt = session.expiresAt;
        if (expiresAt.toMillis() < Date.now()) {
            transaction.update(sessionRef, { status: 'expired' });
            throw new https_1.HttpsError('deadline-exceeded', 'La sesión competitiva expiró.');
        }
        const questions = session.questions;
        const answersById = new Map(submitted.map((answer) => [answer.questionId, answer]));
        let correctAnswers = 0;
        let totalBasePoints = 0;
        let earnedBasePoints = 0;
        let speedXp = 0;
        for (const question of questions) {
            totalBasePoints += question.basePoints ?? 10;
            const answer = answersById.get(question.id);
            if (!answer)
                continue;
            const accepted = [
                question.answer,
                ...(question.acceptedAnswers ?? []),
            ].map(normalize);
            const correct = accepted.includes(normalize(answer.response));
            if (correct) {
                correctAnswers += 1;
                earnedBasePoints += question.basePoints ?? 10;
                const responseMs = Math.max(0, Math.min(Number(answer.responseMilliseconds) || 0, 180000));
                const allowedMs = Math.max(10000, (question.seconds ?? 30) * 1000);
                const speedRatio = Math.max(0, 1 - responseMs / allowedMs);
                speedXp += Math.round(speedRatio * 5);
            }
        }
        const score = totalBasePoints === 0
            ? 0
            : Math.max(0, Math.min(100, Math.round((earnedBasePoints / totalBasePoints) * 100)));
        const passed = score >= 70;
        const difficultyXp = questions.reduce((total, question) => {
            if (question.difficulty === 'hard')
                return total + 3;
            if (question.difficulty === 'medium')
                return total + 2;
            return total + 1;
        }, 0);
        const xp = Math.max(10, Math.min(250, Math.round(score * 0.8) + speedXp + difficultyXp + (passed ? 20 : 0)));
        const currentSeason = String(session.seasonId ?? seasonId());
        const playerRef = db
            .collection('seasons')
            .doc(currentSeason)
            .collection('players')
            .doc(uid);
        const playerSnapshot = await transaction.get(playerRef);
        const previous = playerSnapshot.data() ?? {};
        const displayName = request.auth?.token?.name ??
            request.auth?.token?.email?.split('@')[0] ??
            'Jugador';
        const countryCode = String(request.auth?.token?.countryCode ?? previous.countryCode ?? 'CO').toUpperCase().slice(0, 2);
        const totalPlayerXp = Number(previous.xp ?? 0) + xp;
        transaction.set(playerRef, {
            uid,
            displayName,
            countryCode,
            xp: totalPlayerXp,
            wins: Number(previous.wins ?? 0) + (passed ? 1 : 0),
            sessions: Number(previous.sessions ?? 0) + 1,
            bestScore: Math.max(Number(previous.bestScore ?? 0), score),
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
        }, { merge: true });
        transaction.update(sessionRef, {
            status: 'completed',
            completedAt: firestore_1.FieldValue.serverTimestamp(),
            score,
            xp,
            correctAnswers,
        });
        return {
            score,
            xp,
            correctAnswers,
            totalQuestions: questions.length,
            seasonId: currentSeason,
            totalPlayerXp,
        };
    });
    const betterPlayersSnapshot = await db
        .collection('seasons')
        .doc(result.seasonId)
        .collection('players')
        .where('xp', '>', result.totalPlayerXp)
        .count()
        .get();
    const { totalPlayerXp: _, ...publicResult } = result;
    return {
        ...publicResult,
        globalRank: betterPlayersSnapshot.data().count + 1,
    };
});
