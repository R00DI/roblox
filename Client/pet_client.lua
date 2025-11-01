-- LocalScript: Pet-Shop UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local petRemotes = ReplicatedStorage:WaitForChild("PetRemotes")
local buyPet = petRemotes:WaitForChild("BuyPet")
local equipPet = petRemotes:WaitForChild("EquipPet")
local unequipPet = petRemotes:WaitForChild("UnequipPet")
local getPetData = petRemotes:WaitForChild("GetPetData")
local openShop = petRemotes:WaitForChild("OpenShop")
local renamePet = petRemotes:WaitForChild("RenamePet")
local getPetName = petRemotes:WaitForChild("GetPetName")

-- Pet-Definitionen
local PET_DATA = {
	{
		id = "dog",
		name = "Hund",
		price = 100,
		color = Color3.fromRGB(139, 90, 43),
		bonus = 1.2,
		rarity = "Common"
	},
	{
		id = "cat",
		name = "Katze",
		price = 150,
		color = Color3.fromRGB(255, 200, 150),
		bonus = 1.25,
		rarity = "Common"
	},
	{
		id = "rabbit",
		name = "Hase",
		price = 250,
		color = Color3.fromRGB(255, 255, 255),
		bonus = 1.3,
		rarity = "Uncommon"
	},
	{
		id = "fox",
		name = "Fuchs",
		price = 500,
		color = Color3.fromRGB(255, 100, 0),
		bonus = 1.5,
		rarity = "Rare"
	},
	{
		id = "panda",
		name = "Panda",
		price = 1000,
		color = Color3.fromRGB(50, 50, 50),
		bonus = 1.75,
		rarity = "Epic"
	},
	{
		id = "dragon",
		name = "Drache",
		price = 5000,
		color = Color3.fromRGB(150, 0, 200),
		bonus = 2.5,
		rarity = "Legendary"
	}
}

local RARITY_COLORS = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(100, 255, 100),
	Rare = Color3.fromRGB(100, 150, 255),
	Epic = Color3.fromRGB(200, 100, 255),
	Legendary = Color3.fromRGB(255, 200, 0)
}

local COLORS = {
	bg = Color3.fromRGB(22, 22, 22),
	card = Color3.fromRGB(30, 30, 30),
	titleBg = Color3.fromRGB(28, 28, 28),
	text = Color3.fromRGB(240, 240, 240),
	muted = Color3.fromRGB(180, 180, 180),
	btn = Color3.fromRGB(58, 58, 58),
	btnHover = Color3.fromRGB(70, 70, 70),
	success = Color3.fromRGB(60, 160, 60),
	warn = Color3.fromRGB(200, 160, 60),
	danger = Color3.fromRGB(200, 70, 70),
	accent = Color3.fromRGB(80, 120, 200),
}

local function cornerify(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
end

local function createPetShop()
	local gui = Instance.new("ScreenGui")
	gui.Name = "PetShop"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 700, 0, 500)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.BackgroundColor3 = COLORS.card
	main.Parent = gui
	cornerify(main, 14)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 56)
	titleBar.BackgroundColor3 = COLORS.titleBg
	titleBar.Parent = main
	cornerify(titleBar, 14)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🐾 PET SHOP"
	title.TextColor3 = COLORS.text
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Size = UDim2.new(0, 100, 0, 36)
	coinsLabel.Position = UDim2.new(1, -156, 0.5, -18)
	coinsLabel.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
	coinsLabel.Text = "💰 0"
	coinsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	coinsLabel.TextSize = 18
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.Parent = titleBar
	cornerify(coinsLabel, 10)

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 36, 0, 36)
	close.Position = UDim2.new(1, -44, 0.5, -18)
	close.BackgroundColor3 = COLORS.danger
	close.Text = "X"
	close.TextColor3 = COLORS.text
	close.TextSize = 18
	close.Font = Enum.Font.GothamBold
	close.Parent = titleBar
	cornerify(close, 10)
	close.MouseButton1Click:Connect(function()
		gui.Enabled = false
	end)

	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -32, 0, 40)
	tabBar.Position = UDim2.new(0, 16, 0, 64)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = main

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.Padding = UDim.new(0, 8)
	tabList.Parent = tabBar

	local function makeTab(text)
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 150, 1, 0)
		tab.BackgroundColor3 = COLORS.btn
		tab.Text = text
		tab.TextColor3 = COLORS.text
		tab.TextSize = 16
		tab.Font = Enum.Font.GothamBold
		tab.Parent = tabBar
		cornerify(tab, 10)
		return tab
	end

	local shopTab = makeTab("🛒 Shop")
	local inventoryTab = makeTab("🎒 Inventar")

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -32, 1, -120)
	contentFrame.Position = UDim2.new(0, 16, 0, 112)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = main

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = COLORS.muted
	scrollFrame.Parent = contentFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 200, 0, 280)
	gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame

	local function createPetCard(petInfo, owned, equipped)
		local card = Instance.new("Frame")
		card.BackgroundColor3 = COLORS.bg
		card.Parent = scrollFrame
		cornerify(card, 12)

		local rarityBanner = Instance.new("Frame")
		rarityBanner.Size = UDim2.new(1, 0, 0, 24)
		rarityBanner.BackgroundColor3 = RARITY_COLORS[petInfo.rarity]
		rarityBanner.Parent = card
		cornerify(rarityBanner, 12)

		local rarityLabel = Instance.new("TextLabel")
		rarityLabel.Size = UDim2.new(1, 0, 1, 0)
		rarityLabel.BackgroundTransparency = 1
		rarityLabel.Text = petInfo.rarity
		rarityLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		rarityLabel.TextSize = 14
		rarityLabel.Font = Enum.Font.GothamBold
		rarityLabel.Parent = rarityBanner

		local preview = Instance.new("Frame")
		preview.Size = UDim2.new(1, -16, 0, 80)
		preview.Position = UDim2.new(0, 8, 0, 32)
		preview.BackgroundColor3 = petInfo.color
		preview.Parent = card
		cornerify(preview, 40)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -16, 0, 24)
		nameLabel.Position = UDim2.new(0, 8, 0, 120)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = petInfo.name
		nameLabel.TextColor3 = COLORS.text
		nameLabel.TextSize = 18
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = card

		local bonusLabel = Instance.new("TextLabel")
		bonusLabel.Size = UDim2.new(1, -16, 0, 20)
		bonusLabel.Position = UDim2.new(0, 8, 0, 145)
		bonusLabel.BackgroundTransparency = 1
		bonusLabel.Text = string.format("+%.0f%% Coins/Min", (petInfo.bonus - 1) * 100)
		bonusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		bonusLabel.TextSize = 14
		bonusLabel.Font = Enum.Font.Gotham
		bonusLabel.Parent = card

		-- Rename Button (nur wenn owned)
		if owned then
			local renameBtn = Instance.new("TextButton")
			renameBtn.Size = UDim2.new(1, -16, 0, 32)
			renameBtn.Position = UDim2.new(0, 8, 0, 172)
			renameBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
			renameBtn.Text = "✏️ Umbenennen (50💰)"
			renameBtn.TextColor3 = COLORS.text
			renameBtn.TextSize = 13
			renameBtn.Font = Enum.Font.GothamBold
			renameBtn.Parent = card
			cornerify(renameBtn, 8)

			renameBtn.MouseButton1Click:Connect(function()
				-- Name-Input Dialog
				local currentName = getPetName:InvokeServer(petInfo.id) or petInfo.name

				local inputFrame = Instance.new("Frame")
				inputFrame.Size = UDim2.new(0, 320, 0, 160)
				inputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				inputFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
				inputFrame.BackgroundColor3 = COLORS.card
				inputFrame.ZIndex = 100
				inputFrame.Parent = gui
				cornerify(inputFrame, 12)

				local shadow = Instance.new("Frame")
				shadow.Size = UDim2.new(1, 0, 1, 0)
				shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				shadow.BackgroundTransparency = 0.5
				shadow.ZIndex = 99
				shadow.Parent = gui

				local inputTitle = Instance.new("TextLabel")
				inputTitle.Size = UDim2.new(1, -20, 0, 30)
				inputTitle.Position = UDim2.new(0, 10, 0, 10)
				inputTitle.BackgroundTransparency = 1
				inputTitle.Text = "Pet umbenennen (50 Coins)"
				inputTitle.TextColor3 = COLORS.text
				inputTitle.TextSize = 16
				inputTitle.Font = Enum.Font.GothamBold
				inputTitle.Parent = inputFrame

				local textBox = Instance.new("TextBox")
				textBox.Size = UDim2.new(1, -40, 0, 40)
				textBox.Position = UDim2.new(0, 20, 0, 50)
				textBox.BackgroundColor3 = COLORS.bg
				textBox.Text = currentName
				textBox.PlaceholderText = "Neuer Name..."
				textBox.TextColor3 = COLORS.text
				textBox.TextSize = 18
				textBox.Font = Enum.Font.Gotham
				textBox.ClearTextOnFocus = false
				textBox.Parent = inputFrame
				cornerify(textBox, 8)

				local confirmBtn = Instance.new("TextButton")
				confirmBtn.Size = UDim2.new(0.45, 0, 0, 35)
				confirmBtn.Position = UDim2.new(0.05, 0, 1, -45)
				confirmBtn.BackgroundColor3 = COLORS.success
				confirmBtn.Text = "✓ Bestätigen"
				confirmBtn.TextColor3 = COLORS.text
				confirmBtn.TextSize = 14
				confirmBtn.Font = Enum.Font.GothamBold
				confirmBtn.Parent = inputFrame
				cornerify(confirmBtn, 8)

				local cancelBtn = Instance.new("TextButton")
				cancelBtn.Size = UDim2.new(0.45, 0, 0, 35)
				cancelBtn.Position = UDim2.new(0.5, 0, 1, -45)
				cancelBtn.BackgroundColor3 = COLORS.danger
				cancelBtn.Text = "✗ Abbrechen"
				cancelBtn.TextColor3 = COLORS.text
				cancelBtn.TextSize = 14
				cancelBtn.Font = Enum.Font.GothamBold
				cancelBtn.Parent = inputFrame
				cornerify(cancelBtn, 8)

				confirmBtn.MouseButton1Click:Connect(function()
					local newName = textBox.Text
					if newName and newName ~= "" then
						renamePet:FireServer(petInfo.id, newName)
						wait(0.2)
						refreshUI()
					end
					inputFrame:Destroy()
					shadow:Destroy()
				end)

				cancelBtn.MouseButton1Click:Connect(function()
					inputFrame:Destroy()
					shadow:Destroy()
				end)
			end)
		end

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -16, 0, 40)
		btn.Position = UDim2.new(0, 8, 1, -48)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 16
		btn.TextColor3 = COLORS.text
		btn.Parent = card
		cornerify(btn, 10)

		if owned then
			if equipped then
				btn.Text = "✓ Ausgerüstet"
				btn.BackgroundColor3 = COLORS.success
				btn.MouseButton1Click:Connect(function()
					unequipPet:FireServer()
					wait(0.1)
					refreshUI()
				end)
			else
				btn.Text = "Ausrüsten"
				btn.BackgroundColor3 = COLORS.accent
				btn.MouseButton1Click:Connect(function()
					equipPet:FireServer(petInfo.id)
					wait(0.1)
					refreshUI()
				end)
			end
		else
			btn.Text = string.format("Kaufen: %d 💰", petInfo.price)
			btn.BackgroundColor3 = COLORS.warn
			btn.MouseButton1Click:Connect(function()
				buyPet:FireServer(petInfo.id)
				wait(0.1)
				refreshUI()
			end)
		end

		return card
	end

	function refreshUI()
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		local ownedPets, equippedPet, coins = getPetData:InvokeServer()
		coinsLabel.Text = "💰 " .. coins

		for _, petInfo in ipairs(PET_DATA) do
			local owned = table.find(ownedPets, petInfo.id) ~= nil
			local equipped = equippedPet == petInfo.id
			createPetCard(petInfo, owned, equipped)
		end
	end

	shopTab.MouseButton1Click:Connect(function()
		shopTab.BackgroundColor3 = COLORS.accent
		inventoryTab.BackgroundColor3 = COLORS.btn
		refreshUI()
	end)

	inventoryTab.MouseButton1Click:Connect(function()
		shopTab.BackgroundColor3 = COLORS.btn
		inventoryTab.BackgroundColor3 = COLORS.accent
		refreshUI()
	end)

	shopTab.BackgroundColor3 = COLORS.accent
	refreshUI()

	return gui
end

local petShopGui = createPetShop()

-- Shop öffnen
openShop.OnClientEvent:Connect(function()
	petShopGui.Enabled = true
	refreshUI()
end)

print("Pet-Shop UI geladen! Gehe zum Shop bei 86.5, 15.631, 182.718")