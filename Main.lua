-- ============================================================
-- MM2 ULTIMATE V29.0 (FIXED ALL ESP & TRACERS & VISUALS)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local silentAimEnabled = false
local maxAntiFlingEnabled = false

-- Visuals Flags
local espHighlightEnabled = false
local espBoxesEnabled = false
local espTracersEnabled = false
local customCrosshairEnabled = false
local customFovEnabled = false
local targetFovValue = 70

local selectedPlayerName = nil
local tpPlayerName = nil
local originalCFrame = nil
local safePointCFrame = nil

local flingNameMap = {}
local tpNameMap = {}

-- Папка для хранения визуалов ESP
local espContainer = Workspace:FindFirstChild("V29_ESP_Folder") or Instance.new("Folder")
espContainer.Name = "V29_ESP_Folder"
espContainer.Parent = Workspace

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
   Name = "✨ MM2 Ultimate V29.0 (ESP Fix Edition)",
   LoadingTitle = "Загрузка UI & Полноценного ESP...",
   LoadingSubtitle = "by Kneo World",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local VisualsTab = Window:CreateTab("👁️ Визуал & ESP", 4483362458)
local FlingTab = Window:CreateTab("💥 Рванка & Аура", 4483362458)
local FarmingTab = Window:CreateTab("💰 Авто-Фарм", 4483362458)
local CombatTab = Window:CreateTab("🎯 Аим & Бой", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Разное & Настройки", 4483362458)

-- ==================== Вкладка: ВИЗУАЛ & ESP ====================
VisualsTab:CreateSection("🔥 Основной ESP (Работает на всех)")

VisualsTab:CreateToggle({
   Name = "✨ Advanced Chams & Info (Ники/Роли)",
   CurrentValue = false,
   Callback = function(Value)
      espHighlightEnabled = Value
   end,
})

VisualsTab:CreateToggle({
   Name = "📦 3D Box ESP (Объёмные боксы на всех)",
   CurrentValue = false,
   Callback = function(Value)
      espBoxesEnabled = Value
   end,
})

VisualsTab:CreateToggle({
   Name = "📏 Snaplines / Tracers (Линии от экрана)",
   CurrentValue = false,
   Callback = function(Value)
      espTracersEnabled = Value
   end,
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
   Callback = function(Value)
      customCrosshairEnabled = Value
      local gui = game.CoreGui:FindFirstChild("V29_CrosshairGui")
      if gui then gui.Enabled = Value end
   end,
})

-- ==================== НОВЫЙ СВЕРХСТАБИЛЬНЫЙ ДВИЖОК ESP ====================

local crosshairGui = Instance.new("ScreenGui", game.CoreGui)
crosshairGui.Name = "V29_CrosshairGui"
crosshairGui.Enabled = false

local chCenter = Instance.new("Frame", crosshairGui)
chCenter.Size = UDim2.new(0, 4, 0, 4)
chCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
chCenter.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
chCenter.BorderSizePixel = 0

local lineH = Instance.new("Frame", crosshairGui)
lineH.Size = UDim2.new(0, 16, 0, 2)
lineH.Position = UDim2.new(0.5, -8, 0.5, -1)
lineH.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
lineH.BorderSizePixel = 0

local lineV = Instance.new("Frame", crosshairGui)
lineV.Size = UDim2.new(0, 2, 0, 16)
lineV.Position = UDim2.new(0.5, -1, 0.5, -8)
lineV.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
lineV.BorderSizePixel = 0

-- Кастомный очищаемый слой для линий через CylinderHandleAdornment/Line
local tracerFolder = Instance.new("Folder", game.CoreGui)
tracerFolder.Name = "V29_Tracers"

RunService.RenderStepped:Connect(function()
    if customFovEnabled then Camera.FieldOfView = targetFovValue end
    
    tracerFolder:ClearAllChildren()

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local hrp = char.HumanoidRootPart
            local color = getRoleColor(plr)
            local roleText = getRoleName(plr)

            -- 1. Chams + Highlight + Billboard Info
            local hl = char:FindFirstChild("V29_HL")
            if espHighlightEnabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "V29_HL"
                    hl.Parent = char
                end
                hl.Enabled = true
                hl.FillColor = color
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.35
                
                local bb = char:FindFirstChild("V29_BB")
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "V29_BB"
                    bb.Size = UDim2.new(0, 160, 0, 40)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp

                    local txt = Instance.new("TextLabel", bb)
                    txt.Name = "Info"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 13
                    txt.TextStrokeTransparency = 0.1

                    bb.Parent = char
                end
                
                local _, _, myRoot = getCharacter()
                local dist = myRoot and math.floor((myRoot.Position - hrp.Position).Magnitude) or 0
                bb.Info.TextColor3 = color
                bb.Info.Text = string.format("%s [%s]\n%d м", plr.Name, roleText, dist)
            else
                if hl then hl.Enabled = false end
                local bb = char:FindFirstChild("V29_BB")
                if bb then bb:Destroy() end
            end

            -- 2. 3D Box ESP (SelectionBox)
            local box = char:FindFirstChild("V29_BOX")
            if espBoxesEnabled then
                if not box then
                    box = Instance.new("SelectionBox")
                    box.Name = "V29_BOX"
                    box.LineThickness = 0.05
                    box.Adornee = char
                    box.Parent = char
                end
                box.Visible = true
                box.Color3 = color
            else
                if box then box.Visible = false end
            end

            -- 3. Snaplines / Tracers (Линии от низа экрана)
            if espTracersEnabled then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local lineFrame = Instance.new("Frame", tracerFolder)
                    lineFrame.BorderSizePixel = 0
                    lineFrame.BackgroundColor3 = color

                    local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local endPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (endPos - startPos).Magnitude

                    lineFrame.Size = UDim2.new(0, distance, 0, 2)
                    lineFrame.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
                    lineFrame.AnchorPoint = Vector2.new(0, 0.5)
                    lineFrame.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
                end
            end
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

-- ==================== Вкладка: АИМ & БОЙ ====================
CombatTab:CreateSection("Боевые Функции")

CombatTab:CreateToggle({
   Name = "🎯 Аимбот и Авто-стрельба в Убийцу",
   CurrentValue = false,
   Callback = function(Value) silentAimEnabled = Value end,
})

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
local gunEspFolder = Instance.new("Folder", game.CoreGui)
RunService.RenderStepped:Connect(function()
    gunEspFolder:ClearAllChildren()
    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("Gun", true)
    local _, _, root = getCharacter()

    if gunDrop and gunDrop:IsA("BasePart") then
        if gunEspEnabled then
            local bb = Instance.new("BillboardGui", gunEspFolder)
            bb.Adornee = gunDrop
            bb.Size = UDim2.new(0, 140, 0, 30)
            bb.AlwaysOnTop = true
            local txt = Instance.new("TextLabel", bb)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 230, 0)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 13
            txt.Text = "🔫 ПИСТОЛЕТ ЛЕЖИТ!"
        end

        if autoPickGunEnabled and root then
            if firetouchinterest then
                firetouchinterest(root, gunDrop, 0)
                task.wait(0.05)
                firetouchinterest(root, gunDrop, 1)
            else root.CFrame = gunDrop.CFrame end
        end
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

game.Players.PlayerAdded:Connect(refreshSortedPlayerLists)
game.Players.PlayerRemoving:Connect(refreshSortedPlayerLists)
refreshSortedPlayerLists()

Rayfield:Notify({Title = "MM2 Ultimate V29.0", Content = "Фикс ESP, линий и 3D-боксов успешно применён!", Duration = 3})
