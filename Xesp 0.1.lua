-- Function to toggle ESP visibility
local IsEspEnabled = false
local function ToggleEspVisibility()
    IsEspEnabled = not IsEspEnabled
end

-- Function to add ESP highlight to a character
local function addHighlight(character, teamColor)
    if not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Remove existing highlights
    if character:FindFirstChild("HighlightESP") then
        character.HighlightESP:Destroy()
    end

    -- Add new highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "HighlightESP"
    highlight.Adornee = character
    highlight.FillColor = teamColor or Color3.fromRGB(255, 255, 255) -- Default to white
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.Enabled = true
    highlight.Parent = character
end

-- Function to remove ESP highlight from a character
local function removeHighlight(character)
    if character:FindFirstChild("HighlightESP") then
        character.HighlightESP:Destroy()
    end
end

-- Function to handle ESP toggling
local function updateESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            if IsEspEnabled then
                local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                addHighlight(player.Character, teamColor)
            else
                removeHighlight(player.Character)
            end
        end
    end
end

-- Connect to player added and character added events
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if IsEspEnabled then
            local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
            addHighlight(character, teamColor)
        end
    end)
end)

-- Initial update for current players
for _, player in pairs(game.Players:GetPlayers()) do
    if player.Character then
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        addHighlight(player.Character, teamColor)
    end
end

-- Create draggable ESP toggle button
local function createEspButton()
    local ButtonsGui = Instance.new("ScreenGui")
    ButtonsGui.Name = "ESPButtonsGui"
    ButtonsGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local EspToggleFrame = Instance.new("Frame")
    EspToggleFrame.Size = UDim2.new(0, 100, 0, 100) -- 1:1 ratio
    EspToggleFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    EspToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    EspToggleFrame.BorderSizePixel = 4
    EspToggleFrame.Parent = ButtonsGui
    EspToggleFrame.Active = true

    local ButtonEsp = Instance.new("TextButton")
    ButtonEsp.Name = "ButtonEsp"
    ButtonEsp.Size = UDim2.new(0.8, 0, 0.8, 0)
    ButtonEsp.Position = UDim2.new(0.1, 0, 0.1, 0)
    ButtonEsp.Text = "Toggle ESP"
    ButtonEsp.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    ButtonEsp.BorderSizePixel = 0
    ButtonEsp.Parent = EspToggleFrame

    -- Custom dragging logic for mobile
    local UIS = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos

    local function updatePosition(input)
        local delta = input.Position - dragStart
        EspToggleFrame.Position = UDim2.new(
            0,
            math.clamp(startPos.X.Offset + delta.X, 0, game.Workspace.CurrentCamera.ViewportSize.X - EspToggleFrame.AbsoluteSize.X),
            0,
            math.clamp(startPos.Y.Offset + delta.Y, 0, game.Workspace.CurrentCamera.ViewportSize.Y - EspToggleFrame.AbsoluteSize.Y)
        )
    end

    EspToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = EspToggleFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    EspToggleFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            updatePosition(input)
        end
    end)

    -- Button click to toggle ESP
    ButtonEsp.MouseButton1Click:Connect(function()
        if not dragging then
            ToggleEspVisibility()
            updateESP()
        end
    end)
end

createEspButton()
