# Roblox Admin & Pet System

Dieses Repository enthält zwei vollständige Systeme für Roblox-Spiele: Ein Admin-Interface und ein Pet-System mit Shop. Beide Systeme sind vollständig funktionsfähig und können direkt in Roblox Studio implementiert werden.

## 📋 Übersicht

### Admin System
- **Vollständiges Admin-Interface** mit modernem UI-Design
- **Spieler-Moderation**: Timeban, Permaban, Admin-Verwaltung
- **Flight-Modus** mit WASD-Steuerung
- **Waffen-System** und Coins vergeben
- **DataStore-Integration** für persistente Daten
- **Sicherheitssystem** mit Owner-ID Schutz

### Pet System
- **Pet-Shop** mit 6 verschiedenen Pets (Hund, Katze, Hase, Fuchs, Panda, Drache)
- **Seltenheitssystem** (Common bis Legendary)
- **Coins-pro-Minute System** mit Pet-Boni
- **Pet-Umbenennung** für 50 Coins
- **Automatisches Folgen** der Pets mit Animationen
- **DataStore-Speicherung** aller Pet-Daten

## 🚀 Installation in Roblox Studio

### Schritt 1: Vorbereitung
1. Öffne Roblox Studio
2. Erstelle ein neues Spiel oder öffne ein bestehendes
3. Stelle sicher, dass **HTTP Requests** und **Studio Access to API Services** aktiviert sind:
   - Game Settings → Security → Allow HTTP Requests ✓
   - Game Settings → Security → Enable Studio Access to API Services ✓

### Schritt 2: Admin System einrichten

#### Server-Script (admin.lua)
1. Erstelle ein **ServerScript** in **ServerScriptService**
2. Kopiere den Inhalt von `Server/admin.lua`
3. **WICHTIG**: Ändere die `OWNER_ID` in Zeile 8 zu deiner eigenen Roblox User-ID
   ```lua
   local OWNER_ID = 0000000000 -- <--- DEINE USER ID HIER EINTRAGEN
   ```

#### Client-Script (admin_client.lua)
1. Erstelle ein **LocalScript** in **StarterPlayer → StarterPlayerScripts**
2. Kopiere den Inhalt von `Client/admin_client.lua`

#### Optional: Waffen hinzufügen
1. Erstelle einen Ordner namens **"AdminGuns"** in **ServerStorage**
2. Füge Tool-Objekte (Waffen) in diesen Ordner ein
3. Benenne mindestens eine Waffe **"Pistol"** (oder ändere den Namen im Script)

### Schritt 3: Pet System einrichten

#### Server-Script (pet.lua)
1. Erstelle ein **ServerScript** in **ServerScriptService**
2. Kopiere den Inhalt von `Server/pet.lua`

#### Client-Script (pet_client.lua)
1. Erstelle ein **LocalScript** in **StarterPlayer → StarterPlayerScripts**
2. Kopiere den Inhalt von `Client/pet_client.lua`

#### Optional: Pet-Models hinzufügen
1. Erstelle Models in **ServerStorage** mit folgenden Namen:
   - `DogModel` (für Hund)
   - `CatModel` (für Katze)
   - `RabbitModel` (für Hase)
   - `FoxModel` (für Fuchs)
   - `PandaModel` (für Panda)
   - `DragonModel` (für Drache)
2. Falls keine Models vorhanden sind, verwendet das System automatisch farbige Kugeln als Fallback

### Schritt 4: Testen
1. Klicke auf **Play** in Roblox Studio
2. **Admin-Menü**: Drücke **M** um das Admin-Interface zu öffnen (nur als Owner)
3. **Pet-Shop**: Gehe zu den Koordinaten `86.5, 15.631, 182.718` und klicke auf die leuchtende Kugel

## 🎮 Funktionen im Detail

### Admin System Features
- **M-Taste**: Öffnet das Admin-Menü (nur für Admins)
- **Flight-Modus**: WASD + Space/Shift für Bewegung
- **Timeban**: Temporäre Sperren (60s bis 24h)
- **Permaban**: Permanente Sperren
- **Admin-Verwaltung**: Andere Spieler zu Admins machen
- **Coins vergeben**: 100 Coins an Spieler geben
- **Waffen geben**: Tools aus ServerStorage/AdminGuns verteilen

### Pet System Features
- **6 Pet-Arten** mit unterschiedlichen Seltenheiten und Boni:
  - Hund (100 Coins, +20% Bonus)
  - Katze (150 Coins, +25% Bonus)
  - Hase (250 Coins, +30% Bonus)
  - Fuchs (500 Coins, +50% Bonus)
  - Panda (1000 Coins, +75% Bonus)
  - Drache (5000 Coins, +150% Bonus)
- **Automatische Coins**: Jede Minute Coins basierend auf Pet-Bonus
- **Pet-Umbenennung**: Für 50 Coins eigene Namen vergeben
- **Persistente Daten**: Alle Käufe und Namen werden gespeichert

### Shop-Standort
Der Pet-Shop spawnt automatisch bei den Koordinaten `86.5, 15.631, 182.718`. Falls diese Position in deinem Spiel nicht passt, kannst du sie in der `pet.lua` Datei in der Funktion `createShopClickDetector()` ändern.

## 🔧 Anpassungen

### Admin-System anpassen
- **Owner-ID ändern**: Zeile 8 in `admin.lua`
- **Waffen hinzufügen**: Neue Tools in ServerStorage/AdminGuns
- **Coins-Betrag ändern**: Zeile mit `coins.Value + 100` in `admin.lua`

### Pet-System anpassen
- **Neue Pets hinzufügen**: `PET_DATA` Array in beiden Dateien erweitern
- **Preise ändern**: `price` Werte in `PET_DATA` anpassen
- **Shop-Position**: `shopPart.Position` in `pet.lua` ändern
- **Coins-Rate**: `task.wait(60)` für andere Intervalle ändern

## 📝 Hinweise

- **DataStore**: Beide Systeme verwenden Roblox DataStore für persistente Speicherung
- **Sicherheit**: Das Admin-System hat eingebaute Schutzmaßnahmen gegen Missbrauch
- **Performance**: Alle Animationen und Updates sind optimiert
- **Kompatibilität**: Funktioniert mit allen Roblox-Spieltypen

## 🐛 Troubleshooting

**Admin-Menü öffnet sich nicht:**
- Überprüfe, ob deine User-ID korrekt eingetragen ist
- Stelle sicher, dass beide Scripts (Server + Client) korrekt platziert sind

**Pet-Shop nicht sichtbar:**
- Überprüfe die Koordinaten in deinem Spiel
- Schaue in der Konsole nach Fehlermeldungen

**Pets folgen nicht:**
- Stelle sicher, dass das ServerScript läuft
- Überprüfe, ob Models in ServerStorage vorhanden sind (optional)

**DataStore Fehler:**
- Aktiviere "Studio Access to API Services" in den Game Settings
- Publiziere das Spiel, um DataStore zu testen

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe `LICENSE` Datei für Details.