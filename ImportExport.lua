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

function SwirlUI.Imports:AreAllProfilesApplied()
    local allProfiles = SwirlUI.Utils:GetAllProfiles()
    
    for _, profile in ipairs(allProfiles) do
        if SwirlUI.Utils:HasProfile(profile, true) and not SwirlUI.Utils:IsProfileApplied(profile) then
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
            local success = self[importFunction] and self[importFunction](self, false)
            if success then
                successCount = successCount + 1
            else
                SwirlUI.Utils:Print(string.format("Failed to import %s", SwirlUI.ApplyColor(profile.name, profile.color)))
            end
        else
            SwirlUI.Utils:Print(string.format("%s addon not loaded, skipping", SwirlUI.ApplyColor(profile.name, profile.color)))
        end
    end

    AF.ShowNotificationPopup(string.format("%s\n Import complete! (%d/%d successful)", SwirlUI.NameNoCore, successCount, totalCount), 2)

    if successCount > 0 then
        SwirlUI.SettingsChanged = true
        SwirlUI.Utils:Print(string.format("Please /reload to apply all changes"))
    end
end

function SwirlUI.Imports:ApplyProfiles()
    if not self:CanApplyProfiles() then
        AF.ShowNotificationPopup(string.format("%s\n Not all profiles are available, check their import/enabled status", SwirlUI.NameNoCore), 2)
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
        AF.ShowNotificationPopup(string.format("%s\n Applying all profiles...", SwirlUI.NameNoCore), 2)
        for index, step in ipairs(steps) do
            C_Timer.After(index * 0.5, step)
        end
    else
        AF.ShowNotificationPopup(string.format("%s\n All profiles are already applied", SwirlUI.NameNoCore), 2)
        return false
    end

    C_Timer.After((#steps + 1) * 0.5, function()
        SwirlUI.CreateStatusDisplay_AF()
        SwirlUI:ReloadDialog()
    end)
    
    return true
end

function SwirlUI.Imports:ImportBufflehead(notification)
    local db = SwirlUI.Utils:Import("Bufflehead", notification)
    if db then
        db["global"]["hideOmniCC"] = false
    end
    return true
end

function SwirlUI.Imports:ExportBufflehead()
    local bufflehead = SwirlUI.Utils:GetImportProfile("Bufflehead")
    local data = bufflehead.database["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, bufflehead)
end

function SwirlUI.Imports:ImportPrat(notification)
    return SwirlUI.Utils:Import("Prat-3.0", notification)
end

function SwirlUI.Imports:ExportPrat()
    local prat = SwirlUI.Utils:GetImportProfile("Prat-3.0")

    local profileData = prat.database["profiles"][SwirlUI.Profile]
    local namespacesData = prat.database["namespaces"]

    SwirlUI.Utils:Export(profileData, prat, false)
    SwirlUI.Utils:Export(namespacesData, prat, true)

    return true
end

function SwirlUI.Imports:ImportBasicMinimap(notification)
    return SwirlUI.Utils:Import("BasicMinimap", notification)
end

function SwirlUI.Imports:ExportBasicMinimap()
    local basicMinimap = SwirlUI.Utils:GetImportProfile("BasicMinimap")
    local data = basicMinimap.database["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, basicMinimap)
end

function SwirlUI.Imports:ImportMasque(notification)
    return SwirlUI.Utils:Import("Masque", notification)
end

function SwirlUI.Imports:ExportMasque()
    local masque = SwirlUI.Utils:GetImportProfile("Masque")
    local data = masque.database["profiles"][SwirlUI.Profile]
    return SwirlUI.Utils:Export(data, masque)
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
