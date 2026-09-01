-- ============================================================
-- MM2 ULTIMATE V27.2 (RAYFIELD EDITION + HIGHLIGHT & AURA)
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== Переменные состояний ==========
local isFlingingSingle = false
local isFlingingAll = false
local isSpinAuraEnabled = false
local bunnyHopEnabled = false
local espEnabled = false
local autoFarmEnabled = false
local autoPickGunEnabled = false
local gunEspEnabled = false
local ghostModeEnabled = false
local antiKillEnabled = false
local noclipEnabled = false
local silentAimEnabled = false
local maxAntiFlingEnabled = true

local selectedPlayerName = nil
local tpPlayerName = nil
local originalCFrame = nil
local safePointCFrame = nil
local lastShotTime = 0

-- ========== Вспомогательные функции ==========
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char, char.Humanoid, char.HumanoidRootPart
    end
    return nil, nil, nil
end

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

-- ========== ДВИЖОК РВАНКИ V27 ==========
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

-- ========== ОКНО И ВКЛАДКИ ==========
local Window = Rayfield:CreateWindow({
   Name = "⚡ MM2 Ultimate V27.2",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Kneo World",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local FlingTab = Window:CreateTab("💥 Рванка & Аура", 4483362458)
local FarmingTab = Window:CreateTab("💰 Авто-Фарм", 4483362458)
local CombatTab = Window:CreateTab("🎯 Аим & Бой", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Визуал & ESP", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Телепорт & Разное", 4483362458)

-- ==================== Вкладка: Рванка & Аура ====================
FlingTab:CreateSection("Активная Рванка")

local playerDropdown = FlingTab:CreateDropdown({
   Name = "Выбрать игрока для рванки",
   Options = {"Никого"},
   CurrentOption = {"Никого"},
   MultipleOptions = false,
   Callback = function(Option) selectedPlayerName = Option[1] end,
})

local function refreshPlayerLists()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then table.insert(names, p.Name) end
    end
    playerDropdown:Refresh(names)
end

FlingTab:CreateButton({
   Name = "🔄 Обновить списки игроков",
   Callback = function() refreshPlayerLists() end,
})

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
            Rayfield:Notify({Title = "Ошибка", Content = "Выберите игрока!", Duration = 2})
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
   Name = "🌪️ Крутилка-Аура (Ходишь нормально, касание = вылет)",
   CurrentValue = false,
   Callback = function(Value)
      isSpinAuraEnabled = Value
      if not isSpinAuraEnabled then
          local _, _, root = getCharacter()
          if root then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
      end
   end,
})

-- Логика Крутилки
RunService.Heartbeat:Connect(function()
    if not isSpinAuraEnabled or isFlingingSingle or isFlingingAll then return end
    local char, hum, root = getCharacter()
    if not root or not hum then return end

    -- Принудительное вращение физического тела
    root.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
    
    -- Разрешаем коллизии для соприкосновения
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end)

FlingTab:CreateButton({ Name = "🛑 ЭКСТРЕННЫЙ СТОП РВАНКИ", Callback = function() emergencyStop() end })

FlingTab:CreateToggle({
   Name = "🛡️ Max Anti-Fling (Защита от чужой рванки)",
   CurrentValue = true,
   Callback = function(Value) maxAntiFlingEnabled = Value end,
})

-- ==================== Вкладка: Авто-Фарм ====================
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
   Name = "💰 Auto Farm Coins (с авто-рванкой Убийцы при 40 монетах)",
   CurrentValue = false,
   Callback = function(Value) autoFarmEnabled = Value end,
})

-- ==================== Вкладка: Аим & Бой ====================
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

      local knife = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
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

-- ==================== Вкладка: Визуал & ESP ====================
VisualsTab:CreateSection("Подсветка Игроков (Highlight)")

VisualsTab:CreateToggle({
   Name = "👁️ Real Highlight ESP (Силуэты сквозь стены)",
   CurrentValue = false,
   Callback = function(Value)
      espEnabled = Value
      if not espEnabled then
         for _, p in ipairs(game.Players:GetPlayers()) do
             if p.Character then
                 local hl = p.Character:FindFirstChild("MM2_Highlight")
                 if hl then hl:Destroy() end
                 local bb = p.Character:FindFirstChild("MM2_NameESP")
                 if bb then bb:Destroy() end
             end
         end
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "🔫 Drop Gun ESP (Подсветка пистолета)",
   CurrentValue = false,
   Callback = function(Value) gunEspEnabled = Value end,
})

-- Цикл Highlight ESP
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- Определяем роль и цвет
                local color = Color3.fromRGB(0, 255, 100) -- Невинный (Зеленый)
                if char:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                    color = Color3.fromRGB(255, 0, 0) -- Мардер (Красный)
                elseif char:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                    color = Color3.fromRGB(0, 150, 255) -- Шериф (Синий)
                end

                -- Highlight (Силуэт)
                local hl = char:FindFirstChild("MM2_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "MM2_Highlight"
                    hl.Parent = char
                end
                hl.FillColor = color
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0

                -- Name & Distance Billboard
                local bb = char:FindFirstChild("MM2_NameESP")
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "MM2_NameESP"
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp
                    
                    local txt = Instance.new("TextLabel", bb)
                    txt.Name = "Text"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 11
                    txt.Parent = bb
                    bb.Parent = char
                end
                
                local _, _, myRoot = getCharacter()
                local dist = myRoot and math.floor((myRoot.Position - hrp.Position).Magnitude) or 0
                bb.Text.TextColor3 = color
                bb.Text.Text = plr.Name .. "\n[" .. dist .. "m]"
            end
        end
    end
end)

-- ==================== Вкладка: Телепорт & Разное ====================
MiscTab:CreateSection("Телепортация")

local tpDropdown = MiscTab:CreateDropdown({
   Name = "Выбрать игрока для ТП",
   Options = {"Никого"},
   CurrentOption = {"Никого"},
   MultipleOptions = false,
   Callback = function(Option) tpPlayerName = Option[1] end,
})

MiscTab:CreateButton({
   Name = "⚡ Телепортироваться к игроку",
   Callback = function()
      local targetPlr = game.Players:FindFirstChild(tpPlayerName or "")
      local _, _, root = getCharacter()
      if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") and root then
          root.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
          Rayfield:Notify({Title = "Телепорт", Content = "ТП к " .. targetPlr.Name, Duration = 1.5})
      else
          Rayfield:Notify({Title = "Ошибка", Content = "Игрок не найден!", Duration = 2})
      end
   end,
})

MiscTab:CreateSection("Движение и Физика")

MiscTab:CreateToggle({
   Name = "🐰 Bunny Hop (Авто-прыжки)",
   CurrentValue = false,
   Callback = function(Value) bunnyHopEnabled = Value end,
})

-- Логика Bunny Hop
RunService.RenderStepped:Connect(function()
    if bunnyHopEnabled then
        local char, hum, root = getCharacter()
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

MiscTab:CreateToggle({
   Name = "🧲 Auto Pick Gun (Автоподбор пистолета)",
   CurrentValue = false,
   Callback = function(Value) autoPickGunEnabled = Value end,
})

MiscTab:CreateToggle({
   Name = "👻 Invisible / Ghost Mode",
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
   Name = "🚶 Noclip (Сквозь стены)",
   CurrentValue = false,
   Callback = function(Value) noclipEnabled = Value end,
})

-- ==================== ОБРАБОТЧИКИ СОБЫТИЙ ====================

-- 1. Цикл Noclip & Бессмертие при автофарме
RunService.Stepped:Connect(function()
    if autoFarmEnabled then
        local char, hum = getCharacter()
        if char and hum then
            hum.Health = 100
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    
    if noclipEnabled then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- 2. Автофарм
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
                            end, nil
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
                                table.insert(coins, {part = obj, distance = (root.Position - obj.Position).Magnitude})
                            end
                        end
                    end
                    table.sort(coins, function(a, b) return a.distance < b.distance end)

                    if #coins > 0 and autoFarmEnabled then
                        local targetObj = coins[1].part
                        local targetPos = targetObj.Position - Vector3.new(0, 2.8, 0)
                        local flySpeed = 55

                        while autoFarmEnabled and targetObj.Parent and (root.Position - targetPos).Magnitude > 1.5 do
                            local _, currentHum, currentRoot = getCharacter()
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

-- 3. Aimbot
RunService.RenderStepped:Connect(function()
    if silentAimEnabled then
        local char, hum, root = getCharacter()
        if char and root then
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
        end
    end
end)

-- 4. Gun Drop ESP & Auto Pick
local gunEspFolder = Instance.new("Folder", game.CoreGui)
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
            txt.TextColor3 = Color3.fromRGB(255, 255, 0)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            txt.Text = "🔫 ПИСТОЛЕТ ЗДЕСЬ!"
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

-- 5. Anti-Kill Safety
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
                    if (root.Position - murdHrp.Position).Magnitude < 12 then
                        root.CFrame = root.CFrame + Vector3.new(0, 15, 0)
                    end
                end
            end
        end
    end
end)

-- 6. Max Anti-Fling Protect
RunService.Heartbeat:Connect(function()
    if not maxAntiFlingEnabled or isFlingingSingle or isFlingingAll or autoFarmEnabled or isSpinAuraEnabled then return end
    local char, hum, root = getCharacter()
    if not char or not root or not hum then return end

    if root.AssemblyLinearVelocity.Magnitude > 30 then root.AssemblyLinearVelocity = Vector3.new(0,0,0) end
    if root.AssemblyAngularVelocity.Magnitude > 30 then root.AssemblyAngularVelocity = Vector3.new(0,0,0) end

    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                if (root.Position - otherRoot.Position).Magnitude < 10 and (otherRoot.AssemblyLinearVelocity.Magnitude + otherRoot.AssemblyAngularVelocity.Magnitude) > 80 then
                    otherRoot.AssemblyLinearVelocity = Vector3.new(99999999, 99999999, 99999999)
                end
            end
        end
    end
end)

-- Автообновление списков при входе/выходе игроков
game.Players.PlayerAdded:Connect(refreshPlayerLists)
game.Players.PlayerRemoving:Connect(refreshPlayerLists)
refreshPlayerLists()

Rayfield:Notify({Title = "⚡ MM2 Ultimate V27.2", Content = "Все функции (Highlight ESP, Аура, ТП, BHop) готовы!", Duration = 4})
