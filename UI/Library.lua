-- Library.lua
local UserInputService = game:GetService("UserInputService")
local ConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/geragori11/Menu/refs/heads/main/UI/ConfigManager.lua"))()
local UIBuilder = loadstring(game:HttpGet("СЮДА_ССЫЛКУ_НА_UIBuilder.lua"))()

local Library = {}
Library.Flags = {} -- Хранилище состояний всех тогглов/слайдеров для конфига

function Library:CreateWindow(options)
    local Window = {}
    local ScreenGui, MainFrame, TabContainer = UIBuilder.CreateWindow(options)
    
    -- Система скрытия/открытия меню на клавишу (По умолчанию K)
    Window.ToggleKey = Enum.KeyCode.K
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Функция уведомлений (совместимость с Rayfield)
    function Window:Notify(notifyOptions)
        print("[NOTIFY] " .. notifyOptions.Title .. ": " .. notifyOptions.Content)
        -- Здесь в будущем добавь визуальную плашку уведомления
    end

    function Window:CreateTab(Name, Icon)
        local Tab = {}
        -- Создаем визуальный контейнер для вкладки в TabContainer (в UIBuilder)
        
        function Tab:CreateSection(SectionName)
            -- Отрисовка секции
        end

        function Tab:CreateButton(btnOptions)
            -- btnOptions.Name, btnOptions.Callback
            -- Вызов UIBuilder для отрисовки кнопки
        end

        function Tab:CreateToggle(tglOptions)
            local Toggle = {}
            local Flag = tglOptions.Flag or tglOptions.Name
            Library.Flags[Flag] = tglOptions.CurrentValue or false

            function Toggle:Set(state)
                Library.Flags[Flag] = state
                if tglOptions.Callback then tglOptions.Callback(state) end
                -- Обновить визуал тоггла
            end

            -- Вызов UIBuilder для отрисовки тоггла, по клику -> Toggle:Set(not state)
            return Toggle
        end

        -- Аналогично добавляются CreateSlider, CreateDropdown и т.д.
        
        return Tab
    end

    -- ==========================================
    -- ВСТРОЕННАЯ СИСТЕМА КОНФИГОВ И НАСТРОЕК
    -- ==========================================
    local SettingsTab = Window:CreateTab("Settings", "settings_icon")
    SettingsTab:CreateSection("Управление меню")
    
    -- БИНДЕР КЛАВИШИ
    SettingsTab:CreateButton({
        Name = "Изменить кнопку меню (Текущая: " .. Window.ToggleKey.Name .. ")",
        Callback = function()
            Window:Notify({Title = "Keybind", Content = "Нажми любую клавишу..."})
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Window.ToggleKey = input.KeyCode
                    Window:Notify({Title = "Успех", Content = "Новая кнопка: " .. input.KeyCode.Name})
                    connection:Disconnect()
                end
            end)
        end
    })

    SettingsTab:CreateSection("Система Конфигов")
    
    local ConfigInputName = "Default"
    -- Представим, что у нас есть TextBox (в Rayfield это Input)
    -- SettingsTab:CreateInput({ Name = "Имя конфига", Callback = function(txt) ConfigInputName = txt end })

    SettingsTab:CreateButton({
        Name = "💾 Сохранить конфиг",
        Callback = function()
            ConfigManager:Save(ConfigInputName, Library.Flags)
            Window:Notify({Title = "Конфиг", Content = "Успешно сохранен: " .. ConfigInputName})
        end
    })

    SettingsTab:CreateButton({
        Name = "📂 Загрузить конфиг",
        Callback = function()
            local data = ConfigManager:Load(ConfigInputName)
            if data then
                for flag, value in pairs(data) do
                    -- Обновляем локальные флаги и вызываем коллбеки элементов (нужна логика обновления UI)
                    Library.Flags[flag] = value 
                end
                Window:Notify({Title = "Конфиг", Content = "Загружен: " .. ConfigInputName})
            else
                Window:Notify({Title = "Ошибка", Content = "Конфиг не найден!"})
            end
        end
    })
    
    SettingsTab:CreateButton({
        Name = "🗑️ Удалить конфиг",
        Callback = function()
            if ConfigManager:Delete(ConfigInputName) then
                Window:Notify({Title = "Удалено", Content = "Конфиг " .. ConfigInputName .. " удален."})
            end
        end
    end)

    return Window
end

return Library
