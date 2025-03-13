local currentPoint = {}
local jobBlips = {}
local playerJob = nil


TriggerServerEvent('farming:assignJob')
RegisterNetEvent('farming:receiveJob')
AddEventHandler('farming:receiveJob', function(job)
    playerJob = job
    if Config.Jobs[playerJob] and #Config.Jobs[playerJob].Recolte > 0 then
        local randomIndex = math.random(1, #Config.Jobs[playerJob].Recolte)
        currentPoint[playerJob] = Config.Jobs[playerJob].Recolte[randomIndex]
        print("[DEBUG] Initialisation du point de récolte pour " .. playerJob .. ": " .. 
            tostring(currentPoint[playerJob].x) .. ", " .. 
            tostring(currentPoint[playerJob].y) .. ", " .. 
            tostring(currentPoint[playerJob].z))
    end
    updateJobBlips()
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerJob = job.name
    updateJobBlips()
end)


-- Création et mise à jour des blips
function updateJobBlips()
    for _, blip in pairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}

    if playerJob and Config.Jobs[playerJob] then
        local data = Config.Jobs[playerJob]

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

        for _, rec in pairs(data.Recolte) do
            createBlip(rec, 568, data.Color, "Zone de Récolte")
        end
        createBlip(data.Traitement, 271, data.Color, "Zone de Traitement")
        createBlip(data.Vente, 500, data.Color, "Zone de Vente")
    end
end

-- Ajout des blips de bureau visibles pour tout le monde
Citizen.CreateThread(function()
    for job, data in pairs(Config.Jobs) do
        local blip = AddBlipForCoord(data.Bureau.x, data.Bureau.y, data.Bureau.z)
        SetBlipSprite(blip, 475)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, data.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bureau " .. job)
        EndTextCommandSetBlipName(blip)
    end
end)



Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for job, data in pairs(Config.Jobs) do
            if currentPoint[job] and Vdist2(playerCoords, currentPoint[job]) < 4.0 then
                DrawText3D(currentPoint[job], _U('press_recolte'))
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:recolte', job)
                    -- Nouveau point après récolte
                    local randomIndex = math.random(1, #data.Recolte)
                    currentPoint[job] = data.Recolte[randomIndex]
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- Interaction avec les zones
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]
            print("[DEBUG] Test Stockage Current point" .. tostring(currentPoint));
            -- Récolte
            if currentPoint[playerJob] then
                print("[DEBUG] Vérification de la position du joueur pour la récolte")
                print("[DEBUG] Distance à la zone de récolte: " .. #(playerCoords - currentPoint[playerJob]))
                if #(playerCoords - currentPoint[playerJob]) < 2.0 then
                    DrawText3D(currentPoint[playerJob], "Appuyez sur ~y~E~s~ pour récolter")
                    if IsControlJustReleased(0, 38) then
                        print("[DEBUG] Récolte déclenchée pour le job: " .. tostring(playerJob))
                        TriggerServerEvent('farming:recolte', playerJob)
                    end
                end
            else
                --print("[DEBUG] Aucun point de récolte défini pour le job: " .. tostring(playerJob))
            end
            -- Traitement
            if #(playerCoords - data.Traitement) < 2.0 then
                DrawText3D(data.Traitement, "Appuyez sur ~y~E~s~ pour traiter")
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:traitement', playerJob)
                end
            end

            -- Vente
            if #(playerCoords - data.Vente) < 2.0 then
                DrawText3D(data.Vente, "Appuyez sur ~y~E~s~ pour vendre")
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:vente', playerJob)
                end
            end
        end
        Citizen.Wait(0)
    end
end)


-- Affichage des markers
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]

            -- Marker Récolte actif (jaune)
            if currentPoint[playerJob] then
                print("[DEBUG] Current Point: " .. tostring(currentPoint[playerJob].x) .. ", " .. tostring(currentPoint[playerJob].y) .. ", " .. tostring(currentPoint[playerJob].z))
                DrawMarker(1, currentPoint[playerJob].x, currentPoint[playerJob].y, currentPoint[playerJob].z - 1.0, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    1.0, 1.0, 1.0, 
                    255, 255, 0, 150,  
                    false, false, 2, false, nil, nil, false
                )
            else
                --print("[DEBUG] Aucun currentPoint défini pour: " .. tostring(playerJob))
            end

            -- Marker Traitement (bleu)
            DrawMarker(1, data.Traitement.x, data.Traitement.y, data.Traitement.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                1.0, 1.0, 1.0, 
                0, 0, 255, 150,  
                false, false, 2, false, nil, nil, false
            )

            -- Marker Vente (vert)
            DrawMarker(1, data.Vente.x, data.Vente.y, data.Vente.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                1.0, 1.0, 1.0, 
                0, 255, 0, 150,  
                false, false, 2, false, nil, nil, false
            )
        end
        Citizen.Wait(0)
    end
end)
-- Fonction pour afficher du texte 3D
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
