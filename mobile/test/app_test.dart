import 'package:dgi_proximobile/app.dart';
import 'package:dgi_proximobile/config/app_config.dart';
import 'package:dgi_proximobile/config/official_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API configuration accepts HTTPS only and rejects unknown modes', () {
    expect(
      () => AppConfig.parse(mode: 'api', apiBaseUrl: 'http://example.com/api/'),
      throwsFormatException,
    );
    expect(() => AppConfig.parse(mode: 'unknown'), throwsFormatException);
    final config = AppConfig.parse(
      mode: 'api',
      apiBaseUrl: 'https://example.com/api/',
    );
    expect(config.mode, AppMode.api);
    expect(config.apiBaseUri!.scheme, 'https');
    expect(AppConfig.parse(mode: 'demo').apiBaseUri, isNull);
  });

  test('Official links reject unsafe hosts and user information', () {
    expect(OfficialLinks.isAllowed(Uri.parse('https://dgi.gouv.cd/')), isTrue);
    expect(OfficialLinks.isAllowed(Uri.parse('https://edef.dgirdc.cd/')), isTrue);
    expect(OfficialLinks.isAllowed(Uri.parse('http://dgi.gouv.cd/')), isFalse);
    expect(OfficialLinks.isAllowed(Uri.parse('https://dgi.gouv.cd.evil.test/')), isFalse);
    expect(OfficialLinks.isAllowed(Uri.parse('https://user@dgi.gouv.cd/')), isFalse);
    expect(OfficialLinks.isAllowed(Uri.parse('javascript:alert(1)')), isFalse);
  });

  testWidgets('Launch shows native four-destination navigation and demo notice', (tester) async {
    await tester.pumpWidget(const DgiProximobileApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Données de démonstration'), findsOneWidget);
    expect(find.text('Cher contribuable'), findsOneWidget);
    expect(find.text('Plus proche de vous !'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All destinations remain reachable', (tester) async {
    await tester.pumpWidget(const DgiProximobileApp());
    await tester.tap(find.text('Services').last);
    await tester.pumpAndSettle();
    expect(find.text('Toutes vos démarches, au même endroit.'), findsOneWidget);
    await tester.tap(find.text('Mes demandes').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Le suivi des demandes sera ajouté'), findsOneWidget);
    await tester.tap(find.text('Mon compte').last);
    await tester.pumpAndSettle();
    expect(find.text('Identité fiscale non vérifiée'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Official portal requires consent and uses the injected launcher', (tester) async {
    final opened = <Uri>[];
    await tester.pumpWidget(DgiProximobileApp(openPortal: (uri) async {
      opened.add(uri);
      return true;
    }));
    await tester.tap(find.text('Services').last);
    await tester.pumpAndSettle();
    final portal = find.byKey(const ValueKey('portal-edef'));
    await tester.scrollUntilVisible(portal, 300);
    await tester.tap(portal);
    await tester.pumpAndSettle();
    expect(find.text('Vous allez être redirigé vers un service officiel de la DGI.'), findsOneWidget);
    expect(opened, isEmpty);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(opened, isEmpty);
    await tester.tap(portal);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(opened, [OfficialLinks.edef]);
  });

  testWidgets('Portal launch failure is visible', (tester) async {
    await tester.pumpWidget(DgiProximobileApp(openPortal: (_) async => false));
    await tester.tap(find.text('Services').last);
    await tester.pumpAndSettle();
    final portal = find.byKey(const ValueKey('portal-edef'));
    await tester.scrollUntilVisible(portal, 300);
    await tester.tap(portal);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Impossible d’ouvrir le portail. Veuillez réessayer.'), findsOneWidget);
  });

  testWidgets('Demo logout and local demo email entry are explicit', (tester) async {
    await tester.pumpWidget(const DgiProximobileApp());
    await tester.tap(find.text('Mon compte').last);
    await tester.pumpAndSettle();
    final logout = find.text('Quitter la session de démonstration');
    await tester.scrollUntilVisible(logout, 200);
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.text('Connexion de démonstration'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'alex.demo@example.cd');
    await tester.tap(find.text('Entrer en démonstration'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Small screen with enlarged text has no layout exception', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DgiProximobileApp());
    final context = tester.element(find.byType(NavigationBar));
    final data = MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5));
    await tester.pumpWidget(MediaQuery(data: data, child: const DgiProximobileApp()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
