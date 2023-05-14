local QBCore = exports['qb-core']:GetCoreObject()

local function hasJobPerms(playerJob)
    for i=1, #Config.jobs do
        if playerJob.name == Config.jobs[i].job and playerJob.grade.level >= Config.jobs[i].minGrade then
            return true
        end
    end
    return false
end

local function hasExpired(startTime)
    local timeElapsed = os.time() - startTime
    if timeElapsed > Config.expireTime * 60 * 60 then
        return true
    end
end

QBCore.Functions.CreateUseableItem("prescriptionpad", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if not Player.Functions.GetItemBySlot(item.slot) then return end
    
    if not hasJobPerms(Player.PlayerData.job) then
        TriggerClientEvent("QBCore:Notify", source, "You don't have the right job or high enough grade to do this", "error")
        return
    end
    local playerName = Config.namePrefix .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    TriggerClientEvent("glow_prescription_cl:usePad", source, playerName, Player.PlayerData.charinfo.phone, os.time())
end)

QBCore.Functions.CreateUseableItem("prescription", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if not Player.Functions.GetItemBySlot(item.slot) then return end
    if not item.info.docInfo or not item.info.formInfo or not item.info.unixTime then return end
    
    if hasExpired(item.info.unixTime) then
        TriggerClientEvent("QBCore:Notify", source, "This prescription is expired and has been removed", "error")
        Player.Functions.RemoveItem("prescription", 1, item.slot)
        return
    end

    for i=1, #Config.medList do
        if item.info.formInfo.medication == Config.medList[i].item then
            item.info.formInfo.medication = Config.medList[i].label
            break
        end
    end

    TriggerClientEvent("glow_prescription_cl:usePrescription", source, item.info)
end)

for i=1, #Config.medList do
    QBCore.Functions.CreateUseableItem(Config.medList[i].item, function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player.Functions.GetItemBySlot(item.slot) or not item.info.dosage then return end
        local playerInventory = QBCore.Functions.GetPlayer(source).PlayerData.items

        if item.info.dosage <= 1 then
            Player.Functions.RemoveItem(Config.medList[i].item, 1, item.slot)
            TriggerClientEvent("QBCore:Notify", source, "You take the last dose of your medication", "success")
        else
            local newDosage = item.info.dosage - 1
            playerInventory[item.slot].info.dosage = newDosage 
            Player.Functions.SetInventory(playerInventory)
            TriggerClientEvent("QBCore:Notify", source, "You take your medication and have " .. newDosage .. " dose(s) left", "success")
        end
    end)
end

QBCore.Functions.CreateCallback("glow_prescription_sv:createPrescription", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or not Player.Functions.GetItemByName("prescriptionpad") then return end

    if not hasJobPerms(Player.PlayerData.job) then
        TriggerClientEvent("QBCore:Notify", source, "You don't have the right job to do this", "error")
        cb(false)
        return
    end

    for k, v in pairs(data) do
        if v == "" and k ~= "notes" then
            TriggerClientEvent("QBCore:Notify", source, "Missing form data", "error")
            cb(false)
            return
        end
    end

    if tonumber(data.dosage) < 1 or tonumber(data.dosage) > Config.maxDosage then
        TriggerClientEvent("QBCore:Notify", source, "Invalid dosage. Number must be greater than zero and less than "..Config.maxDosage, "error")
        cb(false)
        return
    end

    data.dosage = math.floor(tonumber(data.dosage))

    if Player.Functions.RemoveItem("prescriptionpad", 1) then
        local docName = Config.namePrefix .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        local info = {
            docInfo = {
                name = docName,
                phone = Player.PlayerData.charinfo.phone,
            },
            formInfo = data,
            unixTime = os.time()
        }
    
        Player.Functions.AddItem("prescription", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["prescription"], "add")
        cb(true)
    end
end)


RegisterNetEvent("glow_prescription_sv:getMeds", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local prescriptions = Player.Functions.GetItemsByName("prescription")
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
   
    if #prescriptions == 0 then 
        TriggerClientEvent("QBCore:Notify", src, "You don't have any prescriptions", "error")
        return
    end

    local invalidPrescript = false
    local expiredPrescript = false

    for i=1, #prescriptions do
        local metadata = prescriptions[i].info.formInfo

        if hasExpired(prescriptions[i].info.unixTime) then
            Player.Functions.RemoveItem("prescription", 1, prescriptions[i].slot)
            expiredPrescript = true
        elseif metadata.patient ~= playerName then
            invalidPrescript = true
        else
            if Player.Functions.RemoveItem("prescription", 1, prescriptions[i].slot) then
                if Player.Functions.AddItem(metadata.medication, 1, nil, {dosage = tonumber(metadata.dosage)}) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[metadata.medication], "add")
                end
            end 
        end
    end

    if invalidPrescript then
        TriggerClientEvent("QBCore:Notify", src, "One or more of these prescriptions don't have your name on it", "error")
    end

    if expiredPrescript then
        TriggerClientEvent("QBCore:Notify", src, "Removed one or more expired prescriptions", "error")
    end
end)