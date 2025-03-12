local currentPoint = {}
local jobBlips = {}
local playerJob = nil



-- Vérifie si le joueur a un job au démarrage et met à jour les blips
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Attente pour s'assurer que ESX est bien chargé
    TriggerServerEvent('farming:requestJob')
end)

RegisterNetEvent('farming:receiveJob')
AddEventHandler('farming:receiveJob', function(job)
    playerJob = job
    updateJobBlips()
end)



-- Mise à jour du job du joueur
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerJob = job.name
    updateJobBlips()
end)

-- Création du blip de Bureau visible par tous
Citizen.CreateThread(function()
    for job, data in pairs(Config.Jobs) do
        local blip = AddBlipForCoord(data.Bureau.x, data.Bureau.y, 200)
        SetBlipSprite(blip, 475) -- Icône entreprise
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, data.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.jobLabel)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Création des blips de farm uniquement pour les joueurs du job
function updateJobBlips()
    -- Supprime les anciens blips
    for _, blip in pairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}

    -- Si le joueur a un job dans Config.Jobs, on affiche les blips
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

        createBlip(data.Traitement, 271, 5, "Zone de Traitement")
        createBlip(data.Vente, 271, 5, "Zone de Vente")
    end
end

-- Vérifie si le joueur a un job au démarrage et demande les blips
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    TriggerServerEvent('farming:requestJob')
end)

RegisterNetEvent('farming:receiveJob')
AddEventHandler('farming:receiveJob', function(job)
    playerJob = job
    updateJobBlips()
end)

-- Sélection d'un point de récolte aléatoire UNIQUEMENT après une récolte
RegisterNetEvent('farming:updateRecoltePoint')
AddEventHandler('farming:updateRecoltePoint', function()
    if playerJob and Config.Jobs[playerJob] then
        local data = Config.Jobs[playerJob]
        local randomIndex = math.random(1, #data.Recolte)
        currentPoint[playerJob] = data.Recolte[randomIndex]
    end
end)


-- Interaction avec les zones (récolte, traitement, vente)
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

        Citizen.Wait(0) -- Vérification en boucle
    end
end)

-- Affichage des markers uniquement pour les joueurs du job
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]

            -- Marker Récolte (jaune)
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

        Citizen.Wait(0) -- Rafraîchit en permanence
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
