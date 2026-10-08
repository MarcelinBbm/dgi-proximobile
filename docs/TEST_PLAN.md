# Plan de tests — DGI PROXIMOBILE

Statut : plan de validation. Aucun test exécutable n’est livré ou exécuté dans ce premier lot documentaire. Chaque résultat devra être rattaché à un commit, une version SDK, un appareil et un environnement.

## Stratégie

Tests unitaires des modèles, validations, repositories, statuts et idempotence. Tests widget des écrans et de la navigation. Tests d’intégration Flutter des parcours DEMO/API. Tests PHP et HTTP avec base de test isolée. Tests manuels des permissions caméra, liens externes, accessibilité et réseau instable.

Aucune donnée fiscale réelle dans les fixtures ou captures. Utiliser des transports et horloges injectables pour tester erreurs, expirations et dates de façon déterministe. Ne pas automatiser des écritures dans les portails officiels.

## Matrice minimale — 31 parcours

| ID | Parcours | Critère d’acceptation |
|---|---|---|
| T01 | Lancement | Splash puis écran cohérent avec session et mode, sans exception |
| T02 | Navigation | Exactement quatre destinations contribuables, état et retour préservés |
| T03 | Accueil | Six cartes en grille, deux grandes cartes et textes demandés lisibles |
| T04 | Services | Huit services et trois outils d’accompagnement accessibles |
| T05 | Liens officiels | Confirmation préalable, navigateur externe, annulation sans ouverture |
| T06 | Connexion DEMO | Email de démonstration accepté, mode et identité fictive visibles |
| T07 | Création demande | Validation, référence et une seule création après succès |
| T08 | Filtres | Toutes, En cours et Terminées correspondent aux statuts documentés |
| T09 | Détail | Référence, historique, messages et avertissement DEMO présents |
| T10 | Message | Texte validé, ajout autorisé, persistance, pas de doublon au retry |
| T11 | Rendez-vous | Motif/service/centre/date/créneau validés, état À confirmer |
| T12 | Statut agent DEMO | Transition simulée, historique cohérent, avertissement permanent |
| T13 | Notifications | Liste et lecture persistantes, contenu verrouillage non sensible |
| T14 | Hors connexion | Avertissement exact et demande en_attente_envoi persistée |
| T15 | Reconnexion | Synchronisation proposée et contrôlée, une seule demande créée |
| T16 | API indisponible | Message générique, Réessayer, aucun basculement DEMO silencieux |
| T17 | QR caméra | Permission accordée/refusée, scan interrompu, aucun résultat fiscal fabriqué |
| T18 | QR malveillant | Schémas dangereux, hôtes externes et contenu excessif rejetés |
| T19 | Persistance locale | Redémarrage conserve brouillons/file, sépare comptes et modes |
| T20 | Déconnexion | Jeton supprimé/révoqué selon mode, aucune fuite inter-utilisateur |
| T21 | Session expirée | Envoi arrêté, réauthentification demandée, brouillon conservé protégé |
| T22 | États réseau | Chargement, succès, erreur, vide et hors connexion sans écran bloqué |
| T23 | Centres | Données validées uniquement, téléphone/maps absents si non configurés |
| T24 | Assistant | FAQ guidée et avertissement, aucune décision ou échéance inventée |
| T25 | Facture normalisée | Contenu et sources visibles, accès e-DEF avec confirmation |
| T26 | Vérification référence | Aucun faux verdict, aucun transfert à une API non autorisée |
| T27 | Profil | Identité non vérifiée tant qu’aucune validation réelle n’existe |
| T28 | Accessibilité | Cibles ≥48 unités logiques, texte agrandi, lecteurs d’écran et petit écran |
| T29 | API validation | Champs inconnus/invalides, méthode interdite et corps excessif rejetés |
| T30 | API autorisations | Accès aux demandes/messages d’un autre compte ou centre refusé |
| T31 | API idempotence | Timeout/retry/double clic créent un résultat unique, conflit détecté |

## Assertions de sûreté

| Situation | Résultat obligatoire |
|---|---|
| Document en DEMO | « Démonstration — aucun document réel n’est vérifié localement. » |
| Messages DEMO | « Historique et messages fictifs. Aucun échange réel avec un agent. » |
| Rendez-vous créé | « Rendez-vous demandé — À confirmer » |
| Réseau absent | « Vous êtes hors connexion. La demande sera envoyée lorsque la connexion sera disponible. » |
| Assistant nécessitant confirmation | « Pour confirmation officielle, veuillez consulter le service compétent de la DGI. » |
| Identité non validée | « Identité fiscale non vérifiée » |
| Erreur API | « Le service est momentanément indisponible. » et bouton Réessayer |

Le texte hors connexion ne doit pas faire croire à une synchronisation garantie quand l’application est fermée. Vérifier aussi l’absence de collecte d’identifiants de portails DGI et de logs contenant données fiscales, jetons ou messages privés.

## Backend

Vérifier les enveloppes JSON et codes 200, 201, 400, 401, 403, 404, 422 et 500 ; ajouter 409 et 429 pour conflits et limitation. Vérifier expiration/révocation, prepared statements, transactions, rollback, contraintes FK, pagination et unicité. Exécuter le schéma et les fixtures séparément sur MySQL 5.7 et 8 si ces deux versions sont annoncées compatibles. Un compte DEMO ou agent simulé doit être inaccessible lorsque le mode DEMO serveur est désactivé.

## Plateformes et preuves

Tester Android 10 à Android 16 lorsque les émulateurs/appareils et SDK le permettent ; documenter chaque version réellement vérifiée. Contrôler minimum API 24 ou supérieur après configuration. Tester au moins un téléphone physique, petit écran, texte agrandi, refus caméra, perte réseau pendant envoi et fermeture avant accusé réception. La compatibilité iOS nécessite sa propre compilation et ne se déduit pas de celle d’Android.

## Commandes prévues

Après création effective de mobile/ :

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter test integration_test
flutter build apk --release
flutter build appbundle --release
```

Depuis la racine, après création des fichiers backend/ :

```bash
find backend -type f -name '*.php' -print0 | xargs -0 -n1 php -l
```

Les tests PHP et HTTP devront disposer d’une commande reproductible définie avec leur implémentation. Les tests d’intégration Flutter nécessitent un appareil ou émulateur compatible. La signature de publication n’est pas remplacée par une signature debug.

## Critère de livraison

Aucun contrôle annoncé comme réussi sans preuve. Pour chaque release : commit source, versions outils, sortie analyze/test/lint, résultats API, matrice appareils, empreintes des artefacts, identité de signature et limites connues. Si un contrôle n’est pas exécuté, le marquer « Non exécuté ». Un build réussi seul ne prouve ni tous les parcours ni une autorisation institutionnelle DGI.
