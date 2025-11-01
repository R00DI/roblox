-- LocalScript: Admin-Menü (mit Coins geben)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local adminRemotes = ReplicatedStorage:WaitForChild("AdminRemotes")
local toggleFlight    = adminRemotes:WaitForChild("ToggleFlight")
local timeoutPlayer   = adminRemotes:WaitForChild("TimeoutPlayer")
local untimeoutPlayer = adminRemotes:WaitForChild("UnTimeoutPlayer")
local banPlayer       = adminRemotes:WaitForChild("BanPlayer")
local unbanPlayer     = adminRemotes:WaitForChild("UnbanPlayer")
local setAdmin        = adminRemotes:WaitForChild("SetAdmin")
local giveWeapon      = adminRemotes:WaitForChild("GiveWeapon")
local giveCoins       = adminRemotes:WaitForChild("GiveCoins") -- NEU
local checkAdmin      = adminRemotes:WaitForChild("CheckAdmin")

local isAdmin = false
local menuOpen = false
local flightEnabled = false

-- Farben
local COLORS = {
	bg       = Color3.fromRGB(22,22,22),
	card     = Color3.fromRGB(30,30,30),
	titleBg  = Color3.fromRGB(28,28,28),
	text     = Color3.fromRGB(240,240,240),
	muted    = Color3.fromRGB(210,210,210),
	btn      = Color3.fromRGB(58,58,58),
	btnHover = Color3.fromRGB(70,70,70),
	success  = Color3.fromRGB(60,160,60),
	warn     = Color3.fromRGB(200,160,60),
	danger   = Color3.fromRGB(200,70,70),
	accent   = Color3.fromRGB(80,120,200),
	infoBg   = Color3.fromRGB(45,45,45),
	coins    = Color3.fromRGB(255,200,50), -- NEU
}

local function cornerify(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = inst
end

local function shadowify(parent)
	local s = Instance.new("ImageLabel")
	s.Name = "Shadow"
	s.BackgroundTransparency = 1
	s.Image = "rbxassetid://5028857084"
	s.ImageColor3 = Color3.new(0,0,0)
	s.ImageTransparency = 0.6
	s.ScaleType = Enum.ScaleType.Slice
	s.SliceCenter = Rect.new(24,24,276,276)
	s.Size = UDim2.new(1, 24, 1, 24)
	s.Position = UDim2.new(0, -12, 0, -12)
	s.ZIndex = (parent.ZIndex or 1)
	s.Parent = parent
end

local function makeBtn(parent, text, color)
	local b = Instance.new("TextButton")
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.Size = UDim2.new(1, 0, 0, 40)
	b.BackgroundColor3 = color or COLORS.btn
	b.Text = text
	b.TextColor3 = COLORS.text
	b.TextSize = 18
	b.Font = Enum.Font.GothamMedium
	b.AutoButtonColor = false
	b.Parent = parent
	b.ZIndex = parent.ZIndex or 1
	cornerify(b, 10)
	b.MouseEnter:Connect(function() b.BackgroundColor3 = COLORS.btnHover end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = color or COLORS.btn end)
	return b
end

local function makeLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 22)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = COLORS.muted
	l.TextSize = 16
	l.Font = Enum.Font.Gotham
	l.Parent = parent
	l.ZIndex = parent.ZIndex or 1
	return l
end

local function makeTextbox(parent, placeholder)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, 0, 0, 40)
	tb.BackgroundColor3 = COLORS.btn
	tb.PlaceholderText = placeholder
	tb.Text = ""
	tb.TextColor3 = COLORS.text
	tb.PlaceholderColor3 = COLORS.muted
	tb.TextSize = 16
	tb.Font = Enum.Font.Gotham
	tb.ClearTextOnFocus = false
	tb.Parent = parent
	tb.ZIndex = parent.ZIndex or 1
	cornerify(tb, 10)
	return tb
end

-- Modal
local function createModal(root, titleText)
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.BackgroundColor3 = Color3.new(0,0,0)
	overlay.BackgroundTransparency = 0.45
	overlay.Size = UDim2.new(1,0,1,0)
	overlay.Visible = false
	overlay.ZIndex = 20
	overlay.Parent = root

	local modal = Instance.new("Frame")
	modal.Name = "Modal"
	modal.Size = UDim2.new(0, 360, 0, 320)
	modal.AnchorPoint = Vector2.new(0.5,0.5)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	modal.BackgroundColor3 = COLORS.card
	modal.ZIndex = 21
	modal.Parent = overlay
	cornerify(modal, 14); shadowify(modal)

	local header = Instance.new("Frame")
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, -16, 0, 46)
	header.Position = UDim2.new(0, 8, 0, 8)
	header.ZIndex = 22
	header.Parent = modal

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -48, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = COLORS.text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 22
	title.Parent = header

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 36, 0, 36)
	close.Position = UDim2.new(1, -36, 0, 4)
	close.BackgroundColor3 = COLORS.danger
	close.Text = "X"
	close.TextColor3 = COLORS.text
	close.TextSize = 18
	close.Font = Enum.Font.GothamBold
	close.ZIndex = 22
	close.Parent = header
	cornerify(close, 10)
	close.MouseButton1Click:Connect(function() overlay.Visible = false end)

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "Body"
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.Position = UDim2.new(0, 16, 0, 60)
	scrollFrame.Size = UDim2.new(1, -32, 1, -76)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = COLORS.muted
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ZIndex = 22
	scrollFrame.Parent = modal

	local body = Instance.new("Frame")
	body.Name = "Content"
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, -6, 1, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.ZIndex = 22
	body.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.PaddingLeft = UDim.new(0, 0)
	padding.PaddingRight = UDim.new(0, 0)
	padding.Parent = body

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = body

	return overlay, modal, body
end

-- GUI
local function createAdminMenu()
	local gui = Instance.new("ScreenGui")
	gui.Name = "AdminMenu"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 5
	gui.Parent = playerGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 460, 0, 580)
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.BackgroundColor3 = COLORS.card
	main.ZIndex = 1
	main.Parent = gui
	cornerify(main, 14); shadowify(main)

	-- Responsive Größenanpassung
	local function resizeToViewport()
		local vps = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
		local w = math.min(520, math.max(420, vps.X*0.38))
		local h = math.min(680, math.max(520, vps.Y*0.82))
		main.Size = UDim2.new(0, math.floor(w), 0, math.floor(h))
	end
	resizeToViewport()
	game:GetService("RunService").RenderStepped:Connect(function() resizeToViewport() end)

	-- Titelzeile
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 56)
	titleBar.BackgroundColor3 = COLORS.titleBg
	titleBar.ZIndex = 2
	titleBar.Parent = main
	cornerify(titleBar, 14)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -56, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "ADMIN MENÜ"
	title.TextColor3 = COLORS.text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 3
	title.Parent = titleBar

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 36, 0, 36)
	close.Position = UDim2.new(1, -44, 0.5, -18)
	close.BackgroundColor3 = COLORS.danger
	close.Text = "X"
	close.TextColor3 = COLORS.text
	close.TextSize = 18
	close.Font = Enum.Font.GothamBold
	close.ZIndex = 3
	close.Parent = titleBar
	cornerify(close, 10)

	-- Status-Banner
	local statusBar = Instance.new("TextLabel")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(1, -32, 0, 32)
	statusBar.Position = UDim2.new(0, 16, 0, 64)
	statusBar.BackgroundColor3 = COLORS.infoBg
	statusBar.Text = "Bereit."
	statusBar.TextColor3 = COLORS.muted
	statusBar.TextSize = 14
	statusBar.Font = Enum.Font.Gotham
	statusBar.ZIndex = 3
	statusBar.Parent = main
	statusBar.TextXAlignment = Enum.TextXAlignment.Left
	statusBar.TextYAlignment = Enum.TextYAlignment.Center
	local statusPad = Instance.new("UIPadding")
	statusPad.PaddingLeft = UDim.new(0, 10)
	statusPad.Parent = statusBar
	cornerify(statusBar, 10)

	local function setStatus(t, col)
		statusBar.Text = t
		if col then statusBar.TextColor3 = col else statusBar.TextColor3 = COLORS.muted end
	end

	-- ScrollingFrame für Hauptinhalt
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollContent"
	scrollFrame.Size = UDim2.new(1, -32, 1, -112)
	scrollFrame.Position = UDim2.new(0, 16, 0, 104)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = COLORS.muted
	scrollFrame.ZIndex = 3
	scrollFrame.Parent = main

	-- Inhaltsbereich
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -6, 1, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.ZIndex = 3
	content.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = content

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 10)
	list.Parent = content

	-- Sektion Bewegung
	makeLabel(content, "Bewegung:")
	local flightBtn = makeBtn(content, "Flight Mode: AUS", COLORS.btn)

	-- Ziel-Spieler
	makeLabel(content, "Ziel-Spieler:")
	local playerBox = makeTextbox(content, "Spielername (Prefix erlaubt)")

	-- Aktionen
	local timebanOpen = makeBtn(content, "Timeban …", COLORS.warn)
	local permabanOpen = makeBtn(content, "Permaban …", COLORS.danger)

	-- NEU: Coins geben
	makeLabel(content, "Belohnungen:")
	local giveCoinsBtn = makeBtn(content, "💰 100 Coins geben", COLORS.coins)

	-- Adminverwaltung
	makeLabel(content, "Adminverwaltung:")
	local addAdmin = makeBtn(content, "Admin hinzufügen", COLORS.success)
	local removeAdmin = makeBtn(content, "Admin entfernen", Color3.fromRGB(170,120,70))

	-- Tools
	makeLabel(content, "Tools:")
	local giveGunBtn = makeBtn(content, "Waffe geben", COLORS.accent)

	-- TIMEBAN MODAL
	local timeOverlay, _, timeBody = createModal(gui, "Timeban")
	local tInfo = makeLabel(timeBody, "Dauer wählen:")
	tInfo.TextColor3 = COLORS.text

	local timeOptions = {
		{label="60 Sekunden", s=60},
		{label="5 Minuten", s=5*60},
		{label="30 Minuten", s=30*60},
		{label="1 Stunde", s=60*60},
		{label="24 Stunden", s=24*60*60},
	}
	for _,opt in ipairs(timeOptions) do
		local b = makeBtn(timeBody, opt.label, COLORS.btn)
		b.MouseButton1Click:Connect(function()
			local target = playerBox.Text
			if target == "" then
				setStatus("Bitte Spielernamen eingeben.", Color3.fromRGB(255,200,140)); return
			end
			timeoutPlayer:FireServer(target, opt.s)
			setStatus(("Timeban gesetzt (%s) für %s."):format(opt.label, target), COLORS.text)
			timeOverlay.Visible = false
		end)
	end
	local unTime = makeBtn(timeBody, "Timeban aufheben", Color3.fromRGB(130,130,70))
	unTime.MouseButton1Click:Connect(function()
		local target = playerBox.Text
		if target == "" then
			setStatus("Bitte Spielernamen eingeben.", Color3.fromRGB(255,200,140)); return
		end
		untimeoutPlayer:FireServer(target)
		setStatus(("Timeban aufgehoben für %s."):format(target), Color3.fromRGB(200,255,200))
		timeOverlay.Visible = false
	end)
	timebanOpen.MouseButton1Click:Connect(function() timeOverlay.Visible = true end)

	-- PERMABAN MODAL
	local banOverlay, _, banBody = createModal(gui, "Permaban")
	local banSet = makeBtn(banBody, "Permaban setzen", Color3.fromRGB(150,60,60))
	local banUn  = makeBtn(banBody, "Permaban aufheben", Color3.fromRGB(110,70,70))
	banSet.MouseButton1Click:Connect(function()
		local target = playerBox.Text
		if target == "" then
			setStatus("Bitte Spielernamen eingeben.", Color3.fromRGB(255,200,140)); return
		end
		banPlayer:FireServer(target)
		setStatus(("Permaban gesetzt für %s."):format(target), COLORS.text)
		banOverlay.Visible = false
	end)
	banUn.MouseButton1Click:Connect(function()
		local target = playerBox.Text
		if target == "" then
			setStatus("Bitte Spielernamen eingeben.", Color3.fromRGB(255,200,140)); return
		end
		unbanPlayer:FireServer(target)
		setStatus(("Permaban aufgehoben für %s."):format(target), Color3.fromRGB(200,255,200))
		banOverlay.Visible = false
	end)
	permabanOpen.MouseButton1Click:Connect(function() banOverlay.Visible = true end)

	-- Close Hauptmenü
	close.MouseButton1Click:Connect(function()
		timeOverlay.Visible = false
		banOverlay.Visible = false
		gui.Enabled = false
		menuOpen = false
	end)

	-- Verbesserter Flight Mode (KORRIGIERT)
	local bodyVelocity, bodyGyro
	local flightSpeed = 50
	local verticalSpeed = 50

	local function enableFlight()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVelocity.Velocity = Vector3.new()
		bodyVelocity.Parent = hrp

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
		bodyGyro.P = 3000
		bodyGyro.D = 500
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp

		flightEnabled = true
	end

	local function disableFlight()
		if bodyVelocity then 
			bodyVelocity.Velocity = Vector3.new() 
			bodyVelocity:Destroy() 
			bodyVelocity = nil 
		end
		if bodyGyro then 
			bodyGyro:Destroy() 
			bodyGyro = nil 
		end
		flightEnabled = false
	end

	RunService.Heartbeat:Connect(function()
		if flightEnabled and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local hum = player.Character:FindFirstChild("Humanoid")
			if hrp and hum and bodyVelocity and bodyGyro then
				local cam = workspace.CurrentCamera
				local md = hum.MoveDirection
				local vel = Vector3.new()

				-- Horizontale Bewegung - DIREKT von der Kamera, nicht vom Charakter
				if md.Magnitude > 0 then
					local camLook = cam.CFrame.LookVector
					local camRight = cam.CFrame.RightVector

					-- Nur horizontale Komponenten (Y auf 0)
					camLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
					camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

					-- WASD relativ zur Kamera
					local moveX = 0
					local moveZ = 0

					if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveZ += 1 end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveZ -= 1 end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveX -= 1 end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveX += 1 end

					vel = (camLook * moveZ + camRight * moveX) * flightSpeed
				end

				-- Vertikale Bewegung (Space/Shift)
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
					vel += Vector3.new(0, verticalSpeed, 0) 
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then 
					vel += Vector3.new(0, -verticalSpeed, 0) 
				end

				bodyVelocity.Velocity = vel

				-- Charakter dreht sich zur Kamera-Richtung
				local lookVector = cam.CFrame.LookVector
				local horizontalLook = Vector3.new(lookVector.X, 0, lookVector.Z)
				if horizontalLook.Magnitude > 0 then
					bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + horizontalLook)
				end
			end
		end
	end)

	flightBtn.MouseButton1Click:Connect(function()
		toggleFlight:FireServer()
		if flightEnabled then
			disableFlight()
			flightBtn.Text = "Flight Mode: AUS"
			flightBtn.BackgroundColor3 = COLORS.btn
			setStatus("Flight aus.")
		else
			enableFlight()
			flightBtn.Text = "Flight Mode: AN"
			flightBtn.BackgroundColor3 = COLORS.success
			setStatus("Flight an. (WASD + Space/Shift)")
		end
	end)

	-- Admin add/remove
	local function getTargetName()
		local t = playerBox.Text
		if t == "" then
			setStatus("Bitte Spielernamen eingeben.", Color3.fromRGB(255,200,140))
			return nil
		end
		return t
	end
	addAdmin.MouseButton1Click:Connect(function()
		local t = getTargetName(); if not t then return end
		setAdmin:FireServer(t, true)
		setStatus("Admin hinzugefügt (Rejoin nötig).", COLORS.text)
	end)
	removeAdmin.MouseButton1Click:Connect(function()
		local t = getTargetName(); if not t then return end
		setAdmin:FireServer(t, false)
		setStatus("Admin entfernt (Rejoin nötig).", COLORS.text)
	end)

	-- Waffe geben
	giveGunBtn.MouseButton1Click:Connect(function()
		giveWeapon:FireServer("Pistol")
		setStatus("Pistol angefragt. Falls nichts erscheint: Prüfe ServerStorage/AdminGuns.", COLORS.text)
	end)

	-- NEU: Coins geben
	giveCoinsBtn.MouseButton1Click:Connect(function()
		local t = getTargetName(); if not t then return end
		giveCoins:FireServer(t)
		setStatus(("100 Coins an %s gegeben!"):format(t), Color3.fromRGB(255,220,100))
	end)

	return gui, timeOverlay, banOverlay
end

-- Admin Check + M
local ok = false
pcall(function() ok = checkAdmin:InvokeServer() end)
if ok then
	isAdmin = true
	local gui, timeOverlay, banOverlay = createAdminMenu()
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.M then
			menuOpen = not menuOpen
			if not menuOpen then
				timeOverlay.Visible = false
				banOverlay.Visible = false
			end
			gui.Enabled = menuOpen
		end
	end)
end