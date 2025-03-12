local currentPoint = {}
local jobBlips = {}

-- Création du blip visible pour tous (Bureau)
Citizen.CreateThread(function()
    for job, data in pairs(Config.Jobs) do
        local blip = AddBlipForCoord(data.Bureau.x, data.Bureau.y, data.Bureau.z)
        SetBlipSprite(blip, 351) -- Icône entreprise
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.jobLabel)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Création des blips de farm uniquement pour les joueurs du job
RegisterNetEvent('farming:createJobBlips')
AddEventHandler('farming:createJobBlips', function(recolte, traitement, vente)
    -- Supprime les anciens blips
    for _, blip in pairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}

    -- Création des nouveaux blips
    local function createBlip(coords, sprite, color, text)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(text)
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)
    end

    createBlip(recolte, 568, 2, "Zone de Récolte")
    createBlip(traitement, 499, 3, "Zone de Traitement")
    createBlip(vente, 500, 1, "Zone de Vente")
end)

-- Suppression des blips si le joueur change de job
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if not Config.Jobs[job.name] then
        for _, blip in pairs(jobBlips) do
            RemoveBlip(blip)
        end
        jobBlips = {}
    else
        TriggerServerEvent('farming:sendBlips')
    end
end)

-- Demande les blips au démarrage
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    TriggerServerEvent('farming:sendBlips')
end)




Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for job, data in pairs(Config.Jobs) do
            if #(playerCoords - data.recolteZone) < 50.0 and not currentPoint[job] then
                currentPoint[job] = vector3(data.recolteZone.x + math.random(-5,5), data.recolteZone.y + math.random(-5,5), data.recolteZone.z)
            end
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for job, data in pairs(Config.Jobs) do
            if currentPoint[job] and #(playerCoords - currentPoint[job]) < 2.0 then
                DrawText3D(currentPoint[job], _U('press_recolte'))
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:recolte', job)
                    currentPoint[job] = nil
                end
            end
            if #(playerCoords - data.traitementZone) < 2.0 then
                DrawText3D(data.traitementZone, _U('press_traitement'))
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:traitement', job)
                end
            end
            if #(playerCoords - data.venteZone) < 2.0 then
                DrawText3D(data.venteZone, _U('press_vente'))
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:vente', job)
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function DrawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end