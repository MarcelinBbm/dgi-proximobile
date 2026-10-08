#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE="$ROOT/mobile"
command -v flutter >/dev/null || { echo 'Flutter est requis.' >&2; exit 1; }
test -f "$MOBILE/pubspec.yaml" || { echo 'mobile/pubspec.yaml introuvable.' >&2; exit 1; }

# Generate only missing platform files; never overwrite application source.
if [ ! -d "$MOBILE/android" ]; then
  TEMPLATE="$(mktemp -d)"
  trap 'rm -rf "$TEMPLATE"' EXIT
  flutter create --platforms=android --project-name=dgi_proximobile \
    --org=cd.proximobile.demo --no-pub "$TEMPLATE/generated"
  cp -R "$TEMPLATE/generated/android" "$MOBILE/android"
  cp "$TEMPLATE/generated/.metadata" "$MOBILE/.metadata"
fi

python3 - "$MOBILE" <<'PY'
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

mobile = pathlib.Path(sys.argv[1])
gradle_candidates = [mobile / 'android/app/build.gradle.kts', mobile / 'android/app/build.gradle']
gradle = next((p for p in gradle_candidates if p.exists()), None)
if gradle is None:
    raise SystemExit('Configuration Gradle non reconnue.')
text = gradle.read_text()
if gradle.suffix == '.kts':
    text, count = re.subn(r'minSdk\s*=\s*[^\r\n]+', 'minSdk = 24', text)
else:
    text, count = re.subn(r'minSdkVersion\s+[^\r\n]+', 'minSdkVersion 24', text)
if count != 1:
    raise SystemExit('Impossible de configurer minSdk de manière sûre.')
gradle.write_text(text)

manifest = mobile / 'android/app/src/main/AndroidManifest.xml'
ns = 'http://schemas.android.com/apk/res/android'
ET.register_namespace('android', ns)
tree = ET.parse(manifest)
root = tree.getroot()
app = root.find('application')
if app is None:
    raise SystemExit('Application Android introuvable.')
app.set(f'{{{ns}}}label', 'DGI PROXIMOBILE — DEMO')
app.set(f'{{{ns}}}usesCleartextTraffic', 'false')
if not any(p.get(f'{{{ns}}}name') == 'android.permission.INTERNET' for p in root.findall('uses-permission')):
    permission = ET.Element('uses-permission', {f'{{{ns}}}name': 'android.permission.INTERNET'})
    root.insert(0, permission)
tree.write(manifest, encoding='utf-8', xml_declaration=True)
print('Plateforme Android préparée : minSdk 24, trafic clair désactivé.')
PY

printf '%s\n' 'Sources Dart préservées. Signature debug uniquement pour ce lot.'
