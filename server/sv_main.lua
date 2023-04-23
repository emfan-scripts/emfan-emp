local emfan = exports['emfan-framework']:getFrameworkSettings()

emfan.createUseableItem(Config.itemName, function(source, item)
    TriggerClientEvent('emfan-emp:client:fireEMP', source)
end)

RegisterServerEvent('emfan-emp:server:PlayWithinDistance', function(soundFile, soundCoords, soundVolume)
    TriggerClientEvent('emfan-emp:client:PlayWithinDistance', -1, soundFile, soundCoords, soundVolume)
end)

RegisterServerEvent('emfan-emp:server:empSendToPlayers', function(xPlayerCoords)
    TriggerClientEvent('emfan-emp:client:empSendToPlayers', -1, xPlayerCoords)
end)