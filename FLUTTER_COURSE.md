# Cours Flutter Complet — Du débutant au projet avancé

> Basé sur un vrai projet : **Booqly** (app de réservation Flutter + ASP.NET Core 8)
> Tous les exemples viennent de code réel.

---

## Table des matières

1. [Dart — Le langage de base](#1-dart--le-langage-de-base)
2. [Flutter — Les fondamentaux](#2-flutter--les-fondamentaux)
3. [Widgets — Tout est un widget](#3-widgets--tout-est-un-widget)
4. [Layout — Mise en page](#4-layout--mise-en-page)
5. [State Management — Provider](#5-state-management--provider)
6. [Navigation — GoRouter](#6-navigation--gorouter)
7. [HTTP & API — Dio](#7-http--api--dio)
8. [Stockage local — Hive](#8-stockage-local--hive)
9. [Formulaires & Validation](#9-formulaires--validation)
10. [Thème — Light/Dark](#10-thème--lightdark)
11. [Animations](#11-animations)
12. [Architecture d'un vrai projet](#12-architecture-dun-vrai-projet)
13. [Patterns avancés](#13-patterns-avancés)
14. [Déploiement](#14-déploiement)

---

## 1. Dart — Le langage de base

### Variables et types

```dart
// Types de base
String nom = 'Booqly';
int age = 25;
double prix = 29.99;
bool actif = true;

// var = type inféré automatiquement
var titre = 'Rendez-vous';  // inféré comme String

// final = assigné une seule fois, évalué à l'exécution
final DateTime maintenant = DateTime.now();

// const = constante de compilation (plus performant)
const String appName = 'Booqly';

// Nullable : le ? signifie que la valeur peut être null
String? notes;           // peut être null
String clientName = '';  // jamais null

// Forcer la non-nullité avec !
String nom2 = notes!;    // ⚠️ crash si notes est null

// Opérateur null-safe
String affichage = notes ?? 'Aucune note';   // valeur par défaut
notes?.toUpperCase();                         // s'exécute seulement si non-null
```

### Fonctions

```dart
// Fonction simple
String bonjour(String prenom) {
  return 'Bonjour $prenom';
}

// Fonction avec paramètres nommés (très utilisé en Flutter)
String formatDate({required DateTime date, bool court = false}) {
  if (court) return '${date.day}/${date.month}';
  return '${date.day}/${date.month}/${date.year}';
}
// Appel :
formatDate(date: DateTime.now());
formatDate(date: DateTime.now(), court: true);

// Arrow function (une seule expression)
String majuscule(String s) => s.toUpperCase();

// Fonction anonyme (lambda)
final multiplier = (int a, int b) => a * b;
```

### Classes

```dart
class Service {
  // Propriétés
  final String id;
  final String name;
  final int durationMinutes;
  final double price;

  // Constructeur
  const Service({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  // Getter calculé
  String get formattedPrice => '${price.toStringAsFixed(2)} €';
  String get formattedDuration => '${durationMinutes} min';

  // Factory constructor (depuis JSON)
  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as String,
    name: json['name'] as String,
    durationMinutes: json['durationMinutes'] as int,
    price: (json['price'] as num).toDouble(),
  );

  // Sérialisation vers JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'durationMinutes': durationMinutes,
    'price': price,
  };
}
```

### Async / Await — Fondamental en Flutter

```dart
// Future = une valeur qui arrivera dans le futur
Future<String> fetchUser() async {
  // await = attendre sans bloquer l'UI
  final response = await http.get(Uri.parse('https://api.example.com/user'));
  return response.body;
}

// Gérer les erreurs
Future<void> loadData() async {
  try {
    final data = await fetchUser();
    print(data);
  } catch (e) {
    print('Erreur : $e');
  }
}

// Stream = flux de valeurs dans le temps
Stream<int> compteur() async* {
  for (int i = 0; i < 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;  // émet une valeur
  }
}
```

### Collections

```dart
// List
List<String> services = ['Coiffure', 'Beauté', 'Santé'];
services.add('Massage');
services.removeWhere((s) => s == 'Santé');

// Map
Map<String, dynamic> user = {
  'name': 'Admin',
  'email': 'admin@gmail.com',
};
String email = user['email'] as String;

// Méthodes essentielles sur les listes
final upcoming = appointments
    .where((a) => a.startTime.isAfter(DateTime.now()))  // filtrer
    .toList();

final noms = services.map((s) => s.name).toList();      // transformer

final total = services.fold<double>(
  0, (sum, s) => sum + s.price,                         // réduire
);

final premier = services.firstWhere(
  (s) => s.id == 'abc',
  orElse: () => throw Exception('Introuvable'),
);
```

---

## 2. Flutter — Les fondamentaux

### Structure d'une app Flutter

```
lib/
├── main.dart               ← point d'entrée
├── app.dart                ← MaterialApp + Router + Providers
├── models/                 ← classes de données
├── providers/              ← logique métier (ChangeNotifier)
├── services/               ← appels API, notifications...
├── screens/                ← pages de l'app
├── widgets/                ← composants réutilisables
├── theme/                  ← couleurs, thème
└── core/
    ├── constants/          ← constantes (URLs, clés...)
    ├── network/            ← client HTTP, intercepteurs
    └── utils/              ← fonctions utilitaires
```

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Initialiser les bindings Flutter avant tout
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive (stockage local)
  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('cache');

  runApp(const AppointEaseApp());
}
```

### MaterialApp — L'app complète

```dart
MaterialApp.router(
  title: 'Booqly',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: themeProvider.mode,
  routerConfig: _router,
)
```

---

## 3. Widgets — Tout est un widget

### StatelessWidget — Sans état interne

```dart
// Utilisez StatelessWidget quand le widget ne change PAS
class ServiceCard extends StatelessWidget {
  final Service service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(service.name),
        subtitle: Text(service.formattedDuration),
        trailing: Text(service.formattedPrice),
      ),
    );
  }
}
```

### StatefulWidget — Avec état interne

```dart
// Utilisez StatefulWidget quand le widget a un état qui change
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;  // ← l'état

  void _increment() {
    setState(() {       // ← déclenche un rebuild
      _count++;
    });
  }

  @override
  void initState() {
    super.initState();
    // S'exécute une seule fois à la création du widget
    // Charger des données ici
  }

  @override
  void dispose() {
    // Libérer les ressources (controllers, streams...)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        ElevatedButton(onPressed: _increment, child: const Text('+')),
      ],
    );
  }
}
```

### Widgets essentiels

```dart
// Texte
Text(
  'Bonjour',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
)

// Image
Image.network('https://example.com/photo.jpg')
Image.asset('assets/logo.png')

// Icône
Icon(Icons.calendar_today, size: 24, color: Colors.blue)

// Boutons
ElevatedButton(
  onPressed: () => print('tapé'),
  child: const Text('Confirmer'),
)
TextButton(onPressed: () {}, child: const Text('Annuler'))
OutlinedButton(onPressed: () {}, child: const Text('Voir'))
IconButton(onPressed: () {}, icon: const Icon(Icons.delete))

// Champ de texte
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'exemple@gmail.com',
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) => print(value),
)

// Divider
const Divider(height: 1)

// SizedBox (espace)
const SizedBox(height: 16)
const SizedBox(width: 8)
```

---

## 4. Layout — Mise en page

### Column et Row

```dart
// Column = axe vertical
Column(
  mainAxisAlignment: MainAxisAlignment.center,    // axe principal (vertical)
  crossAxisAlignment: CrossAxisAlignment.start,   // axe croisé (horizontal)
  children: [
    const Text('Titre'),
    const SizedBox(height: 8),
    const Text('Sous-titre'),
  ],
)

// Row = axe horizontal
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('Gauche'),
    const Text('Droite'),
  ],
)
```

### Expanded et Flexible

```dart
Row(
  children: [
    // Expanded = prend tout l'espace disponible
    Expanded(
      child: TextField(decoration: InputDecoration(hintText: 'Recherche')),
    ),
    const SizedBox(width: 8),
    ElevatedButton(onPressed: () {}, child: const Text('OK')),
  ],
)

// Expanded avec flex (proportions)
Row(
  children: [
    Expanded(flex: 2, child: Container(color: Colors.blue)),  // 2/3
    Expanded(flex: 1, child: Container(color: Colors.red)),   // 1/3
  ],
)
```

### Stack — Superposition

```dart
Stack(
  children: [
    // Fond
    Container(width: double.infinity, height: 200, color: Colors.blue),
    // Par-dessus
    Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    ),
  ],
)
```

### Container — Le plus polyvalent

```dart
Container(
  width: 200,
  height: 100,
  margin: const EdgeInsets.all(16),       // espace extérieur
  padding: const EdgeInsets.all(12),      // espace intérieur
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    gradient: const LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: const Text('Contenu'),
)
```

### Scaffold — Structure d'une page

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Mon titre'),
    actions: [
      IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
    ],
  ),
  body: const Center(child: Text('Contenu')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ],
  ),
)
```

### Listes

```dart
// ListView simple
ListView(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
  ],
)

// ListView.builder — pour les listes longues (lazy loading)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ServiceCard(service: item);
  },
)

// ListView.separated — avec séparateurs
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (_, i) => ServiceCard(service: items[i]),
)

// GridView.builder — grille
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: categories.length,
  itemBuilder: (_, i) => CategoryCard(category: categories[i]),
)
```

### SafeArea et Padding

```dart
// SafeArea = évite les encoches/barres système
SafeArea(
  child: Column(children: [...]),
)

// Padding = ajouter de l'espace
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Text('Contenu'),
)
// Raccourci : EdgeInsets
// .all(16)                      → partout
// .symmetric(h: 20, v: 8)       → horizontal/vertical
// .only(left: 12, top: 8)       → côtés spécifiques
// .fromLTRB(16, 8, 16, 24)      → gauche, haut, droite, bas
```

---

## 5. State Management — Provider

### Pourquoi Provider ?

Sans state management, partager des données entre écrans est complexe.
Provider permet de :
- Centraliser la logique métier
- Notifier tous les widgets qui écoutent quand les données changent
- Séparer UI et logique

### ChangeNotifier — Le modèle de base

```dart
import 'package:flutter/material.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _loading = false;
  String? _error;

  // Getters (lecture seule depuis l'extérieur)
  List<Appointment> get all => _appointments;
  List<Appointment> get upcoming => _appointments
      .where((a) => !a.isCancelled && !a.isCompleted)
      .toList();
  bool get loading => _loading;
  String? get error => _error;

  // Méthode privée pour changer l'état
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners(); // ← réveille tous les widgets qui écoutent
  }

  Future<void> loadMyAppointments() async {
    _setLoading(true);
    try {
      final loaded = await _service.getMyAppointments();
      _appointments = loaded;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirm(String id) async {
    await _service.confirm(id);
    await loadMyAppointments(); // recharger pour mettre à jour l'UI
  }
}
```

### Enregistrer les providers

```dart
// Dans app.dart — rendre les providers disponibles partout
MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthProvider>.value(value: _auth),
    ChangeNotifierProvider(create: (_) => AppointmentProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: MaterialApp.router(...),
)
```

### Lire un provider dans un widget

```dart
// context.watch — rebuild automatique quand les données changent
final appointments = context.watch<AppointmentProvider>();

// context.read — lire sans s'abonner aux changements (dans onPressed, etc.)
final provider = context.read<AppointmentProvider>();
provider.loadMyAppointments();

// Consumer — builder pour cibler précisément ce qui rebuild
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) => MaterialApp(
    themeMode: themeProvider.mode,
    // child = widget statique qui ne rebuild pas
    home: child,
  ),
  child: const MyStaticWidget(),
)
```

### Exemple complet Provider

```dart
class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppointmentProvider>().loadMyAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Erreur : ${provider.error}'));
    }

    return ListView.builder(
      itemCount: provider.upcoming.length,
      itemBuilder: (_, i) => AppointmentCard(appointment: provider.upcoming[i]),
    );
  }
}
```

---

## 6. Navigation — GoRouter

### Pourquoi GoRouter ?

GoRouter gère la navigation par URL (deep linking), les redirections conditionnelles (auth), et les paramètres de route.

### Configuration

```dart
final _router = GoRouter(
  initialLocation: '/',
  refreshListenable: _auth, // se recalcule quand l'auth change
  redirect: (context, state) {
    final isLoggedIn = _auth.isAuthenticated;
    final loc = state.matchedLocation;

    if (loc == '/') return isLoggedIn ? '/home' : '/login';
    if (!isLoggedIn && loc != '/login') return '/login';
    if (isLoggedIn && loc == '/login') return '/home';
    return null; // pas de redirection
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

    // Paramètre de chemin (:id)
    GoRoute(
      path: '/appointments/:id',
      builder: (_, state) => AppointmentDetailScreen(
        appointmentId: state.pathParameters['id']!,
      ),
    ),

    // Paramètres de requête (?serviceId=...)
    GoRoute(
      path: '/booking/:proId/slots',
      builder: (_, state) => SlotPickerScreen(
        proId: state.pathParameters['proId']!,
        serviceId: state.uri.queryParameters['serviceId'] ?? '',
      ),
    ),
  ],
);
```

### Naviguer

```dart
// Aller à une route (push — ajoute au stack)
context.push('/appointments/abc123');

// Aller et remplacer (pas de retour arrière)
context.go('/home');

// Retour arrière
context.pop();

// Avec paramètres de requête
context.push('/booking/pro123/slots?serviceId=svc456');

// Retourner une valeur depuis un écran
final result = await context.push<bool>('/confirmation');
if (result == true) { ... }
```

---

## 7. HTTP & API — Dio

### Configuration du client

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // Intercepteurs
    _dio.interceptors.add(AuthInterceptor(_dio));  // ajoute le token JWT
    _dio.interceptors.add(LogInterceptor());       // logs de debug
  }
}
```

### Intercepteur d'authentification

```dart
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajoute le token JWT à chaque requête
    final box = Hive.box('auth');
    final token = box.get('accessToken');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si token expiré (401) → essayer de le rafraîchir
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Réessayer la requête originale
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
}
```

### Service API

```dart
class AppointmentService {
  final ApiClient _client;

  Future<List<Appointment>> getMyAppointments() async {
    final response = await _client.dio.get('/appointments/my');
    final list = response.data as List<dynamic>;
    return list.map((json) => Appointment.fromJson(json)).toList();
  }

  Future<Appointment> confirm(String id) async {
    final response = await _client.dio.put('/appointments/$id/confirm');
    return Appointment.fromJson(response.data);
  }

  Future<void> cancel(String id) async {
    await _client.dio.put('/appointments/$id/cancel');
  }
}

// Gestion des erreurs Dio
String handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return 'Connexion trop lente';
    case DioExceptionType.receiveTimeout:
      return 'Le serveur ne répond pas';
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 400) return e.response?.data['message'] ?? 'Données invalides';
      if (code == 401) return 'Session expirée';
      if (code == 404) return 'Introuvable';
      return 'Erreur serveur ($code)';
    default:
      return 'Pas de connexion internet';
  }
}
```

---

## 8. Stockage local — Hive

### Initialisation

```dart
// main.dart
await Hive.initFlutter();
await Hive.openBox('auth');    // tokens JWT
await Hive.openBox('cache');   // données mises en cache
```

### Utilisation

```dart
// Écrire
final box = Hive.box('auth');
await box.put('accessToken', 'eyJhbGci...');
await box.put('refreshToken', 'dGhpcyBp...');

// Lire
final token = box.get('accessToken');
final token2 = box.get('accessToken', defaultValue: '');

// Supprimer
await box.delete('accessToken');

// Vider toute la boîte
await box.clear();

// Exemple réel — sauvegarder des IDs vus
final seenRaw = box.get('seen_appointments', defaultValue: <dynamic>[]) as List;
final seenIds = seenRaw.map((e) => e.toString()).toSet();
await box.put('seen_appointments', appointments.map((a) => a.id).toList());
```

---

## 9. Formulaires & Validation

### Form avec GlobalKey

```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    // IMPORTANT : toujours disposer les controllers
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Valider tous les champs
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthProvider>().login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null; // valide
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Minimum 8 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Connexion'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 10. Thème — Light/Dark

### Définir les couleurs

```dart
// theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFF3B82F6);
  static const Color error = Color(0xFFEF4444);
  static const Color textSecondary = Color(0xFF6B7280);

  // Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleur selon statut
  static Color statusColor(String status) {
    switch (status) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF10B981);
      case 'completed': return const Color(0xFF6B7280);
      case 'cancelled': return const Color(0xFFEF4444);
      default:          return const Color(0xFF6B7280);
    }
  }
}
```

### Définir le thème

```dart
// theme/app_theme.dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    // ... mêmes overrides pour le dark mode
  );
}
```

### ThemeProvider — Basculer light/dark

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    // Persister dans Hive
    await Hive.box('cache').put('themeMode', _mode.name);
  }
}
```

---

## 11. Animations

### AnimationController — Contrôle manuel

```dart
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {  // ← requis pour AnimationController

  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward(); // démarrer immédiatement

    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose(); // IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: const FlutterLogo(size: 100),
          ),
        );
      },
    );
  }
}
```

### Animations implicites — Le plus simple

```dart
// AnimatedContainer — transite automatiquement entre deux états
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _expanded ? 200 : 100,
  color: _selected ? Colors.blue : Colors.grey,
  child: const Text('Cliquez'),
)

// AnimatedOpacity
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 200),
  child: const Text('Texte qui disparaît'),
)

// AnimatedSwitcher — transition entre deux widgets
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: _loading
      ? const CircularProgressIndicator(key: ValueKey('loader'))
      : const Icon(Icons.check, key: ValueKey('check')),
)
```

---

## 12. Architecture d'un vrai projet

### Modèle de données (Model)

```dart
// Immutable, sérialisable, sans logique UI
class Appointment {
  final String id;
  final String clientName;
  final Service service;
  final DateTime startTime;
  final String status;

  // Getters métier
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    clientName: json['clientName'],
    service: Service.fromJson(json['service']),
    startTime: DateTime.parse(json['startTime']),
    status: json['status'],
  );
}
```

### Service (couche réseau)

```dart
// Fait les appels API, retourne des models
class AppointmentService {
  final Dio _dio;

  Future<List<Appointment>> getMyAppointments() async {
    final response = await _dio.get('/appointments/my');
    return (response.data as List).map(Appointment.fromJson).toList();
  }
}
```

### Provider (logique métier)

```dart
// Orchestre les services, gère l'état, notifie l'UI
class AppointmentProvider extends ChangeNotifier {
  final _service = AppointmentService();
  List<Appointment> _appointments = [];

  Future<void> loadMyAppointments() async { ... }
  Future<void> confirm(String id) async { ... }
}
```

### Screen (UI)

```dart
// Seulement de l'UI, lit le provider, ne fait pas d'appels API directement
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    return ListView.builder(
      itemCount: provider.upcoming.length,
      itemBuilder: (_, i) => AppointmentCard(appointment: provider.upcoming[i]),
    );
  }
}
```

---

## 13. Patterns avancés

### FutureBuilder — Afficher une Future dans l'UI

```dart
FutureBuilder<List<Professional>>(
  future: _professionalService.getAll(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Erreur : ${snapshot.error}');
    }
    final professionals = snapshot.data!;
    return ListView.builder(
      itemCount: professionals.length,
      itemBuilder: (_, i) => ProfessionalCard(pro: professionals[i]),
    );
  },
)
```

### RefreshIndicator — Pull-to-refresh

```dart
RefreshIndicator(
  onRefresh: () => context.read<AppointmentProvider>().loadMyAppointments(),
  child: ListView.builder(...),
)
```

### SnackBar — Feedback utilisateur

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Rendez-vous confirmé !'),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
  ),
);
```

### Dialog — Confirmation

```dart
final confirm = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Confirmer ?'),
    content: const Text('Cette action est irréversible.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx, false),
        child: const Text('Non'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(ctx, true),
        child: const Text('Oui', style: TextStyle(color: Colors.red)),
      ),
    ],
  ),
);
if (confirm == true) { /* action */ }
```

### BottomSheet — Panel du bas

```dart
showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (ctx) => Padding(
    padding: EdgeInsets.fromLTRB(24, 16, 24,
        MediaQuery.of(ctx).viewInsets.bottom + 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // drag handle
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Options'),
      ],
    ),
  ),
);
```

### Notifications locales

```dart
// Afficher une notification locale (flutter_local_notifications)
final plugin = FlutterLocalNotificationsPlugin();

await plugin.show(
  id.abs(),            // ID positif obligatoire
  'Titre',
  'Corps de la notif',
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'Nom du canal',
      importance: Importance.high,
    ),
  ),
);
```

---

## 14. Déploiement

### Variables d'environnement (dart-define)

```dart
// Dans le code
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:5000/api',
);

// Lancer l'app avec une valeur
flutter run --dart-define=API_URL=http://192.168.1.10:5000/api
```

### Commandes essentielles

```bash
# Analyser le code
dart analyze lib/

# Formater le code
dart format lib/

# Nettoyer le build
flutter clean && flutter pub get

# Lancer sur émulateur Android
flutter run --dart-define=API_URL=http://10.0.2.2:5000/api

# Lancer sur téléphone physique (via ADB)
adb reverse tcp:5000 tcp:5000
flutter run --dart-define=API_URL=http://localhost:5000/api

# Build APK release
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

### pubspec.yaml — Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  google_fonts: ^6.2.1          # polices Google
  table_calendar: ^3.1.2        # calendrier

  # State management
  provider: ^6.1.2

  # Navigation
  go_router: ^14.3.0

  # HTTP
  dio: ^5.7.0

  # Stockage local
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Notifications locales
  flutter_local_notifications: ^17.2.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## Récapitulatif — Les règles d'or

| Règle | Pourquoi |
|---|---|
| `const` partout où possible | Performance : widget non reconstruit |
| `dispose()` les controllers | Éviter les memory leaks |
| `WidgetsBinding.instance.addPostFrameCallback` | Appeler le provider APRÈS le premier build |
| `context.read` dans `onPressed` | Pas de rebuild inutile |
| `context.watch` dans `build` | Rebuild quand les données changent |
| Model immutable | Prédictibilité, pas d'état caché |
| Un fichier = une responsabilité | Maintenabilité |
| `try/catch` sur tous les appels réseau | Pas de crash en prod |

---

> **Prochain projet** → appliquer cette architecture depuis zéro.
