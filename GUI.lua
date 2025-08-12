local _, SwirlUI = ...
local AceGUI = LibStub("AceGUI-3.0")

local function CreateStatusDialog(title, content, editBoxContent)
    local popupName = "SWIRLUI_STATUS_" .. math.random(1000, 9999)

    StaticPopupDialogs[popupName] = {
        text = title .. (content and ("\n\n" .. content) or ""),
        button1 = "OK",
        hasEditBox = editBoxContent and true or false,
        editBoxWidth = editBoxContent and 350 or nil,
        OnShow = function(self)
            if editBoxContent then
                self.EditBox:SetText(editBoxContent)
                self.EditBox:HighlightText()
                self.EditBox:SetFocus()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }

    StaticPopup_Show(popupName)
end

local function CreateImportGUI()
    if SwirlUI.ImportFrame then
        SwirlUI.ImportFrame:Show()
        if SwirlUI.UpdateStatusDisplay then
            SwirlUI.UpdateStatusDisplay()
        end
        if SwirlUI.UpdateImportButtons then
            SwirlUI.UpdateImportButtons()
        end
        return
    end

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(SwirlUI.HeaderNoColon)
    frame:SetWidth(400)
    frame:SetHeight(600)
    frame:SetLayout("Flow")
    frame:SetStatusText(string.format("%s Profile Manager", SwirlUI.HeaderNoColon))
    
    frame:SetCallback("OnClose", function(widget)
        widget:Hide()
        if SwirlUI.SettingsChanged then
            SwirlUI.SettingsChanged = false
            SwirlUI:ReloadDialog()
        end
    end)

    _G["SwirlUI_Frame"] = frame.frame
    table.insert(UISpecialFrames, "SwirlUI_Frame")

    local statusGroup = AceGUI:Create("InlineGroup")
    statusGroup:SetTitle("Profile Status")
    statusGroup:SetFullWidth(true)
    statusGroup:SetHeight(120)
    statusGroup:SetLayout("Flow")
    frame:AddChild(statusGroup)

    local statusText = AceGUI:Create("Label")
    statusText:SetFullWidth(true)
    statusText:SetHeight(150)
    statusText:SetText("")
    statusText:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    statusGroup:AddChild(statusText)
    
    local applyBtn = AceGUI:Create("Button")
    applyBtn:SetText("Apply Profiles")
    applyBtn:SetFullWidth(true)
    applyBtn:SetCallback("OnClick", function()
        SwirlUI.Imports:ApplyProfiles()
        UpdateStatusDisplay()
    end)
    statusGroup:AddChild(applyBtn)

    local importGroup = AceGUI:Create("InlineGroup")
    importGroup:SetTitle("Import Profiles")
    importGroup:SetFullWidth(true)
    importGroup:SetLayout("Flow")
    frame:AddChild(importGroup)

    local importAllBtn = AceGUI:Create("Button")
    importAllBtn:SetText("Import All")
    importAllBtn:SetFullWidth(true)
    importAllBtn:SetCallback("OnClick", function()
        SwirlUI.Imports:ImportAll()
        UpdateStatusDisplay()
        UpdateImportButtons()
    end)
    importGroup:AddChild(importAllBtn)

    local importButtons = {}
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        local btn = AceGUI:Create("Button")
        btn:SetText(profile.name)
        btn:SetWidth(120)
        btn:SetCallback("OnClick", function()
            local importFunction = string.format("Import%s", profile.short or profile.name)
            if SwirlUI.Imports[importFunction] then
                SwirlUI.Imports[importFunction](SwirlUI.Imports)
                UpdateStatusDisplay()
                UpdateImportButtons()
            else
                print(string.format("%s Import function %s not found!", SwirlUI.Header, importFunction))
            end
        end)
        importGroup:AddChild(btn)
        table.insert(importButtons, {button = btn, profile = profile})
    end

    local uiScaleGroup = AceGUI:Create("InlineGroup")
    uiScaleGroup:SetTitle("UI Scale")
    uiScaleGroup:SetFullWidth(true)
    uiScaleGroup:SetLayout("Flow")
    frame:AddChild(uiScaleGroup)

    local uiScale = AceGUI:Create("Slider")
    uiScale:SetLabel("UI Scale")
    uiScale:SetRelativeWidth(1)
    uiScale:SetSliderValues(0.1, 2, 0.01)
    uiScale:SetValue(tonumber(GetCVar("UIScale")))
    uiScale:SetCallback("OnValueChanged", function(widget, event, value)
        UIParent:SetScale(value)
        uiScale:SetValue(value)
        SwirlUI.SettingsChanged = true
    end)
    uiScaleGroup:AddChild(uiScale)

    local presets = {0.53, 0.63, 0.71, 1}
    for _, scale in ipairs(presets) do
        local scaleBtn = AceGUI:Create("Button")
        scaleBtn:SetText(tostring(scale))
        scaleBtn:SetRelativeWidth(0.25)
        scaleBtn:SetCallback("OnClick", function()
            SetCVar("UIScale", scale)
            UIParent:SetScale(scale)
            uiScale:SetValue(scale)
            SwirlUI.SettingsChanged = true
        end)
        uiScaleGroup:AddChild(scaleBtn)
    end

    local helpGroup = AceGUI:Create("InlineGroup")
    helpGroup:SetTitle("Support")
    helpGroup:SetFullWidth(true)
    helpGroup:SetLayout("Flow")
    frame:AddChild(helpGroup)

    local helpLabel = AceGUI:Create("Label")
    helpLabel:SetFullWidth(true)
    helpLabel:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    helpLabel:SetText(string.format("Join Swirl's Discord for %s support", SwirlUI.HeaderNoColon))
    helpGroup:AddChild(helpLabel)

    local discordBox = AceGUI:Create("EditBox")
    discordBox:SetFullWidth(true)
    discordBox:SetText("https://discord.gg/ZU5rhXtbNd")
    discordBox:SetLabel("")
    discordBox:SetCallback("OnEnterPressed", function(widget)
        widget:ClearFocus()
    end)
    helpGroup:AddChild(discordBox)

    function UpdateImportButtons()
        for _, btnData in ipairs(importButtons) do
            local color = SwirlUI.Utils:GetAddonStatusColor(btnData.profile)
            btnData.button:SetText(SwirlUI.ApplyColor(btnData.profile.name, color))
        end
    end

    function UpdateStatusDisplay()
        local statusLines = {}
        
        for _, profile in ipairs(SwirlUI.ImportProfiles) do
            table.insert(statusLines, SwirlUI.Utils:GetAddonStatusText(profile))
        end
        
        for _, addon in ipairs(SwirlUI.ApplyAddons) do
            table.insert(statusLines, SwirlUI.Utils:GetAddonStatusText(addon))
        end
        
        statusText:SetText(table.concat(statusLines, "\n"))
    end

    UpdateImportButtons()
    UpdateStatusDisplay()

    SwirlUI.UpdateImportButtons = UpdateImportButtons
    SwirlUI.UpdateStatusDisplay = UpdateStatusDisplay

    frame:Show()
    
    SwirlUI.ImportFrame = frame
    return frame
end

local function CreateExportGUI()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(string.format("%s Export", SwirlUI.HeaderNoColon))
    frame:SetStatusText(string.format("%s Profile Export", SwirlUI.HeaderNoColon))
    frame:SetLayout("Fill")
    frame:SetWidth(400)
    frame:SetHeight(350)
    
    frame:SetCallback("OnClose", function(widget)
        widget:Hide()
    end)
    
    _G["SwirlUI_Export_Frame"] = frame.frame
    table.insert(UISpecialFrames, "SwirlUI_Export_Frame")

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    local exportGroup = AceGUI:Create("InlineGroup")
    exportGroup:SetTitle("Export Profiles")
    exportGroup:SetFullWidth(true)
    exportGroup:SetLayout("Flow")
    scroll:AddChild(exportGroup)

    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        local btn = AceGUI:Create("Button")
        btn:SetText(string.format("Export %s", profile.name))
        btn:SetFullWidth(true)
        btn:SetCallback("OnClick", function()
            local exportFunction = string.format("Export%s", profile.short or profile.name)
            if SwirlUI.Imports[exportFunction] then
                SwirlUI.Imports[exportFunction](SwirlUI.Imports)
            else
                print(string.format("%s Export function %s not found!", SwirlUI.Header, exportFunction))
            end
        end)
        
        if not IsAddOnLoaded(profile.name) then
            btn:SetDisabled(true)
        end
        
        exportGroup:AddChild(btn)
    end

    frame:Show()
    return frame
end

function SwirlUI:ReloadDialog()
    StaticPopupDialogs["SWIRLUI_RELOAD"] = {
        text = "Reload the UI to apply changes?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("SWIRLUI_RELOAD")
end

SLASH_SWIRLUI1 = "/swirlui"
SLASH_SWIRLUI2 = "/sui"
SLASH_SWIRLUI3 = "/swirl"
SlashCmdList["SWIRLUI"] = function(msg)
    if msg == "export" then
        CreateExportGUI()
    else
        CreateImportGUI()
    end
end

SwirlUI.CreateImportGUI = CreateImportGUI
SwirlUI.CreateExportGUI = CreateExportGUI
SwirlUI.CreateStatusDialog = CreateStatusDialog
