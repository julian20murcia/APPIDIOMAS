import 'package:flutter/material.dart';

class EnglishLessonGameConfig {
  final int lesson;
  final String title;
  final String subtitle;
  final String mission;
  final IconData icon;
  final Color accent;
  final EnglishGameMode mode;

  const EnglishLessonGameConfig({
    required this.lesson,
    required this.title,
    required this.subtitle,
    required this.mission,
    required this.icon,
    required this.accent,
    required this.mode,
  });
}

enum EnglishGameMode {
  greetingRush,
  emotionRadar,
  pronounSpotlight,
  teamBuilder,
  beForge,
  identityDetective,
  numberTap,
  numberCode,
  colorSplash,
  familyTree,
  articleGate,
  inventoryRush,
  avatarBuilder,
  bodyScan,
  clockRace,
  sportsCoach,
  comparisonClimb,
  marketBasket,
  wishWheel,
  petCare,
  routineBuilder,
  passportRun,
  breakfastCafe,
  fruitSlice,
  veggieGarden,
  shoppingCart,
  careerMatch,
  americaTrip,
  cityNavigator,
  roomDesigner,
  actionCamera,
  hideAndSeek,
  jobInterview,
  ownershipLocker,
  sizeSorter,
  calendarDash,
}

const englishLevel1Games = <int, EnglishLessonGameConfig>{
  1: EnglishLessonGameConfig(lesson: 1, title: 'Greeting Rush', subtitle: 'Saluda antes de que se acabe el tiempo', mission: 'Elige el saludo o presentación correcta para cada situación.', icon: Icons.waving_hand_rounded, accent: Color(0xFFFFC857), mode: EnglishGameMode.greetingRush),
  2: EnglishLessonGameConfig(lesson: 2, title: 'Emotion Radar', subtitle: 'Detecta cómo se siente cada persona', mission: 'Relaciona emociones y respuestas naturales a How are you?', icon: Icons.sentiment_satisfied_alt_rounded, accent: Color(0xFFFF7B9C), mode: EnglishGameMode.emotionRadar),
  3: EnglishLessonGameConfig(lesson: 3, title: 'Pronoun Spotlight', subtitle: 'Pon el pronombre bajo el reflector', mission: 'Escoge I, you, he, she o it según la situación.', icon: Icons.person_search_rounded, accent: Color(0xFF55D6BE), mode: EnglishGameMode.pronounSpotlight),
  4: EnglishLessonGameConfig(lesson: 4, title: 'Team Builder', subtitle: 'Forma equipos con we, you y they', mission: 'Identifica qué pronombre representa correctamente a cada grupo.', icon: Icons.groups_rounded, accent: Color(0xFF7AA8FF), mode: EnglishGameMode.teamBuilder),
  5: EnglishLessonGameConfig(lesson: 5, title: 'To Be Forge', subtitle: 'Forja frases con am, is y are', mission: 'Completa la estructura correcta del verbo to be.', icon: Icons.local_fire_department_rounded, accent: Color(0xFFFF955C), mode: EnglishGameMode.beForge),
  6: EnglishLessonGameConfig(lesson: 6, title: 'Identity Detective', subtitle: 'Descubre quién es quién', mission: 'Resuelve pistas de identidad, estado y ubicación usando to be.', icon: Icons.manage_search_rounded, accent: Color(0xFFB78CFF), mode: EnglishGameMode.identityDetective),
  7: EnglishLessonGameConfig(lesson: 7, title: 'Number Tap', subtitle: 'Toca el número correcto', mission: 'Reconoce números rápidamente por su nombre en inglés.', icon: Icons.pin_rounded, accent: Color(0xFFFFD166), mode: EnglishGameMode.numberTap),
  8: EnglishLessonGameConfig(lesson: 8, title: 'Number Code', subtitle: 'Descifra el código numérico', mission: 'Une números escritos con su valor y completa secuencias.', icon: Icons.password_rounded, accent: Color(0xFF06D6A0), mode: EnglishGameMode.numberCode),
  9: EnglishLessonGameConfig(lesson: 9, title: 'Color Splash', subtitle: 'Pinta el mundo en inglés', mission: 'Reconoce colores, tonos y descripciones antes de que desaparezcan.', icon: Icons.palette_rounded, accent: Color(0xFFFF6B6B), mode: EnglishGameMode.colorSplash),
  10: EnglishLessonGameConfig(lesson: 10, title: 'Family Tree', subtitle: 'Reconstruye el árbol familiar', mission: 'Ubica cada miembro de la familia en su relación correcta.', icon: Icons.account_tree_rounded, accent: Color(0xFF4CC9F0), mode: EnglishGameMode.familyTree),
  11: EnglishLessonGameConfig(lesson: 11, title: 'Article Gate', subtitle: 'Abre la puerta con a o an', mission: 'Selecciona el artículo correcto para poder avanzar.', icon: Icons.door_front_door_rounded, accent: Color(0xFFFFB703), mode: EnglishGameMode.articleGate),
  12: EnglishLessonGameConfig(lesson: 12, title: 'Inventory Rush', subtitle: '¿Quién tiene qué?', mission: 'Resuelve posesiones utilizando have y has.', icon: Icons.inventory_2_rounded, accent: Color(0xFF90BE6D), mode: EnglishGameMode.inventoryRush),
  13: EnglishLessonGameConfig(lesson: 13, title: 'Avatar Builder', subtitle: 'Construye el personaje correcto', mission: 'Interpreta descripciones físicas y encuentra la opción que coincide.', icon: Icons.face_retouching_natural_rounded, accent: Color(0xFFF9844A), mode: EnglishGameMode.avatarBuilder),
  14: EnglishLessonGameConfig(lesson: 14, title: 'Body Scan', subtitle: 'Escanea el cuerpo', mission: 'Encuentra rápidamente la parte del cuerpo indicada.', icon: Icons.accessibility_new_rounded, accent: Color(0xFF43AA8B), mode: EnglishGameMode.bodyScan),
  15: EnglishLessonGameConfig(lesson: 15, title: 'Clock Race', subtitle: 'Gánale al reloj', mission: 'Interpreta horas y expresiones de tiempo a toda velocidad.', icon: Icons.alarm_rounded, accent: Color(0xFF577590), mode: EnglishGameMode.clockRace),
  16: EnglishLessonGameConfig(lesson: 16, title: 'Sports Coach', subtitle: 'Arma la rutina del equipo', mission: 'Elige deporte y expresión correcta para cada entrenamiento.', icon: Icons.sports_soccer_rounded, accent: Color(0xFF00B4D8), mode: EnglishGameMode.sportsCoach),
  17: EnglishLessonGameConfig(lesson: 17, title: 'Comparison Climb', subtitle: 'Sube comparando correctamente', mission: 'Usa comparativos y superlativos para llegar a la cima.', icon: Icons.trending_up_rounded, accent: Color(0xFF9B5DE5), mode: EnglishGameMode.comparisonClimb),
  18: EnglishLessonGameConfig(lesson: 18, title: 'Market Basket', subtitle: 'Llena la canasta correcta', mission: 'Distingue cantidades contables e incontables.', icon: Icons.shopping_basket_rounded, accent: Color(0xFFF15BB5), mode: EnglishGameMode.marketBasket),
  19: EnglishLessonGameConfig(lesson: 19, title: 'Wish Wheel', subtitle: 'Gira y responde a la ocasión', mission: 'Escoge el deseo o expresión social adecuada.', icon: Icons.celebration_rounded, accent: Color(0xFFFEE440), mode: EnglishGameMode.wishWheel),
  20: EnglishLessonGameConfig(lesson: 20, title: 'Pet Care', subtitle: 'Cuida a tu mascota virtual', mission: 'Usa vocabulario de mascotas para atender cada necesidad.', icon: Icons.pets_rounded, accent: Color(0xFF00F5D4), mode: EnglishGameMode.petCare),
  21: EnglishLessonGameConfig(lesson: 21, title: 'Routine Builder', subtitle: 'Construye una rutina real', mission: 'Completa hábitos y acciones en presente simple.', icon: Icons.view_timeline_rounded, accent: Color(0xFF00BBF9), mode: EnglishGameMode.routineBuilder),
  22: EnglishLessonGameConfig(lesson: 22, title: 'Passport Run', subtitle: 'Sella el pasaporte europeo', mission: 'Relaciona países, nacionalidades e idiomas.', icon: Icons.airplane_ticket_rounded, accent: Color(0xFF4361EE), mode: EnglishGameMode.passportRun),
  23: EnglishLessonGameConfig(lesson: 23, title: 'Breakfast Café', subtitle: 'Sirve el desayuno perfecto', mission: 'Prepara pedidos utilizando el vocabulario del desayuno.', icon: Icons.coffee_rounded, accent: Color(0xFFD4A373), mode: EnglishGameMode.breakfastCafe),
  24: EnglishLessonGameConfig(lesson: 24, title: 'Fruit Slice', subtitle: 'Corta únicamente la fruta correcta', mission: 'Reconoce frutas y frases relacionadas antes de perder la racha.', icon: Icons.eco_rounded, accent: Color(0xFFFF595E), mode: EnglishGameMode.fruitSlice),
  25: EnglishLessonGameConfig(lesson: 25, title: 'Veggie Garden', subtitle: 'Cultiva el huerto en inglés', mission: 'Identifica vegetales para hacer crecer tu jardín.', icon: Icons.yard_rounded, accent: Color(0xFF8AC926), mode: EnglishGameMode.veggieGarden),
  26: EnglishLessonGameConfig(lesson: 26, title: 'Shopping Cart', subtitle: 'Compra sin equivocarte', mission: 'Responde precios, productos y expresiones de compra.', icon: Icons.shopping_cart_checkout_rounded, accent: Color(0xFFFFCA3A), mode: EnglishGameMode.shoppingCart),
  27: EnglishLessonGameConfig(lesson: 27, title: 'Career Match', subtitle: 'Encuentra la profesión', mission: 'Relaciona ocupaciones con lo que hace cada persona.', icon: Icons.badge_rounded, accent: Color(0xFF1982C4), mode: EnglishGameMode.careerMatch),
  28: EnglishLessonGameConfig(lesson: 28, title: 'America Trip', subtitle: 'Completa la ruta por América', mission: 'Reconoce lugares, países y referencias geográficas.', icon: Icons.public_rounded, accent: Color(0xFF6A4C93), mode: EnglishGameMode.americaTrip),
  29: EnglishLessonGameConfig(lesson: 29, title: 'City Navigator', subtitle: 'Encuentra el lugar correcto', mission: 'Usa pistas para ubicarte en la ciudad.', icon: Icons.explore_rounded, accent: Color(0xFF4D908E), mode: EnglishGameMode.cityNavigator),
  30: EnglishLessonGameConfig(lesson: 30, title: 'Room Designer', subtitle: 'Diseña la habitación', mission: 'Identifica muebles y espacios para completar la casa.', icon: Icons.chair_alt_rounded, accent: Color(0xFFF3722C), mode: EnglishGameMode.roomDesigner),
  31: EnglishLessonGameConfig(lesson: 31, title: 'Action Camera', subtitle: 'Captura la acción que ocurre ahora', mission: 'Reconoce acciones en presente continuo.', icon: Icons.videocam_rounded, accent: Color(0xFFF94144), mode: EnglishGameMode.actionCamera),
  32: EnglishLessonGameConfig(lesson: 32, title: 'Hide & Seek', subtitle: '¿Dónde está escondido?', mission: 'Encuentra objetos usando preposiciones de lugar.', icon: Icons.location_searching_rounded, accent: Color(0xFF277DA1), mode: EnglishGameMode.hideAndSeek),
  33: EnglishLessonGameConfig(lesson: 33, title: 'Job Interview', subtitle: 'Supera la entrevista', mission: 'Identifica profesiones y responde preguntas laborales básicas.', icon: Icons.record_voice_over_rounded, accent: Color(0xFF577590), mode: EnglishGameMode.jobInterview),
  34: EnglishLessonGameConfig(lesson: 34, title: 'Ownership Locker', subtitle: 'Abre el casillero correcto', mission: 'Usa adjetivos posesivos para identificar pertenencias.', icon: Icons.lock_open_rounded, accent: Color(0xFF43AA8B), mode: EnglishGameMode.ownershipLocker),
  35: EnglishLessonGameConfig(lesson: 35, title: 'Size Sorter', subtitle: 'Ordena por tamaño', mission: 'Reconoce y utiliza expresiones de talla y tamaño.', icon: Icons.straighten_rounded, accent: Color(0xFF90BE6D), mode: EnglishGameMode.sizeSorter),
  36: EnglishLessonGameConfig(lesson: 36, title: 'Calendar Dash', subtitle: 'Completa la semana', mission: 'Reconoce días y preguntas de calendario para cerrar el Nivel 1.', icon: Icons.calendar_month_rounded, accent: Color(0xFFF9C74F), mode: EnglishGameMode.calendarDash),
};
