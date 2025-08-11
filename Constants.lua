local _, SwirlUI = ...

local ADDON_TITLE = C_AddOns.GetAddOnMetadata("SwirlUI", "Title")

-- text
SwirlUI.Title = ADDON_TITLE
SwirlUI.Icon = "|TInterface/AddOns/SwirlUI/media/icon.png:16:16|t"

SwirlUI.NameNoCore = SwirlUI.Title:gsub(" Core", "")
SwirlUI.HeaderNoColon = string.format("%s%s", SwirlUI.Icon, SwirlUI.NameNoCore)
SwirlUI.Header = string.format("%s:", SwirlUI.HeaderNoColon)

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
SwirlUI.ProfilesImported = false