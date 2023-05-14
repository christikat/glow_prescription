<h1 align="center">Prescription Medication Script for FiveM QBCore</h1>

## Description
A simple prescription resource for QBCore, created using React. It allows players to fill out prescriptions, and give them to other players. With the prescription, players can go to the pharmacy and interact with the spawned in ped to retrieve their medications.

<div align="center">
    <img height="500" src="https://i.imgur.com/rcVi1WM.png" alt="Prescription UI" />
    <img height="500" src="https://i.imgur.com/3FjSZvZ.png" alt="Ped Interaction" />
</div>

## Key Features
- Prescription form with drop down menu of available medications found in the config
- Prescriptions expire based on time set in config
- Pharmacy will only give medications if the name on prescription matches player name
- Ability to prescribe specific dosages of medication
- Each use of a medication will reduce items metadata by one dose and remove item when no doses remain
- Using a the prescription will display a read only version of the UI

## Installation
- Download latest release at https://github.com/christikat/glow_prescription/releases
- Open the ZIP and move `glow_prescription` into your resource folder and `ensure glow_prescription` in server.cfg
- Add `prescriptionpad`, `prescription`, and all medications in your config to `qbcore/shared/items.lua`
```lua
    ['prescriptionpad'] 			 = {['name'] = 'prescriptionpad', 				['label'] = 'Prescription Pad', 		['weight'] = 1000, 		['type'] = 'item', 		['image'] = 'prescriptionpad.png', 		['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Used to prescribe drugs'},
	['prescription'] 				 = {['name'] = 'prescription', 					['label'] = 'Prescription', 			['weight'] = 500, 		['type'] = 'item', 		['image'] = 'prescription.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A prescription for legal drugs'},
	['amoxicillin'] 				 = {['name'] = 'amoxicillin', 					['label'] = 'Amoxicillin', 				['weight'] = 500, 		['type'] = 'item', 		['image'] = 'amoxicillin.png', 			['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A prescribed antibiotic'},
```
- Items passed in Config.medList will be usable by default with code below, found in server.lua. This can be edited to add custom effects for specific medications

```lua
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

        -- Edit here to add custom med effect
        -- if Config.medList[i].item == "specialMed" then
        --     TriggerClientEvent("customEventName", source)
        -- end
    end)
end
```