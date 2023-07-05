local QBCore = exports['qb-core']:GetCoreObject()
local CanHack = false
local CurrentCops = 0

Citizen.CreateThread(function()
	exports["qb-target"]:AddCircleZone("yachtrobbery", vector3(-2069.08, -1023.72, 2.9109), 0.5, {
        name="yachtrobbery",
        debugPoly=false,
        useZ=true
    }, {
		options = {
			{
				canInteract = function()
					return not CanHack
				end,
				event = "ace-yacht:client:usedcrypter",
				icon = "fa fa-circle",
				label = "Input"
			},
		},
		distance = 2.0
    })
	exports["qb-target"]:AddBoxZone("yachtdevices", vector3(-2055.65, -1027.31, 3.1382), 0.6, 3.5, {
		name="yachtdevices",
		debugPoly=false,
		maxZ=3.63,
		minZ=2.53,
		heading = 249.2
	}, {
		options = {
			{
				canInteract = function()
					return CanHack
				end,
				action = function()
					local success = exports['hackingdevice']:StartMinigame(math.random(10, 15), 'alphanumeric')
					if success then
						QBCore.Functions.Notify('Good job , Start searching yacht', 'success')
						TriggerServerEvent('ace-yacht:server:enablePrizes')
					else
						QBCore.Functions.Notify('Failed', 'error', 3500)
					end
				end,
				icon = "fa fa-circle",
				label = "Hack devices"
			},
		},
		distance = 2.0
	})
	exports["qb-target"]:AddBoxZone("yachtsafecodetarget", vector3(-2069.57, -1020.11, 6.4113), 1.5, 1.0, {
		name="yachtsafecodetarget",
		debugPoly=false,
		heading=72.0,
		maxZ=6.6,
		minZ=6.3
	}, {
		options = {
			{
				type = "client",
				event = "ace-yacht:client:OpenSafe",
				icon = "fa fa-circle",
				label = "Enter Code"
			},
		},
		distance = 2.0
	})
end)

local function AddTarget(Table)
	if #Table < 1 then return end
	for i= 1, 8, 1 do
		if Table[i] then
			exports["qb-target"]:AddCircleZone("yachttarget"..i, Table[i].coords, 1.0, {
				name="yachttarget"..i,
				debugPoly=false,
				useZ=true
			}, {
				options = {
					{
						type = "server",
						event = "ace-yacht:server:getPrize",
						parameters = i,
						icon = "fa fa-circle",
						label = "Take paper"
					},
				},
				distance = 2.0
			})
		end
	end
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('ace-yacht:server:syncMe', function(state, data)
		CanHack = state
		AddTarget(data)
	end)
end)

RegisterNetEvent('police:SetCopCount', function (amount)
    CurrentCops = amount
end)

RegisterNetEvent('ace-yacht:client:enableHack', function()
	CanHack = true
end)

RegisterNetEvent('ace-yacht:client:usedcrypter', function()
	local Player = QBCore.Functions.GetPlayer(source)
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
			QBCore.Functions.TriggerCallback('qb-scoreboard:server:gettimeoutstatus', function(cooldown)
				if not cooldown and CurrentCops >= 10 then
						exports['ps-dispatch']:DrugBoatRobbery()
						TriggerEvent("qb-log:server:CreateLog", "yatch", "yatchrobbery", "white", "Yatch zade **"..GetPlayerName(source).."** Citizen ID : **"..Player.PlayerData.citizenid.. "**", false)
						TriggerServerEvent("QBCore:Server:RemoveItem", "decrypter", 1)
						TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["decrypter"], "remove")
						TriggerServerEvent('ace-yacht:server:enableHack')
						QBCore.Functions.Notify('Decrypting started, wait until it finish')
						TriggerServerEvent("qb-scoreboard:server:startglobaltimeout")
				else
					QBCore.Functions.Notify('City is not enough Safe', 'error')
				end
			end)
		else
			QBCore.Functions.Notify('Missing something...', 'error')
		end
	end, 'decrypter')
end)

RegisterNetEvent('ace-yacht:client:enablePrizes', function(data)
	CanHack = false
	AddTarget(data)
end)

RegisterNetEvent('ace-yacht:client:removePrize', function(i)
	exports["qb-target"]:RemoveZone("yachttarget"..i)
end)

RegisterNetEvent('ace-yacht:client:OpenSafe', function()
	QBCore.Functions.TriggerCallback('ace-yacht:server:GetCode', function(code)
		local input = exports['qb-input']:ShowInput({
			header =  "Enter Code",
			submitText = "Submit",
			inputs = {
				{
					text = "Code",
					name = "code",
					type = "number",
					isRequired = true
				}
			}
		})
		if input and code and tonumber(input.code) == tonumber(code) then
			TriggerServerEvent('ace-yacht:server:lootSafe', code)
		else
			QBCore.Functions.Notify('No', 'error')
		end
	end)
end)

RegisterNetEvent('ace-yacht:client:ShowCode', function(code)
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "open",
		tip = code
	})
end)

RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
end)

RegisterNetEvent('qb:client:uidebug',function()
	SendNUIMessage({
		type = "close",
	})
	SetNuiFocus(false, false)
end)