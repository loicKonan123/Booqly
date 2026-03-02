# DEV USING AI FOR CODING APP
### Le processus complet de développement d'une application avec l'IA

> Basé sur le développement réel de **Booqly** — application de réservation de rendez-vous (Flutter + ASP.NET Core 8)

---

## Table des matières

1. [La philosophie fondamentale](#1-la-philosophie-fondamentale)
2. [Phase 0 — La vision & le prompt initial](#2-phase-0--la-vision--le-prompt-initial)
3. [Phase 1 — L'architecture](#3-phase-1--larchitecture)
4. [Phase 2 — Le backend](#4-phase-2--le-backend)
5. [Phase 3 — Le frontend](#5-phase-3--le-frontend)
6. [Phase 4 — Les fonctionnalités](#6-phase-4--les-fonctionnalités)
7. [Phase 5 — Le design & l'UX](#7-phase-5--le-design--lux)
8. [Phase 6 — La sécurité & l'audit](#8-phase-6--la-sécurité--laudit)
9. [Phase 7 — Les tests](#9-phase-7--les-tests)
10. [Phase 8 — Le déploiement](#10-phase-8--le-déploiement)
11. [L'art du prompt](#11-lart-du-prompt)
12. [Les erreurs à éviter](#12-les-erreurs-à-éviter)
13. [Stack technique recommandée](#13-stack-technique-recommandée)

---

## 1. La philosophie fondamentale

### Le principe de base
Développer avec l'IA ne veut pas dire "demander à l'IA d'écrire du code". Ça veut dire **collaborer** avec l'IA comme tu collaborerais avec un développeur senior. Tu gardes le contrôle de la vision, l'IA exécute avec précision.

### Tes rôles
| Toi | L'IA |
|---|---|
| La vision produit | L'exécution technique |
| Les décisions architecture | L'implémentation des patterns |
| La validation fonctionnelle | Le debug et les corrections |
| La communication métier | La rigueur du code |

### La règle d'or
> **Une grande communication = un grand produit.**
> La qualité de ton application dépend directement de la qualité de tes prompts.

---

## 2. Phase 0 — La vision & le prompt initial

### Étape 1 : Définir le produit

Avant d'écrire une seule ligne de code, tu dois être capable de répondre à ces questions :

```
- Quel problème résout mon app ?
- Qui sont mes utilisateurs ? (rôles)
- Quelles sont les 5 fonctionnalités essentielles ?
- Sur quelle(s) plateforme(s) ? (iOS, Android, Web)
- Quel est mon délai ?
```

### Exemple réel — Booqly

**Le brief initial :**
```
Je veux créer une app de réservation de rendez-vous.
Il y a deux types d'utilisateurs :
- Les clients : ils cherchent des professionnels et réservent
- Les professionnels : ils gèrent leurs services, leurs horaires,
  leurs rendez-vous

Stack : Flutter (mobile + web) + ASP.NET Core 8 backend
```

### Étape 2 : Choisir sa stack AVANT de commencer

**Ne pas laisser l'IA choisir la stack.** C'est ta décision. L'IA va s'adapter.

Critères de choix :
- Ce que tu connais (ou veux apprendre)
- La communauté et les ressources disponibles
- Les contraintes de déploiement (budget, hébergement)
- La scalabilité prévue

---

## 3. Phase 1 — L'architecture

### C'est la phase la plus importante

L'architecture est le squelette de ton app. Une mauvaise architecture = refactoring douloureux plus tard. Prends le temps de la définir correctement.

### Le prompt d'architecture

```
Je construis [DESCRIPTION DE L'APP].
Stack : [FRONTEND] + [BACKEND].

Je veux une architecture [PATTERN] pour le backend :
- Pattern CQRS avec MediatR
- Clean Architecture (Domain / Application / Infrastructure / API)
- Entity Framework Core pour la BDD

Pour le frontend Flutter :
- Pattern Provider pour l'état
- go_router pour la navigation
- Architecture en couches (models / services / providers / screens)

Génère la structure complète des dossiers.
```

### Structure backend générée — Booqly

```
backend/src/
├── Booqly.Domain/
│   ├── Entities/          ← Objets métier purs (User, Appointment, Service...)
│   ├── Enums/             ← AppointmentStatus, UserRole...
│   └── Interfaces/        ← Contrats (IRepository, IUnitOfWork)
│
├── Booqly.Application/
│   ├── Common/
│   │   ├── DTOs/          ← Objets de transfert (ce qu'on renvoie au client)
│   │   └── Interfaces/    ← IJwtService, IEmailService, ISmsService
│   ├── Auth/Commands/     ← Login, Register, ForgotPassword
│   ├── Appointments/      ← CreateAppointment, UpdateStatus, GetMyAppointments
│   ├── Professionals/     ← GetProfessionals, GetById, UpdateProfessional
│   └── Services/          ← CreateService, UpdateService, DeleteService
│
├── Booqly.Infrastructure/
│   ├── Data/              ← AppDbContext, Migrations, Configurations EF
│   ├── Identity/          ← AppUser (ASP.NET Identity)
│   ├── Services/          ← JwtService, EmailService, SmsService
│   └── Jobs/              ← AppointmentReminderJob (Hangfire)
│
└── Booqly.API/
    ├── Controllers/       ← AuthController, AppointmentsController...
    ├── Extensions/        ← ClaimsPrincipalExtensions
    ├── Middlewares/        ← ExceptionMiddleware
    └── Program.cs         ← Configuration de l'app
```

### Structure frontend Flutter générée — Booqly

```
lib/
├── core/
│   ├── constants/         ← ApiConstants, AppStrings
│   ├── errors/            ← Exceptions, Failures
│   ├── network/           ← DioClient, AuthInterceptor
│   └── utils/             ← Validators, DateUtils
│
├── models/                ← User, Appointment, Professional, Service...
├── services/              ← AuthService, AppointmentService, NotificationService
├── providers/             ← AuthProvider, AppointmentProvider, ThemeProvider
│
├── screens/
│   ├── auth/              ← LoginScreen, RegisterScreen, ForgotPasswordScreen
│   ├── home/              ← HomeScreen (client)
│   ├── explore/           ← ExploreScreen, ProfessionalDetailScreen
│   ├── booking/           ← ServiceSelectScreen, SlotPickerScreen, BookingConfirmScreen
│   ├── appointments/      ← AppointmentsScreen, AppointmentDetailScreen
│   ├── dashboard/         ← DashboardScreen (pro), ServicesScreen, AvailabilityScreen
│   └── profile/           ← ProfileScreen, EditProfileScreen, ChangePasswordScreen
│
├── widgets/               ← BooqlyLogo, GlassField (composants réutilisables)
├── theme/                 ← AppColors, AppTheme
└── main.dart
```

### Pourquoi CQRS + MediatR ?

**CQRS** (Command Query Responsibility Segregation) = séparer les actions en lecture (Query) et écriture (Command).

```
Command = "Je veux CHANGER quelque chose"
  → CreateAppointmentCommand
  → RegisterCommand
  → UpdateProfileCommand

Query = "Je veux LIRE quelque chose"
  → GetMyAppointmentsQuery
  → GetProfessionalsQuery
  → GetProfessionalByIdQuery
```

**Avantage :** Chaque opération a son propre fichier. Facile à tester, facile à maintenir, facile à faire évoluer.

---

## 4. Phase 2 — Le backend

### Ordre de développement backend

```
1. Entities (les modèles de données)
2. DbContext + Migrations
3. Authentification (JWT)
4. Endpoints par feature (Commands + Queries + Controller)
```

### Le prompt type pour une feature backend

```
Je dois implémenter [FEATURE] dans mon backend ASP.NET Core 8.
Pattern : CQRS avec MediatR.

Entités concernées : [User, Appointment, etc.]

Crée :
1. La Command/Query record
2. Le Handler correspondant
3. Le DTO de retour
4. L'endpoint dans le Controller

Contraintes :
- Vérifier que l'utilisateur est autorisé (JWT)
- Gérer les erreurs métier avec des exceptions claires
- Pas de logique dans le Controller, tout dans le Handler
```

### Exemple — Création de rendez-vous

```csharp
// 1. La Command (ce qu'on reçoit)
public record CreateAppointmentCommand(
    Guid ClientId,
    Guid ProfessionalId,
    Guid ServiceId,
    string SlotId,
    string? Notes
) : IRequest<AppointmentDto>;

// 2. Le Handler (la logique métier)
public class CreateAppointmentCommandHandler : IRequestHandler<...>
{
    public async Task<AppointmentDto> Handle(...)
    {
        // Valider que le créneau est disponible
        // Vérifier les conflits
        // Créer le rendez-vous
        // Envoyer une notification
        // Retourner le DTO
    }
}

// 3. Le Controller (juste un relais)
[HttpPost]
public async Task<IActionResult> Create([FromBody] CreateBody body)
{
    var result = await mediator.Send(new CreateAppointmentCommand(...));
    return Ok(result);
}
```

### Patterns de sécurité backend

```csharp
// Toujours extraire l'utilisateur des claims JWT
var userId = User.GetUserId();
var role = User.GetRole();

// Toujours vérifier l'autorisation dans le Handler
if (req.Role == "client" && appointment.ClientId != req.UserId)
    throw new UnauthorizedAccessException();
```

---

## 5. Phase 3 — Le frontend

### Ordre de développement frontend Flutter

```
1. Configuration (DioClient, ApiConstants, ThemeProvider)
2. Authentification (login, register, token storage)
3. Navigation (go_router avec guards)
4. Models (fromJson / toJson)
5. Services (appels API)
6. Providers (état global)
7. Screens (UI)
```

### Le pattern Provider — Comment ça marche

```dart
// 1. Service → fait les appels HTTP
class AppointmentService {
  Future<List<Appointment>> getMyAppointments() async {
    final response = await DioClient.instance.get('/appointments/mine');
    return (response.data as List).map(Appointment.fromJson).toList();
  }
}

// 2. Provider → gère l'état et appelle le Service
class AppointmentProvider extends ChangeNotifier {
  final _service = AppointmentService();
  List<Appointment> _appointments = [];
  bool _loading = false;

  Future<void> loadMyAppointments() async {
    _loading = true;
    notifyListeners();
    _appointments = await _service.getMyAppointments();
    _loading = false;
    notifyListeners();
  }
}

// 3. Screen → écoute le Provider
class AppointmentsScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    if (provider.loading) return CircularProgressIndicator();
    return ListView(children: provider.appointments.map(...).toList());
  }
}
```

### La navigation avec go_router

```dart
// Guards d'authentification
redirect: (context, state) {
  final isAuth = context.read<AuthProvider>().isAuthenticated;
  final isPro = context.read<AuthProvider>().isProfessional;

  if (!isAuth) return '/login';
  if (isPro && state.matchedLocation == '/home') return '/dashboard';
  return null;
}
```

### Le prompt type pour un écran Flutter

```
Crée l'écran [NOM] en Flutter.

Données à afficher : [DESCRIPTION]
Provider utilisé : [NomProvider] avec les getters [loading, error, data]
Navigation : [depuis où, vers où]

Design : [dark glass / light / etc.]
Composants :
- Header avec gradient
- Liste scrollable avec SliverList
- État vide avec icône
- État erreur avec message
- Pull-to-refresh

Respecte les couleurs AppColors.primary et la police Poppins.
```

---

## 6. Phase 4 — Les fonctionnalités

### L'ordre logique de développement des features

```
Ordre recommandé :
1. Auth (sans ça, rien ne fonctionne)
2. Navigation et routing
3. La feature principale (core business)
4. Les features secondaires
5. Les notifications
6. Les paramètres / profil
```

### Pour Booqly, l'ordre était

```
1. Auth (Register / Login / JWT)
2. Routing conditionnel (client → /home, pro → /dashboard)
3. Gestion des professionnels (Explorer, Profil pro)
4. Réservation (Services → Créneaux → Confirmation)
5. Dashboard professionnel (RDV reçus, stats)
6. Notifications locales
7. Mot de passe oublié
8. Modifier profil / changer mot de passe
9. Disponibilités pro
10. Audit sécurité
```

### Comment aborder chaque feature

```
1. D'abord le modèle de données (Entity + DTO + Flutter model)
2. Ensuite le backend (Command/Query + Handler + Controller)
3. Enfin le frontend (Service + Provider + Screen)

Toujours dans cet ordre. Ne jamais faire le frontend sans le backend.
```

### Feature : Authentification JWT + Refresh Token

```dart
// AuthInterceptor — automatiquement attaché à chaque requête
onRequest: (options, handler) {
  final token = Hive.box('auth').get('access_token');
  if (token != null) options.headers['Authorization'] = 'Bearer $token';
  handler.next(options);
}

// Si 401 → essayer de refresh automatiquement
onError: (err, handler) async {
  if (err.response?.statusCode == 401) {
    final refreshed = await _tryRefresh();
    if (refreshed) {
      // Rejouer la requête originale avec le nouveau token
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    }
  }
  handler.next(err);
}
```

### Feature : Notifications locales (flutter_local_notifications)

```dart
// Initialisation au démarrage (main.dart)
if (!kIsWeb) {
  tz.initializeTimeZones();
  await NotificationService.instance.init();
}

// Permission Android 13+
await _plugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

// AndroidManifest.xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

// Notification immédiate
await _plugin.show(id, titre, corps, _details());

// Notification programmée (rappel 24h avant)
await _plugin.zonedSchedule(id, titre, corps, scheduledDate, _details(),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
```

---

## 7. Phase 5 — Le design & l'UX

### Les principes de base

**Choisir un style et s'y tenir.** Pour Booqly : dark glass + violet.

```
AppColors.primary = violet
AppColors.surface = fond des cartes
AppColors.brandGradient = violet → bleu (avatars, boutons)
Police = Poppins (Google Fonts)
Border radius standard = 18px (cartes), 14px (champs)
```

### Le prompt type pour le design

```
Améliore le design de [ÉCRAN].
Style : dark glass (fond sombre, cartes avec backdrop filter,
        border blanc 15% opacity)

Modifications :
- Header avec gradient violet doux, titre en gras
- Cartes avec shadow subtile
- Animations d'entrée : FadeTransition + SlideTransition
- États vides avec illustration et texte descriptif
- Pull-to-refresh avec couleur AppColors.primary

Conserve exactement la logique existante, change seulement le visuel.
```

### La responsivité — Pattern clé

```dart
// Ne jamais hardcoder des tailles fixes
// Utiliser clamp() pour adapter à tous les écrans

SizedBox(height: (size.height * 0.05).clamp(16.0, 40.0))
BooqlyLogo(size: (size.height * 0.10).clamp(50.0, 80.0))
Text(style: TextStyle(fontSize: size.height < 700 ? 22 : 28))

// Ne jamais utiliser SliverFillRemaining pour des états vides
// → ça provoque des BOTTOM OVERFLOWED quand le clavier est ouvert
// Utiliser SliverToBoxAdapter à la place
```

### Les animations — Pattern standard

```dart
// Animation d'entrée pour les listes (staggered)
TweenAnimationBuilder<double>(
  duration: Duration(milliseconds: 200 + index.clamp(0, 5) * 70),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (_, v, child) => Opacity(
    opacity: v,
    child: Transform.translate(
      offset: Offset(0, 20 * (1 - v)),
      child: child,
    ),
  ),
  child: _MyCard(...),
)
```

---

## 8. Phase 6 — La sécurité & l'audit

### Checklist sécurité obligatoire

**Backend :**
- [ ] JWT Secret = clé aléatoire de 48+ bytes (jamais un placeholder)
- [ ] Tokens JWT validés sur chaque endpoint `[Authorize]`
- [ ] Autorisation vérifiée dans chaque Handler (pas seulement le Controller)
- [ ] Mots de passe hashés par ASP.NET Identity (bcrypt)
- [ ] CORS restreint aux origines connues en production
- [ ] Secrets dans des variables d'environnement, jamais dans le code

**Frontend :**
- [ ] Tokens stockés en secure storage (flutter_secure_storage) en prod
- [ ] Pas d'IP hardcodée dans le code (utiliser String.fromEnvironment)
- [ ] Pas de clés API dans le code Flutter (visible dans le binaire)
- [ ] Validation des inputs côté client (validators) ET côté serveur

### Générer un JWT Secret sécurisé

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('base64'))"
# → EwYxtQIqLE8sTpldyJcAMCogAvseCnfroFGS34p8ZGt0PAQit13Pt8OmErtFC8lz
```

### URL configurable selon l'environnement

```dart
// api_constants.dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.2.32:5000/api', // défaut dev
);

// Utilisation
flutter run --dart-define=API_URL=http://10.0.2.2:5000/api
flutter build apk --dart-define=API_URL=https://api.booqly.com/api
```

### Le prompt d'audit sécurité

```
Fais un audit de sécurité complet de ce projet.
Vérifie :
1. Les secrets et clés hardcodées
2. Les endpoints non protégés
3. Les validations manquantes
4. Les données sensibles stockées en clair
5. Les injections SQL possibles
6. La gestion des erreurs (pas d'infos sensibles dans les messages)

Backend : [STACK]
Frontend : [STACK]
```

---

## 9. Phase 7 — Les tests

### Ma méthode de test = bout en bout, use case par use case

**Pas de tests unitaires automatisés pour commencer.** Tests manuels structurés d'abord.

### Scénario de test principal — Booqly

```
Scénario 1 : Inscription et connexion
  → Inscris un client → connecte-toi → vérifie le token JWT

Scénario 2 : Réservation complète
  → Client cherche un pro
  → Choisit un service
  → Choisit un créneau
  → Confirme → RDV créé
  → Notif reçue

Scénario 3 : Dashboard professionnel
  → Pro ouvre l'app
  → Voit le RDV du client
  → Reçoit une notif
  → Confirme ou annule

Scénario 4 : Gestion des erreurs
  → Mauvais mot de passe → message d'erreur clair
  → Créneau déjà pris → message d'erreur clair
  → Perte réseau → message d'erreur clair
```

### Tester un device physique Android

```bash
# Vérifier que le device est détecté
adb devices

# Backend accessible depuis le téléphone
# Changer localhost → IP de ton PC sur le réseau WiFi
# Autoriser le port dans le pare-feu Windows
netsh advfirewall firewall add rule name="Flutter Backend" dir=in action=allow protocol=TCP localport=5000

# Lancer sur le device
flutter run --dart-define=API_URL=http://[TON_IP]:5000/api
```

### Résoudre les bugs courants

| Erreur | Cause | Solution |
|---|---|---|
| `type 'String' is not a subtype of 'int'` | Le backend retourne une String, le code essaie de l'indexer comme un Map | Vérifier le type de la réponse avec `rawData is Map` |
| `BOTTOM OVERFLOWED BY X pixels` | `SliverFillRemaining` avec clavier ouvert | Remplacer par `SliverToBoxAdapter` |
| Connection timeout sur device physique | Backend écoute sur `localhost` seulement | Changer pour `0.0.0.0:5000` dans launchSettings.json |
| Notif pas reçue sur Android 13+ | Permission `POST_NOTIFICATIONS` non demandée | Ajouter dans AndroidManifest + demander au runtime |
| Notification ID négatif | `hashCode` peut être négatif | Utiliser `.abs()` |

---

## 10. Phase 8 — Le déploiement

### Checklist avant déploiement production

**Backend :**
```bash
# 1. Changer la connexion DB (LocalDB → SQL Server ou PostgreSQL)
# 2. Changer le JWT secret (variable d'environnement)
# 3. Restreindre CORS aux origines de production
# 4. Activer HTTPS
# 5. Configurer les logs
# 6. Appliquer les migrations
dotnet ef database update --connection "Server=PROD_SERVER;..."
```

**Flutter :**
```bash
# Android → APK signé
flutter build apk --release --dart-define=API_URL=https://api.booqly.com/api

# Android → App Bundle (Google Play)
flutter build appbundle --release --dart-define=API_URL=https://api.booqly.com/api

# iOS
flutter build ios --release --dart-define=API_URL=https://api.booqly.com/api

# Web
flutter build web --release --dart-define=API_URL=https://api.booqly.com/api
```

### Options d'hébergement backend

| Option | Coût | Facilité | Recommandé pour |
|---|---|---|---|
| Railway.app | Gratuit (limité) | ⭐⭐⭐⭐⭐ | MVP / démo |
| Render.com | Gratuit (limité) | ⭐⭐⭐⭐ | MVP / démo |
| Azure App Service | ~10€/mois | ⭐⭐⭐ | Production |
| VPS (Hetzner/OVH) | ~5€/mois | ⭐⭐ | Production avancée |

---

## 11. L'art du prompt

### Les règles d'or du prompt

**Règle 1 : Donne le contexte AVANT la demande**
```
❌ "Fais une notification quand un client réserve"

✅ "Dans mon app Flutter de réservation, quand un client
   (côté AppointmentProvider.book()) réserve un RDV,
   je veux que le professionnel reçoive une notification
   locale via NotificationService.instance.
   Utilise Hive box 'cache' pour tracker les IDs déjà vus."
```

**Règle 2 : Dis ce que tu ne veux PAS**
```
✅ "Modifie uniquement [X]. Ne touche pas au reste.
   N'ajoute pas de nouvelles dépendances.
   Ne change pas l'architecture existante."
```

**Règle 3 : Référence les fichiers existants**
```
✅ "Dans lib/providers/appointment_provider.dart,
   méthode loadMyAppointments(), ajoute..."
```

**Règle 4 : Demande d'abord, code ensuite**
```
✅ Utiliser le mode Plan pour les gros changements :
   → Claude explore le code
   → Propose un plan
   → Tu valides
   → Ensuite il code
```

**Règle 5 : Itère, ne réécris pas tout**
```
❌ "Refais tout l'écran explore"
✅ "Dans ExploreScreen, modifie seulement le header
   pour ajouter une animation de slide-in.
   Garde tout le reste identique."
```

### Types de prompts selon la situation

**Pour débugger une erreur :**
```
J'ai cette erreur : [ERREUR COMPLÈTE]
Ça arrive quand : [CONTEXTE]
Voici le fichier concerné : [CODE]
Je pense que c'est à cause de : [TON HYPOTHÈSE]
```

**Pour une nouvelle feature :**
```
Je veux ajouter : [FEATURE]
Fichiers impactés : [LISTE]
Contraintes : [CE QU'IL NE FAUT PAS TOUCHER]
Pattern existant à suivre : [EXEMPLE DANS LE CODE]
```

**Pour un audit :**
```
Analyse ce [FICHIER/MODULE] et dis-moi :
1. Les problèmes de sécurité
2. Les problèmes de performance
3. Les bugs potentiels
4. Ce qui est bien fait
Ne change rien, juste l'analyse.
```

**Pour le design :**
```
Améliore le visuel de [ÉCRAN] en suivant le design system existant.
Conserve la logique à 100%, change seulement l'UI.
Style de référence : [AUTRE ÉCRAN QUI MARCHE BIEN]
```

---

## 12. Les erreurs à éviter

### Erreurs de process

```
❌ Coder le frontend avant le backend
   → Tu vas inventer des APIs qui n'existent pas

❌ Tout demander en un seul prompt
   → L'IA va faire des compromis, le résultat sera approximatif

❌ Laisser l'IA choisir l'architecture
   → Tu ne comprendra pas ton propre code

❌ Ne pas lire le code généré
   → Tu auras des surprises en production

❌ Ignorer les warnings
   → Ils deviennent des bugs
```

### Erreurs techniques récurrentes

```
❌ Hardcoder des URLs, IPs, secrets dans le code
   → Utiliser String.fromEnvironment et les variables d'env

❌ Stocker des tokens en clair (localStorage, SharedPreferences)
   → Utiliser flutter_secure_storage

❌ Faire la logique dans le Controller
   → Tout dans les Handlers (CQRS)

❌ Un seul écran qui fait tout
   → Décomposer en widgets réutilisables

❌ Ignorer la gestion des erreurs réseau
   → Toujours avoir un état error + message clair pour l'utilisateur
```

---

## 13. Stack technique recommandée

### Stack Booqly (validée en production)

**Backend**
```
ASP.NET Core 8        → Framework web
Entity Framework Core → ORM (SQL Server / PostgreSQL)
ASP.NET Identity      → Auth + gestion des utilisateurs
MediatR               → CQRS (Commands/Queries)
JWT Bearer            → Authentification stateless
Hangfire              → Jobs planifiés (rappels de RDV)
MailKit               → Envoi d'emails
Twilio                → Envoi de SMS
```

**Frontend Flutter**
```
provider              → Gestion d'état global
go_router             → Navigation déclarative + guards
dio                   → Client HTTP + intercepteurs
hive + hive_flutter   → Stockage local (cache, auth)
flutter_secure_storage→  Stockage sécurisé (tokens)
flutter_local_notifications → Notifications locales
timezone              → Gestion des fuseaux horaires (rappels)
google_fonts          → Typographie (Poppins)
table_calendar        → Calendrier de sélection de créneaux
intl                  → Internationalisation (format dates FR)
```

**Outils**
```
Claude Code (CLI)     → Développement assisté par IA
VS Code               → IDE
Swagger               → Documentation et test de l'API
Postman               → Test des endpoints
ADB                   → Debug sur device Android physique
```

---

## Résumé du processus en 8 étapes

```
1. VISION          → Définir le produit, les rôles, les features clés
2. ARCHITECTURE    → Choisir les patterns, générer la structure des dossiers
3. BACKEND         → Entities → Auth → Features (CQRS)
4. FRONTEND        → Config → Auth → Navigation → Models → Screens
5. DESIGN          → Style cohérent, responsive, animations
6. FONCTIONNALITÉS → Core → Secondaires → Notifications → Profil
7. SÉCURITÉ        → Audit, corrections, variables d'env
8. DÉPLOIEMENT     → Build, hébergement, monitoring
```

---

> **Ce cours est vivant.** Il évolue avec chaque projet.
> La meilleure façon d'apprendre cette méthode, c'est de l'appliquer sur un vrai projet,
> d'itérer, et de comprendre chaque ligne de code générée.
>
> L'IA est un outil. La maîtrise reste entre tes mains.
