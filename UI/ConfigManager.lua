-- ConfigManager.lua
local HttpService = game:GetService("HttpService")
local ConfigManager = {}

ConfigManager.FolderName = "XClientConfigs" -- Папка в workspace эксплойта

function ConfigManager:Init()
    if not isfolder(self.FolderName) then
        makefolder(self.FolderName)
    end
end

function ConfigManager:Save(ConfigName, DataMap)
    self:Init()
    local path = self.FolderName .. "/" .. ConfigName .. ".json"
    local json = HttpService:JSONEncode(DataMap)
    writefile(path, json)
end

function ConfigManager:Load(ConfigName)
    self:Init()
    local path = self.FolderName .. "/" .. ConfigName .. ".json"
    if isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success then return data end
    end
    return nil
end

function ConfigManager:Delete(ConfigName)
    local path = self.FolderName .. "/" .. ConfigName .. ".json"
    if isfile(path) then
        delfile(path)
        return true
    end
    return false
end

function ConfigManager:GetConfigs()
    self:Init()
    local configs = {}
    for _, file in ipairs(listfiles(self.FolderName)) do
        local name = file:match("([^/]+)%.json$")
        if name then table.insert(configs, name) end
    end
    return configs
end

return ConfigManager