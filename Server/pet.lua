-- ServerScript: Pet-System mit DataStore
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local playerDataStore = DataStoreService:GetDataStore("PlayerPetData_v2")

-- Remotes erstellen
local petFolder = ReplicatedStorage:FindFirstChild("PetRemotes") or Instance.new("Folder")
petFolder.Name = "PetRemotes"
petFolder.Parent = ReplicatedStorage

local buyPet = petFolder:FindFirstChild("BuyPet") or Instance.new("RemoteEvent")
buyPet.Name = "BuyPet"
buyPet.Parent = petFolder

local equipPet = petFolder:FindFirstChild("EquipPet") or Instance.new("RemoteEvent")
equipPet.Name = "EquipPet"
equipPet.Parent = petFolder

local unequipPet = petFolder:FindFirstChild("UnequipPet") or Instance.new("RemoteEvent")
unequipPet.Name = "UnequipPet"
unequipPet.Parent = petFolder

local getPetData = petFolder:FindFirstChild("GetPetData") or Instance.new("RemoteFunction")
getPetData.Name = "GetPetData"
getPetData.Parent = petFolder

local openShop = petFolder:FindFirstChild("OpenShop") or Instance.new("RemoteEvent")
openShop.Name = "OpenShop"
openShop.Parent = petFolder

local renamePet = petFolder:FindFirstChild("RenamePet") or Instance.new("RemoteEvent")
renamePet.Name = "RenamePet"
renamePet.Parent = petFolder

local getPetName = petFolder:FindFirstChild("GetPetName") or Instance.new("RemoteFunction")
getPetName.Name = "GetPetName"
getPetName.Parent = petFolder

-- Pet-Definitionen
local PET_DATA = {
	{
		id = "dog",
		name = "Hund",
		price = 100,
		modelName = "DogModel",
		color = Color3.fromRGB(139, 90, 43),
		bonus = 1.2,
		rarity = "Common"
	},
	{
		id = "cat",
		name = "Katze",
		price = 150,
		modelName = "CatModel",
		color = Color3.fromRGB(255, 200, 150),
		bonus = 1.25,
		rarity = "Common"
	},
	{
		id = "rabbit",
		name = "Hase",
		price = 250,
		modelName = "RabbitModel",
		color = Color3.fromRGB(255, 255, 255),
		bonus = 1.3,
		rarity = "Uncommon"
	},
	{
		id = "fox",
		name = "Fuchs",
		price = 500,
		modelName = "FoxModel",
		color = Color3.fromRGB(255, 100, 0),
		bonus = 1.5,
		rarity = "Rare"
	},
	{
		id = "panda",
		name = "Panda",
		price = 1000,
		modelName = "PandaModel",
		color = Color3.fromRGB(50, 50, 50),
		bonus = 1.75,
		rarity = "Epic"
	},
	{
		id = "dragon",
		name = "Drache",
		price = 5000,
		modelName = "DragonModel",
		color = Color3.fromRGB(150, 0, 200),
		bonus = 2.5,
		rarity = "Legendary"
	}
}

-- Spielerdaten
local playerData = {}

-- Daten laden
local function loadData(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		return data
	else
		return {
			coins = 100,
			ownedPets = {},
			equippedPet = nil,
			petNames = {}
		}
	end
end

-- Daten speichern
local function saveData(player)
	local data = playerData[player.UserId]
	if not data then return end

	local saveData = {
		coins = data.coins.Value,
		ownedPets = data.ownedPets,
		equippedPet = data.equippedPet,
		petNames = data.petNames
	}

	pcall(function()
		playerDataStore:SetAsync(player.UserId, saveData)
	end)
end

-- Leaderstats erstellen
local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats

	-- Daten laden
	local data = loadData(player)
	coins.Value = data.coins

	-- Pet-Daten initialisieren
	playerData[player.UserId] = {
		coins = coins,
		ownedPets = data.ownedPets,
		equippedPet = data.equippedPet,
		petNames = data.petNames or {},
		joinTime = tick()
	}

	print(player.Name .. " hat " .. coins.Value .. " Coins geladen")
end

-- Pet kaufen
buyPet.OnServerEvent:Connect(function(player, petId)
	local data = playerData[player.UserId]
	if not data then return end

	local petInfo = nil
	for _, pet in ipairs(PET_DATA) do
		if pet.id == petId then
			petInfo = pet
			break
		end
	end

	if not petInfo then return end

	if data.coins.Value < petInfo.price then
		return
	end

	if table.find(data.ownedPets, petId) then
		return
	end

	data.coins.Value -= petInfo.price
	table.insert(data.ownedPets, petId)
	saveData(player)

	print(player.Name .. " hat " .. petInfo.name .. " gekauft!")
end)

-- Pet ausrüsten
equipPet.OnServerEvent:Connect(function(player, petId)
	local data = playerData[player.UserId]
	if not data then return end

	if not table.find(data.ownedPets, petId) then
		return
	end

	if data.equippedPet then
		local oldPet = player.Character and player.Character:FindFirstChild("EquippedPet")
		if oldPet then
			oldPet:Destroy()
		end
	end

	data.equippedPet = petId
	saveData(player)

	spawnPet(player, petId)
	print(player.Name .. " hat Pet ausgerüstet: " .. petId)
end)

-- Pet ablegen
unequipPet.OnServerEvent:Connect(function(player)
	local data = playerData[player.UserId]
	if not data then return end

	data.equippedPet = nil
	saveData(player)

	local pet = player.Character and player.Character:FindFirstChild("EquippedPet")
	if pet then
		pet:Destroy()
	end

	print(player.Name .. " hat Pet abgelegt")
end)

-- Pet-Daten abrufen
getPetData.OnServerInvoke = function(player)
	local data = playerData[player.UserId]
	if not data then return {}, nil, 0 end

	return data.ownedPets, data.equippedPet, data.coins.Value
end

-- Pet umbenennen
renamePet.OnServerEvent:Connect(function(player, petId, newName)
	local data = playerData[player.UserId]
	if not data then return end

	-- Prüfen ob Spieler Pet besitzt
	if not table.find(data.ownedPets, petId) then
		return
	end

	-- Prüfen ob genug Coins
	if data.coins.Value < 50 then
		return
	end

	-- Name filtern (max 20 Zeichen, keine Sonderzeichen)
	newName = string.sub(newName, 1, 20)
	newName = string.gsub(newName, "[^%w%s äöüÄÖÜß]", "")

	if newName == "" or newName == " " then
		newName = "Namenlos"
	end

	-- Coins abziehen und Namen speichern
	data.coins.Value -= 50
	data.petNames[petId] = newName
	saveData(player)

	-- Wenn Pet gerade ausgerüstet ist, neu spawnen
	if data.equippedPet == petId then
		local oldPet = player.Character and player.Character:FindFirstChild("EquippedPet")
		if oldPet then
			oldPet:Destroy()
		end
		wait(0.1)
		spawnPet(player, petId)
	end

	print(player.Name .. " hat Pet umbenannt zu: " .. newName)
end)

-- Pet-Namen abrufen
getPetName.OnServerInvoke = function(player, petId)
	local data = playerData[player.UserId]
	if not data then return nil end

	return data.petNames[petId]
end

-- Pet spawnen (MIT NAMEN)
function spawnPet(player, petId)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Pet-Info finden
	local petInfo = nil
	for _, pet in ipairs(PET_DATA) do
		if pet.id == petId then
			petInfo = pet
			break
		end
	end

	if not petInfo then return end

	-- Model aus ServerStorage laden
	local petTemplate = game:GetService("ServerStorage"):FindFirstChild(petInfo.modelName)
	local pet

	if petTemplate then
		-- Richtiges Model verwenden
		pet = petTemplate:Clone()
		pet.Name = "EquippedPet"

		-- Alle Parts im Model vorbereiten
		for _, part in ipairs(pet:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Massless = true
			end
		end

		-- PrimaryPart finden oder setzen
		if not pet.PrimaryPart then
			local largestPart = nil
			local largestSize = 0
			for _, part in ipairs(pet:GetDescendants()) do
				if part:IsA("BasePart") then
					local size = part.Size.Magnitude
					if size > largestSize then
						largestSize = size
						largestPart = part
					end
				end
			end
			if largestPart then
				pet.PrimaryPart = largestPart
			end
		end

		if not pet.PrimaryPart then
			warn("Kein PrimaryPart für Pet gefunden!")
			pet:Destroy()
			return
		end

		-- Weld erstellen für alle Parts
		local primaryPart = pet.PrimaryPart
		for _, part in ipairs(pet:GetDescendants()) do
			if part:IsA("BasePart") and part ~= primaryPart then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = primaryPart
				weld.Part1 = part
				weld.Parent = primaryPart
			end
		end

		-- BodyPosition für Folgen
		local bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(50000, 50000, 50000)
		bodyPos.P = 10000
		bodyPos.D = 500
		bodyPos.Parent = primaryPart

		-- BodyGyro für Rotation
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(5000, 5000, 5000)
		bodyGyro.P = 3000
		bodyGyro.Parent = primaryPart

		-- Pet ins Character einfügen
		pet:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(3, 0, 0))
		pet.Parent = char

		-- NAMEN HINZUFÜGEN
		local data = playerData[player.UserId]
		local petName = (data and data.petNames[petId]) or petInfo.name

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PetNameTag"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = primaryPart

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = petName
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 20
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.Parent = billboard

		-- Pet folgt Spieler
		local offset = Vector3.new(-3, 0, -2)
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not pet.Parent or not char.Parent or not hrp.Parent or not primaryPart.Parent then
				if pet.Parent then pet:Destroy() end
				connection:Disconnect()
				return
			end

			local targetPos = hrp.Position + (hrp.CFrame.RightVector * offset.X) + Vector3.new(0, offset.Y, 0) + (hrp.CFrame.LookVector * offset.Z)
			bodyPos.Position = targetPos

			-- Pet schaut zum Spieler
			bodyGyro.CFrame = CFrame.new(primaryPart.Position, hrp.Position)

			-- Hüpf-Animation
			local time = tick()
			local bounce = math.sin(time * 4) * 0.3
			bodyPos.Position = targetPos + Vector3.new(0, bounce, 0)
		end)
	else
		-- Fallback: Einfacher Ball
		warn("Pet Model nicht gefunden: " .. petInfo.modelName .. " - Verwende Fallback")

		pet = Instance.new("Model")
		pet.Name = "EquippedPet"

		local ball = Instance.new("Part")
		ball.Name = "PrimaryPart"
		ball.Size = Vector3.new(2, 2, 2)
		ball.Shape = Enum.PartType.Ball
		ball.Material = Enum.Material.SmoothPlastic
		ball.Color = petInfo.color
		ball.CanCollide = false
		ball.Massless = true
		ball.CFrame = hrp.CFrame + Vector3.new(3, 0, 0)
		ball.Parent = pet

		pet.PrimaryPart = ball

		local face = Instance.new("Decal")
		face.Texture = "rbxasset://textures/face.png"
		face.Parent = ball

		local bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(50000, 50000, 50000)
		bodyPos.P = 10000
		bodyPos.D = 500
		bodyPos.Parent = ball

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(5000, 5000, 5000)
		bodyGyro.P = 3000
		bodyGyro.Parent = ball

		pet.Parent = char

		-- NAMEN HINZUFÜGEN
		local data = playerData[player.UserId]
		local petName = (data and data.petNames[petId]) or petInfo.name

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PetNameTag"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = ball

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = petName
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 20
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.Parent = billboard

		local offset = Vector3.new(-3, 1, -2)
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not pet.Parent or not char.Parent or not hrp.Parent then
				if pet.Parent then pet:Destroy() end
				connection:Disconnect()
				return
			end

			local targetPos = hrp.Position + offset
			bodyPos.Position = targetPos
			bodyGyro.CFrame = CFrame.new(ball.Position, hrp.Position)

			local time = tick()
			local bounce = math.sin(time * 4) * 0.5
			bodyPos.Position = targetPos + Vector3.new(0, bounce, 0)
		end)
	end

	print(player.Name .. " hat Pet gespawnt: " .. petInfo.name)
end

-- Spieler beitritt
Players.PlayerAdded:Connect(function(player)
	setupLeaderstats(player)

	player.CharacterAdded:Connect(function(char)
		wait(1)
		local data = playerData[player.UserId]
		if data and data.equippedPet then
			spawnPet(player, data.equippedPet)
		end
	end)
end)

-- Spieler verlässt
Players.PlayerRemoving:Connect(function(player)
	saveData(player)
	playerData[player.UserId] = nil
end)

-- Auto-Save alle 5 Minuten
task.spawn(function()
	while true do
		task.wait(300)
		for _, player in ipairs(Players:GetPlayers()) do
			saveData(player)
		end
		print("Alle Spielerdaten gespeichert!")
	end
end)

-- COINS PRO MINUTE SYSTEM
task.spawn(function()
	while true do
		task.wait(60) -- Jede Minute
		for _, player in ipairs(Players:GetPlayers()) do
			local data = playerData[player.UserId]
			if data then
				local bonus = 10
				if data.equippedPet then
					for _, pet in ipairs(PET_DATA) do
						if pet.id == data.equippedPet then
							bonus = pet.bonus
							break
						end
					end
				end

				local coinsEarned = math.floor(1 * bonus)
				data.coins.Value += coinsEarned
				print(player.Name .. " hat " .. coinsEarned .. " Coins erhalten (pro Minute)")
			end
		end
	end
end)

-- SHOP CLICKDETECTOR ERSTELLEN
local function createShopClickDetector()
	local shopPart = workspace:FindFirstChild("ShopPart")

	if not shopPart then
		shopPart = Instance.new("Part")
		shopPart.Name = "ShopPart"
		shopPart.Size = Vector3.new(4, 6, 4)
		shopPart.Position = Vector3.new(86.5, 15.631, 182.718)
		shopPart.Anchored = true
		shopPart.CanCollide = false
		shopPart.Material = Enum.Material.Neon
		shopPart.Color = Color3.fromRGB(100, 200, 255)
		shopPart.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = shopPart

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(100, 200, 255)
		light.Brightness = 2
		light.Range = 20
		light.Parent = shopPart

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = shopPart

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "🐾 PET SHOP"
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextSize = 24
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Parent = billboard

		local subText = Instance.new("TextLabel")
		subText.Size = UDim2.new(1, 0, 0.5, 0)
		subText.Position = UDim2.new(0, 0, 0.6, 0)
		subText.BackgroundTransparency = 1
		subText.Text = "Klicke zum Öffnen"
		subText.TextColor3 = Color3.fromRGB(200, 200, 200)
		subText.TextSize = 14
		subText.Font = Enum.Font.Gotham
		subText.TextStrokeTransparency = 0.5
		subText.Parent = billboard
	end

	local clickDetector = shopPart:FindFirstChild("ClickDetector")
	if not clickDetector then
		clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 15
		clickDetector.Parent = shopPart
	end

	clickDetector.MouseClick:Connect(function(player)
		openShop:FireClient(player)
		print(player.Name .. " hat den Shop geöffnet (Click)")
	end)

	-- Rotation Animation
	task.spawn(function()
		while shopPart.Parent do
			for i = 0, 360, 2 do
				if not shopPart.Parent then break end
				shopPart.Orientation = Vector3.new(0, i, 0)
				task.wait(0.03)
			end
		end
	end)

	print("Shop ClickDetector erstellt bei: 86.5, 15.631, 182.718")
end

createShopClickDetector()

print("Pet-System mit DataStore geladen!")
print("- Coins werden automatisch jede Minute vergeben")
print("- Daten werden gespeichert")
print("- Shop bei Koordinaten: 86.5, 15.631, 182.718")
print("- Pet-Namen können für 50 Coins geändert werden")