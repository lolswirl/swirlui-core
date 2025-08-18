local _, SwirlUI = ...

local ADDON_TITLE = C_AddOns.GetAddOnMetadata("SwirlUI", "Title")

-- text
SwirlUI.Title = ADDON_TITLE
SwirlUI.Icon = "|TInterface/AddOns/SwirlUI/media/icon.png:16:16|t"

SwirlUI.NameNoCore = SwirlUI.Title:gsub(" Core", "")
SwirlUI.HeaderNoColon = string.format("%s%s", SwirlUI.Icon, SwirlUI.NameNoCore)
SwirlUI.Header = string.format("%s »", SwirlUI.HeaderNoColon)

-- font
SwirlUI.Font = "Interface\\AddOns\\SharedMedia_SwirlUI\\font\\Swirl.ttf"
SwirlUI.FontSize = 12
SwirlUI.FontSizeSmall = 8

-- colors
SwirlUI.Friendly = "49AF4C"
SwirlUI.Neutral = "D8C45B"
SwirlUI.Hostile = "C63F3F"

SwirlUI.ApplyColor = function(text, color)
    return string.format("|cFF%s%s|r", color, text)
end

-- profiles
SwirlUI.Profile = "swirl ui"
SwirlUI.ProfileTenEightyP = "swirl ui 1080p"
SwirlUI.SettingsChanged = false

-- status
SwirlUI.STATUS = {
    ADDON_DISABLED = "AddOn Disabled",
    NO_PROFILE = "No Profile! Import below",
    NEW_VERSION_AVAILABLE = "New Version Available",
    ACTIVE = "Active",
    READY = "Ready",
    DISABLED = "Disabled"
}

SwirlUI.STATUS_ORDER = {
    [SwirlUI.STATUS.ACTIVE] = 1,
    [SwirlUI.STATUS.READY] = 2,
    [SwirlUI.STATUS.NEW_VERSION_AVAILABLE] = 3,
    [SwirlUI.STATUS.ADDON_DISABLED] = 4,
    [SwirlUI.STATUS.NO_PROFILE] = 5
}

SwirlUI.STATUS_TOOLTIPS = {
    [SwirlUI.STATUS.ACTIVE] = "Click to reimport profile",
    [SwirlUI.STATUS.READY] = "Click to apply profile",
    [SwirlUI.STATUS.NO_PROFILE] = "Click to import profile",
    [SwirlUI.STATUS.NEW_VERSION_AVAILABLE] = "Click to reimport profile (new version detected)",
    [SwirlUI.STATUS.ADDON_DISABLED] = "Enable addon to import profile"
}