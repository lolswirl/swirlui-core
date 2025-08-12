local _, SwirlUI = ...

local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local characterProfile = string.format("%s - %s", UnitName("player"), GetRealmName())

SwirlUI.Utils = {}

function SwirlUI.Utils:HasProfile(addon, silent)
    if not IsAddOnLoaded(addon.name) then
        return false
    end

    -- minimapstats doesn't have profiles lol
    if addon.name == "MinimapStats" then
        return true
    end
    
    if not addon.database or not addon.database["profiles"] or not addon.database["profiles"][SwirlUI.Profile] then
        if not silent then
            print(string.format("%s No profile found for %s", SwirlUI.Header, addon.name))
        end
        return false
    end
    return true
end

function SwirlUI.Utils:CheckAddOnLoaded(addon)
    if not IsAddOnLoaded(addon.name) then
        print(string.format("%s %s addon not loaded", SwirlUI.Header, SwirlUI.ApplyColor(addon.name, addon.color)))
        return false
    end
    return true
end

function SwirlUI.Utils:IsProfileApplied(addon)
    if addon.name == "MinimapStats" then
        if not addon.database or not addon.database["global"] then
            return false
        end

        local hasAllValues = true
        for key, value in pairs(addon.data) do
            if addon.database.global[key] ~= value then
                hasAllValues = false
                break
            end
        end

        return hasAllValues
    end

    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = addon.database["profileKeys"] and addon.database["profileKeys"][profileKey]
    return activeProfile == SwirlUI.Profile
end

function SwirlUI.Utils:GetAddonStatus(addon)
    if not IsAddOnLoaded(addon.name) then
        return "AddOn Disabled", SwirlUI.Hostile
    end

    if not self:HasProfile(addon, true) then
        return "No Profile! Import below", SwirlUI.Hostile
    end

    if self:IsProfileApplied(addon) then
        return "Active", SwirlUI.Friendly
    end

    return "Ready", SwirlUI.Neutral
end

function SwirlUI.Utils:GetAddonStatusColor(addon)
    local _, color = self:GetAddonStatus(addon)
    return color
end

function SwirlUI.Utils:GetAddonStatusText(addon)
    local status, statusColor = self:GetAddonStatus(addon)
    local addonText = SwirlUI.ApplyColor(addon.name, addon.color)
    local statusText = SwirlUI.ApplyColor(status, statusColor)
    
    return string.format("%s: %s", addonText, statusText)
end

function SwirlUI.Utils:ApplyProfile(profile)
    if not IsAddOnLoaded(profile.name) then
        print(string.format("%s %s addon not loaded", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
        return false
    end

    if profile.name == "MinimapStats" then
        if not profile.database or not profile.database["global"] then
            print(string.format("%s No profile found for %s", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
            return false
        end

        SwirlUI.Imports:ImportMinimapStats()
        print(string.format("%s Applied %s profile", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
        return true
    end

    if not profile.database or not profile.database["profiles"] or not profile.database["profiles"][SwirlUI.Profile] then
        print(string.format("%s No profile found for %s", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
        return false
    end
    
    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = profile.database["profileKeys"] and profile.database["profileKeys"][profileKey]

    if activeProfile == SwirlUI.Profile then
        print(string.format("%s %s profile is already applied", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
    else
        if not profile.database["profileKeys"] then
            profile.database["profileKeys"] = {}
        end
        profile.database["profileKeys"][profileKey] = SwirlUI.Profile
        print(string.format("%s Applied %s profile", SwirlUI.Header, SwirlUI.ApplyColor(profile.name, profile.color)))
    end
    return true
end

function SwirlUI.Utils:GetImportProfile(identifier, searchBy)
    searchBy = searchBy or "name"
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if profile[searchBy] == identifier then
            return profile
        end
    end
    
    return nil
end

function SwirlUI.Utils:GetApplyAddon(identifier, searchBy)
    searchBy = searchBy or "name"
    
    for _, addon in ipairs(SwirlUI.ApplyAddons) do
        if addon[searchBy] == identifier then
            return addon
        end
    end
    
    return nil
end

function SwirlUI.Utils:GetAllProfiles()
    local allProfiles = {}
    
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        table.insert(allProfiles, profile)
    end
    
    for _, addon in ipairs(SwirlUI.ApplyAddons) do
        table.insert(allProfiles, addon)
    end
    
    return allProfiles
end

function SwirlUI.Utils:Decode(data)
    local decoded = Compress:DecodeForPrint(data)
    local decompressed = Compress:DecompressDeflate(decoded)
    local _, result = Serialize:Deserialize(decompressed)
    return result
end

function SwirlUI.Utils:Encode(data)
    local serialized = Serialize:Serialize(data)
    local compressed = Compress:CompressDeflate(serialized)
    local encoded = Compress:EncodeForPrint(compressed)
    return encoded
end

function SwirlUI.Utils:Export(data, addon, isNamespace)
    local encoded = self:Encode(data)

    local title = string.format("%s Exported", addon.name)
    if isNamespace then
        title = string.format("%s Namespaces Exported", addon.name)
    end

    SwirlUI.CreateStatusDialog(title, nil, encoded)

    return true
end

function SwirlUI.Utils:Import(addonName)
    local importProfile = SwirlUI.Utils:GetImportProfile(addonName)
    if not importProfile or not SwirlUI.Utils:CheckAddOnLoaded(importProfile) then
        return false
    end

    local data = SwirlUI.Utils:Decode(importProfile.string)

    local db = importProfile.database

    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}

    if addonName == "Prat-3.0" and importProfile.namespace and importProfile.namespace ~= "" then
        local namespaceData = SwirlUI.Utils:Decode(importProfile.namespace)

        if db.namespaces then
            wipe(db.namespaces)
        end
        db.namespaces = namespaceData
    end

    if db.profiles[SwirlUI.Profile] then
        wipe(db.profiles[SwirlUI.Profile])
        db.profiles[SwirlUI.Profile] = data
        db.profileKeys[characterProfile] = SwirlUI.Profile
    else
        db.profiles[SwirlUI.Profile] = data
        db.profileKeys[characterProfile] = SwirlUI.Profile
    end

    SwirlUI.ProfilesImported = true
    print(string.format("%s Imported %s", SwirlUI.Header, SwirlUI.ApplyColor(importProfile.name, importProfile.color)))

    return db
end
