local ESX = exports['es_extended']:getSharedObject()

-- Laden der Konfigurationsdatei
Config = {}
Config.CarWash = { positions = {} }

-- Funktion zum Laden der Konfigurationsdatei
function LoadConfig()
    -- Hier wird angenommen, dass die config.lua im shared Verzeichnis liegt
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'shared/config.lua')
    assert(load(configFile))()
end

-- Konfigurationsdatei laden
LoadConfig()

-- Erstellen des Blips auf der Karte
local function createBlip(coord)
    local blip = AddBlipForCoord(coord.x, coord.y, coord.z)

    SetBlipSprite(blip, 100)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.CarWash.blipName)
    EndTextCommandSetBlipName(blip)

    return blip
end

-- Funktion zum Abrufen des Waschtextes basierend auf dem Preis
function getWashText()
    if Config.Price and Config.Price > 0 then
        return string.format(Config.CarWash.washTextWithPrice, Config.Price)
    else
        return Config.CarWash.washText
    end
end

-- Funktion zum Erstellen des Markers
local function createMarker(coord, size)
    local markerConfig = Config.CarWash.marker
    DrawMarker(
        markerConfig.type,              -- Marker-Typ aus der Config
        coord.x, coord.y, coord.z - 1.2,
        0, 0, 0, 
        0, 0, 0, 
        size.x * markerConfig.scale.x,  -- Größe anpassen
        size.y * markerConfig.scale.y,  -- Größe anpassen
        size.z * markerConfig.scale.z,  -- Größe anpassen
        markerConfig.color.r,           -- Marker-Farbe (Rot)
        markerConfig.color.g,           -- Marker-Farbe (Grün)
        markerConfig.color.b,           -- Marker-Farbe (Blau)
        markerConfig.color.a,           -- Marker-Farbe (Alpha)
        false, false, 2, false, nil, nil, false
    )
end

-- Funktion zum Zeichnen von 3D-Text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Funktion, die den Autowaschvorgang startet
function carwash()
    -- Prüfe, ob die Wäsche bereits läuft oder der Spieler nicht in einem Fahrzeug ist
    if isWashing or not IsPedInAnyVehicle(PlayerPedId(), false) then
        return
    end

    -- Setze den Wasch-Status auf "laufend"
    isWashing = true
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local dist = 'cut_family2'
    local fxName = 'cs_fam2_ped_water_splash'
    FreezeEntityPosition(vehicle, true)

    -- Lade und aktiviere den Partikel-Effekt
    RequestNamedPtfxAsset(dist)
    while not HasNamedPtfxAssetLoaded(dist) do
        Wait(1)
    end
    UseParticleFxAssetNextCall(dist)
    local particle = StartParticleFxLoopedAtCoord(fxName, GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 8.0, false, false, false, 0)

    -- Zeige Fortschrittsanzeige an
    if lib.progressCircle({
            duration = Config.CarWash.progress.duration,
            label = Config.CarWash.progress.label,
            position = Config.CarWash.progress.position,
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true
            }
        })
    then
        -- Stoppe den Partikel-Effekt
        StopParticleFxLooped(particle, false)

        -- Setze Fahrzeug-Schmutzlevel zurück und entferne Decals
        SetVehicleDirtLevel(vehicle, 0.0)
        WashDecalsFromVehicle(vehicle, 1.0)

        -- Hebe die Fahrzeug-Freeze auf
        FreezeEntityPosition(vehicle, false)

        -- Setze den Wasch-Zustand zurück
        isWashing = false

        -- Zeige ESX Benachrichtigung an
        TriggerEvent('esx:showNotification', Config.CarWash.washCompletionMessage, 'success')
        
        -- Sende eine Anfrage an den Server, um den Preis abzuziehen, wenn Preis > 0
        if Config.Price and Config.Price > 0 then
            TriggerServerEvent('carwash:chargePlayer', Config.Price)
        end
    end
end

-- Event-Handler für das Starten der Autowäsche
AddEventHandler('nbw_carwash:startWash', carwash)

-- Funktion zur Überprüfung, ob der Spieler das Auto waschen kann
AddEventHandler('nbw_carwash:CanWash', function()
    TriggerServerEvent('nbw_carwash:checkWash')
end)

-- Hauptthread zum Erstellen von Markern und Anzeigen von Text an CarWash-Positionen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Hier sollte die Logik sein, um zu überprüfen, ob der Spieler in der Nähe der Waschanlage ist
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, washLocation in pairs(Config.CarWash.positions) do
            if IsPedInAnyVehicle(playerPed, false) then
                local distance = #(playerCoords - washLocation.coord)
                if distance < 10.0 then -- Sichtbarkeit auf 10.0 erhöht
                    createMarker(washLocation.coord, washLocation.size)
                    DrawText3D(washLocation.coord.x, washLocation.coord.y, washLocation.coord.z + 0.5, getWashText()) -- Text aus Config anzeigen
                    if distance < 5.0 then -- Interaktionsreichweite bleibt bei 5.0
                        if IsControlJustReleased(0, 38) then -- E Taste
                            carwash()
                        end
                    end
                end
            end
        end
    end
end)

local isWashing = false

-- Erstellen von Blips und Zonen für die Waschanlagen
for _, v in pairs(Config.CarWash.positions) do
    v.blip = createBlip(v.coord)

    local zone = lib.zones.box({
        coords = v.coord,
        size = v.size,
        rotation = v.rot,
        debug = v.debug,
    })
    v.zone = zone

    function zone:onEnter()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            return
        end
        if Config.useRadial then
            lib.addRadialItem({
                id = 'carwash',
                icon = Config.radialData.icon,
                label = Config.radialData.label,
                onSelect = function()
                    TriggerEvent('nbw_carwash:CanWash')
                end
            })
            if Config.radialData.useNotify then
                lib.notify({
                    title = Config.radialData.NotifyTitle,
                    description = Config.radialData.NotifyDescription,
                    type = Config.radialData.NotifyType,
                    duration = Config.radialData.NotifyDuration,
                })
            end
            return
        end
    end

    function zone:inside()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            return
        end
        if Config.useRadial then
            return
        end
        if IsControlJustReleased(0, 38) then
            TriggerEvent('nbw_carwash:CanWash')
        end
    end
end
