-- Jeu : Unlock a Rod 🎣
-- Créé par : Alexoris12

local RodModule = {}

RodModule.Rods = {
    { Name = "Wooden Rod", Power = 1, Price = 0, LevelRequired = 1 },
    { Name = "Iron Rod", Power = 2, Price = 250, LevelRequired = 3 },
    { Name = "Golden Rod", Power = 3, Price = 1000, LevelRequired = 6 },
    { Name = "Diamond Rod", Power = 5, Price = 2500, LevelRequired = 10 },
    { Name = "Ruby Rod", Power = 7, Price = 5000, LevelRequired = 30 },
    { Name = "Emeraude Rod", Power = 10, Price = 7500, LevelRequired = 50 },
    { Name = "Obsidian Rod", Power =25, Price = 10000, LevelRequired = 100 }
    
}

function RodModule.GetAvailableRods(level)
    local rods = {}
    for _, rod in ipairs(RodModule.Rods) do
        if level >= rod.LevelRequired then
            table.insert(rods, rod)
        end
    end
    return rods
end

return RodModule

local FishModule = {}

FishModule.Fishes = {
    { Name = "Small Fish", Value = 10, Difficulty = 1 },
    { Name = "Rare Carp", Value = 50, Difficulty = 2 },
    { Name = "Golden Tuna", Value = 150, Difficulty = 3 },
    { Name = "Legendary Shark", Value = 500, Difficulty = 5 },
    { Name = "Mythical Kraken", Value = 1000, Difficulty = 10 },
    { Name = "Secret Leviathan", Value = 5000, Difficulty = 25 },
    { Name = "Inexistant Fisch", Value = 1000000000, Difficulty = 1000 }
}

function FishModule.CatchFish(rodPower)
    local chance = math.random(1, rodPower * 2)
    local caught
    for _, fish in ipairs(FishModule.Fishes) do
        if chance >= fish.Difficulty then
            caught = fish
        end
    end
    return caught or FishModule.Fishes[1]
end

return FishModule

local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("UnlockARod_PlayerData_V1")

local PlayerData = {}
local data = {}
local default = { Coins = 0, Level = 1, FishCaught = 0, Inventory = {} }

function PlayerData.Load(player)
	local success, saved = pcall(function()
		return PlayerDataStore:GetAsync("Player_" .. player.UserId)
	end)
	
	if success and saved then
		data[player.UserId] = saved
	else
		data[player.UserId] = table.clone(default)
	end
end

function PlayerData.Save(player)
	if not data[player.UserId] then return end
	pcall(function()
		PlayerDataStore:SetAsync("Player_" .. player.UserId, data[player.UserId])
	end)
end

function PlayerData.AddCoins(player, amount)
	data[player.UserId].Coins += amount
end

function PlayerData.AddFish(player, fish)
	local d = data[player.UserId]
	d.FishCaught += 1
	table.insert(d.Inventory, fish)
	if d.FishCaught % 5 == 0 then
		d.Level += 1
	end
end

function PlayerData.ClearFish(player)
	data[player.UserId].Inventory = {}
end

function PlayerData.Get(player)
	return data[player.UserId]
end

game.Players.PlayerRemoving:Connect(PlayerData.Save)
game:BindToClose(function()
	for _, plr in ipairs(game.Players:GetPlayers()) do
		PlayerData.Save(plr)
	end
end)

return PlayerData

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RodModule = require(ReplicatedStorage.RodModule)
local FishModule = require(ReplicatedStorage.FishModule)
local PlayerData = require(ReplicatedStorage.PlayerDataModule)

local catchEvent = ReplicatedStorage.RemoteEvents:WaitForChild("CatchFishEvent")
local sellEvent = ReplicatedStorage.RemoteEvents:WaitForChild("SellFishEvent")

game.Players.PlayerAdded:Connect(function(player)
	PlayerData.Load(player)
end)

catchEvent.OnServerEvent:Connect(function(player)
	local pdata = PlayerData.Get(player)
	local rods = RodModule.GetAvailableRods(pdata.Level)
	local rod = rods[#rods]
	local fish = FishModule.CatchFish(rod.Power)

	PlayerData.AddFish(player, fish)
	PlayerData.AddCoins(player, fish.Value)

	print(player.Name .. " a pêché un " .. fish.Name .. " ! +" .. fish.Value .. " coins")
end)

sellEvent.OnServerEvent:Connect(function(player)
	local pdata = PlayerData.Get(player)
	local total = 0
	for _, fish in ipairs(pdata.Inventory) do
		total += fish.Value
	end
	PlayerData.AddCoins(player, total)
	PlayerData.ClearFish(player)
	print(player.Name .. " a vendu ses poissons pour " .. total .. " coins")
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local catchEvent = ReplicatedStorage.RemoteEvents:WaitForChild("CatchFishEvent")
local sellEvent = ReplicatedStorage.RemoteEvents:WaitForChild("SellFishEvent")

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		catchEvent:FireServer()
	end

	if input.KeyCode == Enum.KeyCode.F then
		sellEvent:FireServer()
	end
end)

print("🎮 Contrôles : [E] pour pêcher, [F] pour vendre")

