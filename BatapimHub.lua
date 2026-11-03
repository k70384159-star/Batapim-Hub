print("Batapim Hub - PUMPKIN FARM loaded!")
--// BATAPIM HUB - PUMPKIN FARM
--// Повторный подбор до 3 раз

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- НАСТРОЙКИ
local SEARCH_RADIUS = 350
local STOP_DISTANCE = 3
local SCAN_DELAY = 0.35
local CAMERA_HEIGHT = 25
local TOOL_NUMBER = 4

local MAX_PICKUP_ATTEMPTS = 3
local RETRY_DELAY = 1

local running = false
local autoReset = true
local selectedTool = nil
local wasErrorVisible = false
local destroyed = false
local oldCamera = nil

-- НАЗВАНИЯ ЦЕЛЕЙ
local TARGET_NAMES = {
    ["Skull Lucky Block (2/2)"] = true,
    ["Skull Lucky Block (1/2)"] = true,

    ["Money Money Cat (3/3)"] = true,
    ["Money Money Cat (2/3)"] = true,
    ["Money Money Cat (1/3)"] = true,

    ["Fang Fang Draculang (3/3)"] = true,
    ["Fang Fang Draculang (2/3)"] = true,
    ["Fang Fang Draculang (1/3)"] = true,

    ["Pum Pum Pum (4/4)"] = true,
    ["Pum Pum Pum (3/4)"] = true,
    ["Pum Pum Pum (2/4)"] = true,
    ["Pum Pum Pum (1/4)"] = true,

    ["Spooketti Tualetti (5/5)"] = true,
    ["Spooketti Tualetti (4/5)"] = true,
    ["Spooketti Tualetti (3/5)"] = true,
    ["Spooketti Tualetti (2/5)"] = true,
    ["Spooketti Tualetti (1/5)"] = true,

    ["Spooky Spooky Sahur (4/4)"] = true,
    ["Spooky Spooky Sahur (3/4)"] = true,
    ["Spooky Spooky Sahur (2/4)"] = true,
    ["Spooky Spooky Sahur (1/4)"] = true
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BatapimHub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 300)
main.Position = UDim2.new(0.5, -150, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(22, 27, 32)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(69, 170, 104)
stroke.Thickness = 1.5
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 75)
header.BackgroundColor3 = Color3.fromRGB(30, 48, 39)
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 34)
title.Position = UDim2.fromOffset(14, 8)
title.BackgroundTransparency = 1
title.Text = "🎃 Batapim Hub"
title.TextColor3 = Color3.fromRGB(230, 255, 225)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -25, 0, 20)
subtitle.Position = UDim2.fromOffset(15, 43)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PUMPKIN FARM"
subtitle.TextColor3 = Color3.fromRGB(145, 210, 155)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local function makeButton(parent, text, size, position, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    return button
end

local closeButton = makeButton(
    header, "×",
    UDim2.fromOffset(30, 30),
    UDim2.new(1, -39, 0, 9),
    Color3.fromRGB(110, 48, 48)
)
closeButton.TextSize = 23

local collapseButton = makeButton(
    header, "—",
    UDim2.fromOffset(28, 28),
    UDim2.new(1, -74, 0, 9),
    Color3.fromRGB(55, 85, 65)
)

local startButton = makeButton(
    main, "▶  START",
    UDim2.new(1, -28, 0, 39),
    UDim2.fromOffset(14, 91),
    Color3.fromRGB(49, 145, 83)
)

local stopButton = makeButton(
    main, "■  STOP",
    UDim2.new(1, -28, 0, 39),
    UDim2.fromOffset(14, 138),
    Color3.fromRGB(155, 65, 65)
)

local resetButton = makeButton(
    main, "AUTO RESET: ON",
    UDim2.new(1, -28, 0, 35),
    UDim2.fromOffset(14, 185),
    Color3.fromRGB(55, 105, 75)
)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 42)
status.Position = UDim2.fromOffset(14, 235)
status.BackgroundTransparency = 1
status.Text = "● Готов к поиску"
status.TextColor3 = Color3.fromRGB(190, 205, 195)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.Parent = main

-- СВОРАЧИВАНИЕ
local miniButton = makeButton(
    gui, "🎃",
    UDim2.fromOffset(53, 53),
    main.Position,
    Color3.fromRGB(37, 105, 65)
)
miniButton.TextSize = 27
miniButton.Visible = false
miniButton.Active = true
miniButton.Draggable = true

local function collapse()
    miniButton.Position = main.Position
    main.Visible = false
    miniButton.Visible = true
end

local function expand()
    main.Position = miniButton.Position
    miniButton.Visible = false
    main.Visible = true
end

collapseButton.MouseButton1Click:Connect(collapse)
miniButton.MouseButton1Click:Connect(expand)

-- ПЕРСОНАЖ
local function getCharacter()
    return player.Character
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- ПРОВЕРКА ЧАСТЕЙ ИГРОКОВ
local function isPlayerPart(obj)
    local current = obj

    while current and current ~= workspace do
        if current:IsA("Model")
            and current:FindFirstChildOfClass("Humanoid") then
            return true
        end

        current = current.Parent
    end

    return false
end

-- КАМЕРА
local function saveCamera()
    local camera = workspace.CurrentCamera

    if not oldCamera and camera then
        oldCamera = {
            Type = camera.CameraType,
            Subject = camera.CameraSubject,
            CFrame = camera.CFrame,
            FOV = camera.FieldOfView
        }
    end
end

local function setTopCamera()
    local camera = workspace.CurrentCamera
    local root = getRoot()

    if not camera or not root then return end

    saveCamera()
    camera.CameraType = Enum.CameraType.Scriptable

    local cameraPosition =
        root.Position + Vector3.new(0, CAMERA_HEIGHT, 0)

    camera.CFrame = CFrame.lookAt(
        cameraPosition,
        root.Position,
        Vector3.new(0, 0, -1)
    )
end

local function restoreCamera()
    if not oldCamera then return end

    local camera = workspace.CurrentCamera

    if camera then
        camera.CameraType = oldCamera.Type
        camera.CameraSubject = oldCamera.Subject
        camera.CFrame = oldCamera.CFrame
        camera.FieldOfView = oldCamera.FOV
    end

    oldCamera = nil
end

-- ЧЕТВЁРТЫЙ TOOL
local function equipTool()
    local backpack = player:FindFirstChild("Backpack")
    local humanoid = getHumanoid()

    if not backpack or not humanoid then return end

    local tools = {}

    for _, obj in ipairs(backpack:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(tools, obj)
        end
    end

    if #tools >= TOOL_NUMBER then
        selectedTool = tools[TOOL_NUMBER]
        humanoid:EquipTool(selectedTool)
    end
end

-- ПОЛУЧЕНИЕ ПОЗИЦИИ ОБЪЕКТА
local function getObjectPosition(obj)
    if not obj then return nil end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        return obj:GetPivot().Position
    end

    if obj:IsA("Attachment") then
        return obj.WorldPosition
    end

    return nil
end

-- ПОЛУЧЕНИЕ ОБЪЕКТА ИЗ НАДПИСИ
local function getWorldObject(obj)
    local current = obj

    while current and current ~= workspace do
        if current:IsA("BillboardGui")
            or current:IsA("SurfaceGui") then

            local adornee = current.Adornee

            if adornee then
                if adornee:IsA("Attachment") then
                    adornee = adornee.Parent
                end

                if adornee and (
                    adornee:IsA("BasePart")
                    or adornee:IsA("Model")
                ) and not isPlayerPart(adornee) then
                    return adornee
                end
            end
        end

        current = current.Parent
    end

    current = obj

    while current and current ~= workspace do
        if current:IsA("Model")
            or current:IsA("BasePart") then

            if not isPlayerPart(current) then
                return current
            end
        end

        current = current.Parent
    end

    return nil
end

-- НОРМАЛИЗАЦИЯ ТЕКСТА
local function normalizeText(value)
    if type(value) ~= "string" then
        return ""
    end

    value = string.lower(value)
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")

    return value
end

local normalizedNames = {}

for name in pairs(TARGET_NAMES) do
    normalizedNames[normalizeText(name)] = true
end

-- ПРОВЕРКА НАЗВАНИЯ
local function matchesTargetName(value)
    local text = normalizeText(value)

    if normalizedNames[text] then
        return true
    end

    for name in pairs(normalizedNames) do
        if string.find(text, name, 1, true) then
            return true
        end
    end

    return false
end

-- ПОИСК ЦЕЛИ
local function findTarget()
    local root = getRoot()
    if not root then return nil end

    local bestTarget = nil
    local bestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        local matched = false

        if matchesTargetName(obj.Name) then
            matched = true
        end

        if not matched and (
            obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox")
        ) then
            if matchesTargetName(obj.Text) then
                matched = true
            end
        end

        if matched then
            local target = getWorldObject(obj)

            if target then
                local position = getObjectPosition(target)

                if position then
                    local dx = position.X - root.Position.X
                    local dz = position.Z - root.Position.Z
                    local distance = math.sqrt(dx * dx + dz * dz)

                    if distance <= SEARCH_RADIUS
                        and distance < bestDistance then

                        bestDistance = distance
                        bestTarget = target
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ПОДБОР С ПОВТОРНЫМИ ПОПЫТКАМИ
local currentPrompt = nil
local promptHoldActive = false
local promptAttempts = 0
local promptPhase = "start"
local nextPromptAction = 0
local failedPrompt = nil

local function releasePrompt()
    if currentPrompt and promptHoldActive then
        pcall(function()
            currentPrompt:InputHoldEnd()
        end)
    end

    currentPrompt = nil
    promptHoldActive = false
    promptAttempts = 0
    promptPhase = "start"
    nextPromptAction = 0
end

local function getPromptPart(prompt)
    local parent = prompt.Parent

    if not parent then return nil end

    if parent:IsA("Attachment") then
        parent = parent.Parent
    end

    if parent and parent:IsA("BasePart") then
        return parent
    end

    return nil
end

local function findNearbyPrompt()
    local root = getRoot()
    if not root then return nil end

    if failedPrompt and (
        not failedPrompt.Parent or not failedPrompt.Enabled
    ) then
        failedPrompt = nil
    end

    local closestPrompt = nil
    local closestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt")
            and obj.Enabled
            and obj ~= failedPrompt then

            local part = getPromptPart(obj)

            if part then
                local distance =
                    (part.Position - root.Position).Magnitude

                if distance <= obj.MaxActivationDistance
                    and distance < closestDistance then

                    closestDistance = distance
                    closestPrompt = obj
                end
            end
        end
    end

    return closestPrompt
end

local function updatePrompt()
    if not running then
        releasePrompt()
        return
    end

    local prompt = findNearbyPrompt()

    if prompt ~= currentPrompt then
        releasePrompt()

        if prompt then
            currentPrompt = prompt
            promptPhase = "start"
            promptAttempts = 0
            nextPromptAction = 0
        end
    end

    if not currentPrompt then return end

    if not currentPrompt.Parent or not currentPrompt.Enabled then
        releasePrompt()
        return
    end

    if os.clock() < nextPromptAction then
        return
    end

    if promptPhase == "start" then
        promptAttempts = promptAttempts + 1

        local success = pcall(function()
            currentPrompt:InputHoldBegin()
        end)

        if success then
            promptHoldActive = true
            promptPhase = "release"

            nextPromptAction = os.clock()
                + math.max(currentPrompt.HoldDuration, 0.35)
                + 0.35
        else
            promptPhase = "wait"
            nextPromptAction = os.clock() + RETRY_DELAY
        end

    elseif promptPhase == "release" then
        pcall(function()
            currentPrompt:InputHoldEnd()
        end)

        promptHoldActive = false
        promptPhase = "wait"
        nextPromptAction = os.clock() + RETRY_DELAY

    elseif promptPhase == "wait" then
        if promptAttempts < MAX_PICKUP_ATTEMPTS then
            promptPhase = "start"
            nextPromptAction = os.clock()
        else
            failedPrompt = currentPrompt
            releasePrompt()
        end
    end
end

-- ПРОВЕРКА СООБЩЕНИЙ ДЛЯ AUTO RESET
local function errorTextVisible()
    local messages = {
        "you can't dig here!",
        "you can't dig any deeper!"
    }

    local containers = {
        player:FindFirstChild("PlayerGui"),
        workspace
    }

    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("TextLabel")
                    or obj:IsA("TextButton")
                    or obj:IsA("TextBox") then

                    local text = string.lower(obj.Text)

                    for _, message in ipairs(messages) do
                        if string.find(text, message, 1, true) then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

-- AUTO RESET
local function doAutoReset()
    releasePrompt()

    local humanoid = getHumanoid()
    if not humanoid then return end

    humanoid.Health = 0
    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end

-- STOP
local function stopFarm()
    running = false
    releasePrompt()
    failedPrompt = nil

    local humanoid = getHumanoid()
    local root = getRoot()

    if humanoid and root then
        humanoid:MoveTo(root.Position)
    end

    restoreCamera()

    status.Text = "● Остановлено"
    status.TextColor3 = Color3.fromRGB(220, 170, 170)
end

-- START
local function startFarm()
    if running then return end

    running = true
    wasErrorVisible = false
    failedPrompt = nil

    status.Text = "● Ищем объекты по названию..."
    status.TextColor3 = Color3.fromRGB(130, 235, 150)

    equipTool()
    setTopCamera()
end

-- КНОПКИ
startButton.MouseButton1Click:Connect(startFarm)
stopButton.MouseButton1Click:Connect(stopFarm)

resetButton.MouseButton1Click:Connect(function()
    autoReset = not autoReset

    if autoReset then
        resetButton.Text = "AUTO RESET: ON"
        resetButton.BackgroundColor3 = Color3.fromRGB(55, 105, 75)
    else
        resetButton.Text = "AUTO RESET: OFF"
        resetButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    destroyed = true
    stopFarm()
    gui:Destroy()
end)

-- ОСНОВНОЙ ЦИКЛ
task.spawn(function()
    while not destroyed and gui.Parent do
        if running then
            local humanoid = getHumanoid()
            local root = getRoot()

            if humanoid and root and humanoid.Health > 0 then
                setTopCamera()

                if not selectedTool or not selectedTool.Parent then
                    equipTool()
                end

                updatePrompt()

                local errorVisible = errorTextVisible()

                if autoReset and errorVisible and not wasErrorVisible then
                    wasErrorVisible = true
                    doAutoReset()
                elseif not errorVisible then
                    wasErrorVisible = false
                end

                local target = findTarget()

                if target and target.Parent then
                    local pos = getObjectPosition(target)

                    if pos then
                        local dx = pos.X - root.Position.X
                        local dz = pos.Z - root.Position.Z
                        local distance = math.sqrt(dx * dx + dz * dz)

                        if distance > STOP_DISTANCE then
                            humanoid:MoveTo(Vector3.new(
                                pos.X,
                                root.Position.Y,
                                pos.Z
                            ))

                            status.Text = "● Идём к: " .. target.Name
                        else
                            humanoid:MoveTo(root.Position)
                            status.Text = "● Найден: " .. target.Name
                        end
                    end
                else
                    humanoid:MoveTo(root.Position)
                    status.Text = "● Подходящих объектов нет"
                end
            else
                releasePrompt()
            end
        else
            releasePrompt()
        end

        task.wait(SCAN_DELAY)
    end

    releasePrompt()
end)

-- ПРИ ВОЗРОЖДЕНИИ
player.CharacterAdded:Connect(function()
    releasePrompt()
    failedPrompt = nil
    selectedTool = nil
    wasErrorVisible = false

    task.wait(1)

    if running then
        equipTool()
        setTopCamera()
    end
end)

print("Batapim Hub - PUMPKIN FARM loaded!")
