-- UIBuilder.lua
local CoreGui = game:GetService("CoreGui")

local UIBuilder = {}

-- Создание главного окна
function UIBuilder.CreateWindow(options)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = options.Name or "CustomMenu"
    ScreenGui.ResetOnSpawn = false
    -- Защита от обнаружения (если поддерживается эксплойтом)
    pcall(function() ScreenGui.Parent = CoreGui end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Text = options.Name .. " | " .. (options.LoadingSubtitle or "")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame

    -- Контейнер для вкладок
    local TabContainer = Instance.new("Folder")
    TabContainer.Name = "Tabs"
    TabContainer.Parent = MainFrame

    return ScreenGui, MainFrame, TabContainer
end

-- Здесь можно добавить отрисовку кнопок, тогглов и слайдеров
-- Например: function UIBuilder.CreateButton(parent, text, callback) ... end

return UIBuilder