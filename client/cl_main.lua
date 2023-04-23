local emfan = exports['emfan-framework']:getFrameworkSettings()

local affectedVehicles = {}

local function loadAnimDict(anim) 
    while not HasAnimDictLoaded(anim) do
        Wait(100)
        RequestAnimDict(anim)
    end
end

local function freezeVehicles()
    for _, vehicle in pairs(affectedVehicles) do
        FreezeEntityPosition(vehicle, true)
    end
    return
end

CreateThread(function()
    while true do
        Wait(0)
        if empActive then
            for _, vehicle in pairs(affectedVehicles) do
                SetEntityLights(vehicle, 1)
                SetVehicleEngineOn(vehicle, false, true, true)
            end
        end
    end
end)

RegisterNetEvent('emfan-emp:client:empSendToPlayers', function(empCoords)
    local xPlayer = PlayerPedId()
    local xPlayerCoords = GetEntityCoords(xPlayer)
    if IsPedInAnyVehicle(xPlayer) then
        local xDist = #(empCoords - xPlayerCoords)
        local xVehicle = GetVehiclePedIsIn(xPlayer)
        if xDist <= Config.empRange then
            empActive = true
            affectedVehicles[#affectedVehicles+1] = xVehicle
            SetVehicleEngineOn(xVehicle, false, true, true)
            FreezeEntityPosition(xVehicle, true)
            Wait(Config.empTimer * 1000)
            FreezeEntityPosition(xVehicle, false)
            empActive = false
        end
    end
end)

RegisterNetEvent('emfan-emp:client:fireEMP', function()
    empActive = true
    local xPlayer = PlayerPedId()
    local xPlayerCoords = GetEntityCoords(xPlayer)
    local allVehicles = GetGamePool('CVehicle')
    local anim = Config.empAnim
    TaskStartScenarioAtPosition(PlayerPedId(), anim, GetEntityCoords(PlayerPedId()), 5000, false, true)
    Wait(5000)
    TriggerServerEvent("emfan-emp:server:PlayWithinDistance", 'emp', xPlayerCoords, 10.0)
    ClearPedTasks(PlayerPedId())
    for _, vehicle in pairs(allVehicles) do
        local xDist = #(xPlayerCoords - GetEntityCoords(vehicle))
        if xDist <= Config.empRange then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if IsPedAPlayer(driver) then
                if Config.affectPlayerVehicles then
                    TriggerServerEvent('emfan-emp:server:empSendToPlayers', xPlayerCoords)
                end
            end
            affectedVehicles[vehicle] = vehicle
            BringVehicleToHalt(vehicle, 10.0, Config.empTimer * 1000, false)
        end
    end
    Wait(2000)
    freezeVehicles()
    Wait(5000)
    local allPeds = GetGamePool('CPed')
    local xPlayerCoords = GetEntityCoords(PlayerPedId())
    for _, ped in pairs(allPeds) do
        if not IsPedAPlayer(ped) and IsPedInAnyVehicle(ped) then
            TriggerEvent('emfan-emp:client:PedLeaveVehicle', ped, xPlayerCoords)
        end
    end
    Wait(Config.empTimer * 1000)
    for _, vehicle in pairs(affectedVehicles) do
        SetVehicleLights(vehicle, 0)
        SetVehicleEngineOn(vehicle, true, false, false)
        FreezeEntityPosition(vehicle, false)
    end
    affectedVehicles = {}
    empActive = false
end)

RegisterNetEvent('emfan-emp:client:PedLeaveVehicle', function(ped, xPlayerCoords)
    local closeDoor = math.random(1, 100)
    if closeDoor >= 50 and closeDoor < 95 then
        closeDoor = 0
    elseif closeDoor < 50 then
        closeDoor = 256
    else
        closeDoor = 4160
    end
    Wait(math.random(2000, 10000))
    local xVehicle = GetVehiclePedIsIn(ped)
    TaskLeaveAnyVehicle(ped, xVehicle, closeDoor)
    SetVehicleDoorsLocked(xVehicle, 2)
    TaskGoStraightToCoord(ped, xPlayerCoords.x-math.random(5, 30), xPlayerCoords.y+(math.random(5, 30)), xPlayerCoords.z, 0.1, -1)
    Wait(1000)
    TaskWanderStandard(ped, 10.0, 10)
end)

RegisterNetEvent('emfan-emp:client:PlayWithinDistance', function(soundFile, soundCoords, soundVolume)
	if soundVolume == nil then soundVolume = 1.0 end
    local xPlayer = PlayerPedId()
	local xPlayerCoords = GetEntityCoords(xPlayer)
    local xDist  = #(xPlayerCoords-soundCoords)
	local soundVolume = 1.0 / xDist
    if xDist <= Config.empRange then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = soundFile,
            transactionVolume = soundVolume
        })
    end
end)