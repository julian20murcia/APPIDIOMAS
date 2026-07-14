class World {
  final String id;

  // Información principal
  final String language;
  final String city;
  final String country;
  final String flag;
  final String hello;

  // Textos visuales
  final String title;
  final String subtitle;
  final String themeName;
  final String description;
  final String loginHint;

  // Assets principales
  final String image;
  final String bubbleImage;
  final String backgroundAsset;
  final String landmarkAsset;
  final String secondaryAsset;

  // Contenido del curso
  final List<String> levels;
  final List<String> lessons;
  final List<String> keywords;
  final List<String> decorations;

  const World({
    required this.id,
    required this.language,
    required this.city,
    required this.flag,
    required this.hello,
    required this.image,
    required this.lessons,

    this.country = '',
    this.title = '',
    this.subtitle = '',
    this.themeName = '',
    this.description = '',
    this.loginHint = '',

    this.bubbleImage = '',
    this.backgroundAsset = '',
    this.landmarkAsset = '',
    this.secondaryAsset = '',

    this.levels = const ['A1', 'A2', 'B1', 'B2', 'C1'],
    this.keywords = const [],
    this.decorations = const [],
  });

  String get displayName => '$language · $city';

  String get fullLocation {
    if (country.trim().isEmpty) return city;
    return '$city, $country';
  }

  String get safeTitle {
    if (title.trim().isNotEmpty) return title;
    return displayName;
  }

  String get safeSubtitle {
    if (subtitle.trim().isNotEmpty) return subtitle;
    return 'Aprende $language explorando $city';
  }

  String get safeThemeName {
    if (themeName.trim().isNotEmpty) return themeName;
    return 'Ruta de $city';
  }

  String get safeDescription {
    if (description.trim().isNotEmpty) return description;
    return 'Completa misiones, desbloquea lecciones y avanza en tu aprendizaje.';
  }

  String get safeLoginHint {
    if (loginHint.trim().isNotEmpty) return loginHint;
    return hello;
  }

  String get safeBubbleImage {
    if (bubbleImage.trim().isNotEmpty) return bubbleImage;
    return '';
  }

  String get safeBackgroundAsset {
    if (backgroundAsset.trim().isNotEmpty) return backgroundAsset;
    return image;
  }

  String get safeLandmarkAsset {
    if (landmarkAsset.trim().isNotEmpty) return landmarkAsset;
    return image;
  }

  String get safeSecondaryAsset {
    if (secondaryAsset.trim().isNotEmpty) return secondaryAsset;
    return image;
  }

  bool get hasBubbleImage => bubbleImage.trim().isNotEmpty;
  bool get hasBackgroundAsset => backgroundAsset.trim().isNotEmpty;
  bool get hasLandmarkAsset => landmarkAsset.trim().isNotEmpty;
  bool get hasSecondaryAsset => secondaryAsset.trim().isNotEmpty;
  bool get hasDecorations => decorations.isNotEmpty;
  bool get hasKeywords => keywords.isNotEmpty;
}