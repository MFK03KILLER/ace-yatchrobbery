local QBCore = exports['qb-core']:GetCoreObject()
local Code = nil
local Table = {}
local CanHack = false

local function GenCodes()
	local nums = {1, 2, 3, 4, 5, 6}
	local lecs = {'A', 'B', 'C', 'D', 'E', 'F'}
	local j
	local k
    for i = #nums, 2, -1 do
        j = math.random( i )
        nums[i], nums[j] = nums[j], nums[i]
    end
    for i = #lecs, 2, -1 do
        k = math.random( i )
        lecs[i], lecs[k] = lecs[k], lecs[i]
    end
	local code = ""
	for num, v in pairs(nums) do
		code = code..nums[num]
	end
	Code = tonumber(code)
	local codes = {}
	for i = 1, 6, 1 do
		codes[i] = nums[i].."-"..lecs[i]
	end
	local b
	local Prizes = Config.Prizes
	for i = #Prizes, 2, -1 do
        b = math.random( i )
        Prizes[i], Prizes[b] = Prizes[b], Prizes[i]
    end
	local FinalTable = {}
	for i = 1, 8 ,1 do
		FinalTable[i] = Prizes[i]
	end
	for i = 1, 6 ,1 do
		FinalTable[i].code = codes[i]
	end
	FinalTable[7].code = lecs[1]..lecs[2]..lecs[3]
	FinalTable[8].code = lecs[4]..lecs[5]..lecs[6]
	return FinalTable
end

RegisterServerEvent('ace-yacht:server:enableHack', function()
	local src = source
	SetTimeout(2 * 60 * 1000, function()
		CanHack = true
		TriggerClientEvent('QBCore:Notify', src, 'Decrypting compeleted, you can start hacking devices', 'success')
		TriggerClientEvent('ace-yacht:client:enableHack', -1)
	end)
end)

RegisterServerEvent('ace-yacht:server:enablePrizes', function()
	if CanHack then
		CanHack = false
		Table = GenCodes()
		TriggerClientEvent('ace-yacht:client:enablePrizes', -1, Table)
	end
end)

RegisterServerEvent('ace-yacht:server:getPrize', function(data)
	local src = source
	local i = data.parameters
	if Table[i] then
		local Player = QBCore.Functions.GetPlayer(src)
		Player.Functions.AddItem("yachtnote", 1, false, {tip = Table[i].code})
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["yachtnote"], "add")
		TriggerClientEvent('ace-yacht:client:removePrize', -1, i)
		Table[i] = nil
	end
end)

RegisterNetEvent('ace-yacht:server:lootSafe', function(code)
	local src = source
	if Code and Code == code then
		Code = nil
		local Player = QBCore.Functions.GetPlayer(src)
		local amount = math.random(60, 80)
		Player.Functions.AddItem("goldbar", amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["goldbar"], "add", amount)
		-- Player.Functions.AddItem("red_phonedongle", 1)
		-- TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["red_phonedongle"], "add", 1)
	end
end)

QBCore.Functions.CreateUseableItem('yachtnote' , function(source, item)
	TriggerClientEvent('ace-yacht:client:ShowCode', source, item.info.tip)
end)

QBCore.Functions.CreateCallback('ace-yacht:server:GetCode', function(source, cb)
	if Code then
		cb(Code)
	end
end)

QBCore.Functions.CreateCallback('ace-yacht:server:syncMe', function(source, cb)
	cb(CanHack, Table)
end)