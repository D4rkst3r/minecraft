-- Mekanism Induction Matrix Monitor
-- Für CC: Tweaked
-- Autor: [D4rkst3r]

local function findPeripherals()
    local matrices = {}
    local monitors = {}

    for name, type in pairs(peripheral.getNames()) do
        if type == "induction_matrix" then
            table.insert(matrices, name)
        elseif type == "monitor" then
            table.insert(monitors, name)
        end
    end

    return matrices, monitors
end

local function formatEnergy(energy)
    if energy >= 1000000000 then
        return string.format("%.2f GFE", energy / 1000000000)
    elseif energy >= 1000000 then
        return string.format("%.2f MFE", energy / 1000000)
    elseif energy >= 1000 then
        return string.format("%.2f kFE", energy / 1000)
    else
        return string.format("%.0f FE", energy)
    end
end

local function formatRate(rate)
    if rate >= 1000000 then
        return string.format("%.2f MFE/t", rate / 1000000)
    elseif rate >= 1000 then
        return string.format("%.2f kFE/t", rate / 1000)
    else
        return string.format("%.0f FE/t", rate)
    end
end

local function getPercentage(current, max)
    if max == 0 then return 0 end
    return (current / max) * 100
end

local function drawProgressBar(monitor, x, y, width, percentage, color)
    local filled = math.floor(width * percentage / 100)

    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(colors.gray)
    monitor.write(string.rep(" ", width))

    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(color)
    monitor.write(string.rep(" ", filled))

    monitor.setBackgroundColor(colors.black)
end

local function displayOnMonitor(monitor, matrixData, matrixName)
    local mon = peripheral.wrap(monitor)
    if not mon then return end

    mon.clear()
    mon.setTextScale(1)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)

    local width, height = mon.getSize()

    -- Header
    mon.setCursorPos(1, 1)
    mon.setTextColor(colors.yellow)
    mon.write("=== MEKANISM INDUCTION MATRIX ===")

    mon.setCursorPos(1, 2)
    mon.setTextColor(colors.cyan)
    mon.write("Matrix: " .. matrixName)

    -- Energie Informationen
    local y = 4
    mon.setCursorPos(1, y)
    mon.setTextColor(colors.white)
    mon.write("Energie Speicher:")

    y = y + 1
    mon.setCursorPos(3, y)
    mon.setTextColor(colors.lime)
    mon.write("Aktuell: " .. formatEnergy(matrixData.energy))

    y = y + 1
    mon.setCursorPos(3, y)
    mon.setTextColor(colors.orange)
    mon.write("Maximum: " .. formatEnergy(matrixData.maxEnergy))

    -- Füllstand in Prozent
    local percentage = getPercentage(matrixData.energy, matrixData.maxEnergy)
    y = y + 1
    mon.setCursorPos(3, y)
    mon.setTextColor(colors.yellow)
    mon.write(string.format("Füllstand: %.1f%%", percentage))

    -- Progress Bar
    y = y + 2
    local barColor = colors.red
    if percentage > 25 then barColor = colors.orange end
    if percentage > 50 then barColor = colors.yellow end
    if percentage > 75 then barColor = colors.lime end

    drawProgressBar(mon, 1, y, math.min(width, 30), percentage, barColor)

    -- Ein-/Ausgangsraten
    y = y + 2
    mon.setCursorPos(1, y)
    mon.setTextColor(colors.white)
    mon.write("Transfer Raten:")

    y = y + 1
    mon.setCursorPos(3, y)
    mon.setTextColor(colors.lime)
    mon.write("Eingang: " .. formatRate(matrixData.input))

    y = y + 1
    mon.setCursorPos(3, y)
    mon.setTextColor(colors.red)
    mon.write("Ausgang: " .. formatRate(matrixData.output))

    -- Netto Rate
    local netRate = matrixData.input - matrixData.output
    y = y + 1
    mon.setCursorPos(3, y)
    if netRate > 0 then
        mon.setTextColor(colors.lime)
        mon.write("Netto: +" .. formatRate(netRate))
    elseif netRate < 0 then
        mon.setTextColor(colors.red)
        mon.write("Netto: " .. formatRate(netRate))
    else
        mon.setTextColor(colors.yellow)
        mon.write("Netto: " .. formatRate(0))
    end

    -- Zeit bis voll/leer
    y = y + 2
    if netRate > 0 and matrixData.energy < matrixData.maxEnergy then
        local timeToFull = (matrixData.maxEnergy - matrixData.energy) / netRate / 20 -- /20 für Sekunden
        mon.setCursorPos(1, y)
        mon.setTextColor(colors.cyan)
        mon.write(string.format("Voll in: %.1f min", timeToFull / 60))
    elseif netRate < 0 and matrixData.energy > 0 then
        local timeToEmpty = matrixData.energy / math.abs(netRate) / 20
        mon.setCursorPos(1, y)
        mon.setTextColor(colors.red)
        mon.write(string.format("Leer in: %.1f min", timeToEmpty / 60))
    end

    -- Timestamp
    mon.setCursorPos(1, height)
    mon.setTextColor(colors.gray)
    mon.write("Letzte Aktualisierung: " .. textutils.formatTime(os.time(), false))
end

local function getMatrixData(matrixName)
    local matrix = peripheral.wrap(matrixName)
    if not matrix then return nil end

    return {
        energy = matrix.getEnergy(),
        maxEnergy = matrix.getMaxEnergy(),
        input = matrix.getLastInput(),
        output = matrix.getLastOutput()
    }
end

local function main()
    print("Starte Mekanism Induction Matrix Monitor...")

    while true do
        local matrices, monitors = findPeripherals()

        if #matrices == 0 then
            print("Keine Induction Matrix gefunden!")
            sleep(5)
        elseif #monitors == 0 then
            print("Keine Monitore gefunden!")
            sleep(5)
        else
            -- Zeige Daten auf allen Monitoren für alle Matrizen
            for i, matrixName in ipairs(matrices) do
                local data = getMatrixData(matrixName)
                if data then
                    -- Wenn mehrere Monitore vorhanden, nutze verschiedene für verschiedene Matrizen
                    local monitorIndex = ((i - 1) % #monitors) + 1
                    local monitorName = monitors[monitorIndex]

                    displayOnMonitor(monitorName, data, matrixName)
                    print(string.format("Matrix %s: %s / %s (%.1f%%)",
                        matrixName,
                        formatEnergy(data.energy),
                        formatEnergy(data.maxEnergy),
                        getPercentage(data.energy, data.maxEnergy)))
                end
            end
        end

        sleep(2) -- Aktualisierung alle 2 Sekunden
    end
end

-- Programm starten
main()
