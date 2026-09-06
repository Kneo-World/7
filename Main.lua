-- ============================================================
-- MM2 ULTIMATE V38.0 FULL SCRIPT (AIMLOCK + WALLBANG + CHAMS + AUTO-FARM + ROFL)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== Переменные состояний ==========
local isFlingingSingle = false
local isFlingingAll = false
local isSpinAuraEnabled = false
local bunnyHopEnabled = false
local autoFarmEnabled = false
local autoPickGunEnabled = false
local gunEspEnabled = false
local ghostModeEnabled = false
local noclipEnabled = false
local maxAntiFlingEnabled = false

-- Rofl Variables
local isRoflEnabled = false
local roflTargetName = ""
local roflAnimationId = 120673504606569
local roflTrack = nil

-- Speed & Movement
local speedEnabled = false
local customSpeed = 16

-- Visual Flags
local chamsEnabled = false
local espInfoEnabled = false
local espBoxesEnabled = false
local espTracersEnabled = false
local customCrosshairEnabled = false
local customFovEnabled = false
local targetFovValue = 70
local murderAlertEnabled = true

-- AIMBOT & WALLBANG
local aimbotEnabled = false
local autoTriggerEnabled = false
local aimbotShowFov = true
local aimbotFovRadius = 250
local wallbangEnabled = true

local selectedPlayerName = nil
local tpPlayerName = nil
local originalCFrame = nil
local safePointCFrame = nil

local flingNameMap = {}
local tpNameMap = {}

-- ========== Вспомогательные функции ==========
local function getCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char, char.Humanoid, char.HumanoidRootPart
    end
    return nil, nil, nil
end

local function getRoles()
    local getPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not getPlayerData then return {} end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success or typeof(data) ~= "table" then return {} end
    
    local roles = {}
    for plrName, plrData in pairs(data) do
        if not plrData.Dead then
            roles[plrName] = plrData.Role
        end
    end
    return roles
end

local function getRoleColor(plr)
    if not plr or not plr.Character then return Color3.fromRGB(0, 255, 120) end
    if plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 35, 35)
    elseif plr.Character:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
        return Color3.fromRGB(35, 135, 255)
    end
    return Color3.fromRGB(0, 255, 120)
end

local function getRoleName(plr)
    if not plr or not plr.Character then return "Innocent" end
    if plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
        return "MURDER"
    elseif plr.Character:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
        return "SHERIFF"
    end
    return "Innocent"
end

-- ==================== ПОИСК МАРДЕРА И ЦЕЛЕЙ ====================
local function getMurdererPart()
    local rigs = Workspace:FindFirstChild("Rigs")
    if rigs and rigs:FindFirstChild("Murderer") then
        local m = rigs.Murderer
        return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("UpperTorso") or m:FindFirstChild("Head")
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasKnife = plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                return plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Head")
            end
        end
    end

    local roles = getRoles()
    for plrName, role in pairs(roles) do
        if role == "Murderer" then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character then
                return plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Head")
            end
        end
    end

    return nil
end

local function getKnifeTargetPart()
    local roles = getRoles()
    local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero

    for plrName, role in pairs(roles) do
        if (role == "Sheriff" or role == "Hero") and plrName ~= LocalPlayer.Name then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character then
                local part = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso")
                if part then return part end
            end
        end
    end

    local closestPart = nil
    local shortestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso")
            if hum and hum.Health > 0 and part then
                local dist = (part.Position - myPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

local function getPredictedPosition(targetPart)
    if not targetPart or not targetPart.Parent then return nil end

    local targetPos = targetPart.Position
    local targetVelocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.zero
    
    if targetVelocity.Magnitude < 0.5 then
        return targetPos
    end

    return targetPos + (targetVelocity * 0.18)
end

-- ==================== SILENT AIM HOOK ====================
local isCustomFiring = false
local rawNamecall

rawNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "fireServer") and aimbotEnabled and not isCustomFiring then
        if self.Name == "Shoot" then
            local targetPart = getMurdererPart()
            local predictedPos = getPredictedPosition(targetPart)
            
            if predictedPos then
                isCustomFiring = true
                
                local myChar, _, myRoot = getCharacter()
                local originPos = myRoot and myRoot.Position or (args[1] and args[1].Position) or Vector3.zero
                
                if wallbangEnabled then
                    local dir = (predictedPos - originPos).Unit
                    if dir.Magnitude == 0 then dir = Vector3.new(0, 0, -1) end
                    originPos = predictedPos - (dir * 1.5)
                end

                local originCFrame = CFrame.new(originPos, predictedPos)
                local targetCFrame = CFrame.new(predictedPos)

                self:FireServer(originCFrame, targetCFrame)
                isCustomFiring = false
                return nil
            end

        elseif self.Name == "KnifeThrown" then
            local targetPart = getKnifeTargetPart()
            local predictedPos = getPredictedPosition(targetPart)

            if predictedPos then
                isCustomFiring = true

                local myChar, _, myRoot = getCharacter()
                local originPos = myRoot and myRoot.Position or Vector3.zero

                if wallbangEnabled then
                    local dir = (predictedPos - originPos).Unit
                    if dir.Magnitude == 0 then dir = Vector3.new(0, 0, -1) end
                    originPos = predictedPos - (dir * 1.5)
                end

                local originCFrame = CFrame.new(originPos, predictedPos)
                local targetCFrame = CFrame.new(predictedPos)

                self:FireServer(originCFrame, targetCFrame)
                isCustomFiring = false
                return nil
            end
        end
    end

    return rawNamecall(self, ...)
end))

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
   Name = "✨ MM2 ULTIMATE V38.0",
   LoadingTitle = "Загрузка V38.0...",
   LoadingSubtitle = "by Kneo World",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("🎯 Аимбот & Стрельба", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Визуал & ESP", 4483362458)
local FlingTab = Window:CreateTab("💥 Рванка & Аура", 4483362458)
local RoflTab = Window:CreateTab("🤡 Rofl", 4483362458)
local FarmingTab = Window:CreateTab("💰 Авто-Фарм", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Телепорты & Разное", 4483362458)

-- ==================== Вкладка: АИМБОТ ====================
CombatTab:CreateSection("📱 Настройки Стрельбы")

CombatTab:CreateToggle({
   Name = "🧱 Wallbang (Прострел сквозь стены)",
   CurrentValue = true,
   Callback = function(Value) wallbangEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "🎯 Continuous AimLock (Постоянная наводка)",
   CurrentValue = false,
   Callback = function(Value) aimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "⚡ Auto-Trigger Shoot (Авто-Выстрел)",
   CurrentValue = false,
   Callback = function(Value) autoTriggerEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "⭕ Радиус захвата (FOV)",
   Range = {50, 600},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 250,
   Callback = function(Value) aimbotFovRadius = Value end,
})

CombatTab:CreateToggle({
   Name = "⭕ Показывать FOV Круг",
   CurrentValue = true,
   Callback = function(Value) aimbotShowFov = Value end,
})

CombatTab:CreateSection("🔪 Быстрый Бой")

CombatTab:CreateButton({
   Name = "🔪 KILL ALL (Убить всех за Мардера)",
   Callback = function()
      local char, hum, root = getCharacter()
      if not char then return end

      local knife = char:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
      if not knife then
          Rayfield:Notify({Title = "Ошибка", Content = "Ты не Убийца!", Duration = 2})
          return
      end

      if knife.Parent ~= char then hum:EquipTool(knife) task.wait(0.1) end
      local oldPos = root.CFrame

      for _, plr in ipairs(Players:GetPlayers()) do
          if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
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
   end,
})

-- ==================== ПОСТОЯННАЯ НАВОДКА КАМЕРЫ & FOV ====================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.NumSides = 36

local lastShotTime = 0

RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
    fovCircle.Radius = aimbotFovRadius
    fovCircle.Visible = (aimbotEnabled or autoTriggerEnabled) and aimbotShowFov

    local targetPart = getMurdererPart()
    local predPos = getPredictedPosition(targetPart)

    if predPos then
        local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        local distanceToCenter = (targetScreenPos - screenCenter).Magnitude

        if aimbotEnabled and (distanceToCenter <= aimbotFovRadius or wallbangEnabled) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, predPos)
        end

        if autoTriggerEnabled and (tick() - lastShotTime > 0.35) and (distanceToCenter <= aimbotFovRadius or wallbangEnabled) then
            local char, hum, _ = getCharacter()
            if char then
                local gun = char:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
                if gun then
                    if gun.Parent ~= char and hum then hum:EquipTool(gun) end
                    gun:Activate()
                    lastShotTime = tick()
                end
            end
        end
    end
end)

-- ==================== Вкладка: ВИЗУАЛ & ESP ====================
VisualsTab:CreateSection("✨ Highlights (Chams)")

VisualsTab:CreateToggle({
    Name = "✨ Chams (Highlight ESP)",
    CurrentValue = false,
    Callback = function(Value) chamsEnabled = Value end,
})

VisualsTab:CreateSection("🔥 Drawing ESP Engine")

VisualsTab:CreateToggle({ Name = "📜 Имена + Роли + Дистанция", CurrentValue = false, Callback = function(Value) espInfoEnabled = Value end })
VisualsTab:CreateToggle({ Name = "📦 2D / 3D Боксы (Boxes)", CurrentValue = false, Callback = function(Value) espBoxesEnabled = Value end })
VisualsTab:CreateToggle({ Name = "📏 Snaplines / Tracers", CurrentValue = false, Callback = function(Value) espTracersEnabled = Value end })
VisualsTab:CreateToggle({ Name = "🔫 Drop Gun ESP & Marker", CurrentValue = false, Callback = function(Value) gunEspEnabled = Value end })
VisualsTab:CreateToggle({ Name = "🚨 Murderer Alert (Оповещение)", CurrentValue = true, Callback = function(Value) murderAlertEnabled = Value end })

VisualsTab:CreateSection("🎨 Графика")

VisualsTab:CreateSlider({
   Name = "👁️ Расширение FOV",
   Range = {60, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Callback = function(Value)
      targetFovValue = Value
      customFovEnabled = true
   end,
})

VisualsTab:CreateToggle({ Name = "🎯 Кастомный Прицел (Crosshair)", CurrentValue = false, Callback = function(Value) customCrosshairEnabled = Value end })

-- Chams Implementation
local function applyChams(plr)
    if plr == LocalPlayer then return end
    local function setupHighlight(char)
        if not char then return end
        local highlight = char:FindFirstChild("MM2_Chams") or Instance.new("Highlight")
        highlight.Name = "MM2_Chams"
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then
                conn:Disconnect()
                return
            end
            if chamsEnabled then
                highlight.Enabled = true
                local col = getRoleColor(plr)
                highlight.FillColor = col
                highlight.OutlineColor = col
            else
                highlight.Enabled = false
            end
        end)
    end
    if plr.Character then setupHighlight(plr.Character) end
    plr.CharacterAdded:Connect(setupHighlight)
end

for _, plr in ipairs(Players:GetPlayers()) do applyChams(plr) end
Players.PlayerAdded:Connect(applyChams)

-- Drawing ESP Objects
local ESP_Objects = {}

local function createEspForPlayer(plr)
    if plr == LocalPlayer then return end
    local objects = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Text = Drawing.new("Text")
    }
    objects.Tracer.Thickness = 1.5; objects.Tracer.Transparency = 1; objects.Tracer.Visible = false
    objects.Box.Thickness = 1.5; objects.Box.Filled = false; objects.Box.Transparency = 1; objects.Box.Visible = false
    objects.Text.Size = 14; objects.Text.Center = true; objects.Text.Outline = true; objects.Text.Font = 2; objects.Text.Visible = false
    ESP_Objects[plr] = objects
end

local function removeEspForPlayer(plr)
    if ESP_Objects[plr] then
        for _, obj in pairs(ESP_Objects[plr]) do
            if obj and obj.Remove then obj:Remove() end
        end
        ESP_Objects[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createEspForPlayer(plr) end
Players.PlayerAdded:Connect(createEspForPlayer)
Players.PlayerRemoving:Connect(removeEspForPlayer)

local crossLineH = Drawing.new("Line")
local crossLineV = Drawing.new("Line")
crossLineH.Thickness = 2; crossLineH.Color = Color3.fromRGB(0, 255, 200)
crossLineV.Thickness = 2; crossLineV.Color = Color3.fromRGB(0, 255, 200)

RunService.RenderStepped:Connect(function()
    if customFovEnabled then Camera.FieldOfView = targetFovValue end

    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    if customCrosshairEnabled then
        crossLineH.From = center - Vector2.new(8, 0); crossLineH.To = center + Vector2.new(8, 0); crossLineH.Visible = true
        crossLineV.From = center - Vector2.new(0, 8); crossLineV.To = center + Vector2.new(0, 8); crossLineV.Visible = true
    else
        crossLineH.Visible = false; crossLineV.Visible = false
    end

    for plr, objs in pairs(ESP_Objects) do
        if plr and plr.Parent and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character.Head
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local color = getRoleColor(plr)
                local roleText = getRoleName(plr)
                local _, _, myRoot = getCharacter()
                local dist = myRoot and math.floor((myRoot.Position - hrp.Position).Magnitude) or 0

                if espTracersEnabled then
                    objs.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    objs.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    objs.Tracer.Color = color; objs.Tracer.Visible = true
                else objs.Tracer.Visible = false end

                if espBoxesEnabled then
                    local boxHeight = math.abs(headPos.Y - legPos.Y)
                    local boxWidth = boxHeight * 0.65
                    objs.Box.Size = Vector2.new(boxWidth, boxHeight)
                    objs.Box.Position = Vector2.new(hrpPos.X - (boxWidth / 2), headPos.Y)
                    objs.Box.Color = color; objs.Box.Visible = true
                else objs.Box.Visible = false end

                if espInfoEnabled then
                    objs.Text.Position = Vector2.new(hrpPos.X, headPos.Y - 18)
                    objs.Text.Text = string.format("%s [%s] | %d m", plr.Name, roleText, dist)
                    objs.Text.Color = color; objs.Text.Visible = true
                else objs.Text.Visible = false end
            else
                objs.Tracer.Visible = false; objs.Box.Visible = false; objs.Text.Visible = false
            end
        else
            objs.Tracer.Visible = false; objs.Box.Visible = false; objs.Text.Visible = false
        end
    end
end)

-- Murderer Alert Loop
local alertedMurderers = {}
task.spawn(function()
    while true do
        task.wait(1)
        if murderAlertEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hasKnife = plr.Character:FindFirstChild("Knife")
                    if hasKnife and not alertedMurderers[plr.Name] then
                        alertedMurderers[plr.Name] = true
                        Rayfield:Notify({Title = "⚠️ ОПАСНОСТЬ!", Content = plr.Name .. " ДОСТАЛ НОЖ!", Duration = 4})
                    elseif not hasKnife and alertedMurderers[plr.Name] then
                        alertedMurderers[plr.Name] = nil
                    end
                end
            end
        end
    end
end)

-- ==================== Вкладка: РВАНКА & АУРА ====================
FlingTab:CreateSection("Управление Рванкой")

local playerDropdown = FlingTab:CreateDropdown({
   Name = "Выбрать игрока для Рванки",
   Options = {"Загрузка..."},
   CurrentOption = {"Загрузка..."},
   MultipleOptions = false,
   Callback = function(Option) selectedPlayerName = flingNameMap[Option[1]] end,
})

local tpDropdown = MiscTab:CreateDropdown({
   Name = "Выбрать игрока для Телепорта",
   Options = {"Загрузка..."},
   CurrentOption = {"Загрузка..."},
   MultipleOptions = false,
   Callback = function(Option) tpPlayerName = tpNameMap[Option[1]] end,
})

local function refreshSortedPlayerLists()
    local murderers, sheriffs, innocents = {}, {}, {}
    flingNameMap, tpNameMap = {}, {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local displayName = p.Name
            if p.Character and (p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))) then
                displayName = "🔴 " .. p.Name .. " [MURDER]"
            elseif p.Character and (p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))) then
                displayName = "🔵 " .. p.Name .. " [SHERIFF]"
            end

            flingNameMap[displayName] = p.Name
            tpNameMap[displayName] = p.Name

            if displayName:find("%[MURDER%]") then table.insert(murderers, displayName)
            elseif displayName:find("%[SHERIFF%]") then table.insert(sheriffs, displayName)
            else table.insert(innocents, displayName) end
        end
    end

    local sortedList = {}
    for _, m in ipairs(murderers) do table.insert(sortedList, m) end
    for _, s in ipairs(sheriffs) do table.insert(sortedList, s) end
    for _, i in ipairs(innocents) do table.insert(sortedList, i) end

    if #sortedList == 0 then sortedList = {"Никого нет"} end
    playerDropdown:Refresh(sortedList)
    tpDropdown:Refresh(sortedList)
end

task.spawn(function()
    while true do
        refreshSortedPlayerLists()
        task.wait(2)
    end
end)

local function emergencyStop()
    isFlingingSingle = false 
    isFlingingAll = false
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
    if not root then return end
    originalCFrame = root.CFrame
    local startTime = tick()
    local rotAngle = 0

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
            heartConn:Disconnect() 
            steppedConn:Disconnect() 
            emergencyStop() 
            return
        end
        
        local currentTarget = getTargetFunc()
        local targetRoot = currentTarget and currentTarget.Character and (currentTarget.Character:FindFirstChild("HumanoidRootPart") or currentTarget.Character:FindFirstChild("Torso"))
        
        if targetRoot and currentRoot then
            rotAngle = (rotAngle + 100) % 360
            local predictedPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.1)
            local rotation = CFrame.Angles(math.rad(rotAngle * 2), math.rad(rotAngle), math.rad(rotAngle * 3))
            local offset = Vector3.new(math.cos(math.rad(rotAngle)) * 1.2, 0, math.sin(math.rad(rotAngle)) * 1.2)
            
            currentRoot.CFrame = CFrame.new(predictedPos + offset) * rotation
            currentRoot.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
            currentRoot.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
        end
    end)
end

FlingTab:CreateToggle({
   Name = "💥 Рванка выбранного игрока (10 сек)",
   CurrentValue = false,
   Callback = function(Value)
      isFlingingSingle = Value
      if isFlingingSingle then
         local targetPlr = Players:FindFirstChild(selectedPlayerName or "")
         if targetPlr then
            startFlingLoop(function() return targetPlr end, function() return isFlingingSingle end, 10)
         else
            Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока из списка!", Duration = 2})
            isFlingingSingle = false
         end
      else emergencyStop() end
   end,
})

FlingTab:CreateToggle({
   Name = "🌐 Fling All (Рванка всех)",
   CurrentValue = false,
   Callback = function(Value)
      isFlingingAll = Value
      if isFlingingAll then
         local currentTargetPlayer = nil
         task.spawn(function()
            while isFlingingAll do
               for _, plr in ipairs(Players:GetPlayers()) do
                  if not isFlingingAll then break end
                  if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
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
   end,
})

FlingTab:CreateToggle({
   Name = "🌪️ Крутилка-Аура (Безопасная)",
   CurrentValue = false,
   Callback = function(Value)
      isSpinAuraEnabled = Value
      if not isSpinAuraEnabled then
          local _, _, root = getCharacter()
          if root then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
      end
   end,
})

RunService.Heartbeat:Connect(function()
    if not isSpinAuraEnabled or isFlingingSingle or isFlingingAll then return end
    local char, hum, root = getCharacter()
    if not root or not hum then return end

    root.AssemblyAngularVelocity = Vector3.new(0, 95000, 0)
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                if (root.Position - otherRoot.Position).Magnitude < 4.5 then
                    otherRoot.AssemblyLinearVelocity = Vector3.new(999999, 999999, 999999)
                end
            end
        end
    end
end)

FlingTab:CreateButton({ Name = "🛑 ЭКСТРЕННЫЙ СТОП РВАНКИ", Callback = function() emergencyStop() end })

FlingTab:CreateToggle({
   Name = "🛡️ Max Anti-Fling",
   CurrentValue = false,
   Callback = function(Value) maxAntiFlingEnabled = Value end,
})

-- ==================== Вкладка: ROFL ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local isRoflEnabled = false
local selectedPlayerName = ""

-- Функция получения списка игроков
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    if #list == 0 then
        table.insert(list, "Нет игроков")
    end
    return list
end

-- 1. Выпадающий список (Dropdown)
local PlayerDropdown = RoflTab:CreateDropdown({
   Name = "🎯 Выбери игрока",
   Options = getPlayerList(),
   CurrentOption = {"Нет игроков"},
   MultipleOptions = false,
   Callback = function(Options)
      if type(Options) == "table" then
          selectedPlayerName = Options[1] or ""
      else
          selectedPlayerName = Options or ""
      end
   end,
})

-- Авто-обновление списка
local function refreshDropdown()
    if PlayerDropdown and PlayerDropdown.Set then
        PlayerDropdown:Set(getPlayerList())
    end
end

Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

-- Поза сидения через поворот суставов (Motor6D)
local function applySitPose(character, enable)
    if not character then return end
    
    -- Для R15 и R6 персонажей
    local hipRight = character:FindFirstChild("Right Hip", true) or character:FindFirstChild("RightHip", true)
    local hipLeft = character:FindFirstChild("Left Hip", true) or character:FindFirstChild("LeftHip", true)

    if hipRight and hipLeft then
        if enable then
            -- Поворачиваем бедра вперед (поза сидения)
            hipRight.C6 = CFrame.Angles(0, math.rad(90), math.rad(90))
            hipLeft.C6 = CFrame.Angles(0, math.rad(-90), math.rad(-90))
        end
    end
end

-- 2. Переключатель (Toggle)
RoflTab:CreateToggle({
   Name = "🤡 Включить Head Attach",
   CurrentValue = false,
   Callback = function(Value)
      isRoflEnabled = Value
   end,
})

-- 3. Основной цикл позиционирования
RunService.Heartbeat:Connect(function()
    if not isRoflEnabled or selectedPlayerName == "" or selectedPlayerName == "Нет игроков" then 
        return 
    end

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then return end

    local targetPlayer = Players:FindFirstChild(selectedPlayerName)

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetHead = targetPlayer.Character.Head

        -- Отключаем коллизию всех деталей
        for _, part in ipairs(myChar:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        -- Переводим Humanoid в состояние Sit для красивой позы без сторонних ID
        myHum:ChangeState(Enum.HumanoidStateType.Physics)
        myHum.Sit = true

        -- Разворот поясом/животом к лицу цели и посадка на голову
        -- Y = 0.8 (чуть ниже к голове)
        myRoot.CFrame = targetHead.CFrame * CFrame.new(0, 0.8, 0) * CFrame.Angles(0, math.rad(90), 0)
        
        -- Сброс скоростей
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ==================== Вкладка: АВТО-ФАРМ ====================
FarmingTab:CreateSection("Настройки Фарма")

FarmingTab:CreateButton({
   Name = "📌 Поставить Safe-Точку",
   Callback = function()
      local _, _, root = getCharacter()
      if root then
          safePointCFrame = root.CFrame
          Rayfield:Notify({Title = "Успешно", Content = "Safe-Точка установлена!", Duration = 2})
      end
   end,
})

FarmingTab:CreateToggle({
   Name = "💰 Auto Farm Coins (Телепорт)",
   CurrentValue = false,
   Callback = function(Value) autoFarmEnabled = Value end,
})

-- Полноценная логика авто-фарма монет
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoFarmEnabled then
            local char, _, root = getCharacter()
            local coinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer", true)
            
            if coinContainer and root then
                local coins = {}
                for _, child in ipairs(coinContainer:GetDescendants()) do
                    if child.Name == "Coin" or child.Name == "CoinContainer" or child:IsA("TouchTransmitter") then
                        local coinPart = child:IsA("BasePart") and child or child.Parent
                        if coinPart and coinPart:IsA("BasePart") and coinPart.Transparency < 1 then
                            table.insert(coins, coinPart)
                        end
                    end
                end

                if #coins > 0 then
                    for _, coinPart in ipairs(coins) do
                        if not autoFarmEnabled then break end
                        if coinPart and coinPart.Parent and coinPart.Transparency < 1 then
                            root.CFrame = coinPart.CFrame
                            task.wait(0.35)
                        end
                    end
                elseif safePointCFrame then
                    root.CFrame = safePointCFrame
                end
            elseif safePointCFrame and root then
                root.CFrame = safePointCFrame
            end
        end
    end
end)

-- ==================== Вкладка: РАЗНОЕ ====================
MiscTab:CreateSection("Телепортация")

MiscTab:CreateButton({
   Name = "⚡ Телепортироваться к игроку",
   Callback = function()
      local targetPlr = Players:FindFirstChild(tpPlayerName or "")
      local _, _, root = getCharacter()
      if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") and root then
          root.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
          Rayfield:Notify({Title = "Телепорт", Content = "ТП к " .. targetPlr.Name, Duration = 1.5})
      else
          Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока из списка!", Duration = 2})
      end
   end,
})

MiscTab:CreateSection("Физика & Скорость")

MiscTab:CreateToggle({
    Name = "⚡ Speed Hack (CFrame)",
    CurrentValue = false,
    Callback = function(Value) speedEnabled = Value end,
})

MiscTab:CreateSlider({
    Name = "🏃 Скорость Бега",
    Range = {16, 120},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value) customSpeed = Value end,
})

MiscTab:CreateToggle({ Name = "🐰 Bunny Hop", CurrentValue = false, Callback = function(Value) bunnyHopEnabled = Value end })
MiscTab:CreateToggle({ Name = "🧲 Auto Pick Gun", CurrentValue = false, Callback = function(Value) autoPickGunEnabled = Value end })
MiscTab:CreateToggle({ Name = "🚶 Noclip", CurrentValue = false, Callback = function(Value) noclipEnabled = Value end })

MiscTab:CreateToggle({
   Name = "👻 Ghost Mode",
   CurrentValue = false,
   Callback = function(Value)
      ghostModeEnabled = Value
      local char = getCharacter()
      if char then
          for _, part in ipairs(char:GetChildren()) do
              if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                  part.Transparency = ghostModeEnabled and 0.8 or 0
              end
          end
      end
   end,
})

-- ==================== СЕРВИСНЫЕ ЦИКЛЫ ====================
RunService.Heartbeat:Connect(function()
    if speedEnabled then
        local char, hum, root = getCharacter()
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (customSpeed / 50))
        end
    end
end)

RunService.Stepped:Connect(function()
    if autoFarmEnabled or noclipEnabled then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    if bunnyHopEnabled then
        local _, hum, _ = getCharacter()
        if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    end
end)

-- Drop Gun ESP Marker
local gunEspText = Drawing.new("Text")
gunEspText.Size = 16; gunEspText.Center = true; gunEspText.Outline = true
gunEspText.Color = Color3.fromRGB(255, 230, 0); gunEspText.Visible = false

RunService.RenderStepped:Connect(function()
    local gunDrop = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    local _, _, root = getCharacter()

    if gunDrop and gunDrop:IsA("BasePart") and gunEspEnabled then
        local pos, onScreen = Camera:WorldToViewportPoint(gunDrop.Position)
        if onScreen then
            gunEspText.Position = Vector2.new(pos.X, pos.Y)
            gunEspText.Text = "🔫 ПИСТОЛЕТ ЛЕЖИТ!"
            gunEspText.Visible = true
        else gunEspText.Visible = false end

        if autoPickGunEnabled and root then
            if firetouchinterest then
                firetouchinterest(root, gunDrop, 0)
                task.wait(0.05)
                firetouchinterest(root, gunDrop, 1)
            else root.CFrame = gunDrop.CFrame end
        end
    else
        gunEspText.Visible = false
    end
end)

-- ==================== MAX ANTI-FLING V2 (GUARANTEED) ====================
local AntiFlingVelocity = Instance.new("BodyVelocity")
AntiFlingVelocity.Name = "AntiFlingShield"
AntiFlingVelocity.MaxForce = Vector3.new(0, 0, 0)
AntiFlingVelocity.Velocity = Vector3.new(0, 0, 0)

RunService.Stepped:Connect(function()
    if not maxAntiFlingEnabled or isFlingingSingle or isFlingingAll or isSpinAuraEnabled or isRoflEnabled then 
        AntiFlingVelocity.MaxForce = Vector3.new(0, 0, 0)
        return 
    end

    local char, hum, root = getCharacter()
    if not char or not root or not hum then return end

    -- 1. Полное отключение столкновений с другими игроками
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in ipairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    -- 2. Блокировка регдолла и падений
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end)

RunService.Heartbeat:Connect(function()
    if not maxAntiFlingEnabled or isFlingingSingle or isFlingingAll or autoFarmEnabled or isSpinAuraEnabled or isRoflEnabled then return end
    local char, hum, root = getCharacter()
    if not char or not root or not hum then return end

    -- Прикрепляем BodyVelocity, если его нет
    if AntiFlingVelocity.Parent ~= root then
        AntiFlingVelocity.Parent = root
    end

    -- 3. Детект аномального ускорения и мгновенный сброс
    local currentVel = root.AssemblyLinearVelocity
    local currentRot = root.AssemblyAngularVelocity

    if currentVel.Magnitude > 60 or currentRot.Magnitude > 60 then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        -- Включаем жесткую стабилизацию на 1 кадр
        AntiFlingVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    else
        AntiFlingVelocity.MaxForce = Vector3.new(0, 0, 0)
    end
end)

Rayfield:Notify({Title = "MM2 Ultimate V38.0", Content = "Скрипт V38.0 успешно загружен с вкладкой ROFL!", Duration = 4})
