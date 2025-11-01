

--!strict
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Owner-UserId eintragen
local OWNER_ID = 0000000000 -- <--- DEINE USER ID

-- DataStores
local adminDataStore = DataStoreService:GetDataStore("AdminData_v2")
local banDataStore = DataStoreService:GetDataStore("BanData_v2")
local timebanDataStore = DataStoreService:GetDataStore("TimebanData_v2")

-- In-Memory
local admins = {}
local bannedPlayers = {}
local timebannedPlayers = {} -- [uidStr] = expireEpoch

-- Remotes
local adminRemotes = ReplicatedStorage:FindFirstChild("AdminRemotes") or Instance.new("Folder")
adminRemotes.Name = "AdminRemotes"
adminRemotes.Parent = ReplicatedStorage

local function ensureRemote(name, className)
	local r = adminRemotes:FindFirstChild(name)
	if not r then
		r = Instance.new(className)
		r.Name = name
		r.Parent = adminRemotes
	end
	return r
end

local toggleFlight    = ensureRemote("ToggleFlight", "RemoteEvent")
local timeoutPlayer   = ensureRemote("TimeoutPlayer", "RemoteEvent")
local untimeoutPlayer = ensureRemote("UnTimeoutPlayer", "RemoteEvent")
local banPlayer       = ensureRemote("BanPlayer", "RemoteEvent")
local unbanPlayer     = ensureRemote("UnbanPlayer", "RemoteEvent")
local setAdmin        = ensureRemote("SetAdmin", "RemoteEvent")
local giveWeapon      = ensureRemote("GiveWeapon", "RemoteEvent")
local giveCoins       = ensureRemote("GiveCoins", "RemoteEvent") -- NEU
local checkAdmin      = ensureRemote("CheckAdmin", "RemoteFunction")

-- Utils
local function findPlayerByPrefix(name:string)
	name = name:lower()
	for _,p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1, #name) == name then
			return p
		end
	end
	return nil
end

local function isAdmin(plr:Player)
	return plr.UserId == OWNER_ID or admins[tostring(plr.UserId)] == true
end

local function addAdminLabel(player:Player)
	local function attach()
		local char = player.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		if head:FindFirstChild("AdminLabel") then return end
		local gui = Instance.new("BillboardGui")
		gui.Name = "AdminLabel"
		gui.Size = UDim2.new(0,100,0,36)
		gui.StudsOffset = Vector3.new(0,3,0)
		gui.AlwaysOnTop = true
		gui.Parent = head
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1,0,1,0)
		tl.BackgroundColor3 = Color3.fromRGB(200,0,0)
		tl.BackgroundTransparency = 0.35
		tl.Text = "ADMIN"
		tl.TextColor3 = Color3.fromRGB(255,255,255)
		tl.TextSize = 18
		tl.Font = Enum.Font.GothamBold
		tl.Parent = gui
		local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = tl
	end
	if player.Character then attach() end
	player.CharacterAdded:Connect(function() task.wait(0.5); attach() end)
end

local function removeAdminLabel(player:Player)
	if player.Character then
		local head = player.Character:FindFirstChild("Head")
		if head then
			local label = head:FindFirstChild("AdminLabel")
			if label then label:Destroy() end
		end
	end
end

-- DataStore Load/Save
local function loadAdmin()
	local ok, data = pcall(function() return adminDataStore:GetAsync("AdminList") end)
	admins = (ok and data) or {}
end
local function saveAdmin()
	pcall(function() adminDataStore:SetAsync("AdminList", admins) end)
end
local function loadBans()
	local ok, data = pcall(function() return banDataStore:GetAsync("BannedList") end)
	bannedPlayers = (ok and data) or {}
end
local function saveBans()
	pcall(function() banDataStore:SetAsync("BannedList", bannedPlayers) end)
end
local function loadTimebans()
	local ok, data = pcall(function() return timebanDataStore:GetAsync("TimebannedList") end)
	timebannedPlayers = (ok and data) or {}
end
local function saveTimebans()
	pcall(function() timebanDataStore:SetAsync("TimebannedList", timebannedPlayers) end)
end

-- Init
loadAdmin(); loadBans(); loadTimebans()
admins[tostring(OWNER_ID)] = true; saveAdmin()

-- CheckAdmin
checkAdmin.OnServerInvoke = function(player) return isAdmin(player) end

-- Join handling
local function onJoin(player:Player)
	local uid = tostring(player.UserId)
	-- Permaban
	if bannedPlayers[uid] then
		player:Kick("Du wurdest permanent gebannt!")
		return
	end
	-- Timeban
	local exp = timebannedPlayers[uid]
	if typeof(exp) == "number" then
		local now = os.time()
		if now < exp then
			player:Kick(("Du bist getimebannt (%d s verbleibend)."):format(exp - now))
			return
		else
			timebannedPlayers[uid] = nil
			saveTimebans()
		end
	end
	-- Label
	if isAdmin(player) then addAdminLabel(player) end
end

Players.PlayerAdded:Connect(onJoin)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(onJoin, p) end

-- Events
toggleFlight.OnServerEvent:Connect(function(player) if not isAdmin(player) then return end end)

timeoutPlayer.OnServerEvent:Connect(function(player, targetName:string, duration:number)
	if not isAdmin(player) then return end
	if type(duration) ~= "number" or duration <= 0 then return end
	local target = findPlayerByPrefix(targetName)
	if target and target.UserId ~= OWNER_ID then
		local uid = tostring(target.UserId)
		timebannedPlayers[uid] = os.time() + duration
		saveTimebans()
		target:Kick(("Du wurdest für %d Sekunden getimebannt."):format(duration))
	end
end)

untimeoutPlayer.OnServerEvent:Connect(function(player, targetName:string)
	if not isAdmin(player) then return end
	local target = findPlayerByPrefix(targetName)
	if target and target.UserId ~= OWNER_ID then
		local uid = tostring(target.UserId)
		if timebannedPlayers[uid] then
			timebannedPlayers[uid] = nil
			saveTimebans()
		end
	end
end)

banPlayer.OnServerEvent:Connect(function(player, targetName:string)
	if not isAdmin(player) then return end
	local target = findPlayerByPrefix(targetName)
	if target and target.UserId ~= OWNER_ID then
		bannedPlayers[tostring(target.UserId)] = true
		saveBans()
		target:Kick("Du wurdest permanent gebannt!")
	end
end)

unbanPlayer.OnServerEvent:Connect(function(player, targetName:string)
	if not isAdmin(player) then return end
	local target = findPlayerByPrefix(targetName)
	if target then
		local uid = tostring(target.UserId)
		if bannedPlayers[uid] then
			bannedPlayers[uid] = nil
			saveBans()
		end
	end
end)

setAdmin.OnServerEvent:Connect(function(player, targetName:string, status:boolean)
	if player.UserId ~= OWNER_ID then return end
	local target = findPlayerByPrefix(targetName)
	if target then
		local uid = tostring(target.UserId)
		if status then
			admins[uid] = true
			addAdminLabel(target)
		else
			admins[uid] = nil
			removeAdminLabel(target)
		end
		saveAdmin()
		target:Kick("Dein Admin-Status wurde geändert. Bitte rejoine!")
	end
end)

-- Waffe geben
giveWeapon.OnServerEvent:Connect(function(player, weaponName:string?)
	if not isAdmin(player) then return end
	weaponName = weaponName or "Pistol"
	local bag = ServerStorage:FindFirstChild("AdminGuns")
	if not bag then return end
	local tool = bag:FindFirstChild(weaponName)
	if not tool or not tool:IsA("Tool") then return end

	local char = player.Character or player.CharacterAdded:Wait()
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return end

	local clone = tool:Clone()
	clone.Parent = backpack
end)

-- NEU: Coins geben
giveCoins.OnServerEvent:Connect(function(player, targetName:string)
	if not isAdmin(player) then return end

	local target = findPlayerByPrefix(targetName)
	if not target then 
		warn("Spieler nicht gefunden: " .. targetName)
		return 
	end

	-- Coins zum Leaderstats hinzufügen
	local leaderstats = target:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins and coins:IsA("IntValue") then
			coins.Value = coins.Value + 100
			print(player.Name .. " hat " .. target.Name .. " 100 Coins gegeben. Neuer Stand: " .. coins.Value)
		else
			warn("Coins IntValue nicht gefunden bei " .. target.Name)
		end
	else
		warn("Leaderstats nicht gefunden bei " .. target.Name)
	end
end)

print("[Admin UI kompakt + Untermenüs + GiveWeapon + GiveCoins] geladen.")