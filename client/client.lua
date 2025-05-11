local ESX = exports['es_extended']:getSharedObject()

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
    TriggerServerEvent('farming:requestBlips')
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

RegisterCommand('openBossFarming', function()
    ESX.PlayerData = ESX.GetPlayerData()
    if not playerJob or not ESX.PlayerData or not ESX.PlayerData.job then 
        ESX.ShowNotification("❌ Les données de votre métier ne sont pas encore chargées.")
        return 
    end

    if ESX.PlayerData.job.name == playerJob and ESX.PlayerData.job.grade_name == 'boss' then
        OpenFarmingBossMenu()
    else
    end
end, false)



RegisterKeyMapping('OpenBossMenu', 'Menu Boss Farming', 'keyboard', 'F6')

function OpenFarmingBossMenu()
    ESX.UI.Menu.CloseAll()
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'farming_boss_menu', {
        title = "Menu Patron - " .. playerJob,
        align = 'right',
        elements = {
            {label = "👥 Recruter un joueur", value = "recruter"},
            {label = "⚙️ Gérer les employés", value = "gestion"},
            {label = "💰 Gérer la banque", value = "banque"},
            {label = "🚪 Fermer le menu", value = "close"}
        }
    }, function(data, menu)
        if data.current.value == 'recruter' then
            RecruterJoueur()
        elseif data.current.value == 'gestion' then
            OpenEmployeesList()
        elseif data.current.value == 'banque' then
            OpenSocietyBankMenu()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function RecruterJoueur()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance < 3.0 then
        TriggerServerEvent('farming:recruter', GetPlayerServerId(closestPlayer), playerJob)
        ESX.ShowNotification("✅ Joueur recruté.")
    else
        ESX.ShowNotification("❌ Aucun joueur proche.")
    end
end

function OpenSocietyBankMenu()
    ESX.TriggerServerCallback('farming:getSocietyMoney', function(money)
        local elements = {
            {label = "💵 Argent en société : " .. money .. "$", value = nil},
            {label = "➕ Déposer de l'argent", value = "deposit"},
            {label = "➖ Retirer de l'argent", value = "withdraw"},
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'society_bank_menu', {
            title = "Gestion Banque - " .. playerJob,
            align = 'right',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'deposit' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_amount', {
                    title = "Montant à déposer"
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    if amount then
                        TriggerServerEvent('farming:depositSocietyMoney', playerJob, amount)
                        menu2.close()
                    else
                        ESX.ShowNotification("❌ Montant invalide.")
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)

            elseif data.current.value == 'withdraw' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_amount', {
                    title = "Montant à retirer"
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    if amount then
                        TriggerServerEvent('farming:withdrawSocietyMoney', playerJob, amount)
                        menu2.close()
                    else
                        ESX.ShowNotification("❌ Montant invalide.")
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end



function OpenEmployeesList()
    ESX.TriggerServerCallback('farming:getEmployees', function(employees)
        local elements = {}

        for _, employee in pairs(employees) do
            table.insert(elements, {
                label = employee.name .. " - Grade: " .. employee.gradeLabel,
                value = employee
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'employee_list', {
            title = "Liste des employés",
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local selected = data.current.value
            OpenEmployeeActions(selected)
        end, function(data, menu)
            menu.close()
        end)
    end, playerJob)
end


function OpenEmployeeActions(employee)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'employee_actions', {
        title = employee.name,
        align = 'top-left',
        elements = {
            {label = "🔼 Changer le grade", value = "promote"},
            {label = "❌ Virer l'employé", value = "fire"}
        }
    }, function(data, menu)
        if data.current.value == 'promote' then
            OpenGradeSelection(employee)
        elseif data.current.value == 'fire' then
            TriggerServerEvent('farming:fireEmployee', employee.identifier, playerJob)
            ESX.ShowNotification("👋 " .. employee.name .. " a été licencié.")
        end
    end, function(data, menu)
        menu.close()
    end)
end


function OpenGradeSelection(employee)
    ESX.TriggerServerCallback('farming:getJobGrades', function(grades)
        local elements = {}

        for _, grade in ipairs(grades) do
            table.insert(elements, {
                label = grade.label,
                value = grade.grade
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'grade_select', {
            title = "Changer grade - " .. employee.name,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            TriggerServerEvent('farming:setEmployeeGrade', employee.identifier, playerJob, data.current.value)
            ESX.ShowNotification("✅ Grade modifié pour " .. employee.name)
        end, function(data, menu)
            menu.close()
        end)
    end, playerJob)
end


function KeyboardInput(textEntry, exampleText, maxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', exampleText, '', '', '', maxStringLength)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end
