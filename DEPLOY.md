# 🚀 Guide de déploiement — Booqly

> Stack : Flutter (Android / iOS) + ASP.NET Core 8 + PostgreSQL

---

## Sommaire

1. [Déployer le backend](#1-déployer-le-backend-aspnet-core-8)
2. [Configurer la base de données](#2-base-de-données-postgresql)
3. [Mettre à jour l'URL dans Flutter](#3-mettre-à-jour-lurl-dans-flutter)
4. [Build Android](#4-build-android)
5. [Build iOS](#5-build-ios-mac-requis)
6. [Variables d'environnement](#6-variables-denvironnement)
7. [Checklist finale](#7-checklist-finale)

---

## 1. Déployer le backend ASP.NET Core 8

### Option A — Railway ⭐ (recommandé pour démarrer)

Le plus simple : détection automatique de .NET, déploiement en 5 minutes.

```bash
# Installer Railway CLI
npm install -g @railway/cli

# Depuis la racine du projet backend
cd backend

# Connexion + initialisation
railway login
railway init      # "Create new project" → donne un nom (ex: booqly-api)

# Premier déploiement
railway up

# Récupère l'URL publique dans le dashboard Railway :
# https://booqly-api.up.railway.app
```

Ajouter les variables d'environnement dans le dashboard Railway → Settings → Variables :

```
ConnectionStrings__Default   = postgresql://user:pass@host:5432/booqly
Jwt__Secret                  = une_clé_aléatoire_de_minimum_32_caractères
Jwt__Issuer                  = https://booqly-api.up.railway.app
Jwt__Audience                = booqly-app
ASPNETCORE_ENVIRONMENT       = Production
ASPNETCORE_URLS              = http://+:$PORT
```

---

### Option B — Render (gratuit)

1. Va sur [render.com](https://render.com) → **New Web Service**
2. Connecte ton dépôt GitHub
3. Configure :

```
Root Directory  : backend
Build Command   : dotnet publish src/Booqly.API -c Release -o out
Start Command   : dotnet out/Booqly.API.dll
Runtime         : .NET
```

4. Ajoute les variables d'environnement dans l'onglet **Environment** (voir [section 6](#6-variables-denvironnement)).

---

### Option C — Azure App Service (.NET natif)

```bash
# Publier en local
cd backend/src/Booqly.API
dotnet publish -c Release -o ./publish

# Connexion Azure
az login

# Créer le service (une seule fois)
az group create --name booqly-rg --location westeurope
az appservice plan create --name booqly-plan --resource-group booqly-rg --sku F1 --is-linux
az webapp create --name booqly-api --resource-group booqly-rg \
  --plan booqly-plan --runtime "DOTNETCORE:8.0"

# Déployer
az webapp deploy --name booqly-api --resource-group booqly-rg \
  --src-path ./publish --type zip

# URL : https://booqly-api.azurewebsites.net
```

---

### Option D — VPS avec Docker

Créer un `Dockerfile` à la racine de `backend/` :

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish src/Booqly.API -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Booqly.API.dll"]
```

```bash
# Builder et pusher sur Docker Hub
docker build -t tonpseudo/booqly-api:latest .
docker push tonpseudo/booqly-api:latest

# Sur le VPS
docker pull tonpseudo/booqly-api:latest
docker run -d -p 80:80 \
  -e ConnectionStrings__Default="..." \
  -e Jwt__Secret="..." \
  --name booqly-api \
  tonpseudo/booqly-api:latest
```

---

## 2. Base de données PostgreSQL

### Neon.tech (gratuit, recommandé)

1. Crée un compte sur [neon.tech](https://neon.tech)
2. **New Project** → nom : `booqly`
3. Copie la **Connection string** :
   ```
   postgresql://user:pass@ep-xxx.eu-central-1.aws.neon.tech/booqly?sslmode=require
   ```
4. Colle-la dans `ConnectionStrings__Default` de ton hébergement.

### Supabase (alternative)

1. [supabase.com](https://supabase.com) → New Project
2. Settings → Database → **Connection string** (URI mode)
3. Même manipulation que Neon.

---

## 3. Mettre à jour l'URL dans Flutter

Une fois l'API déployée, ouvre `lib/core/constants/api_constants.dart` et remplace la ligne 5 :

```dart
// Avant (dev local)
static const String baseUrl = 'http://10.0.2.2:5000/api';

// Après (production)
static const String baseUrl = 'https://booqly-api.up.railway.app/api';
```

---

## 4. Build Android

### APK direct (partage par lien / WhatsApp / Drive)

```bash
flutter build apk --release

# Fichier généré :
# build/app/outputs/flutter-apk/app-release.apk
```

### Google Play Store (AAB signé)

#### Étape 1 — Générer une keystore (une seule fois)

```bash
keytool -genkey -v \
  -keystore android/booqly.jks \
  -alias booqly \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> ⚠️ **Conserve ce fichier `.jks` précieusement.** Sans lui, tu ne pourras plus mettre à jour l'app sur le Play Store.

#### Étape 2 — Créer `android/key.properties`

```properties
storePassword=TON_MOT_DE_PASSE
keyPassword=TON_MOT_DE_PASSE
keyAlias=booqly
storeFile=../booqly.jks
```

> Ajoute `android/key.properties` et `android/*.jks` dans `.gitignore`.

#### Étape 3 — Référencer dans `android/app/build.gradle`

Ajoute en haut du fichier (avant `android {`) :

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dans le bloc `android > buildTypes` :

```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

#### Étape 4 — Vérifier l'identifiant de l'app

Dans `android/app/build.gradle` :

```groovy
defaultConfig {
    applicationId "com.tonnom.booqly"   // ← unique sur le Play Store
    versionCode 1
    versionName "1.0.0"
}
```

#### Étape 5 — Builder l'AAB

```bash
flutter build appbundle --release

# Fichier généré :
# build/app/outputs/bundle/release/app-release.aab
```

Upload ce fichier dans la [Google Play Console](https://play.google.com/console).

---

## 5. Build iOS (Mac requis)

> Nécessite : Mac + Xcode + compte Apple Developer (99 $/an)

```bash
# Ouvrir le projet dans Xcode pour configurer le Bundle ID et le signing
open ios/Runner.xcworkspace

# Builder l'IPA
flutter build ipa --release

# Ensuite dans Xcode :
# Product → Archive → Distribute App → App Store Connect
```

---

## 6. Variables d'environnement

À configurer sur ton hébergement backend (Railway, Render, Azure…).

| Variable | Valeur |
|----------|--------|
| `ConnectionStrings__Default` | Chaîne PostgreSQL complète |
| `Jwt__Secret` | Clé aléatoire 32+ caractères |
| `Jwt__Issuer` | URL publique de l'API |
| `Jwt__Audience` | `booqly-app` |
| `Jwt__ExpiresInMinutes` | `60` |
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `ASPNETCORE_URLS` | `http://+:$PORT` (Railway/Render) |

**Générer un JWT Secret sécurisé :**

```bash
# Sur Linux/Mac
openssl rand -base64 48

# Sur Windows PowerShell
[System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
```

---

## 7. Checklist finale

### Backend

- [ ] API déployée et accessible (`GET /health` ou `/api/professionals` répond)
- [ ] Base de données PostgreSQL connectée (migrations appliquées)
- [ ] JWT Secret configuré (32+ caractères)
- [ ] HTTPS activé (Railway/Render/Azure le font automatiquement)
- [ ] CORS configuré pour autoriser les requêtes Flutter

### Flutter

- [ ] `baseUrl` mis à jour avec l'URL de production
- [ ] `applicationId` unique dans `build.gradle`
- [ ] Keystore générée et sécurisée (hors dépôt git)
- [ ] `versionCode` / `versionName` corrects
- [ ] APK ou AAB buildé en mode release (`--release`)
- [ ] Testé sur un vrai appareil Android avant soumission

### Play Store (si applicable)

- [ ] Compte Google Play Console créé (25 $ une seule fois)
- [ ] Screenshots de l'app préparées (2-8 par format)
- [ ] Icône 512×512 px préparée
- [ ] Description de l'app rédigée (FR + EN)
- [ ] Politique de confidentialité publiée (obligatoire)

---

## Résumé — chemin le plus rapide

```
1. Créer une base PostgreSQL sur Neon.tech (5 min)
2. Déployer le backend sur Railway (10 min)
3. Mettre à jour baseUrl dans api_constants.dart (1 min)
4. flutter build apk --release (5 min)
5. Envoyer l'APK par lien de téléchargement
```

**Total : environ 20 minutes** pour avoir l'app fonctionnelle sur des appareils Android réels.
