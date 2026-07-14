import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/lingoverse_app.dart';
import 'core/theme/brand.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Brand.bgDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LingoVerseApp());
}
