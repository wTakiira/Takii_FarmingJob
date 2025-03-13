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
        local job = xPlayer.getJob().name
        TriggerClientEvent('farming:receiveJob', src, job)
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
            TriggerClientEvent('esx:showNotification', src, "Pas assez d'ingrédients!")
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
            TriggerClientEvent('esx:showNotification', src, "Rien à vendre!")
        end
    end
end)
