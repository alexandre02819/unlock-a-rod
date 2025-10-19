-- Jeu : Unlock a Rod 🎣
-- Créé par : Alexandre

-- Création de la canne à pêche légendaire
local rod = Instance.new("Tool")
rod.Name = "FishingRod"
rod.RequiresHandle = true

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 4, 1)
handle.BrickColor = BrickColor.new("Bright green")
handle.Parent = rod

rod.Parent = game.ServerStorage

-- Base magique où la canne est enfermée
local base = Instance.new("Part")
base.Anchored = true
base.Size = Vector3.new(10, 1, 10)
base.Position = Vector3.new(0, 0.5, 0)
base.BrickColor = BrickColor.new("Bright orange")
base.Name = "RodBase"
base.Parent = workspace

-- Apparence visuelle de la canne coincée dans la base
local rodModel = handle:Clone()
rodModel.Name = "RodInStone"
rodModel.Anchored = true
rodModel.Position = Vector3.new(0, 3, 0)
rodModel.BrickColor = BrickColor.new("Bright green")
rodModel.Parent = workspace

-- Quand le joueur touche la zone, il "débloque" la canne
base.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player then
		if not player.Backpack:FindFirstChild("FishingRod") then
			local newRod = rod:Clone()
			newRod.Parent = player.Backpack
			rodModel:Destroy()
			print(player.Name .. " a débloqué la canne légendaire 🎣 !")
		end
	end
end)