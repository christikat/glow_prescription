local QBCore = exports['qb-core']:GetCoreObject()
local pharmaPed = nil

local function loadModel(model)
    if HasModelLoaded(model) then return end
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(10)
	end
end

local function spawnPed()
    if pharmaPed then return end
    loadModel(Config.ped.model)
    pharmaPed = CreatePed(0, Config.ped.model, Config.ped.coords, false, false)
    
    SetEntityAsMissionEntity(pharmaPed)
    SetPedFleeAttributes(pharmaPed, 0, 0)
    SetBlockingOfNonTemporaryEvents(pharmaPed, true)
    SetEntityInvincible(pharmaPed, true)
    FreezeEntityPosition(pharmaPed, true)
    TaskStartScenarioInPlace(pharmaPed, Config.ped.idleAnim, 0, false)

    exports['qb-target']:AddTargetEntity(pharmaPed, {
        options = {
            {
                type = "server",
                event = "glow_prescription_sv:getMeds",
                icon = "fa-solid fa-prescription-bottle-medical",
                label = "Get Medication",
            },
        },
        distance = 2.0
    })   
    pedSpawned = true
end

local function despawnPed()
    if pharmaPed and DoesEntityExist(pharmaPed) then
        DeleteEntity(pharmaPed)
        pharmaPed = nil
    end
end

RegisterNUICallback("hideFrame", function(_, cb)
    SendNUIMessage({
        action = "setVisible",
        data = false,
    })
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("submit", function(data, cb)
    QBCore.Functions.TriggerCallback("glow_prescription_sv:createPrescription", function(success)
        if success then
            SetNuiFocus(false, false)
            SendNUIMessage({
                action = "setVisible",
                data = false,
            })
        end
    end, (data))
    cb({})
end)

RegisterNetEvent("glow_prescription_cl:usePad", function(name, phone, unixTime)
    SendNUIMessage({
        action = "setupForm",
        data = {
            docInfo = {
                name = name,
                phone = phone,
            }, 
            medInfo = Config.medList,
            unixTime = unixTime
        }
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent("glow_prescription_cl:usePrescription", function(metadata)
    SendNUIMessage({
        action = "setupReadOnly",
        data = metadata,
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnPed()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    despawnPed()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    spawnPed()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    despawnPed()
end)
