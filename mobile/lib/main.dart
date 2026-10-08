import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(DgiProximobileApp(config: AppConfig.fromEnvironment()));
  } on FormatException {
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Configuration invalide. Vérifiez APP_MODE et API_BASE_URL. '
                'Le mode API exige une adresse HTTPS sans identifiants.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
