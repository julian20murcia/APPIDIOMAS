import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

const inputPath = resolve(
  process.cwd(),
  process.argv[2] ?? '../build/question_banks.json',
);

const raw = await readFile(inputPath, 'utf8');
const lessons = JSON.parse(raw);

for (const lesson of lessons) {
  const lessonNumber = String(lesson.lessonNumber);
  const collection = db
    .collection('questionBanks')
    .doc(lessonNumber)
    .collection('questions');

  const existing = await collection.get();
  let batch = db.batch();
  let operations = 0;

  for (const document of existing.docs) {
    batch.delete(document.ref);
    operations += 1;

    if (operations === 450) {
      await batch.commit();
      batch = db.batch();
      operations = 0;
    }
  }

  if (operations > 0) {
    await batch.commit();
  }

  batch = db.batch();
  operations = 0;

  for (const question of lesson.questions) {
    const ref = collection.doc(question.id);
    batch.set(ref, question);
    operations += 1;

    if (operations === 450) {
      await batch.commit();
      batch = db.batch();
      operations = 0;
    }
  }

  if (operations > 0) {
    await batch.commit();
  }

  await db.collection('questionBanks').doc(lessonNumber).set({
    lessonNumber: lesson.lessonNumber,
    lessonTitle: lesson.lessonTitle,
    questionCount: lesson.questions.length,
    updatedAt: new Date(),
  });

  console.log(
    `Lección ${lessonNumber}: ${lesson.questions.length} preguntas publicadas.`,
  );
}

console.log('Todos los bancos fueron publicados correctamente.');
