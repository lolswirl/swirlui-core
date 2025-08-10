local _, SwirlUI = ...

local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local characterProfile = string.format("%s - %s", UnitName("player"), GetRealmName())

SwirlUI.Utils = {}

function SwirlUI.Utils:HasProfile(addonName, database, silent)
    if not IsAddOnLoaded(addonName) then
        return false
    end
    
    if not database or not database["profiles"] or not database["profiles"][SwirlUI.Profile] then
        if not silent then
            print(string.format("%s No profile found for %s", SwirlUI.Header, addonName))
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

function SwirlUI.Utils:IsProfileApplied(addonName, database)
    if not self:HasProfile(addonName, database, true) then
        return false
    end

    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = database["profileKeys"] and database["profileKeys"][profileKey]
    return activeProfile == SwirlUI.Profile
end

function SwirlUI.Utils:GetAddonStatus(addonName, database)
    if not IsAddOnLoaded(addonName) then
        return "AddOn Disabled", SwirlUI.Hostile
    end

    if not self:HasProfile(addonName, database, true) then
        return "No Profile! Import below", SwirlUI.Hostile
    end

    if self:IsProfileApplied(addonName, database) then
        return "Active", SwirlUI.Friendly
    end

    return "Ready", SwirlUI.Neutral
end

function SwirlUI.Utils:GetAddonStatusColor(addonName, database)
    local _, color = self:GetAddonStatus(addonName, database)
    return color
end

function SwirlUI.Utils:GetAddonStatusText(addonInfo)
    local addonName = addonInfo.name
    local status, statusColor = self:GetAddonStatus(addonName, addonInfo.database)
    local addonText = SwirlUI.ApplyColor(addonInfo.name or addonName, addonInfo.color)
    local statusText = SwirlUI.ApplyColor(status, statusColor)
    
    return string.format("%s: %s", addonText, statusText)
end

function SwirlUI.Utils:ApplyProfile(addonName, database, color)
    if not IsAddOnLoaded(addonName) then
        print(string.format("%s %s addon not loaded", SwirlUI.Header, SwirlUI.ApplyColor(addonName, color)))
        return false
    end
    
    if not database or not database["profiles"] or not database["profiles"][SwirlUI.Profile] then
        print(string.format("%s No profile found for %s", SwirlUI.Header, SwirlUI.ApplyColor(addonName, color)))
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

function SwirlUI.Utils:Export(data, addon, isNamespace)
    local serialized = Serialize:Serialize(data)
    local compressed = Compress:CompressDeflate(serialized)
    local encoded = Compress:EncodeForPrint(compressed)

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

    local decoded = Compress:DecodeForPrint(importProfile.string)
    local decompressed = Compress:DecompressDeflate(decoded)
    local _, data = Serialize:Deserialize(decompressed)

    local db = importProfile.database

    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}

    if addonName == "Prat-3.0" and importProfile.namespace and importProfile.namespace ~= "" then
        local decodedNamespace = Compress:DecodeForPrint(importProfile.namespace)
        local decompressedNamespace = Compress:DecompressDeflate(decodedNamespace)
        local _, namespaceData = Serialize:Deserialize(decompressedNamespace)

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
