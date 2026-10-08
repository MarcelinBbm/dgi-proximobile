# Architecture cible — DGI PROXIMOBILE

Statut : spécification du premier lot documentaire, pas une implémentation validée.

## Périmètre et références

Flutter natif, Material 3 et null safety. Android prioritaire, architecture compatible iOS. Backend PHP 8+, PDO, MySQL 5.7/8 et HTTPS, compatible Hostinger. Les références fournies sont le document « Conception DGI PROXIMOBILE » et le prototype HTML. Le prototype sert de référence, il ne sera pas encapsulé dans une WebView. Le logo doit être extrait d’une référence autorisée puis vérifié ; aucun logo de remplacement ne doit être présenté comme officiel.

## Structure

```text
dgi-proximobile/
  mobile/
    android/
    ios/
    assets/branding/
    assets/demo/
    lib/
      main.dart
      app.dart
      config/
      models/
      services/
      repositories/contracts/
      repositories/demo/
      repositories/remote/
      providers/
      screens/
      widgets/
    test/
    integration_test/
    pubspec.yaml
  backend/
    public/api/
    src/Auth/
    src/Controllers/
    src/Repositories/
    src/Validation/
    src/Http/
    database/
    tests/
    .env.example
  docs/
```

## Séparation des responsabilités

Les écrans affichent les états et délèguent les actions aux providers. Provider est le choix de gestion d’état du prototype. Les providers utilisent des contrats de repositories ; les implémentations DEMO et HTTP sont distinctes. Les services transversaux gèrent transport HTTP, stockage sécurisé, persistance, connectivité et lancement des portails officiels.

L’URL API est centralisée dans `mobile/lib/config/app_config.dart`. Les liens externes sont centralisés dans `mobile/lib/config/official_links.dart`. Les versions de packages et les SDK Android doivent être déterminés dans l’environnement Flutter disponible, verrouillés et testés, pas déclarés compatibles sans compilation.

## Navigation et interface

NavigationBar contribuable avec exactement quatre destinations : Accueil, Services, Mes demandes, Mon compte. Les écrans de détail restent rattachés à leur destination. La vue agent de démonstration est séparée du parcours contribuable.

Palette : bleu #0D47A1, bleu foncé #07336B, fond #F4F6FA, blanc #FFFFFF, vert #1E9E55, orange #F59E0B, rouge #E91E4D, violet #7C3AC8, turquoise #08A0B5. Cibles tactiles d’au moins 48 unités logiques Flutter ; prise en charge de l’agrandissement de texte et des petits écrans. En-tête commun avec logo, titre, slogan et notifications. La grille d’accueil conserve ses six services sur trois colonnes sans troncature essentielle.

## Modules fonctionnels

| Module | Responsabilité |
|---|---|
| Accueil et Services | Orientation vers les huit services et trois outils d’accompagnement |
| Profil fiscal | Identité non vérifiée tant qu’aucun rattachement officiel validé n’existe |
| Assistant | FAQ guidée et orientation, sans décision fiscale |
| Facture normalisée | Contenu versionné et accès officiel e-DEF |
| Vérification documentaire | Référence ou scan QR, sans authentification locale fabriquée |
| Assistance | Formulaire validé, brouillon et envoi idempotent |
| Mes demandes | Filtres, détail, historique et échanges |
| Rendez-vous | Demande de créneau, statut À confirmer par défaut |
| Centres | Données validées, recherche et actions téléphone/cartographie |
| Notifications | Informations génériques, sans donnée fiscale sur écran verrouillé |
| Agent DEMO | Simulation affichée explicitement, sans accès privilégié réel |
| Guides et actualités | Source, date, lien officiel et validation éditoriale |

## Modes et confiance

DEMO : utilisateur fictif Alex M., `alex.demo@example.cd`, références DEMO-001 à DEMO-003 et messages fictifs. Le mode email seul est admis uniquement ici. Afficher « Données de démonstration » et les avertissements spécifiques.

API : backend de l’organisation, pas une API DGI présumée officielle. Une panne propose explicitement le mode DEMO ; elle ne transforme jamais les demandes réelles en données fictives. Partitionner caches et files d’attente par utilisateur, environnement et mode. Les demandes DEMO ne sont jamais synchronisées vers un service réel.

Intégration officielle future : adapter dédié uniquement après contrat, documentation et autorisation DGI. Aucun endpoint officiel privé n’est inventé.

## Portails externes

| Service | URL fournie dans le cahier des charges |
|---|---|
| Institutionnel | https://dgi.gouv.cd/ |
| e-DEF | https://edef.dgirdc.cd/ |
| Authentification documentaire | https://dgi.gouv.cd/verifier-un-document-authentification-qr-n/ |
| Communiqués | https://dgi.gouv.cd/communiques-officiels/ |

Les autres URL restent non configurées jusqu’à validation DGI. Avant ouverture avec url_launcher : « Vous allez être redirigé vers un service officiel de la DGI. » Lancer en navigateur externe, gérer l’échec. Un QR n’est pas une URL fiable : rejeter les schémas dangereux et hôtes non autorisés, ne jamais ouvrir automatiquement son contenu. Sans API autorisée, ne pas prétendre transmettre ou vérifier la référence.

## API et données

Endpoints prévus : config.php, login.php, profil.php, demandes.php, demande_detail.php, messages.php, centres.php, notifications.php, rendezvous.php, faq.php, health.php. config.php initialise l’application et ne publie aucun secret. Prévoir aussi des endpoints publics de lecture pour guides et actualités.

Enveloppe JSON `success`, `message`, `data`. Réponses adaptées : 200, 201, 400, 401, 403, 404, 422, 500 ; prévoir 409 pour conflit et 429 pour limitation. Les erreurs internes ne révèlent aucune trace SQL. Méthodes et champs autorisés doivent être documentés avant implémentation.

Tables métier : users, demandes, messages, notifications, centres_fiscaux, rendezvous, faq, guides, actualites. Tables complémentaires : sessions, historique_demandes et clés d’idempotence. Ajouter created_at, updated_at lorsque pertinent, clés étrangères, index de recherche et contraintes d’unicité. Utiliser utf8mb4 et des dates serveur UTC, affichées dans le fuseau approprié sans le supposer à partir du téléphone.

Statuts : brouillon, en_attente_envoi, recue, affectee, en_cours, attente_contribuable, resolue, cloturee, a_confirmer. Le serveur contrôle transitions et rôles ; le client ne décide pas de ses propres habilitations. L’historique est enregistré transactionnellement avec chaque changement.

## Hors connexion

La connectivité réseau est un indicateur, pas la preuve que l’API répond. Cache des guides publics, stockage durable des brouillons et file d’envoi protégée. SharedPreferences est réservé aux réglages non sensibles. Jetons dans flutter_secure_storage ; données personnelles locales chiffrées avec gestion du cycle de vie des clés.

Chaque envoi possède une clé d’idempotence persistante, unique par utilisateur et opération. Le serveur conserve le résultat ; une même clé avec un contenu différent produit un conflit. Après timeout, réutiliser la même clé. Synchronisation séquentielle ou verrouillée, retries bornés, arrêt sur session expirée et validation 422. Proposer une synchronisation contrôlée à la reconnexion. Ne pas promettre un envoi en arrière-plan lorsque l’application est fermée.

## Sécurité

HTTPS, requêtes PDO préparées, validation stricte et limites de taille. Secrets hors dépôt et racine publique. Tokens aléatoires, expirables, révocables et stockés hachés côté serveur. Contrôle de propriété des demandes/messages et périmètre centre/rôle des agents sur chaque endpoint. L’email seul et les actions agent simulées sont désactivés en production. MFA requis pour les agents réels.

Limiter les connexions et actions sensibles. Journaliser des événements techniques sans jeton, NIF, message personnel ou document fiscal. Échapper les contenus dans tout futur back-office. Notifications de verrouillage génériques ; consultation détaillée après authentification. Les pièces jointes restent une capacité future désactivée jusqu’à validation du stockage, des types, de la taille et de l’analyse de sécurité.

## Validation et publication

Chaque écran distant gère chargement, succès, erreur, vide, hors connexion et session expirée. Aucune échéance inventée. Aucune confirmation de rendez-vous sans validation réelle. Tests unitaires, widget, intégration, API et revue graphique avant release. Lint PHP, analyse Dart, tests et compilation doivent produire des preuves ; les contrôles non exécutés restent marqués comme tels.
