--// BATAPIM HUB - PUMPKIN FARM
--// Выбор цветов + движение к деталям
--// Без автокопания и удержания ProximityPrompt

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- НАСТРОЙКИ
local SEARCH_RADIUS = 350
local STOP_DISTANCE = 3
local SCAN_DELAY = 0.35
local CAMERA_HEIGHT = 25
local TOOL_NUMBER = 4

local running = false
local autoReset = true
local selectedTool = nil
local wasErrorVisible = false
local destroyed = false
local oldCamera = nil

-- ВЫБРАННЫЕ ЦВЕТА
local selectedColors = {}

local colorList = {
    {name = "Красный", color = Color3.fromRGB(230, 55, 55)},
    {name = "Оранжевый", color = Color3.fromRGB(240, 135, 40)},
    {name = "Жёлтый", color = Color3.fromRGB(240, 220, 50)},
    {name = "Зелёный", color = Color3.fromRGB(55, 200, 80)},
    {name = "Голубой", color = Color3.fromRGB(50, 200, 220)},
    {name = "Синий", color = Color3.fromRGB(55, 100, 230)},
    {name = "Фиолетовый", color = Color3.fromRGB(150, 65, 210)},
    {name = "Розовый", color = Color3.fromRGB(240, 100, 170)},
    {name = "Белый", color = Color3.fromRGB(240, 240, 240)},
    {name = "Серый", color = Color3.fromRGB(130, 130, 130)},
    {name = "Чёрный", color = Color3.fromRGB(30, 30, 30)}
}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BatapimHub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 445)
main.Position = UDim2.new(0.5, -150, 0.5, -222)
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

local colorTitle = Instance.new("TextLabel")
colorTitle.Size = UDim2.new(1, -28, 0, 22)
colorTitle.Position = UDim2.fromOffset(14, 226)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "ВЫБЕРИ ЦВЕТА ЦЕЛИ"
colorTitle.TextColor3 = Color3.fromRGB(180, 220, 185)
colorTitle.TextSize = 12
colorTitle.Font = Enum.Font.GothamBold
colorTitle.TextXAlignment = Enum.TextXAlignment.Left
colorTitle.Parent = main

local colorScroll = Instance.new("ScrollingFrame")
colorScroll.Size = UDim2.new(1, -28, 0, 137)
colorScroll.Position = UDim2.fromOffset(14, 250)
colorScroll.BackgroundColor3 = Color3.fromRGB(29, 35, 39)
colorScroll.BorderSizePixel = 0
colorScroll.ScrollBarThickness = 4
colorScroll.CanvasSize = UDim2.fromOffset(0, 0)
colorScroll.Parent = main

Instance.new("UICorner", colorScroll).CornerRadius = UDim.new(0, 10)

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -5, 0, 32)
grid.CellPadding = UDim2.fromOffset(6, 5)
grid.Parent = colorScroll

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    colorScroll.CanvasSize = UDim2.fromOffset(
        0,
        grid.AbsoluteContentSize.Y + 8
    )
end)

local colorButtons = {}

local function updateColorButton(name)
    local button = colorButtons[name]
    if not button then return end

    if selectedColors[name] then
        button.Text = "✓ " .. name
        button.BackgroundColor3 = Color3.fromRGB(49, 125, 75)
    else
        button.Text = name
        button.BackgroundColor3 = Color3.fromRGB(55, 62, 67)
    end
end

for _, info in ipairs(colorList) do
    local button = makeButton(
        colorScroll,
        info.name,
        UDim2.new(0, 100, 0, 32),
        UDim2.new(),
        Color3.fromRGB(55, 62, 67)
    )

    button.TextSize = 11
    button.TextColor3 = info.color

    colorButtons[info.name] = button

    button.MouseButton1Click:Connect(function()
        selectedColors[info.name] = not selectedColors[info.name]
        updateColorButton(info.name)
    end)
end

local allButton = makeButton(
    main, "ВЫБРАТЬ ВСЕ ЦВЕТА",
    UDim2.new(1, -28, 0, 30),
    UDim2.fromOffset(14, 393),
    Color3.fromRGB(65, 85, 105)
)
allButton.TextSize = 11

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 18)
status.Position = UDim2.fromOffset(14, 422)
status.BackgroundTransparency = 1
status.Text = "● Выбери цвета"
status.TextColor3 = Color3.fromRGB(190, 205, 195)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.Parent = main

allButton.MouseButton1Click:Connect(function()
    local allSelected = true

    for _, info in ipairs(colorList) do
        if not selectedColors[info.name] then
            allSelected = false
            break
        end
    end

    for _, info in ipairs(colorList) do
        selectedColors[info.name] = not allSelected
        updateColorButton(info.name)
    end
end)

--// СВОРАЧИВАНИЕ
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

--// ПЕРСОНАЖ
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

--// КАМЕРА
local function saveCamera()
    local camera = workspace.CurrentCamera

    if not oldCamera then
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

    local cameraPosition = root.Position + Vector3.new(0, CAMERA_HEIGHT, 0)

    camera.CFrame = CFrame.lookAt(
        cameraPosition,
        root.Position,
        Vector3.new(0, 0, -1)
    )
end

local function restoreCamera()
    if not oldCamera then return end

    local camera = workspace.CurrentCamera
    camera.CameraType = oldCamera.Type
    camera.CameraSubject = oldCamera.Subject
    camera.CFrame = oldCamera.CFrame
    camera.FieldOfView = oldCamera.FOV

    oldCamera = nil
end

--// ВЫБОР ЧЕТВЁРТОГО TOOL
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

--// ОПРЕДЕЛЕНИЕ ЦВЕТА
local function getColorName(color)
    local h, s, v = Color3.toHSV(color)

    if s < 0.20 then
        if v > 0.85 then
            return "Белый"
        elseif v < 0.18 then
            return "Чёрный"
        else
            return "Серый"
        end
    end

    if h < 0.035 or h >= 0.96 then
        return "Красный"
    elseif h < 0.09 then
        return "Оранжевый"
    elseif h < 0.17 then
        return "Жёлтый"
    elseif h < 0.42 then
        return "Зелёный"
    elseif h < 0.53 then
        return "Голубой"
    elseif h < 0.70 then
        return "Синий"
    elseif h < 0.86 then
        return "Фиолетовый"
    else
        return "Розовый"
    end
end

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

--// ПОИСК ЦЕЛИ ПО ЦВЕТУ
local function findTarget()
    local root = getRoot()
    if not root then return nil end

    local anySelected = false

    for _, value in pairs(selectedColors) do
        if value then
            anySelected = true
            break
        end
    end

    if not anySelected then
        return nil
    end

    local bestTarget = nil
    local bestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart")
            and obj.Transparency < 0.95
            and obj.Size.Magnitude > 0.5
            and not isPlayerPart(obj) then

            local colorName = getColorName(obj.Color)

            if selectedColors[colorName] then
                local pos = obj.Position

                -- Расстояние только по X и Z.
                -- Высота Y не учитывается.
                local dx = pos.X - root.Position.X
                local dz = pos.Z - root.Position.Z
                local distance = math.sqrt(dx * dx + dz * dz)

                if distance <= SEARCH_RADIUS
                    and distance < bestDistance then

                    bestDistance = distance
                    bestTarget = obj
                end
            end
        end
    end

    return bestTarget
end

--// ПРОВЕРКА СООБЩЕНИЙ ДЛЯ AUTO RESET
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

--// AUTO RESET
local function doAutoReset()
    local humanoid = getHumanoid()
    if not humanoid then return end

    humanoid.Health = 0
    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end

--// STOP
local function stopFarm()
    running = false

    local humanoid = getHumanoid()
    local root = getRoot()

    if humanoid and root then
        humanoid:MoveTo(root.Position)
    end

    restoreCamera()

    status.Text = "● Остановлено"
    status.TextColor3 = Color3.fromRGB(220, 170, 170)
end

--// START
local function startFarm()
    if running then return end

    local hasSelection = false

    for _, value in pairs(selectedColors) do
        if value then
            hasSelection = true
            break
        end
    end

    if not hasSelection then
        status.Text = "● Сначала выбери цвет!"
        status.TextColor3 = Color3.fromRGB(255, 170, 100)
        return
    end

    running = true
    wasErrorVisible = false

    status.Text = "● Ищем детали..."
    status.TextColor3 = Color3.fromRGB(130, 235, 150)

    equipTool()
    setTopCamera()
end

--// КНОПКИ
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

--// ОСНОВНОЙ ЦИКЛ
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

                local errorVisible = errorTextVisible()

                if autoReset and errorVisible and not wasErrorVisible then
                    wasErrorVisible = true
                    doAutoReset()
                elseif not errorVisible then
                    wasErrorVisible = false
                end

                local target = findTarget()

                if target and target.Parent then
                    local pos = target.Position

                    local dx = pos.X - root.Position.X
                    local dz = pos.Z - root.Position.Z
                    local distance = math.sqrt(dx * dx + dz * dz)

                    if distance > STOP_DISTANCE then
                        -- Идём к X/Z цели, но сохраняем свою высоту Y.
                        humanoid:MoveTo(Vector3.new(
                            pos.X,
                            root.Position.Y,
                            pos.Z
                        ))

                        status.Text = "● Идём к детали"
                    else
                        humanoid:MoveTo(root.Position)
                        status.Text = "● Над деталью — копай!"
                    end
                else
                    humanoid:MoveTo(root.Position)
                    status.Text = "● Подходящих деталей нет"
                end
            end
        end

        task.wait(SCAN_DELAY)
    end
end)

--// ПРИ ВОЗРОЖДЕНИИ
player.CharacterAdded:Connect(function()
    selectedTool = nil
    wasErrorVisible = false

    task.wait(1)

    if running then
        equipTool()
        setTopCamera()
    end
end)

print("Batapim Hub - PUMPKIN FARM loaded!")
