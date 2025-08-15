local _, SwirlUI = ...
local AF = _G.AbstractFramework

SwirlUI.Imports = {}

function SwirlUI.Imports:CanApplyProfiles()
    local allProfiles = SwirlUI.Utils:GetAllProfiles()
    
    for _, profile in ipairs(allProfiles) do
        if not SwirlUI.Utils:HasProfile(profile, true) then
            return false
        end
    end
    
    return true
end

function SwirlUI.Imports:ImportAll()
    local successCount = 0
    local totalCount = #SwirlUI.ImportProfiles
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if C_AddOns.IsAddOnLoaded(profile.name) then
            local importFunction = string.format("Import%s", profile.short or profile.name)
            local success = self[importFunction] and self[importFunction](self)
            if success then
                successCount = successCount + 1
            else
                print(string.format("%s Failed to import %s", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
            end
        else
            print(string.format("%s %s addon not loaded, skipping", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
        end
    end

    print(string.format("%s Import complete! (%d/%d successful)", SwirlUI.Header, successCount, totalCount))

    if successCount > 0 then
        SwirlUI.SettingsChanged = true
        print(string.format("%s Type /reload to apply all changes", SwirlUI.Header))
    end
end

function SwirlUI.Imports:ApplyProfiles()
    if not self:CanApplyProfiles() then
        print(string.format("%s Not all profiles are available. Import first!", SwirlUI.Header))
        return false
    end

    local steps = {}
    local stepIndex = 0
    local allProfiles = SwirlUI.Utils:GetAllProfiles()
    
    for _, profile in ipairs(allProfiles) do
        if not SwirlUI.Utils:IsProfileApplied(profile) then
            stepIndex = stepIndex + 1
            table.insert(steps, function()
                SwirlUI.Utils:ApplyProfile(profile)
            end)
        end
    end

    if (#steps > 0) then
        AF.ShowNotificationPopup(string.format("%s\n Applying all profiles...", SwirlUI.HeaderNoColon), 2)
        for index, step in ipairs(steps) do
            C_Timer.After(index * 0.5, step)
        end
    else
        AF.ShowNotificationPopup(string.format("%s\n All profiles are already applied", SwirlUI.HeaderNoColon), 2)
        return false
    end

    C_Timer.After((#steps + 1) * 0.5, function()
        SwirlUI:ReloadDialog()
    end)
    
    return true
end

function SwirlUI.Imports:ImportBufflehead()
    local db = SwirlUI.Utils:Import("Bufflehead")
    db["global"]["hideOmniCC"] = false
    return true
end

function SwirlUI.Imports:ExportBufflehead()
    local bufflehead = SwirlUI.Utils:GetImportProfile("Bufflehead")
    local data = bufflehead.database["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, bufflehead)
end

function SwirlUI.Imports:ImportPrat()
    return SwirlUI.Utils:Import("Prat-3.0")
end

function SwirlUI.Imports:ExportPrat()
    local prat = SwirlUI.Utils:GetImportProfile("Prat-3.0")

    local profileData = prat.database["profiles"][SwirlUI.Profile]
    local namespacesData = prat.database["namespaces"]

    SwirlUI.Utils:Export(profileData, prat, false)
    SwirlUI.Utils:Export(namespacesData, prat, true)

    return true
end

function SwirlUI.Imports:ImportBasicMinimap()
    return SwirlUI.Utils:Import("BasicMinimap")
end

function SwirlUI.Imports:ExportBasicMinimap()
    local basicMinimap = SwirlUI.Utils:GetImportProfile("BasicMinimap")
    local data = basicMinimap.database["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, basicMinimap)
end

function SwirlUI.Imports:ImportVocalRaidAssistant()
    return SwirlUI.Utils:Import("VocalRaidAssistant")
end

function SwirlUI.Imports:ExportVocalRaidAssistant()
    local vocalRaidAssistant = SwirlUI.Utils:GetImportProfile("VocalRaidAssistant")
    -- no idea why i can't call vocalRaidAssistant.database when its defined in Strings.lua
    local data = VocalRaidAssistantDB["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, vocalRaidAssistant)
end

function SwirlUI.Imports:ImportMinimapStats()
    local importProfile = SwirlUI.Utils:GetImportProfile("MinimapStats")
    if not importProfile or not SwirlUI.Utils:CheckAddOnLoaded(importProfile) then
        return false
    end
    importProfile.database.global = importProfile.data
    SwirlUI.SettingsChanged = true
    print(string.format("%s Imported %s", SwirlUI.Header, SwirlUI.ApplyColor(importProfile.name, importProfile.color)))
    SwirlUI.Utils:StoreProfileVersion(importProfile)
end

function SwirlUI.Imports:ExportMinimapStats()
    local minimapStats = SwirlUI.Utils:GetImportProfile("MinimapStats")
    local data = minimapStats.database.global
    return SwirlUI.Utils:Export(data, minimapStats)
end

function SwirlUI.Imports:GetAddonStatus(addonName, database)
    if not C_AddOns.IsAddOnLoaded(addonName) then
        return SwirlUI.STATUS.DISABLED, SwirlUI.Hostile
    elseif SwirlUI.Utils:HasProfile(addonName, database, true) then
        return SwirlUI.STATUS.ACTIVE, SwirlUI.Friendly
    else
        return SwirlUI.STATUS.READY, SwirlUI.Neutral
    end
end

function SwirlUI.Imports:GetProfileStatus()
    local status = {}
    local allProfiles = SwirlUI.Utils:GetAllProfiles()
    
    for _, profile in ipairs(allProfiles) do
        local addonLoaded = C_AddOns.IsAddOnLoaded(profile.name)
        local hasDB = addonLoaded and profile.database ~= nil
        local hasProfile = SwirlUI.Utils:HasProfile(profile, true)

        table.insert(status, {
            name = profile.name,
            color = profile.color or "FFFFFF",
            addonLoaded = addonLoaded,
            hasDB = hasDB,
            hasProfile = hasProfile
        })
    end
    
    return status
end
