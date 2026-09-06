-- ============================================================
-- MM2 ULTIMATE V37.6 FULL SCRIPT (HOOK NOCLIP + GETPLAYERDATA)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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
local antiKillEnabled = false
local noclipEnabled = false
local maxAntiFlingEnabled = false

-- Visual Flags
local espInfoEnabled = false
local espBoxesEnabled = false
local espTracersEnabled = false
local customCrosshairEnabled = false
local customFovEnabled = false
local targetFovValue = 70

-- MOBILE AIMBOT & WALLBANG
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

-- Получение данных ролей с сервера MM2
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

local function getMurderer()
    local roles = getRoles()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if roles[plr.Name] == "Murderer" or plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
                return plr
            end
        end
    end
    return nil
end

-- Расчёт позиции с упреждением движения
local function getPredictedTargetCFrame()
    local murder = getMurderer()
    if murder and murder.Character then
        local targetPart = murder.Character:FindFirstChild("Head") or murder.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero
            local predictedPos = targetPart.Position + (velocity * 0.13)
            return CFrame.new(predictedPos), targetPart
        end
    end
    return nil, nil
end

-- ==================== ХУК ВЫСТРЕЛА (ПРОСТРЕЛ СКВОЗЬ СТЕНЫ) ====================
local shootEvent = ReplicatedStorage:FindFirstChild("Shoot", true)

if shootEvent and shootEvent:IsA("RemoteEvent") then
    local oldFireServer
    
    oldFireServer = hookfunction(shootEvent.FireServer, newcclosure(function(self, ...)
        local args = {...}
        
        if wallbangEnabled and not checkcaller() then
            local predCFrame, _ = getPredictedTargetCFrame()
            if predCFrame then
                if #args >= 2 then
                    args[1] = predCFrame * CFrame.new(0, 0, -0.2)
                    args[2] = predCFrame
                else
                    for i = 1, #args do
                        if typeof(args[i]) == "CFrame" then
                            args[i] = predCFrame
                        elseif typeof(args[i]) == "Vector3" then
                            args[i] = predCFrame.Position
                        end
                    end
                end
            end

            local disabledParts = {}
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object:IsA("BasePart") and object.CanCollide then
                    local isPlayerPart = false
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr.Character and object:IsDescendantOf(plr.Character) then
                            isPlayerPart = true
                            break
                        end
                    end
                    if not isPlayerPart then
                        object.CanCollide = false
                        table.insert(disabledParts, object)
                    end
                end
            end
            
            local result = oldFireServer(self, unpack(args))
            
            task.spawn(function()
                task.wait()
                for _, part in ipairs(disabledParts) do
                    if part and part.Parent then
                        part.CanCollide = true
                    end
                end
            end)
            
            return result
        end
        
        return oldFireServer(self, ...)
    end))
end

-- ==================== ОКНО RAYFIELD ====================
local Window = Rayfield:CreateWindow({
   Name = "✨ MM2 ULTIMATE V37.6",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Kneo World",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("🎯 Аимбот & Стрельба", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Визуал & ESP", 4483362458)
local FlingTab = Window:CreateTab("💥 Рванка & Аура", 4483362458)
local FarmingTab = Window:CreateTab("💰 Авто-Фарм", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Телепорты & Разное", 4483362458)

-- ==================== Вкладка: АИМБОТ ====================
CombatTab:CreateSection("📱 Настройки Стрельбы")

CombatTab:CreateToggle({
   Name = "🧱 Wallbang (Hook Noclip + Pred)",
   CurrentValue = true,
   Callback = function(Value) wallbangEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "🎯 Touch Lock (Доводка Камеры)",
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

-- FOV Circle Drawing
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

    local predCFrame, targetPart = getPredictedTargetCFrame()
    if predCFrame and targetPart then
        local screenPos, onScreen = Camera:WorldToViewportPoint(predCFrame.Position)
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        local distanceToCenter = (targetScreenPos - screenCenter).Magnitude

        if (onScreen and distanceToCenter <= aimbotFovRadius) or wallbangEnabled then
            if aimbotEnabled and onScreen then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predCFrame.Position)
            end

            if autoTriggerEnabled and (tick() - lastShotTime > 0.4) then
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
    end
end)

-- ==================== Вкладка: ВИЗУАЛ & ESP ====================
VisualsTab:CreateSection("🔥 Drawing ESP Engine")

VisualsTab:CreateToggle({ Name = "📜 Имена + Роли + Дистанция", CurrentValue = false, Callback = function(Value) espInfoEnabled = Value end })
VisualsTab:CreateToggle({ Name = "📦 2D / 3D Боксы (Boxes)", CurrentValue = false, Callback = function(Value) espBoxesEnabled = Value end })
VisualsTab:CreateToggle({ Name = "📏 Snaplines / Tracers", CurrentValue = false, Callback = function(Value) espTracersEnabled = Value end })
VisualsTab:CreateToggle({ Name = "🔫 Drop Gun ESP & Marker", CurrentValue = false, Callback = function(Value) gunEspEnabled = Value end })

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

local ESP_Objects = {}

local function createEspForPlayer(plr)
    if plr == LocalPlayer then return end
    local objects = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Text = Drawing.new("Text")
    }
    objects.Tracer.Thickness = 1.5
    objects.Tracer.Transparency = 1
    objects.Tracer.Visible = false

    objects.Box.Thickness = 1.5
    objects.Box.Filled = false
    objects.Box.Transparency = 1
    objects.Box.Visible = false

    objects.Text.Size = 14
    objects.Text.Center = true
    objects.Text.Outline = true
    objects.Text.Font = 2
    objects.Text.Visible = false

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
                    objs.Tracer.Color = color
                    objs.Tracer.Visible = true
                else objs.Tracer.Visible = false end

                if espBoxesEnabled then
                    local boxHeight = math.abs(headPos.Y - legPos.Y)
                    local boxWidth = boxHeight * 0.65
                    objs.Box.Size = Vector2.new(boxWidth, boxHeight)
                    objs.Box.Position = Vector2.new(hrpPos.X - (boxWidth / 2), headPos.Y)
                    objs.Box.Color = color
                    objs.Box.Visible = true
                else objs.Box.Visible = false end

                if espInfoEnabled then
                    objs.Text.Position = Vector2.new(hrpPos.X, headPos.Y - 18)
                    objs.Text.Text = string.format("%s [%s] | %d m", plr.Name, roleText, dist)
                    objs.Text.Color = color
                    objs.Text.Visible = true
                else objs.Text.Visible = false end
            else
                objs.Tracer.Visible = false; objs.Box.Visible = false; objs.Text.Visible = false
            end
        else
            objs.Tracer.Visible = false; objs.Box.Visible = false; objs.Text.Visible = false
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
   Name = "💰 Auto Farm Coins",
   CurrentValue = false,
   Callback = function(Value) autoFarmEnabled = Value end,
})

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

MiscTab:CreateSection("Физика & Персонаж")

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

-- Anti-Fling Protect Loop
RunService.Heartbeat:Connect(function()
    if not maxAntiFlingEnabled or isFlingingSingle or isFlingingAll or autoFarmEnabled or isSpinAuraEnabled then return end
    local char, hum, root = getCharacter()
    if not char or not root or not hum then return end

    local horizVel = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
    if horizVel.Magnitude > 120 then 
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) 
    end
    if root.AssemblyAngularVelocity.Magnitude > 120 then 
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) 
    end

    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end)

Rayfield:Notify({Title = "MM2 Ultimate V37.6", Content = "Скрипт полностью готов и запущен!", Duration = 4})
