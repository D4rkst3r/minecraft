-- Installer für Induction Matrix Monitor
local githubUser = "D4rkst3r"
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
