local currentPoint = {}
local jobBlips = {}
local playerJob = nil

-- Vérifie si le joueur a un job au démarrage et met à jour les blips
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    TriggerServerEvent('farming:requestJob')
end)

RegisterNetEvent('farming:receiveJob')
AddEventHandler('farming:receiveJob', function(job)
    playerJob = job
    updateJobBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerJob = job.name
    updateJobBlips()
end)

-- Création et mise à jour des blips
function updateJobBlips()
    -- Suppression des anciens blips
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

        -- Création des blips
        for _, rec in pairs(data.Recolte) do
            createBlip(rec, 568, data.Color, "Zone de Récolte")
        end
        createBlip(data.Traitement, 271, data.Color, "Zone de Traitement")
        createBlip(data.Vente, 500, data.Color, "Zone de Vente")
    end
end

-- Mise à jour du point de récolte
RegisterNetEvent('farming:setRecoltePoint')
AddEventHandler('farming:setRecoltePoint', function(point)
    print("Received Point: " .. tostring(point.x) .. ", " .. tostring(point.y) .. ", " .. tostring(point.z))
    if playerJob and Config.Jobs[playerJob] then
        currentPoint[playerJob] = point
    end
end)

-- Sélection d'un point de récolte aléatoire après une récolte
RegisterNetEvent('farming:updateRecoltePoint')
AddEventHandler('farming:updateRecoltePoint', function()
    if playerJob and Config.Jobs[playerJob] then
        local data = Config.Jobs[playerJob]
        local randomIndex = math.random(1, #data.Recolte)
        currentPoint[playerJob] = data.Recolte[randomIndex]
    end
end)

-- Interaction avec les zones
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]

            -- Récolte
            if currentPoint[playerJob] and #(playerCoords - currentPoint[playerJob]) < 2.0 then
                DrawText3D(currentPoint[playerJob], "Appuyez sur ~y~E~s~ pour récolter")
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('farming:recolte', playerJob)
                end
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

            -- Débogage du currentPoint pour s'assurer qu'il a des coordonnées valides
            if currentPoint[playerJob] then
                print("Current Point: " .. tostring(currentPoint[playerJob].x) .. ", " .. tostring(currentPoint[playerJob].y) .. ", " .. tostring(currentPoint[playerJob].z))
            end

            -- Marker Récolte actif (jaune)
            if currentPoint[playerJob] then
                DrawMarker(1, currentPoint[playerJob].x, currentPoint[playerJob].y, currentPoint[playerJob].z - 1.0, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    1.0, 1.0, 1.0, 
                    255, 255, 0, 150,  
                    false, false, 2, false, nil, nil, false
                )
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