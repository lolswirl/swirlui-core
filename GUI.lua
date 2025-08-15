local AF = _G.AbstractFramework
local _, SwirlUI = ...

local _, UNIT_CLASS = UnitClass("player")

AF.AddColor(SwirlUI.Hostile, SwirlUI.Hostile)
AF.AddColor(SwirlUI.Friendly, SwirlUI.Friendly)
AF.AddColor(SwirlUI.Neutral, SwirlUI.Neutral)
AF.AddColor("accent", AF.GetColorHex(UNIT_CLASS))
AF.AddButtonColor("accent_hover", {0.15, 0.15, 0.15, 1}, AF.GetColorTable("accent", 0.7))
AF.AddColor("background", {0.024, 0.024, 0.031, 0.75})
AF.AddColor("background2", {0.024, 0.024, 0.031, 0.3})

function SwirlUI.ShowImportGUI_AF()
    if _G.SWIRLUI_AF_FRAME then
        _G.SWIRLUI_AF_FRAME:Show()
        if SwirlUI.UpdateStatusDisplay_AF then
            SwirlUI.UpdateStatusDisplay_AF()
        end
        return
    end

    local frame = AF.CreateHeaderedFrame(AF.UIParent, "SWIRLUI_AF_FRAME",
        SwirlUI.HeaderNoColon, 440, 450)
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

    local statusGroup = AF.CreateTitledPane(frame, "Profile Status", 430, 200)
    AF.SetPoint(statusGroup, "TOPLEFT", frame, "TOPLEFT", 5, -5)

    local statusScrollLists = {}

    local applyBtn = AF.CreateButton(statusGroup, "Apply Profiles", "accent_hover", 430, 24)
    AF.SetPoint(applyBtn, "BOTTOMLEFT", statusGroup, "BOTTOMLEFT", 0, -45)
    applyBtn:SetOnClick(function()
        SwirlUI.Imports:ApplyProfiles()
        SwirlUI.UpdateStatusDisplay_AF()
    end)

    local uiScaleGroup = AF.CreateTitledPane(frame, "UI Scale", 430, 100)
    AF.SetPoint(uiScaleGroup, "TOPLEFT", statusGroup, "BOTTOMLEFT", 0, -55)

    local uiScaleSlider = AF.CreateSlider(uiScaleGroup, "UI Scale", 430, 0.1, 2, 0.01, false, true)
    AF.SetPoint(uiScaleSlider, "TOPLEFT", uiScaleGroup, "TOPLEFT", 0, -42)
    uiScaleSlider:SetValue(tonumber(GetCVar("UIScale")))
    uiScaleSlider:SetAfterValueChanged(function(value)
        UIParent:SetScale(value)
        SetCVar("UIScale", value)
        SwirlUI.SettingsChanged = true
    end)

    local presetScales = {0.53, 0.63, 0.71, 1}
    for i, scale in ipairs(presetScales) do
        local scaleBtn = AF.CreateButton(uiScaleGroup, tostring(scale), "accent_hover", 100, 24)
        AF.SetPoint(scaleBtn, "TOPLEFT", uiScaleSlider, "BOTTOMLEFT", 6 + (i-1) * 106, -20)
        scaleBtn:SetOnClick(function()
            SetCVar("UIScale", scale)
            UIParent:SetScale(scale)
            uiScaleSlider:SetValue(scale)
            SwirlUI.SettingsChanged = true
        end)
    end

    local supportGroup = AF.CreateTitledPane(frame, "Support", 430, 90)
    AF.SetPoint(supportGroup, "TOPLEFT", uiScaleGroup, "BOTTOMLEFT", 0, -10)

    local helpText = AF.CreateFontString(supportGroup, string.format("Join the discord for %s support", SwirlUI.HeaderNoColon), "white", "AF_FONT_NORMAL")
    AF.SetPoint(helpText, "TOPLEFT", 0, -25)

    local discordBox = AF.CreateEditBox(supportGroup, nil, 430, 20)
    AF.SetPoint(discordBox, "TOPLEFT", 0, -45)
    discordBox:SetText("https://discord.gg/ZU5rhXtbNd")
    discordBox:SetNotUserChangable(true)
    discordBox:SetCursorPosition(0)

    function SwirlUI.CreateStatusDisplay_AF()
        for _, data in pairs(statusScrollLists) do
            data.scrollList:Hide()
            data.scrollList:Reset()
        end
        statusScrollLists = {}
        
        local newStatusGroups = {}
        local newAllProfiles = SwirlUI.Utils:GetAllProfiles()

        for _, profile in ipairs(newAllProfiles) do
            AF.AddColor(profile.name, profile.color)
            local status = SwirlUI.Utils:GetAddonStatus(profile)
            
            if not newStatusGroups[status] then
                newStatusGroups[status] = {}
            end
            table.insert(newStatusGroups[status], profile)
        end

        local newStatusList = {}
        for status, _ in pairs(newStatusGroups) do
            table.insert(newStatusList, status)
        end
        
        table.sort(newStatusList, function(a, b)
            local orderA = SwirlUI.STATUS_ORDER[a] or 999
            local orderB = SwirlUI.STATUS_ORDER[b] or 999
            if orderA == orderB then
                return a < b
            end
            return orderA < orderB
        end)

        local totalWidth = 430
        local listCount = #newStatusList
        local spacing = 10
        local columnWidth = math.floor((totalWidth - (listCount - 1) * spacing) / listCount)
        local listHeight = (#newAllProfiles + 1) * 22

        for i, status in ipairs(newStatusList) do
            local profiles = newStatusGroups[status]
            local color = SwirlUI.Utils:GetAddonStatusColor(profiles[1])
            
            local xOffset = math.floor((i - 1) * (columnWidth + spacing))
            
            -- annoying margining in ScrollList from BorderedFrame
            if listCount == 2 then
                if i == 1 then
                    xOffset = xOffset + 1
                elseif i == 2 then
                    xOffset = xOffset - 1
                end
            elseif listCount == 3 then
                if i == 1 or i == 3 then
                    xOffset = xOffset + 1
                end
            end
            
            local scrollList = AF.CreateScrollList(statusGroup, nil, 5, 5, 7, 22, 2, "background2", color)
            AF.SetPoint(scrollList, "TOPLEFT", statusGroup, "TOPLEFT", xOffset, -40)
            AF.SetSize(scrollList, columnWidth, listHeight)
            scrollList:SetLabel(status, color)
            scrollList.accentColor = color
            
            if scrollList.scrollThumb then
                scrollList.scrollThumb:SetBackdropColor(AF.GetColorRGB(color, 0.7))
                scrollList.scrollThumb.r, scrollList.scrollThumb.g, scrollList.scrollThumb.b = AF.GetColorRGB(color)
            end
            
            local statusWidgets = {}
            for _, profile in ipairs(profiles) do
                local addonName = profile.name or profile.short
                local addonColor = SwirlUI.Utils:GetAddonStatusColor(profile)
                
                local btn = AF.CreateButton(scrollList.slotFrame, SwirlUI.ApplyColor(addonName, profile.color), addonColor .. "_transparent", nil, 22, nil, "none", "")
                btn:SetTextJustifyH("LEFT")
                btn:SetTextColor(AF.GetColorRGB(addonColor))
                
                if profile.string or profile.data then
                    btn:SetOnClick(function()
                        local importFunction = string.format("Import%s", profile.short or profile.name)
                        if SwirlUI.Imports[importFunction] then
                            SwirlUI.Imports[importFunction](SwirlUI.Imports)
                            SwirlUI.UpdateStatusDisplay_AF()
                        end
                    end)
                end

                local tooltip = SwirlUI.STATUS_TOOLTIPS[status]
                if not profile.string and not profile.data then
                    tooltip = "Import profile through '/wago'"
                end
                AF.SetTooltips(btn, "ANCHOR_CURSOR_RIGHT", 0, 2, "", tooltip)

                table.insert(statusWidgets, btn)
            end
            
            scrollList:SetWidgets(statusWidgets)
            statusScrollLists[status] = {scrollList = scrollList}
        end
    end

    function SwirlUI.UpdateStatusDisplay_AF()
        SwirlUI.CreateStatusDisplay_AF()
    end

    SwirlUI.CreateStatusDisplay_AF()

    SwirlUI.UpdateStatusDisplay = SwirlUI.UpdateStatusDisplay_AF

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
        local btn = AF.CreateButton(exportGroup, string.format("Export %s", SwirlUI.ApplyColor(profile.name, profile.color)), "accent_hover", 300, 24)
        AF.SetPoint(btn, "TOPLEFT", 0, yOffset)
        yOffset = yOffset - 29
        btn:SetOnClick(function()
            local exportFunction = string.format("Export%s", profile.short or profile.name)
            if SwirlUI.Imports[exportFunction] then
                SwirlUI.Imports[exportFunction](SwirlUI.Imports)
            else
                print(string.format("%s Export function %s not found!", SwirlUI.Header, exportFunction))
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