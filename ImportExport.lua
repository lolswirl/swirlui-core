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

function SwirlUI.Imports:ImportBasicMinimap(notification)
    return SwirlUI.Utils:Import("BasicMinimap", notification)
end

function SwirlUI.Imports:ImportBasicMinimap1440p(notification)
    -- Find the 1440p profile by short name
    local profile1440p = nil
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if profile.short == "BasicMinimap1440p" then
            profile1440p = profile
            break
        end
    end
    
    if not profile1440p or not SwirlUI.Utils:CheckAddOnLoaded(profile1440p) then
        return false
    end

    local data = SwirlUI.Utils:Decode(profile1440p.string)
    local db = profile1440p.database

    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}

    local characterProfile = string.format("%s - %s", UnitName("player"), GetRealmName())
    local targetProfile = profile1440p.targetProfile or SwirlUI.ProfileFourteenFortyP

    if db.profiles[targetProfile] then
        wipe(db.profiles[targetProfile])
        db.profiles[targetProfile] = data
        db.profileKeys[characterProfile] = targetProfile
    else
        db.profiles[targetProfile] = data
        db.profileKeys[characterProfile] = targetProfile
    end

    SwirlUI.SettingsChanged = true
    local displayName = profile1440p.displayName or profile1440p.name
    if notification then
        local AF = _G.AbstractFramework
        AF.ShowNotificationPopup(string.format("%s\n Imported %s", SwirlUI.NameNoCore, SwirlUI.ApplyColor(displayName, profile1440p.color)), 2)
    else
        SwirlUI.Utils:Print(string.format("Imported %s", SwirlUI.ApplyColor(displayName, profile1440p.color)))
    end

    SwirlUI.Utils:StoreProfileVersion(profile1440p)

    return db
end

function SwirlUI.Imports:ExportBasicMinimap()
    local basicMinimap = SwirlUI.Utils:GetImportProfile("BasicMinimap")
    if not basicMinimap then return false end
    local targetProfile = basicMinimap.targetProfile or SwirlUI.ProfileTenEightyP
    local data = basicMinimap.database["profiles"][targetProfile]
    return SwirlUI.Utils:Export(data, basicMinimap)
end

function SwirlUI.Imports:ExportBasicMinimap1440p()
    -- Search for the 1440p variant by short name
    local basicMinimap1440p = nil
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if profile.short == "BasicMinimap1440p" then
            basicMinimap1440p = profile
            break
        end
    end
    if not basicMinimap1440p then return false end
    local data = basicMinimap1440p.database["profiles"][SwirlUI.ProfileFourteenFortyP]
    return SwirlUI.Utils:Export(data, basicMinimap1440p)
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
