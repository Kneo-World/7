-- ============================================================
-- MM2 ULTIMATE V26.9.3 (MAX FLING & ULTRA ANTI-FLING ENGINE)
-- ============================================================

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char, char.Humanoid, char.HumanoidRootPart
    end
    return nil, nil, nil
end

-- Переменные состояний
local isFlingingSingle = false
local isFlingingAll = false
local espEnabled = false
local autoFarmEnabled = false
local autoPickGunEnabled = false
local gunEspEnabled = false
local ghostModeEnabled = false
local antiKillEnabled = false
local noclipEnabled = false
local silentAimEnabled = false
local maxAntiFlingEnabled = true -- По умолчанию включена ультра-защита
local selectedPlayer = nil
local bav = nil
local originalCFrame = nil
local safePointCFrame = nil

-- ========== GUI Setup ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2_Mobile_Panel_V26_9_3"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Кнопка Toggle
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 140, 0, 38)
toggleGuiBtn.Position = UDim2.new(0.5, -70, 0, 10)
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
toggleGuiBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
toggleGuiBtn.Text = "👁️ HIDE / SHOW"
toggleGuiBtn.Font = Enum.Font.GothamBold
toggleGuiBtn.TextSize = 13
toggleGuiBtn.Parent = screenGui

local tgCorner = Instance.new("UICorner") tgCorner.CornerRadius = UDim.new(0, 10) tgCorner.Parent = toggleGuiBtn
local tgStroke = Instance.new("UIStroke") 
tgStroke.Color = Color3.fromRGB(0, 230, 255) 
tgStroke.Thickness = 1.5 
tgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tgStroke.Parent = toggleGuiBtn

-- Главный Фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 430)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -215)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner") mainCorner.CornerRadius = UDim.new(0, 14) mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke") 
mainStroke.Color = Color3.fromRGB(45, 50, 70) 
mainStroke.Thickness = 1.5 
mainStroke.Parent = mainFrame

toggleGuiBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- Шапка (Title Bar)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner") titleCorner.CornerRadius = UDim.new(0, 14) titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ MM2 ULTIMATE V26.9.3"
title.TextColor3 = Color3.fromRGB(0, 230, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 1, 0)
sep.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
sep.BorderSizePixel = 0
sep.Parent = titleBar

-- Скролл Контейнер
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -50)
scroll.Position = UDim2.new(0, 6, 0, 46)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 680)
scroll.ClipsDescendants = true
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function createButton(text, defaultColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = defaultColor
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = scroll

    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = btn
    local s = Instance.new("UIStroke") 
    s.Color = Color3.fromRGB(255, 255, 255) 
    s.Transparency = 0.9 
    s.Thickness = 1 
    s.Parent = btn

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.96, -8, 0, 34)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -8, 0, 36)}):Play()
    end)

    btn.Activated:Connect(function() callback(btn) end)
    return btn
end

-- Перетаскивание
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== Выбор Игрока ==========
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -8, 0, 36)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ClipsDescendants = false
dropdownFrame.Parent = scroll
local dpCorner = Instance.new("UICorner") dpCorner.CornerRadius = UDim.new(0, 8) dpCorner.Parent = dropdownFrame

local selectBtn = Instance.new("TextButton")
selectBtn.Size = UDim2.new(1, 0, 1, 0)
selectBtn.BackgroundTransparency = 1
selectBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
selectBtn.Text = "👤 Выбрать игрока..."
selectBtn.Font = Enum.Font.GothamMedium
selectBtn.TextSize = 12
selectBtn.Parent = dropdownFrame

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0, 110)
listFrame.Position = UDim2.new(0, 0, 1, 4)
listFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
listFrame.BorderSizePixel = 0
listFrame.Visible = false
listFrame.ZIndex = 10
listFrame.ScrollBarThickness = 3
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 255)
listFrame.Parent = dropdownFrame

local lfCorner = Instance.new("UICorner") lfCorner.CornerRadius = UDim.new(0, 8) lfCorner.Parent = listFrame
local lfStroke = Instance.new("UIStroke") lfStroke.Color = Color3.fromRGB(45, 50, 70) lfStroke.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = listFrame

local function updatePlayerList()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local players = game.Players:GetPlayers()
    local count = 0
    for _, plr in ipairs(players) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(32, 35, 50)
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Text = "  " .. plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 11
            btn.Parent = listFrame
            
            local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 5) bCorner.Parent = btn

            btn.Activated:Connect(function()
                selectedPlayer = plr
                selectBtn.Text = "👤 Цель: " .. plr.Name
                listFrame.Visible = false
            end)
            count = count + 1
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, count * 29 + 4)
end

selectBtn.Activated:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then updatePlayerList() end
end)

-- Safe-Point
createButton("📌 Поставить Safe-Точку", Color3.fromRGB(60, 45, 110), function(btn)
    local _, _, root = getCharacter()
    if root then
        safePointCFrame = root.CFrame
        btn.Text = "✅ Safe-Точка Установлена!"
        task.wait(1.5)
        btn.Text = "📌 Поставить Safe-Точку"
    end
end)

-- ESP
local espFolder = Instance.new("Folder", screenGui)
createButton("👁️ Role ESP: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    espEnabled = not espEnabled
    btn.Text = espEnabled and "👁️ Role ESP: ВКЛ ✅" or "👁️ Role ESP: ВЫКЛ"
    btn.BackgroundColor3 = espEnabled and Color3.fromRGB(15, 110, 80) or Color3.fromRGB(32, 35, 48)
    if not espEnabled then espFolder:ClearAllChildren() end
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    espFolder:ClearAllChildren()
    local _, _, myRoot = getCharacter()
    if not myRoot then return end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local hrp = char.HumanoidRootPart
            local color = Color3.fromRGB(0, 255, 150)

            if char:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                color = Color3.fromRGB(255, 50, 50)
            elseif char:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                color = Color3.fromRGB(0, 170, 255)
            end

            local bb = Instance.new("BillboardGui", espFolder)
            bb.Adornee = hrp
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.AlwaysOnTop = true

            local txt = Instance.new("TextLabel", bb)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = color
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 11
            local dist = math.floor((myRoot.Position - hrp.Position).Magnitude)
            txt.Text = plr.Name .. "\n[" .. dist .. "m]"
        end
    end
end)

local function getCoinCount()
    local coinData = player:FindFirstChild("CoinData") or player:FindFirstChild("leaderstats")
    if coinData then
        local coins = coinData:FindFirstChild("Coins") or coinData:FindFirstChild("Coin")
        if coins then return coins.Value end
    end
    local gui = player.PlayerGui:FindFirstChild("MainGUI", true)
    if gui then
        local coinLabel = gui:FindFirstChild("CoinLabel", true) or gui:FindFirstChild("Coins", true)
        if coinLabel and coinLabel:IsA("TextLabel") then
            local val = tonumber(coinLabel.Text:match("%d+"))
            if val then return val end
        end
    end
    return 0
end

local function getMurderer()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then 
                return plr 
            end
        end
    end
    return nil
end

-- ========== УЛЬТРА РВАНКА V26.9 ENGINE ==========
local function emergencyStop()
    isFlingingSingle = false isFlingingAll = false
    if bav then bav:Destroy() bav = nil end
    local char, _, root = getCharacter()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        if originalCFrame then root.CFrame = originalCFrame end
    end
end

local function startFlingLoop(getTargetFunc, isRunningCheck, durationLimit)
    local char, hum, root = getCharacter()
    if root then originalCFrame = root.CFrame end

    -- Максимально возможное вращательное ускорение по всем осям
    bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.AngularVelocity = Vector3.new(99999999, 99999999, 99999999)
    bav.P = 9999999
    if root then bav.Parent = root end

    local startTime = tick()
    local angle = 0

    local steppedConn = RunService.Stepped:Connect(function()
        if not isRunningCheck() then return end
        local currentChar = getCharacter()
        if currentChar then
            for _, part in ipairs(currentChar:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    local heartConn
    heartConn = RunService.Heartbeat:Connect(function()
        local _, _, currentRoot = getCharacter()
        if not isRunningCheck() or not currentRoot or (durationLimit and (tick() - startTime > durationLimit)) then
            heartConn:Disconnect() steppedConn:Disconnect() emergencyStop() return
        end
        local currentTarget = getTargetFunc()
        local targetRoot = currentTarget and currentTarget.Character and (currentTarget.Character:FindFirstChild("HumanoidRootPart") or currentTarget.Character:FindFirstChild("Torso"))
        if targetRoot and currentRoot then
            angle = angle + 120
            -- Опережение траектории цели на 0.12 сек
            local predictedCenter = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.12)
            local offsetX = math.cos(math.rad(angle)) * 0.8
            local offsetZ = math.sin(math.rad(angle)) * 0.8
            currentRoot.CFrame = CFrame.new(predictedCenter + Vector3.new(offsetX, 0, offsetZ))
            
            -- Каскадный импульс 
            currentRoot.AssemblyLinearVelocity = Vector3.new(99999999, 99999999, 99999999)
            currentRoot.AssemblyAngularVelocity = Vector3.new(99999999, 99999999, 99999999)
        end
    end)
end

-- Auto Farm
createButton("💰 Auto Farm Coins: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    autoFarmEnabled = not autoFarmEnabled
    btn.Text = autoFarmEnabled and "💰 Auto Farm Coins: ВКЛ ✅" or "💰 Auto Farm Coins: ВЫКЛ"
    btn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(160, 110, 0) or Color3.fromRGB(32, 35, 48)
end)

RunService.Stepped:Connect(function()
    if autoFarmEnabled then
        local char, hum, root = getCharacter()
        if char and hum then
            hum.Health = 100
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if autoFarmEnabled then
            local char, hum, root = getCharacter()
            if root and hum and hum.Health > 0 then
                if getCoinCount() >= 40 then
                    local murderer = getMurderer()
                    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                        isFlingingSingle = true
                        startFlingLoop(
                            function() return murderer end, 
                            function() 
                                local mChar = murderer.Character
                                local mRoot = mChar and mChar:FindFirstChild("HumanoidRootPart")
                                local mHum = mChar and mChar:FindFirstChild("Humanoid")
                                if not autoFarmEnabled or not mRoot or (mHum and mHum.Health <= 0) or mRoot.Position.Y > 200 then
                                    isFlingingSingle = false
                                end
                                return isFlingingSingle 
                            end, 
                            nil
                        )

                        while isFlingingSingle and autoFarmEnabled do task.wait(0.2) end
                        emergencyStop()
                    end

                    if safePointCFrame then
                        local _, _, currentRoot = getCharacter()
                        if currentRoot then
                            currentRoot.CFrame = safePointCFrame
                            currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                    task.wait(1)
                else
                    local coins = {}
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name == "Coin_Server" or obj.Name:find("Coin")) then
                            if obj.Transparency < 0.9 and obj.Parent then
                                local dist = (root.Position - obj.Position).Magnitude
                                table.insert(coins, {part = obj, distance = dist})
                            end
                        end
                    end

                    table.sort(coins, function(a, b) return a.distance < b.distance end)

                    if #coins > 0 and autoFarmEnabled then
                        local targetObj = coins[1].part
                        local targetPos = targetObj.Position - Vector3.new(0, 2.8, 0)
                        local flySpeed = 55

                        while autoFarmEnabled and targetObj.Parent and (root.Position - targetPos).Magnitude > 1.5 do
                            local currentFrameChar, currentHum, currentRoot = getCharacter()
                            if not currentRoot or currentHum.Health <= 0 or getCoinCount() >= 40 then break end

                            currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            local direction = (targetPos - currentRoot.Position).Unit
                            local stepDistance = math.min((targetPos - currentRoot.Position).Magnitude, flySpeed * 0.03)
                            currentRoot.CFrame = CFrame.new(currentRoot.Position + direction * stepDistance)
                            task.wait(0.03)
                        end

                        if autoFarmEnabled and targetObj.Parent and firetouchinterest then
                            firetouchinterest(root, targetObj, 0)
                            task.wait(0.03)
                            firetouchinterest(root, targetObj, 1)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- Aimbot
createButton("🎯 Аимбот на Убийцу: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    silentAimEnabled = not silentAimEnabled
    btn.Text = silentAimEnabled and "🎯 Аимбот на Убийцу: ВКЛ ✅" or "🎯 Аимбот на Убийцу: ВЫКЛ"
    btn.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(0, 130, 160) or Color3.fromRGB(32, 35, 48)
end)

local lastShotTime = 0
RunService.RenderStepped:Connect(function()
    if not silentAimEnabled then return end
    local char, hum, root = getCharacter()
    if not char or not root then return end

    local murderer = getMurderer()
    if murderer and murderer.Character then
        local murdHead = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
        if murdHead then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, murdHead.Position)
            root.CFrame = CFrame.new(root.Position, Vector3.new(murdHead.Position.X, root.Position.Y, murdHead.Position.Z))

            local gun = char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
            if gun then
                if gun.Parent ~= char then hum:EquipTool(gun) end
                if tick() - lastShotTime > 0.3 then
                    lastShotTime = tick()
                    gun:Activate()
                    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChildWhichIsA("RemoteEvent", true) or ReplicatedStorage:FindFirstChild("Shoot", true)
                    if shootRemote and shootRemote:IsA("RemoteEvent") then
                        shootRemote:FireServer(murdHead.Position, murdHead.CFrame)
                    end
                end
            end
        end
    end
end)

-- Kill All
createButton("🔪 KILL ALL (ЗА МАРДЕРА)", Color3.fromRGB(150, 25, 35), function(btn)
    local char, hum, root = getCharacter()
    if not char then return end

    local knife = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
    if not knife then
        btn.Text = "❌ ТЫ НЕ МАРДЕР!" task.wait(1) btn.Text = "🔪 KILL ALL (ЗА МАРДЕРА)" return
    end

    if knife.Parent ~= char then hum:EquipTool(knife) task.wait(0.1) end
    local oldPos = root.CFrame

    btn.Text = "⚔️ УНИЧТОЖЕНИЕ..."
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local targetRoot = plr.Character.HumanoidRootPart
            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2)
            knife:Activate()
            
            local knifeHandle = knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
            if knifeHandle and firetouchinterest then
                firetouchinterest(knifeHandle, targetRoot, 0)
                task.wait(0.03)
                firetouchinterest(knifeHandle, targetRoot, 1)
            end
            task.wait(0.15)
        end
    end

    root.CFrame = oldPos
    btn.Text = "✅ ВСЕ УБИТЫ!" task.wait(1) btn.Text = "🔪 KILL ALL (ЗА МАРДЕРА)"
end)

-- Drop Gun ESP & Auto Pick
createButton("🔫 Drop Gun ESP: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    gunEspEnabled = not gunEspEnabled
    btn.Text = gunEspEnabled and "🔫 Drop Gun ESP: ВКЛ ✅" or "🔫 Drop Gun ESP: ВЫКЛ"
    btn.BackgroundColor3 = gunEspEnabled and Color3.fromRGB(0, 120, 170) or Color3.fromRGB(32, 35, 48)
end)

createButton("🧲 Auto Pick Gun: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    autoPickGunEnabled = not autoPickGunEnabled
    btn.Text = autoPickGunEnabled and "🧲 Auto Pick Gun: ВКЛ ✅" or "🧲 Auto Pick Gun: ВЫКЛ"
    btn.BackgroundColor3 = autoPickGunEnabled and Color3.fromRGB(0, 120, 170) or Color3.fromRGB(32, 35, 48)
end)

local gunEspFolder = Instance.new("Folder", screenGui)
RunService.RenderStepped:Connect(function()
    gunEspFolder:ClearAllChildren()
    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("Gun", true)
    local _, _, root = getCharacter()

    if gunDrop and gunDrop:IsA("BasePart") then
        if gunEspEnabled then
            local bb = Instance.new("BillboardGui", gunEspFolder)
            bb.Adornee = gunDrop
            bb.Size = UDim2.new(0, 120, 0, 30)
            bb.AlwaysOnTop = true
            local txt = Instance.new("TextLabel", bb)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 220, 0)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            txt.Text = "🔫 ПИСТОЛЕТ ЗДЕСЬ!"
        end

        if autoPickGunEnabled and root then
            if firetouchinterest then
                firetouchinterest(root, gunDrop, 0)
                task.wait(0.05)
                firetouchinterest(root, gunDrop, 1)
            else
                root.CFrame = gunDrop.CFrame
            end
        end
    end
end)

-- Ghost Mode
createButton("👻 Invisible (Ghost): ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    ghostModeEnabled = not ghostModeEnabled
    btn.Text = ghostModeEnabled and "👻 Invisible: ВКЛ ✅" or "👻 Invisible: ВЫКЛ"
    btn.BackgroundColor3 = ghostModeEnabled and Color3.fromRGB(100, 20, 160) or Color3.fromRGB(32, 35, 48)
    
    local char = getCharacter()
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = ghostModeEnabled and 0.8 or 0
            end
        end
    end
end)

-- Anti-Kill Safety
createButton("🛡️ Anti-Kill Safety: ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    antiKillEnabled = not antiKillEnabled
    btn.Text = antiKillEnabled and "🛡️ Anti-Kill: ВКЛ ✅" or "🛡️ Anti-Kill: ВЫКЛ"
    btn.BackgroundColor3 = antiKillEnabled and Color3.fromRGB(160, 20, 80) or Color3.fromRGB(32, 35, 48)
end)

RunService.Heartbeat:Connect(function()
    if not antiKillEnabled then return end
    local _, _, root = getCharacter()
    if not root then return end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            if char:FindFirstChild("Knife") then
                local murdHrp = char:FindFirstChild("HumanoidRootPart")
                if murdHrp then
                    local dist = (root.Position - murdHrp.Position).Magnitude
                    if dist < 12 then
                        root.CFrame = root.CFrame + Vector3.new(0, 15, 0)
                    end
                end
            end
        end
    end
end)

-- ========== 8. MAX ANTI-FLING & COUNTER-LAUNCH (УЛЬТРА ЗАЩИТА) ==========
createButton("🛡️ Max Anti-Fling: ВКЛ ✅", Color3.fromRGB(180, 50, 0), function(btn)
    maxAntiFlingEnabled = not maxAntiFlingEnabled
    btn.Text = maxAntiFlingEnabled and "🛡️ Max Anti-Fling: ВКЛ ✅" or "🛡️ Max Anti-Fling: ВЫКЛ"
    btn.BackgroundColor3 = maxAntiFlingEnabled and Color3.fromRGB(180, 50, 0) or Color3.fromRGB(32, 35, 48)
end)

RunService.Heartbeat:Connect(function()
    if not maxAntiFlingEnabled or isFlingingSingle or isFlingingAll then return end
    local char, hum, root = getCharacter()
    if not char or not root or not hum then return end

    -- Мгновенное гашение кинетической энергии собственного тела
    if root.AssemblyLinearVelocity.Magnitude > 30 then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if root.AssemblyAngularVelocity.Magnitude > 30 then
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end

    -- Защита состояния персонажа (падение/регдолл)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    -- Контр-удар по вражеским рванщикам в радиусе 10 метров
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                -- Отключение коллизии с чужими хитбоксами
                for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local dist = (root.Position - otherRoot.Position).Magnitude
                local otherSpeed = otherRoot.AssemblyLinearVelocity.Magnitude + otherRoot.AssemblyAngularVelocity.Magnitude
                
                -- Детект опасной скорости атакующего
                if dist < 10 and otherSpeed > 80 then
                    otherRoot.AssemblyLinearVelocity = Vector3.new(99999999, 99999999, 99999999)
                    otherRoot.AssemblyAngularVelocity = Vector3.new(99999999, 99999999, 99999999)
                end
            end
        end
    end
end)

-- Noclip
createButton("🚶 Noclip (Сквозь стены): ВЫКЛ", Color3.fromRGB(32, 35, 48), function(btn)
    noclipEnabled = not noclipEnabled
    btn.Text = noclipEnabled and "🚶 Noclip: ВКЛ ✅" or "🚶 Noclip: ВЫКЛ"
    btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 140, 200) or Color3.fromRGB(32, 35, 48)
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- Кнопки атаки
local rvBtn = createButton("💥 РВАНКА ЦЕЛИ (10 СЕК)", Color3.fromRGB(160, 35, 35), function(btn)
    if isFlingingAll then return end
    if not selectedPlayer then
        btn.Text = "⚠️ ВЫБЕРИТЕ ИГРОКА!" task.wait(0.8) btn.Text = "💥 РВАНКА ЦЕЛИ (10 СЕК)" return
    end
    isFlingingSingle = not isFlingingSingle
    if isFlingingSingle then
        btn.BackgroundColor3 = Color3.fromRGB(30, 140, 40) btn.Text = "🔥 АТАКА..."
        startFlingLoop(function() return selectedPlayer end, function() return isFlingingSingle end, 10)
    else emergencyStop() end
end)

local allBtn = createButton("🌐 FLING ALL (ВЫКЛ)", Color3.fromRGB(110, 30, 150), function(btn)
    if isFlingingSingle then return end
    isFlingingAll = not isFlingingAll
    if isFlingingAll then
        btn.BackgroundColor3 = Color3.fromRGB(30, 140, 40) btn.Text = "🌐 FLING ALL (ВКЛ) 🔥"
        local currentTargetPlayer = nil
        task.spawn(function()
            while isFlingingAll do
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if not isFlingingAll then break end
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        currentTargetPlayer = plr
                        local tRoot = plr.Character.HumanoidRootPart
                        local st = tick()
                        while isFlingingAll and (tick() - st < 4) do
                            if not tRoot or not tRoot.Parent or tRoot.Position.Y > 200 then break end
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.1)
            end
            emergencyStop()
        end)
        startFlingLoop(function() return currentTargetPlayer end, function() return isFlingingAll end, nil)
    else emergencyStop() end
end)

createButton("🛑 ЭКСТРЕННЫЙ СТОП РВАНКИ", Color3.fromRGB(200, 90, 0), function()
    emergencyStop()
    rvBtn.Text = "💥 РВАНКА ЦЕЛИ (10 СЕК)" rvBtn.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
    allBtn.Text = "🌐 FLING ALL (ВЫКЛ)" allBtn.BackgroundColor3 = Color3.fromRGB(110, 30, 150)
end)

print("✅ MM2 V26.9.3 ULTIMATE ENGINE LOADED!")
