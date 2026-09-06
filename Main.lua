local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local oldGui = CoreGui:FindFirstChild("SaturnGui") or LocalPlayer.PlayerGui:FindFirstChild("SaturnGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SaturnGui"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer.PlayerGui end

-- Перетаскивание UI
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Open Button
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0, 115, 0, 32)
openBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
openBtn.Text = ""
openBtn.AutoButtonColor = false
openBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = openBtn

local blueLine = Instance.new("Frame")
blueLine.Name = "BlueLine"
blueLine.Size = UDim2.new(0, 5, 0.7, 0)
blueLine.Position = UDim2.new(0, 6, 0.15, 0)
blueLine.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
blueLine.BorderSizePixel = 0
blueLine.Parent = openBtn

local lineCorner = Instance.new("UICorner")
lineCorner.CornerRadius = UDim.new(0, 4)
lineCorner.Parent = blueLine

local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, -20, 1, 0)
btnText.Position = UDim2.new(0, 18, 0, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "Saturn"
btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
btnText.Font = Enum.Font.SourceSansBold
btnText.TextSize = 20
btnText.TextXAlignment = Enum.TextXAlignment.Left
btnText.Parent = openBtn

makeDraggable(openBtn)

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 480, 0, 310)
mainWindow.Position = UDim2.new(0.5, -240, 0.4, -155)
mainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainWindow.BorderSizePixel = 0
mainWindow.ClipsDescendants = false
mainWindow.Visible = false
mainWindow.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainWindow

-- Left Sidebar
local sidePanel = Instance.new("Frame")
sidePanel.Name = "SidePanel"
sidePanel.Size = UDim2.new(0, 100, 1, -16)
sidePanel.Position = UDim2.new(0, 8, 0, 8)
sidePanel.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
sidePanel.BorderSizePixel = 0
sidePanel.Parent = mainWindow

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 8)
sideCorner.Parent = sidePanel

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -12, 0, 30)
titleLabel.Position = UDim2.new(0, 8, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Saturn"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = sidePanel

local tabHolder = Instance.new("Frame")
tabHolder.Name = "TabHolder"
tabHolder.Size = UDim2.new(1, -16, 1, -45)
tabHolder.Position = UDim2.new(0, 8, 0, 40)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = sidePanel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabHolder

-- Вкладки
local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Name = "MainTabBtn"
mainTabBtn.Size = UDim2.new(1, 0, 0, 24)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
mainTabBtn.Text = "Main"
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabBtn.Font = Enum.Font.SourceSansBold
mainTabBtn.TextSize = 13
mainTabBtn.LayoutOrder = 1
mainTabBtn.Parent = tabHolder

local mainTabBtnCorner = Instance.new("UICorner")
mainTabBtnCorner.CornerRadius = UDim.new(0, 5)
mainTabBtnCorner.Parent = mainTabBtn

local visualTabBtn = Instance.new("TextButton")
visualTabBtn.Name = "VisualTabBtn"
visualTabBtn.Size = UDim2.new(1, 0, 0, 24)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
visualTabBtn.Text = "Visual"
visualTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
visualTabBtn.Font = Enum.Font.SourceSansBold
visualTabBtn.TextSize = 13
visualTabBtn.LayoutOrder = 2
visualTabBtn.Parent = tabHolder

local visualTabBtnCorner = Instance.new("UICorner")
visualTabBtnCorner.CornerRadius = UDim.new(0, 5)
visualTabBtnCorner.Parent = visualTabBtn

-- Container for Pages
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -122, 1, -16)
container.Position = UDim2.new(0, 114, 0, 8)
container.BackgroundTransparency = 1
container.Parent = mainWindow

local mainPage = Instance.new("Frame")
mainPage.Name = "MainPage"
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = container

local visualPage = Instance.new("Frame")
visualPage.Name = "VisualPage"
visualPage.Size = UDim2.new(1, 0, 1, 0)
visualPage.BackgroundTransparency = 1
visualPage.Visible = false
visualPage.Parent = container

mainTabBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = true
    visualPage.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    visualTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
end)

visualTabBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    visualPage.Visible = true
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    visualTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    mainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
end)

-- ESP Section
local espSection = Instance.new("Frame")
espSection.Name = "ESPSection"
espSection.Size = UDim2.new(0, 170, 1, 0)
espSection.Position = UDim2.new(0, 0, 0, 0)
espSection.BackgroundTransparency = 1
espSection.Parent = mainPage

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(1, 0, 0, 18)
espLabel.Position = UDim2.new(0, 0, 0, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
espLabel.Font = Enum.Font.SourceSansBold
espLabel.TextSize = 14
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = espSection

local espBox = Instance.new("Frame")
espBox.Name = "ESPBox"
espBox.Size = UDim2.new(1, 0, 1, -22)
espBox.Position = UDim2.new(0, 0, 0, 22)
espBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
espBox.BorderSizePixel = 0
espBox.Parent = espSection

local espBoxCorner = Instance.new("UICorner")
espBoxCorner.CornerRadius = UDim.new(0, 8)
espBoxCorner.Parent = espBox

local espList = Instance.new("UIListLayout")
espList.FillDirection = Enum.FillDirection.Vertical
espList.SortOrder = Enum.SortOrder.LayoutOrder
espList.Padding = UDim.new(0, 5)
espList.Parent = espBox

local espPadding = Instance.new("UIPadding")
espPadding.PaddingTop = UDim.new(0, 8)
espPadding.PaddingLeft = UDim.new(0, 8)
espPadding.PaddingRight = UDim.new(0, 8)
espPadding.Parent = espBox

-- Combat Section
local combatSection = Instance.new("Frame")
combatSection.Name = "CombatSection"
combatSection.Size = UDim2.new(0, 170, 1, 0)
combatSection.Position = UDim2.new(0, 180, 0, 0)
combatSection.BackgroundTransparency = 1
combatSection.Parent = mainPage

local combatLabel = Instance.new("TextLabel")
combatLabel.Size = UDim2.new(1, 0, 0, 18)
combatLabel.Position = UDim2.new(0, 0, 0, 0)
combatLabel.BackgroundTransparency = 1
combatLabel.Text = "Combat"
combatLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
combatLabel.Font = Enum.Font.SourceSansBold
combatLabel.TextSize = 14
combatLabel.TextXAlignment = Enum.TextXAlignment.Left
combatLabel.Parent = combatSection

local combatBox = Instance.new("Frame")
combatBox.Name = "CombatBox"
combatBox.Size = UDim2.new(1, 0, 1, -22)
combatBox.Position = UDim2.new(0, 0, 0, 22)
combatBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
combatBox.BorderSizePixel = 0
combatBox.Parent = combatSection

local combatBoxCorner = Instance.new("UICorner")
combatBoxCorner.CornerRadius = UDim.new(0, 8)
combatBoxCorner.Parent = combatBox

local combatList = Instance.new("UIListLayout")
combatList.FillDirection = Enum.FillDirection.Vertical
combatList.SortOrder = Enum.SortOrder.LayoutOrder
combatList.Padding = UDim.new(0, 5)
combatList.Parent = combatBox

local combatPadding = Instance.new("UIPadding")
combatPadding.PaddingTop = UDim.new(0, 8)
combatPadding.PaddingLeft = UDim.new(0, 8)
combatPadding.PaddingRight = UDim.new(0, 8)
combatPadding.Parent = combatBox

-- Role Colors
local roleColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
    Default = Color3.fromRGB(200, 200, 200)
}

-- Toggle Switch
local function createToggle(name, parent, layoutOrder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -36, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(180, 180, 190)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switchTrack = Instance.new("TextButton")
    switchTrack.Size = UDim2.new(0, 32, 0, 16)
    switchTrack.Position = UDim2.new(1, -32, 0.5, -8)
    switchTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    switchTrack.Text = ""
    switchTrack.AutoButtonColor = false
    switchTrack.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = switchTrack

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 12, 0, 12)
    ball.Position = UDim2.new(0, 2, 0.5, -6)
    ball.BackgroundColor3 = Color3.fromRGB(160, 160, 170)
    ball.BorderSizePixel = 0
    ball.Parent = switchTrack

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball

    local state = false
    switchTrack.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(switchTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            TweenService:Create(ball, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(switchTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            TweenService:Create(ball, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(160, 160, 170)}):Play()
        end
        callback(state)
    end)
    return frame
end

local function getRoles()
    local getPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not getPlayerData then return {} end
    local data = getPlayerData:InvokeServer()
    local roles = {}
    for plr, plrData in pairs(data) do
        if not plrData.Dead then
            roles[plr] = plrData.Role
        end
    end
    return roles
end

-- ESP Players
createToggle("ESP Players", espBox, 1, function(Value)
    _G.ESP_ENABLED = Value
    if not Value then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head and head:FindFirstChild("RoleESP") then head.RoleESP:Destroy() end
                local hl = player.Character:FindFirstChild("RoleHighlight")
                if hl then hl:Destroy() end
            end
        end
    else
        task.spawn(function()
            while _G.ESP_ENABLED do
                local roles = getRoles()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local role = roles[player.Name] or "Default"
                            local esp = head:FindFirstChild("RoleESP")
                            if not esp then
                                esp = Instance.new("BillboardGui")
                                esp.Name = "RoleESP"
                                esp.Adornee = head
                                esp.Size = UDim2.new(5, 0, 5, 0)
                                esp.AlwaysOnTop = true
                                esp.Parent = head
                                local label = Instance.new("TextLabel", esp)
                                label.Name = "RoleLabel"
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.TextStrokeTransparency = 0
                                label.TextSize = 12
                                label.Font = Enum.Font.SourceSansBold
                            end
                            local label = esp:FindFirstChild("RoleLabel")
                            if label then
                                label.Text = string.format("%s (%s)", player.Name, role)
                                label.TextColor3 = roleColors[role] or roleColors.Default
                            end

                            local hl = player.Character:FindFirstChild("RoleHighlight")
                            if not hl then
                                hl = Instance.new("Highlight", player.Character)
                                hl.Name = "RoleHighlight"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.FillTransparency = 0.4
                                hl.OutlineTransparency = 0
                            end
                            hl.FillColor = roleColors[role] or roleColors.Default
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

-- ESP Gun
createToggle("ESP Gun", espBox, 2, function(Value)
    _G.GunEsp = Value
    if not Value then
        local gun = Workspace:FindFirstChild("GunDrop", true)
        if gun then
            if gun:FindFirstChild("GunHighlight") then gun.GunHighlight:Destroy() end
            if gun:FindFirstChild("GunEsp") then gun.GunEsp:Destroy() end
        end
    else
        task.spawn(function()
            while _G.GunEsp do
                local gun = Workspace:FindFirstChild("GunDrop", true)
                if gun then
                    if not gun:FindFirstChild("GunHighlight") then
                        local gunh = Instance.new("Highlight", gun)
                        gunh.Name = "GunHighlight"
                        gunh.FillColor = Color3.new(1, 1, 0)
                        gunh.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        gunh.FillTransparency = 0.4
                    end
                    if not gun:FindFirstChild("GunEsp") then
                        local esp = Instance.new("BillboardGui", gun)
                        esp.Name = "GunEsp"
                        esp.Adornee = gun
                        esp.Size = UDim2.new(5, 0, 5, 0)
                        esp.AlwaysOnTop = true
                        local text = Instance.new("TextLabel", esp)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.TextStrokeTransparency = 0
                        text.TextColor3 = Color3.fromRGB(255, 255, 0)
                        text.Font = Enum.Font.SourceSansBold
                        text.TextSize = 14
                        text.Text = "Gun Drop"
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

-- Xray
local xrayOriginals = {}
createToggle("Xray", espBox, 3, function(Value)
    if Value then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                if obj.LocalTransparencyModifier == 0 then
                    xrayOriginals[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = 0.65
                end
            end
        end
    else
        for obj, orig in pairs(xrayOriginals) do
            if obj and obj.Parent then
                obj.LocalTransparencyModifier = orig
            end
        end
        xrayOriginals = {}
    end
end)

-- Color Inputs
local function createColorInput(roleName, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = espBox

    local txt = Instance.new("TextBox")
    txt.Size = UDim2.new(1, -26, 1, 0)
    txt.Position = UDim2.new(0, 0, 0, 0)
    txt.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    txt.TextColor3 = Color3.fromRGB(220, 220, 220)
    txt.Text = roleName .. " #"
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 11
    txt.Parent = frame

    local txtC = Instance.new("UICorner")
    txtC.CornerRadius = UDim.new(0, 4)
    txtC.Parent = txt

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 20, 0, 20)
    preview.Position = UDim2.new(1, -20, 0, 1)
    preview.BackgroundColor3 = roleColors[roleName] or Color3.fromRGB(250, 250, 250)
    preview.BorderSizePixel = 0
    preview.Parent = frame

    local prevC = Instance.new("UICorner")
    prevC.CornerRadius = UDim.new(0, 4)
    prevC.Parent = preview

    txt.FocusLost:Connect(function()
        local hex = txt.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                local c = Color3.fromRGB(r, g, b)
                roleColors[roleName] = c
                preview.BackgroundColor3 = c
            end
        end
    end)
end

createColorInput("Murderer", 4)
createColorInput("Sheriff", 5)
createColorInput("Hero", 6)
createColorInput("Innocent", 7)

-- ==========================================
-- SILENT AIM & WALLSHOT LOGIC VIA HOOK
-- ==========================================
_G.SilentAimEnabled = false
_G.WallshotEnabled = false

-- Поиск Мардера (для Шерифа)
local function getMurdererPart()
    local rigs = Workspace:FindFirstChild("Rigs")
    if rigs and rigs:FindFirstChild("Murderer") then
        local m = rigs.Murderer
        return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("UpperTorso")
    end

    local roles = getRoles()
    for plrName, role in pairs(roles) do
        if role == "Murderer" then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character then
                return plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso")
            end
        end
    end
    return nil
end

-- Поиск Приоритетной Цели (Шериф / Герой / Ближайший) (для Мардера)
local function getKnifeTargetPart()
    local roles = getRoles()
    local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero

    -- Приоритет 1: Шериф или Герой
    for plrName, role in pairs(roles) do
        if (role == "Sheriff" or role == "Hero") and plrName ~= LocalPlayer.Name then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character then
                local part = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("UpperTorso")
                if part then return part end
            end
        end
    end

    -- Приоритет 2: Ближайший живой игрок
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

-- Предикшн движения цели
local function getPredictedPosition(targetPart)
    if not targetPart or not targetPart.Parent then return nil end

    local targetPos = targetPart.Position
    local targetVelocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.zero
    
    if targetVelocity.Magnitude < 0.5 then
        return targetPos
    end

    return targetPos + (targetVelocity * 0.2)
end

createToggle("Silent Aim", combatBox, 1, function(Value)
    _G.SilentAimEnabled = Value
end)

createToggle("Wallshot", combatBox, 2, function(Value)
    _G.WallshotEnabled = Value
end)

-- Перехват выстрела пистолета и броска ножа
local isCustomFiring = false
local rawNamecall

rawNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "fireServer") and _G.SilentAimEnabled and not isCustomFiring then
        -- 1. СТРЕЛЬБА ИЗ ПИСТОЛЕТА (Шериф)
        if self.Name == "Shoot" then
            local targetPart = getMurdererPart()
            local predictedPos = getPredictedPosition(targetPart)
            
            if predictedPos then
                isCustomFiring = true
                
                local originalOrigin = args[1]
                local finalOriginCFrame = originalOrigin
                local targetCFrame = CFrame.new(predictedPos)

                -- Логика Wallshot для огнестрела
                if _G.WallshotEnabled then
                    local myPos = (originalOrigin and originalOrigin.Position) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero
                    local fireDir = (predictedPos - myPos).Unit
                    if fireDir.Magnitude == 0 then fireDir = Vector3.new(0, 0, -1) end
                    
                    -- Смещение точки спавна пули прямо перед врагом (за стеной)
                    local wallshotOriginPos = predictedPos - (fireDir * 2)
                    finalOriginCFrame = CFrame.new(wallshotOriginPos, predictedPos)
                end

                self:FireServer(finalOriginCFrame, targetCFrame)
                isCustomFiring = false
                return nil
            end

        -- 2. БРОСОК НОЖА (Мардер)
        elseif self.Name == "KnifeThrown" then
            local targetPart = getKnifeTargetPart()
            local predictedPos = getPredictedPosition(targetPart)

            if predictedPos then
                isCustomFiring = true

                local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero
                local throwDir = (predictedPos - myPos).Unit
                if throwDir.Magnitude == 0 then throwDir = Vector3.new(0, 0, -1) end

                -- Логика Wallshot для броска ножа
                local originPos = myPos
                if _G.WallshotEnabled then
                    originPos = predictedPos - (throwDir * 2)
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

-- Asset Image
local assetImage = Instance.new("ImageLabel")
assetImage.Name = "MimiAsset"
assetImage.Size = UDim2.new(0, 130, 0, 130)
assetImage.Position = UDim2.new(1, -140, 0, -130)
assetImage.BackgroundTransparency = 1
assetImage.ZIndex = 10
assetImage.Parent = mainWindow

task.spawn(function()
    local assetId = "17735982342"
    local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png"
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            local imageUrl = data.data[1].imageUrl
            if getcustomasset and writefile then
                local fileName = "mimi_asset_cache.png"
                pcall(function()
                    writefile(fileName, game:HttpGet(imageUrl))
                    assetImage.Image = getcustomasset(fileName)
                end)
            else
                assetImage.Image = imageUrl
            end
            return
        end
    end

    assetImage.Image = "rbxassetid://" .. assetId
end)

makeDraggable(mainWindow)

openBtn.MouseButton1Click:Connect(function()
    mainWindow.Visible = not mainWindow.Visible
end)

print("Saturn GUI loaded successfully!")
