local ESX = exports['es_extended']:getSharedObject()

local currentPoint = {}
local jobBlips = {}
local playerJob = nil
local PlayerData = {}
RegisterNetEvent('esx:playerLoaded', function(data) PlayerData = data end)
RegisterNetEvent('esx:setJob', function(job) PlayerData.job = job end)

-- Réception du job attribué
RegisterNetEvent('farming:receiveJob', function(job)
    playerJob = job
    if Config.Jobs[playerJob] and #Config.Jobs[playerJob].Recolte > 0 then
        local randomIndex = math.random(1, #Config.Jobs[playerJob].Recolte)
        currentPoint[playerJob] = Config.Jobs[playerJob].Recolte[randomIndex]
    end
    updateJobBlips()
end)

-- Changement de job
RegisterNetEvent('esx:setJob', function(job)
    playerJob = job.name
    TriggerServerEvent('farming:assignJob')
    updateJobBlips()
end)

-- Chargement du joueur
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    playerJob = xPlayer.job.name
    TriggerServerEvent('farming:assignJob')
    TriggerServerEvent('farming:requestBlips')
    updateJobBlips()
end)

-- Commande pour ouvrir le menu boss
-- RegisterCommand("openBossFarming", function()
--     ESX.PlayerData = ESX.GetPlayerData()
--     if not playerJob or not ESX.PlayerData or not ESX.PlayerData.job then 
--         ESX.ShowNotification("❌ Les données de votre métier ne sont pas encore chargées.")
--         return 
--     end

--     if Config.Jobs[playerJob] and ESX.PlayerData.job.name == playerJob and ESX.PlayerData.job.grade_name == 'boss' then
--         OpenBossMenu()
--     else
--         ESX.ShowNotification("❌ Vous n'avez pas le grade requis pour accéder à ce menu.")
--     end
-- end, false)

-- Création des blips dynamiques
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

-- Création des blips de bureaux au démarrage
CreateThread(function()
    for job, data in pairs(Config.Jobs) do
        local blip = AddBlipForCoord(data.Bureau.x, data.Bureau.y, data.Bureau.z)
        SetBlipSprite(blip, 475)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, data.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U("office") .. data.jobLabel)
        EndTextCommandSetBlipName(blip)
    end
end)

-- -- Menu Boss
-- function OpenBossMenu()
--     local elements = {
--         {label = "👥 Recruter un employé", value = "recruit"},
--         {label = "❌ Virer un employé", value = "fire"},
--         {label = "💰 Gérer la caisse de l'entreprise", value = "manage_funds"}
--     }

--     ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
--         title    = "Gestion du métier",
--         align    = 'top-left',
--         elements = elements
--     }, function(data, menu)
--         if data.current.value == "recruit" then
--             -- à implémenter
--         elseif data.current.value == "fire" then
--             -- à implémenter
--         elseif data.current.value == "manage_funds" then
--             -- à implémenter
--         end
--     end, function(data, menu)
--         menu.close()
--     end)
-- end

-- ProgressBar
function StartProgressBar(duration, label, animDict, animName)
    local ped = PlayerPedId()
    local success = lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = animDict, clip = animName }
    })

    return success
end

-- Interactions récolte / traitement / vente
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]

            -- Récolte
            if currentPoint[playerJob] and #(coords - currentPoint[playerJob]) < 2.0 then
                DrawText3D(currentPoint[playerJob], _U("press_gather"))
                if IsControlJustReleased(0, 38) then
                    if StartProgressBar(3500, _U("inprogress_gather"), "pickup_object", "pickup_low") then
                        TriggerServerEvent('farming:recolte', playerJob)
                        local rand = math.random(1, #data.Recolte)
                        currentPoint[playerJob] = data.Recolte[rand]
                    end
                end
            end

            -- Traitement
            if #(coords - data.Traitement) < 2.0 then
                DrawText3D(data.Traitement, _U("press_process"))
                if IsControlJustReleased(0, 38) then
                    if StartProgressBar(2000, _U("inprogress_process"), "mini@repair", "fixing_a_ped") then
                        TriggerServerEvent('farming:traitement', playerJob)
                    end
                end
            end

            -- Vente
            if #(coords - data.Vente) < 2.0 then
                DrawText3D(data.Vente, _U("press_sell"))
                if IsControlJustReleased(0, 38) then
                    if StartProgressBar(2000, _U("inprogress_sell"), "mp_common", "givetake1_a") then
                        TriggerServerEvent('farming:vente', playerJob)
                    end
                end
            end

            -- Bureau
            if data.Bureau and #(coords - data.Bureau) < 2.0 and PlayerData.job.grade_name == 'boss' then
                DrawText3D(data.Bureau, "[E] Accéder au menu de gestion")
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('esx_society:openBossMenu', playerJob, function(data, menu)
                        menu.close()
                    end, { wash = false }) -- Tu peux mettre true si tu veux activer le blanchiment
                end
            end
        end
    end
end)

-- Marqueurs au sol
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if playerJob and Config.Jobs[playerJob] then
            local data = Config.Jobs[playerJob]
            if currentPoint[playerJob] then
                DrawMarker(1, currentPoint[playerJob].x, currentPoint[playerJob].y, currentPoint[playerJob].z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 2.0, 255, 255, 0, 150, false, false, 2, false, nil, nil, false)
            end
            DrawMarker(1, data.Traitement.x, data.Traitement.y, data.Traitement.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 2.0, 0, 0, 255, 150, false, false, 2, false, nil, nil, false)
            DrawMarker(1, data.Vente.x, data.Vente.y, data.Vente.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 2.0, 0, 255, 0, 150, false, false, 2, false, nil, nil, false)
            if data.Bureau and PlayerData.job.grade_name == 'boss' then
                DrawMarker(1, data.Bureau.x, data.Bureau.y, data.Bureau.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 2.0, 255, 0, 255, 150, false, false, 2, false, nil, nil, false)
            end
        end
    end
end)

-- DrawText3D simple
function DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local p = GetGameplayCamCoords()
    local dist = #(p - coords)
    local scale = 0.35 / dist * 2.0

    if onScreen then
        SetTextScale(0.0 * scale, 2 * scale)
        SetTextFont(0)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end
