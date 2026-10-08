# Compilation Android et validation distante

Ce guide décrit le workflow du socle Flutter. Il ne constitue pas une preuve que les tests ou la compilation ont réussi. Consulter les résultats de chaque exécution GitHub Actions.

## GitHub Actions

Le fichier `.github/workflows/flutter-android.yml` déclenche la validation lors des changements de sources, script ou workflow sur `feature/dgi-proximobile`, ainsi que lors des pull requests vers main. Aucun déploiement ni commit automatique n’est effectué. Le jeton du job a seulement `contents: read`.

Le runner Ubuntu installe Java 17 et Flutter stable, puis enregistre leurs versions et le commit source. Le canal stable facilite la première mise en route ; après le premier résultat validé, il faudra épingler le SDK exact et conserver le lockfile validé. Les actions tierces doivent également être épinglées à des commits vérifiés avant un usage de production.

La préparation Android génère une application temporaire, copie uniquement Android et les métadonnées lorsqu’ils manquent, puis configure minSdk 24, le nom DEMO et le refus du trafic HTTP en clair. Les fichiers Dart, tests et pubspec ne sont jamais remplacés. compileSdk et targetSdk restent ceux du modèle du SDK Flutter installé et doivent être contrôlés dans les journaux.

Le job exécute ensuite pub get, analyze, test et build apk --debug. Chaque étape bloque la suivante en cas d’échec. Les journaux sont conservés même en cas d’échec. L’APK et l’archive du projet Android préparé sont déposés uniquement après réussite de la compilation et du conditionnement.

## Téléchargements

Ouvrir https://github.com/MarcelinBbm/dgi-proximobile/actions et sélectionner l’exécution correspondant au commit souhaité.

| Artefact | Contenu |
|---|---|
| validation-logs | Versions outils, résultats des commandes, rapport JSON des tests lorsqu’ils ont été lancés |
| android-demo-debug | APK debug, projet préparé et empreintes SHA-256 après réussite |

Les liens de téléchargement sont fournis par GitHub dans l’exécution, pas fabriqués à l’avance. Le workflow ne publie aucune release officielle. Les artefacts sont configurés pour une conservation de 14 jours, sous réserve des politiques du dépôt. Le téléchargement peut nécessiter une connexion GitHub.

L’archive contient Android, les sources et le lockfile produit par cette exécution. Elle exclut caches, build, local.properties et le workflow. L’APK debug sert aux essais du socle, pas à une publication Play Store. Il n’est pas l’application métier complète et ne prouve pas un essai sur téléphone.

## Exécution locale

Installer Flutter stable, Android SDK, Java compatible avec le SDK utilisé, puis vérifier les licences Android et un téléphone/émulateur.

Depuis la racine du dépôt :

```bash
flutter doctor -v
bash scripts/bootstrap_android.sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=APP_MODE=demo
flutter build apk --debug --dart-define=APP_MODE=demo
```

L’APK local se trouve normalement dans `mobile/build/app/outputs/flutter-apk/app-debug.apk` après réussite. Le script exige bash et Python 3 ; sous Windows utiliser un environnement adapté ou le runner GitHub. Les dossiers générés localement ne sont pas automatiquement enregistrés dans Git.

## API et signature

APP_MODE=api et API_BASE_URL configurent uniquement le futur backend. Le socle actuel n’implémente pas encore son transport HTTP. Aucun serveur DGI n’est connecté.

Une release ultérieure exige une configuration de signature dédiée, avec secrets hors dépôt. Ne pas présenter le modèle Android utilisant une clé debug comme une signature de publication. Les commandes attendues après configuration et validation seront :

```bash
flutter build apk --release --dart-define=APP_MODE=demo
flutter build appbundle --release --dart-define=APP_MODE=demo
```

Ces deux commandes ne sont pas exécutées dans le workflow actuel. iOS nécessite un environnement macOS et une validation séparée. Les versions Android 10 à 16 doivent être testées individuellement avant toute annonce de compatibilité.

## Limites et récupération

Si les workflows sont désactivés, un administrateur doit les autoriser dans les réglages Actions du dépôt. Si le connecteur ne peut pas écrire `.github/workflows/`, créer le fichier exact dans GitHub sur la branche convenue, avec une autorisation workflow appropriée. Ne jamais transmettre un jeton dans une conversation.

Une erreur d’analyse ou de test doit être corrigée dans le code concerné après lecture du résultat ; ne pas contourner le contrôle. Un manque de SDK ou une erreur de signature ne doit pas être présenté comme une panne API. Toujours distinguer workflow créé, job déclenché, tests réussis, build réussi et essai réel sur appareil.
