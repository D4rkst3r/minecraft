# Mekanism Induction Matrix Monitor - Installation Guide

## 📋 Voraussetzungen

- Minecraft mit CC: Tweaked Mod
- Mekanism Mod mit Induction Matrix
- Mindestens ein Computer und ein Monitor von CC: Tweaked
- Internet-Verbindung im Spiel (HTTP API muss aktiviert sein)

## 🔧 Hardware Setup

1. **Computer platzieren** - Advanced Computer empfohlen für Farben
2. **Monitor(e) anschließen** - Nutze Netzwerkkabel oder platziere direkt daneben
3. **Induction Matrix verbinden** - Computer muss die Matrix als Peripherie erkennen können

## 📁 GitHub Repository erstellen

### 1. Repository auf GitHub erstellen

```
Repository Name: minecraft-induction-monitor
Beschreibung: CC: Tweaked Monitor für Mekanism Induction Matrix
```

### 2. Dateien hochladen

Lade folgende Dateien in dein Repository:

- `induction_monitor.lua` (Das Hauptprogramm)
- `installer.lua` (Installations-Script)
- `README.md` (Dokumentation)

## 📦 Installer Script erstellen

Erstelle eine Datei namens `installer.lua`:

```lua
-- Installer für Induction Matrix Monitor
local githubUser = "DEIN_GITHUB_USERNAME"
local repoName = "minecraft-induction-monitor"
local branch = "main"

local function downloadFile(filename, path)
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s",
                             githubUser, repoName, branch, filename)

    print("Lade " .. filename .. " herunter...")

    local response = http.get(url)
    if not response then
        error("Fehler beim Herunterladen von " .. filename)
    end

    local content = response.readAll()
    response.close()

    local file = fs.open(path, "w")
    file.write(content)
    file.close()

    print(filename .. " erfolgreich heruntergeladen!")
end

local function install()
    print("=== Mekanism Induction Monitor Installer ===")
    print("Installiere von GitHub...")

    -- Hauptprogramm herunterladen
    downloadFile("induction_monitor.lua", "induction_monitor")

    -- Startup script erstellen (optional)
    print("Möchtest du das Programm beim Start automatisch ausführen? (j/n)")
    local input = read()
    if input:lower() == "j" or input:lower() == "ja" then
        local startup = fs.open("startup", "w")
        startup.writeLine('shell.run("induction_monitor")')
        startup.close()
        print("Auto-Start aktiviert!")
    end

    print("\n=== Installation abgeschlossen! ===")
    print("Starte das Programm mit: induction_monitor")
    print("Oder starte den Computer neu für Auto-Start")
end

install()
```

## 🚀 Installation im Spiel

### Methode 1: Direkte Installation von GitHub

1. **Computer einschalten**
2. **HTTP API prüfen:**

   ```lua
   print(http.checkURL("https://github.com"))
   ```

   (Sollte `true` zurückgeben)

3. **Installer herunterladen und ausführen:**

   ```lua
   pastebin get DEIN_PASTEBIN_CODE installer
   installer
   ```

   **ODER direkt von GitHub:**

   ```lua
   shell.run("wget", "https://raw.githubusercontent.com/DEIN_USERNAME/minecraft-induction-monitor/main/installer.lua", "installer")
   installer
   ```

### Methode 2: Manueller Download

1. **Programm herunterladen:**

   ```lua
   shell.run("wget", "https://raw.githubusercontent.com/DEIN_USERNAME/minecraft-induction-monitor/main/induction_monitor.lua", "induction_monitor")
   ```

2. **Programm starten:**
   ```lua
   induction_monitor
   ```

## ⚙️ Konfiguration

### Automatisches Setup

Das Programm erkennt automatisch:

- Alle verfügbaren Induction Matrix Blöcke
- Alle angeschlossenen Monitore
- Ordnet Monitore automatisch den Matrizen zu

### Mehrere Matrizen

- Bei mehreren Matrizen werden sie auf verschiedene Monitore verteilt
- Jede Matrix bekommt ihren eigenen Bildschirm
- Bei mehr Matrizen als Monitore wird rotiert

## 🎮 Verwendung

### Anzeige-Elemente:

- **Energie Speicher:** Aktuell / Maximum in FE (Forge Energy)
- **Füllstand:** Prozentuale Anzeige mit Farb-kodiertem Balken
- **Transfer Raten:** Ein- und Ausgangsraten
- **Netto Rate:** Differenz zwischen Ein- und Ausgang
- **Zeit-Prognose:** Wie lange bis voll/leer bei aktueller Rate

### Farb-Kodierung:

- 🔴 **Rot:** < 25% Füllstand
- 🟠 **Orange:** 25-50% Füllstand
- 🟡 **Gelb:** 50-75% Füllstand
- 🟢 **Grün:** > 75% Füllstand

## 🛠️ Anpassungen

### Monitor-Größe ändern:

```lua
-- In der displayOnMonitor Funktion
mon.setTextScale(0.5) -- Kleinere Schrift
mon.setTextScale(1.5) -- Größere Schrift
```

### Update-Intervall ändern:

```lua
-- Am Ende der main() Funktion
sleep(1) -- Schnellere Updates (1 Sekunde)
sleep(5) -- Langsamere Updates (5 Sekunden)
```

## 📝 Fehlerbehebung

### "Keine Induction Matrix gefunden"

- Prüfe ob die Matrix korrekt angeschlossen ist
- Nutze `peripheral.getNames()` um verfügbare Geräte zu sehen

### "Keine Monitore gefunden"

- Stelle sicher dass Monitore mit Netzwerkkabel verbunden sind
- Oder platziere sie direkt neben dem Computer

### HTTP Fehler

- Prüfe ob HTTP API in der CC: Tweaked Config aktiviert ist
- Server-Admins müssen eventuell URLs freigeben

## 🔄 Updates

Um das Programm zu aktualisieren:

```lua
shell.run("wget", "https://raw.githubusercontent.com/D4rkst3r/minecraft/main/induction_monitor.lua", "induction_monitor")
```

## 📚 Weitere Features (Erweiterbar)

- Alarm bei niedrigem Energiestand
- Redstone-Ausgabe für Automatisierung
- Web-Interface über HTTP API
- Datenlogging in Dateien
- Multi-Server Monitoring
