ESX = exports["es_extended"]:getSharedObject()

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
    end
end)
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
            end
        else
            print("^1Erreur : jobData invalide pour " .. tostring(jobName) .. "^7")
        end
    end
end)

RegisterNetEvent('farming:requestJob')
AddEventHandler('farming:requestJob', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        TriggerClientEvent('farming:receiveJob', src, xPlayer.getJob().name)
    end
end)


RegisterNetEvent('farming:sendBlips')
AddEventHandler('farming:sendBlips', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source) 
    if xPlayer then
        local jobData = Config.Jobs[xPlayer.job.name]
        if jobData then
            TriggerClientEvent('farming:createJobBlips', _source, jobData.Recolte, jobData.Traitement, jobData.Vente)
        end
    end
end)



RegisterServerEvent('farming:recolte')
AddEventHandler('farming:recolte', function(job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(Config.Jobs[job].itemRecolte, 1)
        TriggerClientEvent('farming:updateRecoltePoint', src)
    end
end)


RegisterServerEvent('farming:traitement')
AddEventHandler('farming:traitement', function(job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem(Config.Jobs[job].itemRecolte).count > 0 then
        xPlayer.removeInventoryItem(Config.Jobs[job].itemRecolte, 5)
        xPlayer.addInventoryItem(Config.Jobs[job].itemTraitement, 1)
    else
        TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
    end
end)

RegisterServerEvent('farming:vente')
AddEventHandler('farming:vente', function(job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem(Config.Jobs[job].itemTraitement).count > 0 then
        xPlayer.removeInventoryItem(Config.Jobs[job].itemTraitement, 1)
        xPlayer.addMoney(Config.Jobs[job].prixVente)
    else
        TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
    end
end)


