local currentPoint = {}
local jobBlips = {}
local playerJob = nil


RegisterNetEvent('farming:receiveJob')
AddEventHandler('farming:receiveJob', function(job)
    playerJob = job
    if Config.Jobs[playerJob] and #Config.Jobs[playerJob].Recolte > 0 then
        local randomIndex = math.random(1, #Config.Jobs[playerJob].Recolte)
        currentPoint[playerJob] = Config.Jobs[playerJob].Recolte[randomIndex]
    end
    updateJobBlips()
    Citizen.Wait(2000) 
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerJob = job.name
    TriggerServerEvent('farming:assignJob')
    updateJobBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerJob = xPlayer.job.name
    TriggerServerEvent('farming:assignJob')
    updateJobBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent('farming:requestBlips')
end)

RegisterCommand("jobmenu", function()
    if playerJob and Config.Jobs[playerJob] and Config.Jobs[playerJob].Boss then
        OpenBossMenu()
    end
end, false)

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
            createBlip(rec, 568, data.Color, _U('recolte_zone'))
        end
        createBlip(data.Traitement, 271, data.Color, _U("process_zone"))
        createBlip(data.Vente, 500, data.Color, _U("sell_zone"))
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
        AddTextComponentString(_U("office") .. job)
        EndTextCommandSetBlipName(blip)
    end
end)

function OpenBossMenu()
    local elements = {
        {label = "Recruter un employé", value = "recruit"},
        {label = "Virer un employé", value = "fire"},
        {label = "Gérer la caisse de l'entreprise", value = "manage_funds"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
        title    = "Gestion du job",
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == "recruit" then
            -- Logique pour recruter un employé
        elseif data.current.value == "fire" then
            -- Logique pour virer un employé
        elseif data.current.value == "manage_funds" then
            -- Logique pour gérer les fonds
        end
    end, function(data, menu)
        menu.close()
    end)
end



-- Ajout d'animations et de progress bar lors des actions
function StartProgressBar(duration, label, animDict, animName)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 8.0, -1, 49, 0, false, false, false)
    exports['progressBars']:startUI(duration, label)
    Citizen.Wait(duration)
    ClearPedTasks(PlayerPedId())
end



Citizen.CreateThread(function()
    while not playerJob or not currentPoint[playerJob] do
        Citizen.Wait(500) -- Attends que les données soient bien chargées
    end

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for job, data in pairs(Config.Jobs) do
            if currentPoint[job] and Vdist2(playerCoords, currentPoint[job]) < 4.0 then
                DrawText3D(currentPoint[job], _U('press_gather'))
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
            -- Récolte
            if currentPoint[playerJob] then
                if #(playerCoords - currentPoint[playerJob]) < 2.0 then
                    DrawText3D(currentPoint[playerJob], _U("press_gather"))
                    if IsControlJustReleased(0, 38) then
                        StartProgressBar(5000, _U("inprogress_gather"), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer")
                        TriggerServerEvent('farming:recolte', playerJob)
                    end
                end
            else
                --print("[DEBUG] Aucun point de récolte défini pour le job: " .. tostring(playerJob))
            end
            -- Traitement
            if #(playerCoords - data.Traitement) < 2.0 then
                DrawText3D(data.Traitement, _U("press_process"))
                if IsControlJustReleased(0, 38) then
                    StartProgressBar(7000, _U("inprogress_process"), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer")
                    TriggerServerEvent('farming:traitement', playerJob)
                end
            end

            -- Vente
            if #(playerCoords - data.Vente) < 2.0 then
                DrawText3D(data.Vente, _U("press_sell"))
                if IsControlJustReleased(0, 38) then
                    StartProgressBar(6000, _U("inprogress_sell"), "mp_common", "givetake1_a")
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
