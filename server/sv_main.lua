local emfan = exports['emfan-framework']:getFrameworkSettings()

emfan.createUseableItem(Config.itemName, function(source, item)
    TriggerClientEvent('emfan-emp:client:fireEMP', source)
end)