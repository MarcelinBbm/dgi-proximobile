# DGI PROXIMOBILE

« Votre assistant fiscal de proximité »

Le contexte fonctionnel retient la télédéclaration, l’immatriculation en ligne, l’e-NIF, l’authentification des documents fiscaux, la facture normalisée émise au moyen d’un dispositif électronique fiscal et la réforme de la fiscalité directe concernant notamment l’impôt sur les sociétés et l’impôt sur le revenu des personnes physiques.

## État du projet

Projet en préparation : ce premier lot contient uniquement la documentation et les exclusions Git. L’application Flutter, l’API PHP, la base MySQL et les tests exécutables ne sont pas encore implémentés. Aucun APK ni AAB n’a été compilé ou testé.

Ce prototype n’est pas une application officielle DGI déjà mise en production. Tout usage institutionnel nécessite une validation et des autorisations de la DGI.

## Architecture prévue

Application Flutter native, Material 3, Android en priorité avec architecture compatible iOS. API REST PHP 8+, PDO et MySQL 5.7/8, compatible avec un hébergement Hostinger HTTPS.

- `mobile/` : application, assets et tests Flutter à créer.
- `backend/` : API, schéma MySQL et tests à créer.
- `docs/ARCHITECTURE.md` : architecture cible et frontières de confiance.
- `docs/TEST_PLAN.md` : parcours et critères de validation.

## Modes

Le mode DEMO utilise des données fictives identifiables. Le mode API se connecte uniquement au backend configuré. Une panne ne doit jamais remplacer silencieusement des données réelles par des données fictives. Le passage en démonstration doit être proposé explicitement et isoler les données locales.

Les futurs accès aux API officielles nécessitent des contrats et autorisations DGI. Aucun accès de ce type n’est implémenté ou supposé disponible.

## Garde-fous

Ne pas collecter les identifiants des portails externes DGI. Ne pas fabriquer de résultat d’authentification documentaire, de déclaration envoyée ou de décision fiscale. Un rendez-vous reste « À confirmer » sans validation réelle. L’identité fiscale reste « Identité fiscale non vérifiée » sans rattachement validé.

L’email seul est réservé à la démonstration. En production, utiliser une authentification validée, des sessions sécurisées et des habilitations serveur ; MFA pour les agents.

## Configuration prévue

L’URL du backend sera centralisée dans `mobile/lib/config/app_config.dart`. Les portails officiels seront centralisés dans `mobile/lib/config/official_links.dart`. Les secrets MySQL et autres secrets restent côté serveur, hors racine publique et hors dépôt.

## Commandes de validation à exécuter après implémentation

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Ces commandes ne sont pas encore exécutables sur ce lot documentaire. La signature release, les versions SDK et les permissions devront être configurées et vérifiées sur l’environnement de compilation.

## Confidentialité

Le dépôt est public : aucun secret, fichier de signature, jeton, document fiscal réel ou donnée personnelle de contribuable ne doit y être ajouté. Les profils et échanges de présentation doivent être fictifs et signalés comme tels.
