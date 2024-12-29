-- Function to create health bar
local function createHealthBar()
    -- Create a ScreenGui for the health bar
    local healthGui = Instance.new("ScreenGui")
    healthGui.Name = "HealthGui"
    healthGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Create a Frame for the health bar background
    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "BackgroundFrame"
    backgroundFrame.Size = UDim2.new(0.15, 0, 0.0375, 0) -- Reduced size (3/4 of original)
    backgroundFrame.Position = UDim2.new(0.425, 0, 0.01, 0)
    backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    backgroundFrame.BackgroundTransparency = 0.5 -- Increased transparency
    backgroundFrame.BorderSizePixel = 2
    backgroundFrame.Parent = healthGui

    -- Create a Frame for the health bar
    local healthFrame = Instance.new("Frame")
    healthFrame.Name = "HealthFrame"
    healthFrame.Size = UDim2.new(1, -4, 1, -4)
    healthFrame.Position = UDim2.new(0, 2, 0, 2)
    healthFrame.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFrame.BorderSizePixel = 0
    healthFrame.Parent = backgroundFrame

    return backgroundFrame, healthFrame
end

-- Function to update the health bar
local function updateHealth(healthFrame)
    local player = game.Players.LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local maxHealth = humanoid.MaxHealth
            local currentHealth = math.clamp(humanoid.Health, 0, maxHealth)
            local healthPercentage = currentHealth / maxHealth
            
            -- Update the size of the health bar
            healthFrame.Size = UDim2.new(math.clamp(healthPercentage, 0, 1), -4, 1, -4)
            
            -- Change color based on health percentage
            if healthPercentage >= 0.5 then
                healthFrame.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
            elseif healthPercentage >= 0.2 then
                healthFrame.BackgroundColor3 = Color3.new(1, 1, 0) -- Yellow
            else
                healthFrame.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
            end
        end
    end
end

-- Function to create draggable ESP button
local function createEspButton()
    local Buttons1 = Instance.new("ScreenGui")
    Buttons1.Name = "EspGui"
    Buttons1.Parent = game.Players.LocalPlayer.PlayerGui
    
    local EspToggleFrame = Instance.new("Frame")
    EspToggleFrame.Size = UDim2.new(0, 100, 0, 50)
    EspToggleFrame.Position = UDim2.new(0.9, -100, 0.5, -25)
    EspToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    EspToggleFrame.BorderSizePixel = 4
    EspToggleFrame.Parent = Buttons1
    EspToggleFrame.Active = true
    EspToggleFrame.Draggable = true

    -- Constraint to keep the button inside the screen
    EspToggleFrame:GetPropertyChangedSignal("Position"):Connect(function()
        local pos = EspToggleFrame.Position
        EspToggleFrame.Position = UDim2.new(
            math.clamp(pos.X.Scale, 0, 1 - (EspToggleFrame.Size.X.Offset / workspace.CurrentCamera.ViewportSize.X)),
            math.clamp(pos.X.Offset, 0, workspace.CurrentCamera.ViewportSize.X - EspToggleFrame.Size.X.Offset),
            math.clamp(pos.Y.Scale, 0, 1 - (EspToggleFrame.Size.Y.Offset / workspace.CurrentCamera.ViewportSize.Y)),
            math.clamp(pos.Y.Offset, 0, workspace.CurrentCamera.ViewportSize.Y - EspToggleFrame.Size.Y.Offset)
        )
    end)

    local buttonEsp = Instance.new("TextButton")
    buttonEsp.Name = "ButtonEsp"
    buttonEsp.Size = UDim2.new(0.8, 0, 0.8, 0)
    buttonEsp.Position = UDim2.new(0.1, 0, 0.1, 0)
    buttonEsp.Text = "Toggle ESP"
    buttonEsp.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    buttonEsp.BorderSizePixel = 0
    buttonEsp.Parent = EspToggleFrame

    return buttonEsp
end

-- Function to toggle ESP outlines
local IsEspEnabled = false
local function toggleESP()
    IsEspEnabled = not IsEspEnabled
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if IsEspEnabled then
                local outline = Instance.new("SelectionBox")
                outline.Name = "ESPOutline"
                outline.Adornee = player.Character.Head
                outline.LineThickness = 0.05
                outline.Color3 = Color3.new(1, 0, 0) -- Red outline
                outline.Parent = player.Character
            else
                if player.Character:FindFirstChild("ESPOutline") then
                    player.Character.ESPOutline:Destroy()
                end
            end
        end
    end
end

-- Connect button click to toggle ESP
local espButton = createEspButton()
espButton.MouseButton1Click:Connect(toggleESP)

-- Handle health bar updates
local backgroundFrame, healthFrame = createHealthBar()
game:GetService("RunService").RenderStepped:Connect(function()
    updateHealth(healthFrame)
end)
