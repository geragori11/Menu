-- options/keybind.lua
local UserInputService = game:GetService("UserInputService")

return function(ParentPage, config, Library)
    local Title = config.Name or "Keybind"
    local Description = config.Info or "Hold to see details"
    local DefaultBind = config.Default or Enum.KeyCode.E
    local Callback = config.Callback or function() end

    local CurrentBind = DefaultBind

    local BindFrame = Instance.new("Frame")
    BindFrame.Size = UDim2.new(1, -10, 0, 40)
    BindFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    BindFrame.Parent = ParentPage
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = BindFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = Title
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = BindFrame

    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0, 80, 0, 24)
    BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
    BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BindBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    BindBtn.Text = CurrentBind.Name
    BindBtn.Font = Enum.Font.GothamMedium
    BindBtn.TextSize = 12
    BindBtn.Parent = BindFrame
    
    Instance.new("UICorner").Parent = BindBtn

    -- Тултип (подсказка при наведении на название модуля)
    Library:AddTooltip(TextLabel, Description)

    -- Смена бинда
    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                CurrentBind = input.KeyCode
                BindBtn.Text = input.KeyCode.Name
                listening = false
            end
        else
            if input.KeyCode == CurrentBind then
                task.spawn(Callback)
            end
        end
    end)
end