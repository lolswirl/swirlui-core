local _, SwirlUI = ...
local AF = _G.AbstractFramework
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local characterProfile = string.format("%s - %s", UnitName("player"), GetRealmName())

SwirlUI.Utils = {}

function SwirlUI.Utils:Print(message)
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then
        return
    end
    print(string.format("%s %s", SwirlUI.Header, message))
end

function SwirlUI.Utils:HasProfile(addon, silent)
    if not IsAddOnLoaded(addon.name) then
        return false
    end
    
    if not addon.database or not addon.database["profiles"] or 
       (not addon.database["profiles"][SwirlUI.Profile] and not addon.database["profiles"][SwirlUI.ProfileTenEightyP]) then
        if not silent then
            self:Print(string.format("No profile found for %s", SwirlUI.ApplyColor(addon.name, addon.color)))
        end
        return false
    end
    return true
end

function SwirlUI.Utils:CheckAddOnLoaded(addon)
    if not IsAddOnLoaded(addon.name) then
        self:Print(string.format("%s addon not loaded", SwirlUI.ApplyColor(addon.name, addon.color)))
        return false
    end
    return true
end

function SwirlUI.Utils:IsProfileApplied(addon)

    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = addon.database["profileKeys"] and addon.database["profileKeys"][profileKey]
    return activeProfile == SwirlUI.Profile or activeProfile == SwirlUI.ProfileTenEightyP
end

function SwirlUI.Utils:GetAddonStatus(addon)
    if not IsAddOnLoaded(addon.name) then
        return SwirlUI.STATUS.ADDON_DISABLED, SwirlUI.Hostile
    end

    if not self:HasProfile(addon, true) then
        return SwirlUI.STATUS.NO_PROFILE, SwirlUI.Hostile
    end

    if self:IsProfileVersionChanged(addon) then
        return SwirlUI.STATUS.NEW_VERSION_AVAILABLE, SwirlUI.Orange
    end

    if self:IsProfileApplied(addon) then
        return SwirlUI.STATUS.ACTIVE, SwirlUI.Friendly
    end

    return SwirlUI.STATUS.READY, SwirlUI.Neutral
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
        self:Print(string.format("%s addon not loaded", SwirlUI.ApplyColor(profile.name, profile.color)))
        return false
    end

    if not profile.database or not profile.database["profiles"] or 
       (not profile.database["profiles"][SwirlUI.Profile] and not profile.database["profiles"][SwirlUI.ProfileTenEightyP]) then
        self:Print(string.format("No profile found for %s", SwirlUI.ApplyColor(profile.name, profile.color)))
        return false
    end
    
    local profileKey = string.format("%s - %s", UnitName("player"), GetRealmName())
    local activeProfile = profile.database["profileKeys"] and profile.database["profileKeys"][profileKey]

    if activeProfile == SwirlUI.Profile or activeProfile == SwirlUI.ProfileTenEightyP then
        self:Print(string.format("%s profile is already applied", SwirlUI.ApplyColor(profile.name, profile.color)))
    else
        if not profile.database["profileKeys"] then
            profile.database["profileKeys"] = {}
        end
        profile.database["profileKeys"][profileKey] = SwirlUI.Profile
        self:Print(string.format("Applied %s profile", SwirlUI.ApplyColor(profile.name, profile.color)))
    end

    self:StoreProfileVersion(profile)
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

function SwirlUI.Utils:Import(addonName, notification)
    local importProfile = SwirlUI.Utils:GetImportProfile(addonName)
    if not importProfile or not SwirlUI.Utils:CheckAddOnLoaded(importProfile) then
        return false
    end

    local data = SwirlUI.Utils:Decode(importProfile.string)

    local db = importProfile.database

    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}

    if db.profiles[SwirlUI.Profile] then
        wipe(db.profiles[SwirlUI.Profile])
        db.profiles[SwirlUI.Profile] = data
        db.profileKeys[characterProfile] = SwirlUI.Profile
    else
        db.profiles[SwirlUI.Profile] = data
        db.profileKeys[characterProfile] = SwirlUI.Profile
    end

    SwirlUI.SettingsChanged = true
    if notification then
        AF.ShowNotificationPopup(string.format("%s\n Imported %s", SwirlUI.NameNoCore, SwirlUI.ApplyColor(importProfile.name, importProfile.color)), 2)
    else
        self:Print(string.format("Imported %s", SwirlUI.ApplyColor(importProfile.name, importProfile.color)))
    end

    self:StoreProfileVersion(importProfile)

    return db
end

function SwirlUI.Utils:GetStoredProfileVersion(profile)
    if not SwirlUIDB or not SwirlUIDB.profileVersions then
        return nil
    end
    return SwirlUIDB.profileVersions[profile.name]
end

function SwirlUI.Utils:StoreProfileVersion(profile)
    if not SwirlUIDB then
        SwirlUIDB = { profileVersions = {} }
    end
    if not SwirlUIDB.profileVersions then
        SwirlUIDB.profileVersions = {}
    end

    SwirlUIDB.profileVersions[profile.name] = profile.version
end

function SwirlUI.Utils:IsProfileVersionChanged(profile)
    if not profile.version then return end

    local storedVersion = self:GetStoredProfileVersion(profile)

    if not storedVersion then
        return true
    end
    
    return profile.version ~= storedVersion
end