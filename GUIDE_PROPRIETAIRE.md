# Booqly — Guide Propriétaire

> Ce guide explique comment accéder à la base de données, gérer les données, et exploiter l'application en tant que propriétaire / administrateur.

---


Email	deva
Mot de passe	Booqly2026
Rôle	professional (accès dashboard, agenda, services, disponibilités)
ID	8ae7b334-faf3-4841-b1a8-da26b00b9a33
## Sommaire
Email	client.test@booqly.com
Mot de passe	Test1234!
Nom	Thomas Dupont
Rôle	Client


Champ	Valeur
Email	admin@gmail.com
Mot de passe	Admin123!
Prénom	Admin
Nom	Client
Rôle	client


1. [Lancer l'application](#1-lancer-lapplication)
2. [Accéder à la base de données](#2-accéder-à-la-base-de-données)
3. [Explorer la DB via SQL Server Object Explorer](#3-explorer-la-db-via-sql-server-object-explorer)
4. [Ajouter des données manuellement (SQL)](#4-ajouter-des-données-manuellement-sql)
5. [Accéder à l'API Swagger](#5-accéder-à-lapi-swagger)
6. [Créer des comptes via l'API](#6-créer-des-comptes-via-lapi)
7. [Gérer les rendez-vous via l'API](#7-gérer-les-rendez-vous-via-lapi)
8. [Tableau de bord Hangfire (jobs planifiés)](#8-tableau-de-bord-hangfire)
9. [Passer en production](#9-passer-en-production)

---

## 1. Lancer l'application

### Backend (API)
```powershell
cd C:\Users\konan\Downloads\Booqly\backend\src\Booqly.API
dotnet run
```
- API disponible sur : **http://localhost:5000**
- Pour arrêter : `Ctrl+C` dans le terminal, ou `taskkill /IM "Booqly.API.exe" /F`

### Frontend (Flutter Web)
```powershell
cd C:\Users\konan\Downloads\Booqly
flutter run -d chrome
```

---

## 2. Accéder à la base de données

### Informations de connexion (développement)

| Paramètre | Valeur |
|---|---|
| Serveur | `(localdb)\mssqllocaldb` |
| Base de données | `BooqlyDb_Dev` |
| Authentification | Windows (intégrée) |

### Via Visual Studio / VS Code (SQL Server Object Explorer)

1. Ouvrir **Visual Studio** → menu `Affichage` → `Explorateur d'objets SQL Server`
2. Cliquer `+` → `SQL Server` → `Ajouter un serveur SQL Server`
3. Serveur : `(localdb)\mssqllocaldb`
4. Authentification : `Windows`
5. Naviguer : `BooqlyDb_Dev` → `Tables`

### Via Azure Data Studio (recommandé, gratuit)

1. Télécharger : https://aka.ms/azuredatastudio
2. Nouvelle connexion :
   - Type : `Microsoft SQL Server`
   - Serveur : `(localdb)\mssqllocaldb`
   - Authentification : `Windows Authentication`
3. Sélectionner `BooqlyDb_Dev`

### Via ligne de commande (sqlcmd)
```powershell
sqlcmd -S "(localdb)\mssqllocaldb" -d BooqlyDb_Dev -E
```

---

## 3. Explorer la DB via SQL Server Object Explorer

### Tables principales

| Table | Contenu |
|---|---|
| `Users` | Comptes clients et professionnels |
| `Professionals` | Profils professionnels (bio, catégorie, note) |
| `Services` | Services proposés par chaque professionnel |
| `Availabilities` | Plages horaires de disponibilité |
| `Appointments` | Tous les rendez-vous |
| `AspNetUsers` | Comptes Identity (email + mot de passe hashé) |

### Requêtes utiles

```sql
-- Voir tous les utilisateurs
SELECT u.Id, u.Email, u.FirstName, u.LastName, u.Role, u.CreatedAt
FROM Users u;

-- Voir tous les professionnels avec leur profil
SELECT u.FirstName, u.LastName, u.Email, p.Category, p.Rating, p.ReviewCount
FROM Professionals p
JOIN Users u ON p.UserId = u.Id;

-- Voir tous les rendez-vous à venir
SELECT
    c.FirstName + ' ' + c.LastName AS Client,
    pro.FirstName + ' ' + pro.LastName AS Professionnel,
    s.Name AS Service,
    a.StartTime,
    a.Status
FROM Appointments a
JOIN Users c ON a.ClientId = c.Id
JOIN Professionals p ON a.ProfessionalId = p.Id
JOIN Users pro ON p.UserId = pro.Id
JOIN Services s ON a.ServiceId = s.Id
WHERE a.StartTime > GETUTCDATE()
ORDER BY a.StartTime;

-- Chiffre d'affaires par professionnel
SELECT
    u.FirstName + ' ' + u.LastName AS Professionnel,
    COUNT(*) AS NbRDV,
    SUM(s.Price) AS ChiffreAffaires
FROM Appointments a
JOIN Professionals p ON a.ProfessionalId = p.Id
JOIN Users u ON p.UserId = u.Id
JOIN Services s ON a.ServiceId = s.Id
WHERE a.Status = 'Completed'
GROUP BY u.FirstName, u.LastName
ORDER BY ChiffreAffaires DESC;

-- Statistiques globales
SELECT
    (SELECT COUNT(*) FROM Users WHERE Role = 'Client') AS TotalClients,
    (SELECT COUNT(*) FROM Users WHERE Role = 'Professional') AS TotalProfessionnels,
    (SELECT COUNT(*) FROM Appointments) AS TotalRDV,
    (SELECT COUNT(*) FROM Appointments WHERE Status = 'Completed') AS RDVTermines,
    (SELECT COUNT(*) FROM Appointments WHERE Status = 'Cancelled') AS RDVAnnules;
```

---

## 4. Ajouter des données manuellement (SQL)

### Mettre à jour la catégorie d'un professionnel
```sql
UPDATE Professionals
SET Category = 'Coiffure'
WHERE Id = '...'; -- remplacer par le vrai GUID
```

### Modifier la note d'un professionnel
```sql
UPDATE Professionals
SET Rating = 4.8, ReviewCount = 50
WHERE Id = '...';
```

### Annuler un rendez-vous manuellement
```sql
UPDATE Appointments
SET Status = 'Cancelled', UpdatedAt = GETUTCDATE()
WHERE Id = '...';
```

### Désactiver un service
```sql
UPDATE Services
SET IsActive = 0, UpdatedAt = GETUTCDATE()
WHERE Id = '...';
```

### Supprimer un utilisateur (cascade complète)
```sql
-- D'abord supprimer les rendez-vous liés
DELETE FROM Appointments WHERE ClientId = '...';
-- Puis supprimer le profil
DELETE FROM Users WHERE Id = '...';
-- Puis supprimer le compte Identity
DELETE FROM AspNetUsers WHERE Id = '...';
```

---

## 5. Accéder à l'API Swagger

L'interface Swagger permet de tester tous les endpoints sans code.

**URL :** http://localhost:5000/swagger

### S'authentifier dans Swagger

1. Appeler `POST /api/auth/login` avec un compte existant
2. Copier le `accessToken` de la réponse
3. Cliquer sur **Authorize** (cadenas en haut à droite)
4. Coller : `Bearer <token>` → **Authorize**
5. Tous les endpoints protégés sont maintenant accessibles

---

## 6. Créer des comptes via l'API

### Créer un compte client
```http
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "client@example.com",
  "password": "MonMotDePasse1",
  "firstName": "Prénom",
  "lastName": "Nom",
  "phone": "+33600000000",
  "role": "client"
}
```

### Créer un compte professionnel
```http
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "pro@example.com",
  "password": "MonMotDePasse1",
  "firstName": "Sophie",
  "lastName": "Martin",
  "phone": "+33698765432",
  "role": "professional"
}
```

La réponse contient `accessToken` + `refreshToken` + `user`.

### Se connecter
```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "pro@example.com",
  "password": "MonMotDePasse1"
}
```

---

## 7. Gérer les rendez-vous via l'API

> Toutes ces routes nécessitent le header : `Authorization: Bearer <token>`

### Voir mes rendez-vous
```http
GET http://localhost:5000/api/appointments/mine
```

### Créer un rendez-vous (côté client)
```http
POST http://localhost:5000/api/appointments
Content-Type: application/json

{
  "professionalId": "GUID_DU_PRO",
  "serviceId": "GUID_DU_SERVICE",
  "slotId": "2026-03-01T09:00:00",
  "notes": "Première visite"
}
```

### Confirmer / Annuler / Terminer un RDV (côté professionnel)
```http
PATCH http://localhost:5000/api/appointments/GUID_DU_RDV/status
Content-Type: application/json

{ "status": "confirmed" }
{ "status": "cancelled" }
{ "status": "completed" }
```

### Voir les créneaux disponibles
```http
GET http://localhost:5000/api/professionals/GUID_PRO/slots?serviceId=GUID_SERVICE&date=2026-03-01
```

### Statistiques du professionnel connecté
```http
GET http://localhost:5000/api/dashboard/stats
```

---

## 8. Tableau de bord Hangfire

Hangfire gère les **SMS de rappel automatiques** 24h avant chaque RDV.

**URL :** http://localhost:5000/hangfire

### Ce que tu peux faire ici

| Action | Description |
|---|---|
| **Jobs récurrents** | Voir le job `appointment-reminders` (toutes les heures) |
| **Jobs en file** | Voir les SMS en attente d'envoi |
| **Historique** | Voir tous les jobs exécutés et leur statut |
| **Réessayer** | Relancer un job qui a échoué |
| **Serveurs** | Voir les workers actifs |

### Déclencher manuellement le rappel SMS

Dans l'onglet **Recurring Jobs** → cliquer **Trigger Now** sur `appointment-reminders`.

---

## 9. Passer en production

### 1. Configurer `appsettings.json`

```json
{
  "ConnectionStrings": {
    "Default": "Server=MON_SERVEUR;Database=BooqlyDb;User Id=SA;Password=MON_MDP;"
  },
  "Jwt": {
    "Secret": "UNE_CLE_SECRETE_DE_32_CARACTERES_MINIMUM",
    "ExpiryMinutes": "60"
  },
  "Twilio": {
    "AccountSid": "ACxxxxxxxxxxxxx",
    "AuthToken": "xxxxxxxxxxxxx",
    "From": "+33XXXXXXXXX"
  }
}
```

### 2. Appliquer les migrations sur la prod
```powershell
$env:ConnectionStrings__Default = "Server=PROD_SERVER;Database=BooqlyDb;..."
dotnet ef database update --project src/Booqly.Infrastructure --startup-project src/Booqly.API
```

### 3. Publier l'API
```powershell
dotnet publish src/Booqly.API -c Release -o ./publish
```

### 4. Changer l'URL du backend dans le Flutter

Modifier [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart) :
```dart
static const String baseUrl = 'https://api.tondomaine.com/api';
```

### 5. Désactiver le mock mode

Modifier [lib/core/mock/mock_data.dart](lib/core/mock/mock_data.dart) :
```dart
const bool kMockMode = false;
```

---

## Récapitulatif des URLs

| Service | URL |
|---|---|
| API REST | http://localhost:5000/api |
| Swagger (docs interactives) | http://localhost:5000/swagger |
| Hangfire (jobs planifiés) | http://localhost:5000/hangfire |
| Flutter Web | http://localhost:XXXX (généré par `flutter run`) |

---

*Généré pour le projet Booqly — backend ASP.NET Core 8 + Clean Architecture*
