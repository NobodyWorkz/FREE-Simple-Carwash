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

-- Funktion zum erstellen des Markers
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
local function drawText3D(x, y, z, text)
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

-- Erstellen von Markern und Anzeigen von Text an CarWash-Positionen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, location in ipairs(Config.CarWash.positions) do
            local coord = location.coord
            local size = location.size
            if Vdist(playerCoords, coord.x, coord.y, coord.z) < 10.0 then -- Sichtbarkeit auf 10.0 erhöht
                createMarker(coord, size)
                drawText3D(coord.x, coord.y, coord.z + 0.5, Config.CarWash.washText) -- Text aus Config anzeigen
                if Vdist(playerCoords, coord.x, coord.y, coord.z) < 5.0 then -- Interaktionsreichweite bleibt bei 5.0
                    if IsControlJustReleased(1, 51) then -- E Taste
                    end
                end
            end
        end
    end
end)

local isWashing = false

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
        if not IsPedInAnyVehicle(cache.ped, false) then
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
        if not IsPedInAnyVehicle(cache.ped, false) then
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

AddEventHandler('nbw_carwash:CanWash', function()
    TriggerServerEvent('nbw_carwash:checkWash')
end)

-- Funktion für die Wäsche
function startWash()
    -- Prüfe, ob die Wäsche bereits läuft
    if isWashing then
        return
    end

    -- Setze den Wasch-Status auf "laufend"
    isWashing = true
    local vehicle = GetVehiclePedIsIn(cache.ped)
    local dist = 'cut_family2'
    local fxName = 'cs_fam2_ped_water_splash'
    FreezeEntityPosition(vehicle, true)

    -- Lade und aktiviere den Partikel-Effekt
    RequestNamedPtfxAsset(dist)
    while not HasNamedPtfxAssetLoaded(dist) do
        Wait(1)
    end
    UseParticleFxAssetNextCall(dist)
    local particle = StartParticleFxLoopedAtCoord(fxName, GetEntityCoords(cache.ped), 0.0, 0.0, 0.0, 8.0, false, false, false, 0)

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
    end
end

-- Registriere das Event
RegisterNetEvent('nbw_carwash:startWash', startWash)

