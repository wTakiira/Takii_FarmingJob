ESX = exports["es_extended"]:getSharedObject()

MySQL.ready(function()
    for jobName, jobData in pairs(Config.Jobs) do
        if jobData and jobData.jobLabel and jobData.grades then
            for _, gradeData in ipairs(jobData.grades) do
                MySQL.insert([[
                    INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) 
                    SELECT ?, ?, ?, ?, ?, ?, ? WHERE NOT EXISTS (
                        SELECT name FROM job_grades WHERE job_name = ? AND grade = ?
                    )
                ]], {jobName, gradeData.grade, gradeData.name, gradeData.label, gradeData.salary, gradeData.skin_male, gradeData.skin_female, jobName, gradeData.grade}, function(rowsChanged)
                    if rowsChanged > 0 then
                        print("^2Job grade ajouté : " .. jobName .. " (" .. gradeData.label .. ")^7")
                    else
                        print("^3Le job grade " .. jobName .. " (" .. gradeData.label .. ") existe déjà dans la base de données.^7")
                    end
                end)
                Wait(200)
            end
        else
            print("^1Erreur : jobData invalide pour " .. tostring(jobName) .. "^7")
        end
    end
end)

MySQL.ready(function()
    for jobName, jobData in pairs(Config.Jobs) do
        if jobData and jobData.jobLabel then
            MySQL.insert([[
                INSERT INTO jobs (name, label) 
                SELECT ?, ? WHERE NOT EXISTS (
                    SELECT name FROM jobs WHERE name = ?
                )
            ]], {jobName, jobData.jobLabel, jobName}, function(rowsChanged)
                if rowsChanged > 0 then
                    print("^2Job ajouté : " .. jobName .. " (" .. jobData.jobLabel .. ")^7")
                else
                    print("^3Le job " .. jobName .. " existe déjà dans la base de données.^7")
                end
            end)
        else
            print("^1Erreur : jobData invalide pour " .. tostring(jobName) .. "^7")
        end
        Wait(200)
    end
end)


RegisterNetEvent('farming:requestBlips')
AddEventHandler('farming:requestBlips', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local jobData = Config.Jobs[xPlayer.job.name]
        if jobData then
            TriggerClientEvent('farming:createJobBlips', src, jobData.Recolte or {}, jobData.Traitement or {}, jobData.Vente or {})
        end
    end
end)



RegisterNetEvent('farming:sendBlips')
AddEventHandler('farming:sendBlips', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local jobData = Config.Jobs[xPlayer.job.name]
        if jobData then
            TriggerClientEvent('farming:createJobBlips', src, jobData.Recolte or {}, jobData.Traitement or {}, jobData.Vente or {})
            print("Oui mais non pour le joueur " .. xPlayer.identifier)
        else
            print("Données du job non trouvées pour le joueur " .. xPlayer.identifier)
        end
    end
end)

RegisterServerEvent('farming:assignJob')
AddEventHandler('farming:assignJob', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local job = xPlayer.getJob().name        TriggerClientEvent('farming:receiveJob', src, job)
        print("[DEBUG] Job envoyé au client : " .. job)
    else
        print("[ERROR] Impossible de récupérer le joueur ESX pour l'ID " .. src)
    end
end)

RegisterServerEvent('farming:recolte')
AddEventHandler('farming:recolte', function(job)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and Config.Jobs[job] then
        local itemRecolte = Config.Jobs[job].itemRecolte
        if itemRecolte then
            xPlayer.addInventoryItem(itemRecolte, 1)
            TriggerClientEvent('farming:updateRecoltePoint', src)
        else
            print("Aucun item de récolte trouvé pour le job " .. job)
        end
    end
end)

RegisterServerEvent('farming:traitement')
AddEventHandler('farming:traitement', function(job)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and Config.Jobs[job] then
        local item = Config.Jobs[job].itemRecolte
        if xPlayer.getInventoryItem(item).count >= 5 then
            xPlayer.removeInventoryItem(item, 5)
            xPlayer.addInventoryItem(Config.Jobs[job].itemTraitement, 1)
        else
            TriggerClientEvent('esx:showNotification', src, _U('not_enough'))
        end
    end
end)

RegisterServerEvent('farming:vente')
AddEventHandler('farming:vente', function(job)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and Config.Jobs[job] then
        local item = Config.Jobs[job].itemTraitement
        if xPlayer.getInventoryItem(item).count > 0 then
            xPlayer.removeInventoryItem(item, 1)
            xPlayer.addMoney(Config.Jobs[job].prixVente)
        else
            TriggerClientEvent('esx:showNotification', src, _U('not_enough'))
        end
    end
end)

RegisterServerEvent('farming:recruter')
AddEventHandler('farming:recruter', function(jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = GetClosestPlayer(source)

    if target then
        local targetPlayer = ESX.GetPlayerFromId(target)
        targetPlayer.setJob(jobName, 0)
        xPlayer.showNotification("✅ Vous avez recruté ~g~" .. targetPlayer.getName())
        targetPlayer.showNotification("📋 Vous avez été recruté par ~b~" .. xPlayer.getName())
    else
        xPlayer.showNotification("❌ Aucun joueur à proximité.")
    end
end)

RegisterServerEvent('farming:virer')
AddEventHandler('farming:virer', function(jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = GetClosestPlayer(source)

    if target then
        local targetPlayer = ESX.GetPlayerFromId(target)
        targetPlayer.setJob("unemployed", 0)
        xPlayer.showNotification("🗑️ Vous avez viré ~r~" .. targetPlayer.getName())
        targetPlayer.showNotification("❌ Vous avez été viré par ~b~" .. xPlayer.getName())
    else
        xPlayer.showNotification("❌ Aucun joueur à proximité.")
    end
end)

ESX.RegisterServerCallback('farming:getSocietyMoney', function(source, cb)
    local society = "society_" .. ESX.GetPlayerFromId(source).job.name
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        cb(account.money)
    end)
end)

RegisterServerEvent('farming:depositSociety')
AddEventHandler('farming:depositSociety', function(amount, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    amount = tonumber(amount)
    local society = "society_" .. jobName

    if amount and amount > 0 and xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
            account.addMoney(amount)
        end)
        xPlayer.showNotification("✅ Vous avez déposé ~g~" .. amount .. "$~s~ dans la société.")
    else
        xPlayer.showNotification("❌ Montant invalide ou fonds insuffisants.")
    end
end)

RegisterServerEvent('farming:withdrawSociety')
AddEventHandler('farming:withdrawSociety', function(amount, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    amount = tonumber(amount)
    local society = "society_" .. jobName

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if amount and amount > 0 and account.money >= amount then
            account.removeMoney(amount)
            xPlayer.addMoney(amount)
            xPlayer.showNotification("💸 Vous avez retiré ~g~" .. amount .. "$~s~ de la société.")
        else
            xPlayer.showNotification("❌ Montant invalide ou fonds insuffisants.")
        end
    end)
end)

ESX.RegisterServerCallback('farming:getEmployees', function(source, cb, jobName)
    local xPlayers = ESX.GetExtendedPlayers('job', jobName)
    local employees = {}

    for _, xPlayer in pairs(xPlayers) do
        table.insert(employees, {
            name = xPlayer.getName(),
            identifier = xPlayer.getIdentifier(),
            grade = xPlayer.job.grade,
            gradeLabel = xPlayer.job.label
        })
    end

    cb(employees)
end)


ESX.RegisterServerCallback('farming:getJobGrades', function(source, cb, jobName)
    local job = ESX.GetJob(jobName)
    local grades = {}

    for k, v in pairs(job.grades) do
        if v then
            table.insert(grades, {
                grade = v.grade,
                label = v.label
            })
        end
    end

    table.sort(grades, function(a, b) return a.grade < b.grade end)
    cb(grades)
end)

RegisterNetEvent('farming:fireEmployee', function(identifier, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= jobName or xPlayer.job.grade_name ~= 'boss' then return end

    MySQL.update('UPDATE users SET job = @job, job_grade = 0 WHERE identifier = @identifier', {
        ['@job'] = 'unemployed',
        ['@identifier'] = identifier
    }, function(rowsChanged)
        -- Optionnel : kick ou notifie le joueur viré
        local target = ESX.GetPlayerFromIdentifier(identifier)
        if target then
            target.setJob('unemployed', 0)
            target.showNotification("❌ Vous avez été licencié.")
        end
    end)
end)

RegisterNetEvent('farming:setEmployeeGrade', function(identifier, jobName, grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= jobName or xPlayer.job.grade_name ~= 'boss' then return end

    MySQL.update('UPDATE users SET job = @job, job_grade = @grade WHERE identifier = @identifier', {
        ['@job'] = jobName,
        ['@grade'] = grade,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        local target = ESX.GetPlayerFromIdentifier(identifier)
        if target then
            target.setJob(jobName, grade)
            target.showNotification("📈 Vous avez été promu au grade : " .. grade)
        end
    end)
end)


function GetClosestPlayer(src)
    local players = ESX.GetPlayers()
    local closestPlayer, closestDistance
    local srcPed = GetPlayerPed(src)
    local srcCoords = GetEntityCoords(srcPed)

    for _, playerId in ipairs(players) do
        if playerId ~= src then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local dist = #(srcCoords - targetCoords)

            if not closestDistance or dist < closestDistance then
                closestPlayer = playerId
                closestDistance = dist
            end
        end
    end

    if closestDistance and closestDistance < 3.0 then
        return closestPlayer
    else
        return nil
    end
end
