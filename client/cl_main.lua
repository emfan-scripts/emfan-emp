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
end

RegisterNetEvent('emfan-emp:client:fireEMP', function()
    empActive = true
    local xPlayer = PlayerPedId()
    local xPlayerCoords = GetEntityCoords(xPlayer)
    local allVehicles = GetGamePool('CVehicle')
    
    local anim = Config.empAnim
    TaskStartScenarioAtPosition(PlayerPedId(), anim, GetEntityCoords(PlayerPedId()), 5000, false, true)
    Wait(5000)
    ClearPedTasks(PlayerPedId())

    for _, vehicle in pairs(allVehicles) do
        local xDist = #(xPlayerCoords - GetEntityCoords(vehicle))
        if xDist <= Config.empRange then
            affectedVehicles[vehicle] = vehicle
            SetVehicleLights(vehicle, 1)
            SetVehicleEngineOn(vehicle, false, true, true)
            BringVehicleToHalt(vehicle, 10.0, Config.empTimer * 1000, false)
        end
    end
    Wait(2000)
    freezeVehicles()
    Wait(5000)
    local allPeds = GetGamePool('CPed')
    local xPlayerCoords = GetEntityCoords(PlayerPedId())
    for _, ped in pairs(allPeds) do
        if not IsPedAPlayer(ped) then
            local closeDoor = math.random(1, 100)
            if closeDoor >= 50 and closeDoor < 95 then
                closeDoor = 0
            elseif closeDoor < 50 then
                closeDoor = 256
            else
                closeDoor = 4160
            end
            Wait(math.random(500, 2000))
            local xVehicle = GetVehiclePedIsIn(ped)
            TaskLeaveAnyVehicle(ped, xVehicle, closeDoor)
            SetVehicleDoorsLocked(xVehicle, 2)
            
            TaskGoStraightToCoord(ped, xPlayerCoords.x-math.random(5, 30), xPlayerCoords.y+(math.random(5, 30)), xPlayerCoords.z, 0.1, -1)
            Wait(1000)
            TaskWanderStandard(ped, 10.0, 10)
        end
    end
    Wait(Config.empTimer * 1000 - 7000)
    for _, vehicle in pairs(affectedVehicles) do
        SetVehicleLights(vehicle, 0)
        SetVehicleEngineOn(vehicle, true, false, false)
        FreezeEntityPosition(vehicle, false)
    end
    affectedVehicles = {}
end)

