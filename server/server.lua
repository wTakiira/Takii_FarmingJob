ESX = exports["es_extended"]:getSharedObject()

MySQL.ready(function()
    -- Ajoute le job si inexistant
    MySQL.Async.execute([[
        INSERT INTO jobs (name, label) 
        SELECT * FROM (SELECT @jobName AS name, @jobLabel AS label) AS tmp
        WHERE NOT EXISTS (
            SELECT name FROM jobs WHERE name = @jobName
        ) LIMIT 1;
    ]], {
        ['@jobName'] = jobName,
        ['@jobLabel'] = jobLabel
    })

    -- Ajoute le grade de base si inexistant
    MySQL.Async.execute([[
        INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) 
        SELECT * FROM (
            SELECT @jobName AS job_name, 0 AS grade, 'recrue' AS name, 'Recrue' AS label, 50 AS salary, '{}' AS skin_male, '{}' AS skin_female
        ) AS tmp 
        WHERE NOT EXISTS (
            SELECT job_name FROM job_grades WHERE job_name = @jobName
        );
    ]], {
        ['@jobName'] = jobName
    })

    print("^2[INFO] Le job " .. jobName .. " a été ajouté à la base de données !^0")
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
    end
end)

RegisterServerEvent('farming:traitement')
AddEventHandler('farming:traitement', function(job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getInventoryItem(Config.Jobs[job].itemRecolte).count > 0 then
        xPlayer.removeInventoryItem(Config.Jobs[job].itemRecolte, 1)
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


