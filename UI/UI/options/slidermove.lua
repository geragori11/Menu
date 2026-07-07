-- options/slidermove.lua
local UserInputService = game:GetService("UserInputService")

return function(ParentPage, config, Library)
    local Title = config.Name or "Slider"
    local Description = config.Info or "Drag to adjust"
    local Min = config.Min or 0
    local Max = config.Max or 100
    local Step = config.Step or 1
    local Default = config.Default or Min
    local Callback = config.Callback or function() end

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    SliderFrame.Parent = ParentPage
    Instance.new("UICorner").Parent = SliderFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = Title
    TextLabel.Size = UDim2.new(0.6, 0, 0, 25)
    TextLabel.Position = UDim2.new(0, 10, 0, 5)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(Default)
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 5)
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = SliderFrame

    -- Полоса слайдера
    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 35)
    SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderBar.Text = ""
    SliderBar.AutoButtonColor = false
    SliderBar.Parent = SliderFrame
    Instance.new("UICorner").Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    Instance.new("UICorner").Parent = SliderFill

    Library:AddTooltip(TextLabel, Description)

    -- Логика перетаскивания (Drag)
    local isDragging = false

    local function updateSlider()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        local percentage = math.clamp((mousePos - barPos) / barWidth, 0, 1)
        
        local rawValue = Min + (percentage * (Max - Min))
        local value = math.floor(rawValue / Step) * Step
        value = math.clamp(value, Min, Max)

        SliderFill.Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)
        ValueLabel.Text = tostring(value)
        task.spawn(Callback, value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end