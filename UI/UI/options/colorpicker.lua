-- options/colorpicker.lua
return function(ParentPage, config, Library)
    local Title = config.Name or "Colorpicker"
    local Description = config.Info or "Choose a color"
    local DefaultColor = config.Default or Color3.fromRGB(255, 0, 0)
    local Callback = config.Callback or function() end

    local CPFrame = Instance.new("Frame")
    CPFrame.Size = UDim2.new(1, -10, 0, 40)
    CPFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    CPFrame.Parent = ParentPage
    Instance.new("UICorner").Parent = CPFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = Title
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = CPFrame

    local ColorDisplay = Instance.new("TextButton")
    ColorDisplay.Size = UDim2.new(0, 30, 0, 20)
    ColorDisplay.Position = UDim2.new(1, -40, 0.5, -10)
    ColorDisplay.BackgroundColor3 = DefaultColor
    ColorDisplay.Text = ""
    ColorDisplay.Parent = CPFrame
    Instance.new("UICorner").Parent = ColorDisplay

    Library:AddTooltip(TextLabel, Description)

    ColorDisplay.MouseButton1Click:Connect(function()
        -- Здесь открывается палитра. Для примера сделаем простой тоггл между красным и зеленым
        local targetColor = ColorDisplay.BackgroundColor3 == Color3.fromRGB(255, 0, 0) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ColorDisplay.BackgroundColor3 = targetColor
        task.spawn(Callback, targetColor)
    end)
end