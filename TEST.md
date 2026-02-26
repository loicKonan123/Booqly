# Booqly — Guide de test complet

## Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| **Client** | admin@gmail.com | Admin123! |
| **Professionnel** | _(ton compte pro)_ | _(ton mot de passe)_ |

---

## Audit sécurité — État actuel

| # | Point | Statut |
|---|---|---|
| 1 | JWT Secret (64 chars, aléatoire) | ✅ Corrigé |
| 2 | IP hardcodée → `String.fromEnvironment` | ✅ Corrigé |
| 3 | CORS `AllowAnyOrigin` | ⚠️ OK en dev, à restreindre en prod |
| 4 | Tokens dans Hive (non chiffré) | ⚠️ Acceptable pour MVP |
| 5 | 18 warnings Flutter `prefer_const` | ℹ️ Style seulement, pas critique |

---

## Checklist de tests fonctionnels

### Auth
- [ ] Inscription client (nouveau email, mot de passe valide)
- [ ] Inscription professionnel (rôle "Professionnel")
- [ ] Connexion client
- [ ] Connexion professionnel
- [ ] Déconnexion
- [ ] Mot de passe oublié (email reçu ?)
- [ ] Validation formulaires : email invalide → message d'erreur
- [ ] Validation formulaires : mot de passe trop court → message d'erreur
- [ ] Token expiré → refresh automatique (rester connecté 1h+)

### Client — Explorer
- [ ] Liste des professionnels s'affiche
- [ ] Filtrer par catégorie (Coiffure, Beauté, Santé…)
- [ ] Cliquer sur un professionnel → voir son profil
- [ ] Profil professionnel : services et créneaux visibles

### Client — Réservation
- [ ] Choisir un service
- [ ] Choisir un créneau disponible
- [ ] Écran de confirmation : informations correctes
- [ ] Confirmer → rendez-vous créé
- [ ] Notification reçue après confirmation (côté client)
- [ ] Le rendez-vous apparaît dans "Mes rendez-vous → À venir"

### Client — Rendez-vous
- [ ] Liste "À venir" correcte
- [ ] Liste "Passés" correcte
- [ ] Détail d'un rendez-vous accessible
- [ ] Annuler un rendez-vous → statut "Annulé"
- [ ] Rendez-vous annulé passe dans "Passés"

### Professionnel — Dashboard
- [ ] Compteur "À venir" correct
- [ ] Compteur "Total" correct
- [ ] Liste des prochains RDV visible
- [ ] Pull-to-refresh fonctionne

### Professionnel — Notifications
- [ ] Client réserve → professionnel reçoit notif en ouvrant l'app
- [ ] La notif affiche : nom client, service, date

### Professionnel — Services
- [ ] Créer un service (nom, durée, prix)
- [ ] Modifier un service existant
- [ ] Supprimer un service

### Professionnel — Disponibilités
- [ ] Ajouter des créneaux de disponibilité
- [ ] Les créneaux créés apparaissent côté client

### Profil (client + pro)
- [ ] Modifier prénom / nom / téléphone
- [ ] Les modifications sont sauvegardées après reconnexion
- [ ] Changer le mot de passe → reconnexion avec nouveau mot de passe
- [ ] Basculer mode sombre ↔ clair
- [ ] Le thème persiste après fermeture de l'app

---

## Scénario de test complet (bout en bout)

```
1. Créer compte professionnel → ajouter 1 service + disponibilités
2. Créer compte client (ou utiliser admin@gmail.com / Admin123!)
3. [Client] Explorer → trouver le pro → réserver
4. [Pro] Ouvrir l'app → vérifier notif + RDV dans dashboard
5. [Pro] Confirmer ou annuler le RDV
6. [Client] Vérifier que le statut est mis à jour
```

---

## Lancer l'app

```bash
# Téléphone physique (IP WiFi de ton PC)
flutter run --dart-define=API_URL=http://192.168.2.32:5000/api

# Émulateur Android
flutter run --dart-define=API_URL=http://10.0.2.2:5000/api

# Web
flutter run -d chrome --dart-define=API_URL=http://localhost:5000/api
```

## Commandes utiles

```bash
# Analyser le code Flutter
dart analyze lib/

# Compiler le backend
cd backend && dotnet build src/Booqly.API/Booqly.API.csproj

# Lancer le backend
cd backend && dotnet run --project src/Booqly.API/Booqly.API.csproj
```
