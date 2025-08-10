local _, SwirlUI = ...

IsAddOnLoaded = C_AddOns.IsAddOnLoaded

SwirlUI.Imports = {}

function SwirlUI.Imports:IsImportActive(addonName, database)
    return SwirlUI.Utils:HasProfile(addonName, database, true)
end

function SwirlUI.Imports:CanApplyProfiles()
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if not SwirlUI.Utils:HasProfile(profile.name, profile.database, true) then
            return false
        end
    end
    
    for _, addon in ipairs(SwirlUI.ApplyAddons) do
        if not SwirlUI.Utils:HasProfile(addon.name, addon.database, true) then
            return false
        end
    end
    
    return true
end

function SwirlUI.Imports:ImportAll()
    local successCount = 0
    local totalCount = #SwirlUI.ImportProfiles
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if IsAddOnLoaded(profile.name) then
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
        SwirlUI.ProfilesImported = true
        print(string.format("%s Type /reload to apply all changes", SwirlUI.Header))
    end
end

function SwirlUI.Imports:ApplyProfiles()
    if not self:CanApplyProfiles() then
        print(string.format("%s Not all profiles are available. Import first!", SwirlUI.Header))
        return false
    end

    print(string.format("%s Applying all profiles...", SwirlUI.Header))

    local steps = {}
    local stepIndex = 0
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if self:IsImportActive(profile.name, profile.database) then
            stepIndex = stepIndex + 1
            table.insert(steps, function()
                self:ApplyProfile(profile.name, profile.database, profile.color)
            end)
        end
    end

    for _, addon in ipairs(SwirlUI.ApplyAddons) do
        if self:IsImportActive(addon.name, addon.database) then
            stepIndex = stepIndex + 1
            table.insert(steps, function()
                self:ApplyProfile(addon.name, addon.database, addon.color)
            end)
        end
    end

    for index, step in ipairs(steps) do
        C_Timer.After(index * 0.5, step)
    end

    C_Timer.After((#steps + 1) * 0.5, function()
        SwirlUI:ReloadDialog()
    end)
    
    return true
end

function SwirlUI.Imports:ApplyProfile(addonName, database, color)
    if not SwirlUI.Utils:HasProfile(addonName, database, false) then
        return false
    end
    
    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = database["profileKeys"] and database["profileKeys"][profileKey]

    if activeProfile == SwirlUI.Profile then
        print(string.format("%s %s profile is already applied", SwirlUI.Header, SwirlUI.ApplyColor(addonName, color)))
    else
        if not database["profileKeys"] then
            database["profileKeys"] = {}
        end
        database["profileKeys"][profileKey] = SwirlUI.Profile
        print(string.format("%s Applied %s profile", SwirlUI.Header, SwirlUI.ApplyColor(addonName, color)))
    end
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

function SwirlUI.Imports:GetAddonStatus(addonName, database)
    if not IsAddOnLoaded(addonName) then
        return "Disabled", SwirlUI.Hostile
    elseif self:IsImportActive(addonName, database) then
        return "Active", SwirlUI.Friendly
    else
        return "Ready", SwirlUI.Neutral
    end
end

function SwirlUI.Imports:GetProfileStatus()
    local status = {}
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        local addonLoaded = IsAddOnLoaded(profile.name)
        local hasDB = addonLoaded and profile.database ~= nil
        local hasProfile = SwirlUI.Utils:HasProfile(profile.name, profile.database, true)

        table.insert(status, {
            name = profile.name,
            color = profile.color or "FFFFFF",
            addonLoaded = addonLoaded,
            hasDB = hasDB,
            hasProfile = hasProfile
        })
    end
    
    for _, addon in ipairs(SwirlUI.ApplyAddons) do
        local addonLoaded = IsAddOnLoaded(addon.name)
        local hasDB = addonLoaded and addon.database ~= nil
        local hasProfile = SwirlUI.Utils:HasProfile(addon.name, addon.database, true)
        
        table.insert(status, {
            name = addon.name,
            color = addon.color or "FFFFFF", 
            addonLoaded = addonLoaded,
            hasDB = hasDB,
            hasProfile = hasProfile
        })
    end
    
    return status
end
