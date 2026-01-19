local addonName, SwirlUI = ...
local U = SwirlUI.Utils
local AF = _G.AbstractFramework

local _, UNIT_CLASS = UnitClass("player")

AF.AddColor(SwirlUI.Hostile, SwirlUI.Hostile)
AF.AddColor(SwirlUI.Friendly, SwirlUI.Friendly)
AF.AddColor(SwirlUI.Neutral, SwirlUI.Neutral)
AF.AddColor(SwirlUI.Orange, SwirlUI.Orange)
AF.RegisterAddon(addonName)
AF.SetAddonAccentColor(
    addonName,
    AF.GetColorHex(UNIT_CLASS),
    {0.15, 0.15, 0.15, 1},
    AF.GetColorHex(UNIT_CLASS, 0.7)
)
-- AF.AddColor("accent", AF.GetColorHex(UNIT_CLASS))
-- AF.AddColor("accent_hover", AF.GetColorHex(UNIT_CLASS))
-- AF.AddButtonColor("accent_hover", {0.15, 0.15, 0.15, 1}, AF.GetColorTable("accent", 0.7))
AF.AddColor("background", {0.024, 0.024, 0.031, 0.75})
AF.AddColor("background2", {0.024, 0.024, 0.031, 0.3})

-- override AF fonts with outlines
AF.CreateFont(SwirlUI.Title, "AF_FONT_TITLE", SwirlUI.Font, SwirlUI.FontSize + 2, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_NORMAL", SwirlUI.Font, SwirlUI.FontSize + 1, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_CHAT", SwirlUI.Font, SwirlUI.FontSize + 1, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_OUTLINE", SwirlUI.Font, SwirlUI.FontSize + 1, "OUTLINE", false, "accent")
AF.CreateFont(SwirlUI.Title, "AF_FONT_SMALL", SwirlUI.Font, SwirlUI.FontSize - 1, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_CHINESE", SwirlUI.Font, SwirlUI.FontSize + 2, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_TOOLTIP_HEADER", SwirlUI.Font, SwirlUI.FontSize + 2, "OUTLINE", false, "white")
AF.CreateFont(SwirlUI.Title, "AF_FONT_TOOLTIP", SwirlUI.Font, SwirlUI.FontSize + 1, "OUTLINE", false, "white")


SwirlUI.frames = SwirlUI.frames or {}

local lastShownTab
local profilesBtn, optionsBtn

local function CreateTabButtons(optionsFrame)
    profilesBtn = AF.CreateButton(optionsFrame, "Profiles", addonName, 220, 21)
    optionsBtn = AF.CreateButton(optionsFrame, "Options", addonName, 221, 21)

    profilesBtn:SetFrameLevel(optionsFrame:GetFrameLevel() + 2)
    optionsBtn:SetFrameLevel(optionsFrame:GetFrameLevel() + 2)

    profilesBtn:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 0, 0)
    optionsBtn:SetPoint("LEFT", profilesBtn, "RIGHT", -1, 0)

    local function ShowTab(tab)
        if lastShownTab ~= tab then
            AF.Fire("ShowOptionsTab", tab.id)
            lastShownTab = tab
        end
    end

    AF.CreateButtonGroup({profilesBtn, optionsBtn}, ShowTab, function() end, function() end, function() end, function() end)
end

function SwirlUI.ShowImportGUI_AF()
    if _G.SWIRLUI_AF_FRAME then
        _G.SWIRLUI_AF_FRAME:Show()
        if lastShownTab then
            AF.Fire("ShowOptionsTab", lastShownTab)
        else
            profilesBtn:Click()
        end
        return
    end

    local frame = AF.CreateHeaderedFrame(AF.UIParent, "SWIRLUI_AF_FRAME",
        SwirlUI.HeaderNoColon, 440, 475)
    AF.SetPoint(frame, "CENTER", UIParent, "CENTER", 0, 0)
    frame:SetTitleColor("white")
    frame:SetFrameLevel(100)
    frame:SetTitleJustify("CENTER")
    
    frame:SetScript("OnHide", function()
        if SwirlUI.SettingsChanged then
            SwirlUI.SettingsChanged = false
            SwirlUI:ReloadDialog(frame)
        end
    end)

    _G["SwirlUI_AF_Frame"] = frame
    table.insert(UISpecialFrames, "SwirlUI_AF_Frame")

    SwirlUI.frames.optionsFrame = frame

    local supportGroup = AF.CreateTitledPane(frame, "Support", 430, 65)
    AF.SetPoint(supportGroup, "BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
    supportGroup:SetFrameLevel(frame:GetFrameLevel() + 3)

    local helpText = AF.CreateFontString(supportGroup, string.format("Join the discord for %s support", SwirlUI.HeaderNoColon), "white", "AF_FONT_NORMAL")
    AF.SetPoint(helpText, "TOPLEFT", 0, -25)

    local discordBox = AF.CreateEditBox(supportGroup, nil, 430, 20)
    AF.SetPoint(discordBox, "TOPLEFT", 0, -45)
    discordBox:SetText("https://discord.gg/ZU5rhXtbNd")
    discordBox:SetNotUserChangable(true)
    discordBox:SetCursorPosition(0)

    CreateTabButtons(frame)

    if not lastShownTab then
        profilesBtn:Click()
    end

    frame:Show()
    _G.SWIRLUI_AF_FRAME = frame
end

function SwirlUI.ShowExportGUI_AF()
    if _G.SWIRLUI_AF_EXPORT_FRAME then
        _G.SWIRLUI_AF_EXPORT_FRAME:Show()
        return
    end

    local buttonHeight = 24
    local spacing = 5

    local height = (#SwirlUI.ImportProfiles * buttonHeight) + ((#SwirlUI.ImportProfiles - 1) * spacing) + 35

    local frame = AF.CreateHeaderedFrame(AF.UIParent, "SWIRLUI_AF_EXPORT_FRAME",
        SwirlUI.HeaderNoColon .. " Export", 310, height)
    AF.SetPoint(frame, "CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameLevel(100)
    frame:SetTitleColor("white")
    frame:SetTitleJustify("CENTER")
    frame:SetScript("OnHide", function()
        frame:Hide()
    end)
    _G["SwirlUI_AF_EXPORT_FRAME"] = frame
    table.insert(UISpecialFrames, "SwirlUI_AF_EXPORT_FRAME")

    local exportGroup = AF.CreateTitledPane(frame, "Export Profiles", 300, 260)
    AF.SetPoint(exportGroup, "TOPLEFT", 5, -5)

    local yOffset = -25
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        local btn = AF.CreateButton(exportGroup, string.format("Export %s", SwirlUI.ApplyColor(profile.name, profile.color)), addonName, 300, 24)
        AF.SetPoint(btn, "TOPLEFT", 0, yOffset)
        yOffset = yOffset - 29
        btn:SetOnClick(function()
            local exportFunction = string.format("Export%s", profile.short or profile.name)
            if SwirlUI.Imports[exportFunction] then
                SwirlUI.Imports[exportFunction](SwirlUI.Imports)
            else
                U:Print(string.format("Export function %s not found!", exportFunction))
            end
        end)
    end

    frame:Show()
    return frame
end

function SwirlUI:ReloadDialog(frame)
    local text = "Reload the UI to apply changes?"
    AF.ShowConfirmPopup(text, function()
        C_UI.Reload()
    end, function()
    end)
end

function SwirlUI.CreateStatusDialog(title, content, editBoxContent)
    local width, height = 400, 25
    if editBoxContent then height = height + 40 end
    if content then height = height + 30 end
    local frame = AF.CreateHeaderedFrame(AF.UIParent, nil, title, width, height)
    AF.SetPoint(frame, "CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameLevel(200)
    frame:SetTitleColor("white")
    frame:SetTitleJustify("CENTER")
    frame:SetMovable(false)
    frame:SetResizable(false)
    frame:SetScript("OnHide", function()
        frame:Hide()
    end)
    frame:Show()

    local yOffset = -5
    if content then
        local contentText = AF.CreateFontString(frame, content, "white", "AF_FONT_NORMAL")
        AF.SetPoint(contentText, "TOPLEFT", frame, "TOPLEFT", 5, yOffset)
        yOffset = yOffset - 30
    end

    local editBox
    if editBoxContent then
        editBox = AF.CreateEditBox(frame, nil, width - 10, 24)
        AF.SetPoint(editBox, "TOPLEFT", frame, "TOPLEFT", 5, yOffset)
        editBox:SetText(editBoxContent)
        editBox:SetNotUserChangable(true)
        editBox:SetCursorPosition(0)
        editBox:HighlightText()
        editBox:SetFocus()
        yOffset = yOffset - 40
    end

    local okBtn = AF.CreateButton(frame, "OK", addonName, 80, 24)
    AF.SetPoint(okBtn, "BOTTOM", frame, "BOTTOM", 0, 5)
    okBtn:SetOnClick(function()
        frame:Hide()
    end)
    
    return frame
end

SLASH_SWIRLUI1 = "/swirlui"
SLASH_SWIRLUI2 = "/sui"
SLASH_SWIRLUI3 = "/swirl"
SlashCmdList["SWIRLUI"] = function(msg)
    if msg == "export" then
        SwirlUI.ShowExportGUI_AF()
    else
        SwirlUI.ShowImportGUI_AF()
    end
end