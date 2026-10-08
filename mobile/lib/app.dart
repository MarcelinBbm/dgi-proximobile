import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/app_config.dart';
import 'config/official_links.dart';
import 'config/theme.dart';

typedef PortalLauncher = Future<bool> Function(Uri uri);

Future<bool> _launchExternalPortal(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class DgiProximobileApp extends StatelessWidget {
  const DgiProximobileApp({
    super.key,
    this.config = const AppConfig.demo(),
    this.openPortal,
  });

  final AppConfig config;
  final PortalLauncher? openPortal;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'DGI PROXIMOBILE',
        debugShowCheckedModeBanner: false,
        theme: buildDgiTheme(),
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: _FoundationShell(
          config: config,
          openPortal: openPortal ?? _launchExternalPortal,
        ),
      );
}

class _FoundationShell extends StatefulWidget {
  const _FoundationShell({required this.config, required this.openPortal});
  final AppConfig config;
  final PortalLauncher openPortal;

  @override
  State<_FoundationShell> createState() => _FoundationShellState();
}

class _FoundationShellState extends State<_FoundationShell> {
  int _selected = 0;
  bool _demoSession = true;
  bool _launching = false;

  void _showNotImplemented(String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Ce parcours n’est pas encore implémenté dans ce lot de fondation. '
          'Aucune demande, déclaration ou réservation n’a été envoyée.',
        ),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        )],
      ),
    );
  }

  Future<void> _openOfficial(Uri uri) async {
    if (_launching) return;
    if (!OfficialLinks.isAllowed(uri)) {
      _showNotImplemented('Adresse non autorisée');
      return;
    }
    setState(() => _launching = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service officiel externe'),
        content: Text('${OfficialLinks.redirectNotice}\n\n${uri.host}\n\n'
            'PROXIMOBILE ne collecte pas votre mot de passe de ce portail.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuer')),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _launching = false);
      return;
    }
    var opened = false;
    try {
      opened = await widget.openPortal(uri);
    } on Exception {
      opened = false;
    }
    if (!mounted) return;
    setState(() => _launching = false);
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible d’ouvrir le portail. Veuillez réessayer.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.mode == AppMode.api) {
      return Scaffold(
        appBar: AppBar(title: const Text('DGI PROXIMOBILE')),
        body: const SafeArea(child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text(
            'Mode API configuré. Le transport HTTP et la connexion au backend '
            'ne sont pas encore implémentés dans ce lot. '
            'Aucune connexion aux serveurs DGI n’est effectuée.',
            textAlign: TextAlign.center,
          )),
        )),
      );
    }
    if (!_demoSession) {
      return _DemoEntry(onEntered: () => setState(() {
        _demoSession = true;
        _selected = 0;
      }));
    }
    final pages = <Widget>[
      _HomePage(onService: _showNotImplemented),
      _ServicesPage(onService: _showNotImplemented, onPortal: _openOfficial, launching: _launching),
      const _RequestsFoundationPage(),
      _AccountPage(
        onMenu: _showNotImplemented,
        onLogout: () => setState(() => _demoSession = false),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 112,
        title: const _BrandTitle(),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showNotImplemented('Notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFF1CC),
            child: const Text('Données de démonstration',
                style: TextStyle(fontWeight: FontWeight.w600, color: DgiColors.darkBlue)),
          ),
          Expanded(child: pages[_selected]),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (value) => setState(() => _selected = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Mes demandes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Mon compte'),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();
  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DGI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('PROXIMOBILE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
          Text('Votre assistant fiscal de proximité', style: TextStyle(fontSize: 11)),
        ],
      );
}

class _ServiceSpec {
  const _ServiceSpec(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const _services = <_ServiceSpec>[
  _ServiceSpec('Mon profil fiscal', 'NIF / e-NIF\nCatégorie de contribuable', Icons.badge_outlined, DgiColors.primary),
  _ServiceSpec('Mes obligations', 'TVA | IS/IRPP\nAutres impôts', Icons.event_note_outlined, DgiColors.purple),
  _ServiceSpec('Facture normalisée', 'DEF / e-DEF\nGuide et accompagnement', Icons.receipt_long_outlined, DgiColors.success),
  _ServiceSpec('Télédéclaration', 'Déclarer en ligne\nSuivi de vos dossiers', Icons.cloud_upload_outlined, DgiColors.turquoise),
  _ServiceSpec('Prendre rendez-vous', 'Choisir un service\nDate et heure', Icons.calendar_month_outlined, DgiColors.primary),
  _ServiceSpec('Assistance', 'Signaler une difficulté\nSuivi de votre demande', Icons.support_agent, DgiColors.error),
  _ServiceSpec('Mon centre fiscal', 'Localiser votre centre et ses coordonnées', Icons.location_on_outlined, DgiColors.primary),
  _ServiceSpec('Notifications', 'Échéances | Actualités\nRéformes fiscales', Icons.notifications_outlined, DgiColors.purple),
];

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onService});
  final ValueChanged<String> onService;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        key: const PageStorageKey('home'),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bonjour,'),
            Text('Cher contribuable', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DgiColors.darkBlue)),
            SizedBox(height: 8),
            Text('Simplifions ensemble vos démarches fiscales.'),
          ])),
          const SizedBox(height: 16),
          Material(
            color: DgiColors.primary,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onService('Votre assistant fiscal'),
              child: const Padding(padding: EdgeInsets.all(20), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Votre assistant fiscal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Trouvez rapidement les réponses à toutes vos questions fiscales.', style: TextStyle(color: Colors.white)),
                ])),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white),
              ])),
            ),
          ),
          const SizedBox(height: 16),
          for (var row = 0; row < 2; row++) ...[
            IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var column = 0; column < 3; column++) ...[
                if (column > 0) const SizedBox(width: 8),
                Expanded(child: _ServiceTile(
                  spec: _services[row * 3 + column],
                  onTap: () => onService(_services[row * 3 + column].title),
                )),
              ],
            ])),
            const SizedBox(height: 8),
          ],
          for (final spec in _services.skip(6)) ...[
            _ServiceRow(spec: spec, onTap: () => onService(spec.title)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _Panel(child: Column(children: [
            const Text('Une question ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('Notre équipe est à votre écoute'),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => onService('Assistance'), child: const Text('Demander une assistance')),
          ])),
          const Padding(padding: EdgeInsets.all(20), child: Text('Plus proche de vous !', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: DgiColors.darkBlue))),
          const Text('Prototype en construction. Logo officiel et fidélité graphique à vérifier.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ]),
      );
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.spec, required this.onTap});
  final _ServiceSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(children: [
            Icon(spec.icon, color: spec.color, size: 28),
            const SizedBox(height: 10),
            Text(spec.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text(spec.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ]),
        )),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.spec, required this.onTap});
  final _ServiceSpec spec;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          minVerticalPadding: 16,
          leading: Icon(spec.icon, color: spec.color),
          title: Text(spec.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(spec.subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}

class _ServicesPage extends StatelessWidget {
  const _ServicesPage({required this.onService, required this.onPortal, required this.launching});
  final ValueChanged<String> onService;
  final ValueChanged<Uri> onPortal;
  final bool launching;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        key: const PageStorageKey('services'),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Services', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Text('Toutes vos démarches, au même endroit.'),
          const SizedBox(height: 16),
          for (final spec in _services) ...[
            _ServiceRow(spec: spec, onTap: () => onService(spec.title)),
            const SizedBox(height: 8),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('POUR VOUS ACCOMPAGNER', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final spec in const [
            _ServiceSpec('Votre assistant fiscal', 'Des réponses guidées, étape par étape', Icons.chat_bubble_outline, DgiColors.primary),
            _ServiceSpec('Vérifier un document fiscal', 'QR code ou référence officielle', Icons.qr_code_scanner, DgiColors.success),
            _ServiceSpec('Guides pratiques', 'Des étapes simples à consulter', Icons.menu_book_outlined, DgiColors.purple),
          ]) ...[
            _ServiceRow(spec: spec, onTap: () => onService(spec.title)),
            const SizedBox(height: 8),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('SERVICES OFFICIELS EXTERNES', style: TextStyle(fontWeight: FontWeight.bold))),
          _portal('institutional', 'Site institutionnel DGI', OfficialLinks.institutional),
          _portal('edef', 'Accéder à e-DEF', OfficialLinks.edef),
          _portal('verification', 'Authentification officielle des documents', OfficialLinks.verification),
          _portal('communiques', 'Communiqués officiels', OfficialLinks.communiques),
          const SizedBox(height: 16),
          const Text('Télédéclaration, e-NIF et autres plateformes : adresses à valider par la DGI. Aucun lien n’est inventé.'),
        ]),
      );

  Widget _portal(String id, String title, Uri uri) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton.icon(
          key: ValueKey('portal-$id'),
          onPressed: launching ? null : () => onPortal(uri),
          icon: const Icon(Icons.open_in_new),
          label: Text(title),
        ),
      );
}

class _RequestsFoundationPage extends StatelessWidget {
  const _RequestsFoundationPage();
  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Mes demandes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text('Retrouvez vos échanges et vos rendez-vous.'),
          SizedBox(height: 16),
          _Panel(child: Text('Le suivi des demandes sera ajouté dans le lot fonctionnel. Aucune demande réelle n’est chargée ou envoyée par ce socle.')),
        ]),
      );
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({required this.onMenu, required this.onLogout});
  final ValueChanged<String> onMenu;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppConfig.demoName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Profil fictif de présentation'),
            SizedBox(height: 12),
            Text('Identité fiscale non vérifiée', style: TextStyle(fontWeight: FontWeight.bold, color: DgiColors.darkBlue)),
            SizedBox(height: 12),
            Text('NIF : Non renseigné'),
            Text('Centre de rattachement : À confirmer'),
          ])),
          const SizedBox(height: 16),
          for (final title in const ['Mon profil fiscal', 'Langue et notifications', 'Sécurité et connexion', 'Mes données personnelles', 'À propos de PROXIMOBILE'])
            ListTile(title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: () => onMenu(title)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onLogout, child: const Text('Quitter la session de démonstration')),
          const SizedBox(height: 8),
          const Text('Session locale de présentation, sans authentification DGI et sans jeton. La persistance et l’authentification distante ne font pas partie de ce lot.'),
        ]),
      );
}

class _DemoEntry extends StatefulWidget {
  const _DemoEntry({required this.onEntered});
  final VoidCallback onEntered;
  @override
  State<_DemoEntry> createState() => _DemoEntryState();
}

class _DemoEntryState extends State<_DemoEntry> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('DGI PROXIMOBILE')),
        body: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Connexion de démonstration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Accès fictif local, sans connexion DGI. Utilisez alex.demo@example.cd. Aucun mot de passe de portail officiel n’est demandé.'),
            const SizedBox(height: 24),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email de démonstration'),
              validator: (value) => value?.trim().toLowerCase() == AppConfig.demoEmail
                  ? null : 'Utilisez le compte de démonstration indiqué.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) widget.onEntered();
              },
              child: const Text('Entrer en démonstration'),
            ),
          ])),
        )),
      );
}
