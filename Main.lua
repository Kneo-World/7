-- ============================================================
-- MM2 ULTIMATE V31.0 (FPS AIMBOT FOR SHERIFF + DRAWING ESP)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

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

-- AIMBOT SYSTEM VARIABLES
local aimbotEnabled = false
local aimbotAutoShoot = false
local aimbotWallCheck = true
local aimbotShowFov = true
local aimbotFovRadius = 150
local aimbotSmoothness = 0.25 -- 0.05 (очень плавно) ... 1 (мгновенно)
local aimbotTargetPart = "Head" -- "Head" или "HumanoidRootPart"

local selectedPlayerName = nil
local tpPlayerName = nil
local originalCFrame = nil
local safePointCFrame = nil

local flingNameMap = {}
local tpNameMap = {}

-- ========== Вспомогательные функции ==========
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char, char.Humanoid, char.HumanoidRootPart
    end
    return nil, nil, nil
end

local function getRoleColor(plr)
    if not plr or not plr.Character then return Color3.fromRGB(0, 255, 120) end
    if plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 35, 35) -- Murderer (Красный)
    elseif plr.Character:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
        return Color3.fromRGB(35, 135, 255) -- Sheriff (Синий)
    end
    return Color3.fromRGB(0, 255, 120) -- Innocent (Зелёный)
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
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
                return plr
            end
        end
    end
    return nil
end

-- ========== ДВИЖОК РВАНКИ ==========
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
            heartConn:Disconnect() 
            steppedConn:Disconnect() 
            emergencyStop() 
            return
        end
        
        local currentTarget = getTargetFunc()
        local targetRoot = currentTarget and currentTarget.Character and (currentTarget.Character:FindFirstChild("HumanoidRootPart") or currentTarget.Character:FindFirstChild("Torso"))
        
        if targetRoot and currentRoot then
            angle = (angle + 100) % 360
            local targetVel = targetRoot.AssemblyLinearVelocity
            local predictedPos = targetRoot.Position + (targetVel * 0.15)
            local offset = Vector3.new(math.cos(math.rad(angle)) * 1.5, 0, math.sin(math.rad(angle)) * 1.5)
            
            currentRoot.CFrame = CFrame.new(predictedPos + offset)
            currentRoot.AssemblyLinearVelocity = (angle % 20 == 0) and Vector3.new(999999, 999999, 999999) or Vector3.new(0, 999999, 0)
            currentRoot.AssemblyAngularVelocity = Vector3.new(999999, 999999, 999999)
        end
    end)
end

-- ========== ОКНО RAYFIELD ==========
local Window = Rayfield:CreateWindow({
   Name = "✨ MM2 Ultimate V31.0 (FPS Aimbot & Direct Render)",
   LoadingTitle = "Загрузка UI, Aimbot & ESP...",
   LoadingSubtitle = "by Kneo World",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("🎯 FPS Аимбот & Бой", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Визуал & ESP", 4483362458)
local FlingTab = Window:CreateTab("💥 Рванка & Аура", 4483362458)
local FarmingTab = Window:CreateTab("💰 Авто-Фарм", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Разное & Настройки", 4483362458)

-- ==================== Вкладка: АИМБОТ & БОЙ ====================
CombatTab:CreateSection("🎯 FPS Аимбот на Убийцу (Включение на N)")

local aimToggle = CombatTab:CreateToggle({
   Name = "🎯 Аимбот Активирован [Клавиша N]",
   CurrentValue = false,
   Callback = function(Value) 
      aimbotEnabled = Value 
   end,
})

CombatTab:CreateDropdown({
   Name = "🎯 Цель Прицеливания",
   Options = {"Голова (Head)", "Торс (HumanoidRootPart)"},
   CurrentOption = {"Голова (Head)"},
   MultipleOptions = false,
   Callback = function(Option)
      if Option[1] == "Голова (Head)" then
         aimbotTargetPart = "Head"
      else
         aimbotTargetPart = "HumanoidRootPart"
      end
   end,
})

CombatTab:CreateSlider({
   Name = "⚡ Плавность Наведения (Smoothness)",
   Range = {5, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 25,
   Callback = function(Value)
      aimbotSmoothness = Value / 100
   end,
})

CombatTab:CreateSlider({
   Name = "⭕ Радиус FOV Аимбота",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Callback = function(Value)
      aimbotFovRadius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "⭕ Показывать Круг FOV",
   CurrentValue = true,
   Callback = function(Value) aimbotShowFov = Value end,
})

CombatTab:CreateToggle({
   Name = "🧱 Проверка Стен (Wall Check)",
   CurrentValue = true,
   Callback = function(Value) aimbotWallCheck = Value end,
})

CombatTab:CreateToggle({
   Name = "🔫 Авто-Выстрел при наведении",
   CurrentValue = false,
   Callback = function(Value) aimbotAutoShoot = Value end,
})

CombatTab:CreateSection("🔪 Дополнительный Бой")

CombatTab:CreateButton({
   Name = "🔪 KILL ALL (Убить всех за Мардера)",
   Callback = function()
      local char, hum, root = getCharacter()
      if not char then return end

      local knife = char:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife"))
      if not knife then
          Rayfield:Notify({Title = "Ошибка", Content = "Ты не Убийца!", Duration = 2})
          return
      end

      if knife.Parent ~= char then hum:EquipTool(knife) task.wait(0.1) end
      local oldPos = root.CFrame

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
   end,
})

-- Переключение Аимбота на клавишу N
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        aimbotEnabled = not aimbotEnabled
        aimToggle:Set(aimbotEnabled)
        Rayfield:Notify({
            Title = "Аимбот",
            Content = aimbotEnabled and "🎯 Аимбот ВКЛЮЧЁН (Клавиша N)" or "🚫 Аимбот ВЫКЛЮЧЁН (Клавиша N)",
            Duration = 1.5
        })
    end
end)

-- ДВИЖОК АИМБОТА И КРУГА FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.NumSides = 32

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = mousePos
    fovCircle.Radius = aimbotFovRadius
    fovCircle.Visible = aimbotEnabled and aimbotShowFov

    if not aimbotEnabled then return end

    local murderer = getMurderer()
    if not murderer or not murderer.Character then return end

    local targetPart = murderer.Character:FindFirstChild(aimbotTargetPart) or murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return end

    local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    if distToMouse > aimbotFovRadius then return end

    -- Wall Check (Проверка препятствий)
    if aimbotWallCheck then
        local myChar = player.Character
        if myChar then
            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
            local ignoreList = {myChar, murderer.Character}
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
            if hit and not hit:IsDescendantOf(murderer.Character) then return end
        end
    end

    -- Плавный поворот камеры на цель (FPS Smooth Aimbot)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimbotSmoothness)

    -- Авто-выстрел за Шерифа
    if aimbotAutoShoot then
        local char, hum, _ = getCharacter()
        local gun = char and char:FindFirstChild("Gun")
        if gun then
            gun:Activate()
        end
    end
end)

-- ==================== Вкладка: ВИЗУАЛ & ESP ====================
VisualsTab:CreateSection("🔥 Drawing ESP (Прямой рендер поверх экрана)")

VisualsTab:CreateToggle({
   Name = "📜 Имена + Роли + Дистанция",
   CurrentValue = false,
   Callback = function(Value) espInfoEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "📦 2D / 3D Боксы (Boxes)",
   CurrentValue = false,
   Callback = function(Value) espBoxesEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "📏 Snaplines / Tracers (Линии к игрокам)",
   CurrentValue = false,
   Callback = function(Value) espTracersEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "🔫 Drop Gun ESP & Marker",
   CurrentValue = false,
   Callback = function(Value) gunEspEnabled = Value end,
})

VisualsTab:CreateSection("🎨 Графика и Камера")

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

VisualsTab:CreateToggle({
   Name = "🎯 Кастомный Крестик (Crosshair)",
   CurrentValue = false,
   Callback = function(Value) customCrosshairEnabled = Value end,
})

-- ==================== ПРЯМОЙ DRAWING ESP ДВИЖОК ====================
local ESP_Objects = {}

local function createEspForPlayer(plr)
    if plr == player then return end
    
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

for _, plr in ipairs(game.Players:GetPlayers()) do
    createEspForPlayer(plr)
end

game.Players.PlayerAdded:Connect(createEspForPlayer)
game.Players.PlayerRemoving:Connect(removeEspForPlayer)

-- Кастомный прицел
local crossLineH = Drawing.new("Line")
local crossLineV = Drawing.new("Line")
crossLineH.Thickness = 2
crossLineH.Color = Color3.fromRGB(0, 255, 200)
crossLineV.Thickness = 2
crossLineV.Color = Color3.fromRGB(0, 255, 200)

RunService.RenderStepped:Connect(function()
    if customFovEnabled then Camera.FieldOfView = targetFovValue end

    -- Отрисовка прицела
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    if customCrosshairEnabled then
        crossLineH.From = center - Vector2.new(8, 0)
        crossLineH.To = center + Vector2.new(8, 0)
        crossLineH.Visible = true

        crossLineV.From = center - Vector2.new(0, 8)
        crossLineV.To = center + Vector2.new(0, 8)
        crossLineV.Visible = true
    else
        crossLineH.Visible = false
        crossLineV.Visible = false
    end

    -- Отрисовка ESP
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

                -- Tracers
                if espTracersEnabled then
                    objs.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    objs.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    objs.Tracer.Color = color
                    objs.Tracer.Visible = true
                else objs.Tracer.Visible = false end

                -- Box
                if espBoxesEnabled then
                    local boxHeight = math.abs(headPos.Y - legPos.Y)
                    local boxWidth = boxHeight * 0.65
                    
                    objs.Box.Size = Vector2.new(boxWidth, boxHeight)
                    objs.Box.Position = Vector2.new(hrpPos.X - (boxWidth / 2), headPos.Y)
                    objs.Box.Color = color
                    objs.Box.Visible = true
                else objs.Box.Visible = false end

                -- Text Info
                if espInfoEnabled then
                    objs.Text.Position = Vector2.new(hrpPos.X, headPos.Y - 18)
                    objs.Text.Text = string.format("%s [%s] | %d m", plr.Name, roleText, dist)
                    objs.Text.Color = color
                    objs.Text.Visible = true
                else objs.Text.Visible = false end
            else
                objs.Tracer.Visible = false
                objs.Box.Visible = false
                objs.Text.Visible = false
            end
        else
            objs.Tracer.Visible = false
            objs.Box.Visible = false
            objs.Text.Visible = false
        end
    end
end)

-- ==================== Вкладка: РВАНКА & АУРА ====================
FlingTab:CreateSection("Управление Рванкой")

local playerDropdown = FlingTab:CreateDropdown({
   Name = "Выбрать игрока для рванки",
   Options = {"Загрузка..."},
   CurrentOption = {"Загрузка..."},
   MultipleOptions = false,
   Callback = function(Option) 
      selectedPlayerName = flingNameMap[Option[1]]
   end,
})

local tpDropdown = MiscTab:CreateDropdown({
   Name = "Выбрать игрока для Телепорта",
   Options = {"Загрузка..."},
   CurrentOption = {"Загрузка..."},
   MultipleOptions = false,
   Callback = function(Option) 
      tpPlayerName = tpNameMap[Option[1]]
   end,
})

local function refreshSortedPlayerLists()
    local murderers, sheriffs, innocents = {}, {}, {}
    flingNameMap, tpNameMap = {}, {}

    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
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

FlingTab:CreateToggle({
   Name = "💥 Рванка выбранного игрока (10 сек)",
   CurrentValue = false,
   Callback = function(Value)
      isFlingingSingle = Value
      if isFlingingSingle then
         local targetPlr = game.Players:FindFirstChild(selectedPlayerName or "")
         if targetPlr then
            startFlingLoop(function() return targetPlr end, function() return isFlingingSingle end, 10)
         else
            Rayfield:Notify({Title = "Ошибка", Content = "Сначала выберите игрока из списка!", Duration = 2})
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
   end,
})

FlingTab:CreateSection("Пассивная Защита & Крутилка")

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
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
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
   Callback = function(Value) 
      maxAntiFlingEnabled = Value
      local _, hum, _ = getCharacter()
      if hum then
          hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
          hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
      end
   end,
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
   Name = "⚡ Телепортироваться к выбранному игроку",
   Callback = function()
      local targetPlr = game.Players:FindFirstChild(tpPlayerName or "")
      local _, _, root = getCharacter()
      if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") and root then
          root.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
          Rayfield:Notify({Title = "Телепорт", Content = "ТП к " .. targetPlr.Name, Duration = 1.5})
      else
          Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока из списка!", Duration = 2})
      end
   end,
})

MiscTab:CreateSection("Движение и Физика")

MiscTab:CreateToggle({
   Name = "🐰 Bunny Hop",
   CurrentValue = false,
   Callback = function(Value) bunnyHopEnabled = Value end,
})

MiscTab:CreateToggle({
   Name = "🧲 Auto Pick Gun",
   CurrentValue = false,
   Callback = function(Value) autoPickGunEnabled = Value end,
})

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

MiscTab:CreateToggle({
   Name = "🛡️ Anti-Kill Safety",
   CurrentValue = false,
   Callback = function(Value) antiKillEnabled = Value end,
})

MiscTab:CreateToggle({
   Name = "🚶 Noclip",
   CurrentValue = false,
   Callback = function(Value) noclipEnabled = Value end,
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
gunEspText.Size = 16
gunEspText.Center = true
gunEspText.Outline = true
gunEspText.Color = Color3.fromRGB(255, 230, 0)
gunEspText.Visible = false

RunService.RenderStepped:Connect(function()
    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("Gun", true)
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

Rayfield:Notify({Title = "MM2 Ultimate V31.0", Content = "FPS Аимбот готов! Нажми 'N' для включения/выключения.", Duration = 4})
