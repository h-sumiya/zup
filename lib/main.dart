import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/services/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  runApp(const ZupApp());
}
