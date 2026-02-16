local addonName, SwirlUI = ...
local AF = _G.AbstractFramework

local optionsTab

local function SetGroupHoverEffect(group)
    group:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(AF.GetColorRGB(addonName))
    end)

    group:SetScript("OnLeave", function(self)
        -- check if cursor is still in bounds in case of child elements *technically* leaving the group
        C_Timer.After(0.01, function()
            local x, y = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            x, y = x / scale, y / scale

            local left = self:GetLeft()
            local right = self:GetRight()
            local top = self:GetTop()
            local bottom = self:GetBottom()

            if not (left and right and top and bottom) then
                self:SetBackdropBorderColor(AF.GetColorRGB("black"))
                return
            end

            if x >= left and x <= right and y >= bottom and y <= top then
                -- still in bounds! :D
            else
                self:SetBackdropBorderColor(AF.GetColorRGB("black"))
            end
        end)
    end)
end

local function CreateUIScaleGroup(scrollContent, borderedFrameWidth, availableWidgetWidth)
    local uiScaleGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 80, "background2", "black")
    uiScaleGroup:SetLabel("UI Scale")
    AF.SetPoint(uiScaleGroup, "TOPLEFT", scrollContent, "TOPLEFT", 5, -20)
    SetGroupHoverEffect(uiScaleGroup)

    local uiScaleSlider = AF.CreateSlider(uiScaleGroup, "UI Scale", availableWidgetWidth, 0.1, 2, 0.01, false, true)
    AF.SetPoint(uiScaleSlider, "TOPLEFT", uiScaleGroup, "TOPLEFT", 5, -20)
    uiScaleSlider:SetValue(tonumber(GetCVar("UIScale")))
    uiScaleSlider:SetAfterValueChanged(function(value)
        UIParent:SetScale(value)
        SetCVar("UIScale", value)
        SwirlUI.SettingsChanged = true
    end)

    local presetScales = {0.53, 0.63, 0.71, 1}
    for i, scale in ipairs(presetScales) do
        local buttonWidth = (availableWidgetWidth - ((#presetScales - 1) * 5)) / #presetScales
        local scaleBtn = AF.CreateButton(uiScaleGroup, tostring(scale), addonName, buttonWidth, 22)
        AF.SetPoint(scaleBtn, "TOPLEFT", uiScaleSlider, "BOTTOMLEFT", (i-1) * (buttonWidth + 5), -20)
        scaleBtn:SetOnClick(function()
            SetCVar("UIScale", scale)
            UIParent:SetScale(scale)
            uiScaleSlider:SetValue(scale)
            SwirlUI.SettingsChanged = true
        end)
    end

    return uiScaleGroup
end

local function CreateChatBubblesGroup(scrollContent, previousGroup, borderedFrameWidth)
    local chatBubblesGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 82, "background2", "black")
    chatBubblesGroup:SetLabel("Chat Bubbles")
    AF.SetPoint(chatBubblesGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(chatBubblesGroup)

    local chatBubblesEnabled = AF.CreateCheckButton(chatBubblesGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.chatBubbles.enabled = checked
        AF.Fire("SwirlUI_ChatBubbles_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(chatBubblesEnabled, "TOPLEFT", chatBubblesGroup, "TOPLEFT", 5, -10)
    chatBubblesEnabled:SetChecked(SwirlUIDB.uiSettings.chatBubbles.enabled)

    local chatBubblesFontSize = AF.CreateSlider(chatBubblesGroup, "Font Size", 200, 2, 24, 1, false, true)
    AF.SetPoint(chatBubblesFontSize, "TOPLEFT", chatBubblesEnabled, "BOTTOMLEFT", 0, -25)
    chatBubblesFontSize:SetValue(SwirlUIDB.uiSettings.chatBubbles.fontSize)
    chatBubblesFontSize:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.chatBubbles.fontSize = value
        AF.Fire("SwirlUI_ChatBubbles_Changed")
        SwirlUI.SettingsChanged = true
    end)

    return chatBubblesGroup
end

local function CreateUIErrorsGroup(scrollContent, previousGroup, borderedFrameWidth)
    local uiErrorsGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 127, "background2", "black")
    uiErrorsGroup:SetLabel("UI Errors")
    AF.SetPoint(uiErrorsGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(uiErrorsGroup)

    local uiErrorsEnabled = AF.CreateCheckButton(uiErrorsGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.uiErrors.enabled = checked
        AF.Fire("SwirlUI_UIErrors_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(uiErrorsEnabled, "TOPLEFT", uiErrorsGroup, "TOPLEFT", 5, -10)
    uiErrorsEnabled:SetChecked(SwirlUIDB.uiSettings.uiErrors.enabled)

    local uiErrorsFontSize = AF.CreateSlider(uiErrorsGroup, "Font Size", 200, 8, 24, 1, false, true)
    AF.SetPoint(uiErrorsFontSize, "TOPLEFT", uiErrorsEnabled, "BOTTOMLEFT", 0, -25)
    uiErrorsFontSize:SetValue(SwirlUIDB.uiSettings.uiErrors.fontSize)
    uiErrorsFontSize:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.uiErrors.fontSize = value
        AF.Fire("SwirlUI_UIErrors_Changed")
        SwirlUI.SettingsChanged = true
    end)

    local uiErrorsOffsetX = AF.CreateSlider(uiErrorsGroup, "X Offset", 200, -500, 500, 1, false, true)
    AF.SetPoint(uiErrorsOffsetX, "TOPLEFT", uiErrorsFontSize, "BOTTOMLEFT", 0, -35)
    uiErrorsOffsetX:SetValue(SwirlUIDB.uiSettings.uiErrors.offsetX)
    uiErrorsOffsetX:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.uiErrors.offsetX = value
        AF.Fire("SwirlUI_UIErrors_Changed")
        SwirlUI.SettingsChanged = true
    end)

    local uiErrorsOffsetY = AF.CreateSlider(uiErrorsGroup, "Y Offset", 200, -500, 500, 1, false, true)
    AF.SetPoint(uiErrorsOffsetY, "TOPLEFT", uiErrorsOffsetX, "TOPRIGHT", 10, 0)
    uiErrorsOffsetY:SetValue(SwirlUIDB.uiSettings.uiErrors.offsetY)
    uiErrorsOffsetY:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.uiErrors.offsetY = value
        AF.Fire("SwirlUI_UIErrors_Changed")
        SwirlUI.SettingsChanged = true
    end)

    return uiErrorsGroup
end

local function CreateActionStatusGroup(scrollContent, previousGroup, borderedFrameWidth)
    local actionStatusGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 127, "background2", "black")
    actionStatusGroup:SetLabel("Action Status")
    AF.SetPoint(actionStatusGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(actionStatusGroup)

    local actionStatusEnabled = AF.CreateCheckButton(actionStatusGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.actionStatus.enabled = checked
        AF.Fire("SwirlUI_ActionStatus_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(actionStatusEnabled, "TOPLEFT", actionStatusGroup, "TOPLEFT", 5, -10)
    actionStatusEnabled:SetChecked(SwirlUIDB.uiSettings.actionStatus.enabled)

    local actionStatusFontSize = AF.CreateSlider(actionStatusGroup, "Font Size", 200, 8, 24, 1, false, true)
    AF.SetPoint(actionStatusFontSize, "TOPLEFT", actionStatusEnabled, "BOTTOMLEFT", 0, -25)
    actionStatusFontSize:SetValue(SwirlUIDB.uiSettings.actionStatus.fontSize)
    actionStatusFontSize:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.actionStatus.fontSize = value
        AF.Fire("SwirlUI_ActionStatus_Changed")
        SwirlUI.SettingsChanged = true
    end)

    local actionStatusOffsetX = AF.CreateSlider(actionStatusGroup, "X Offset", 200, -500, 500, 1, false, true)
    AF.SetPoint(actionStatusOffsetX, "TOPLEFT", actionStatusFontSize, "BOTTOMLEFT", 0, -35)
    actionStatusOffsetX:SetValue(SwirlUIDB.uiSettings.actionStatus.offsetX)
    actionStatusOffsetX:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.actionStatus.offsetX = value
        AF.Fire("SwirlUI_ActionStatus_Changed")
        SwirlUI.SettingsChanged = true
    end)

    local actionStatusOffsetY = AF.CreateSlider(actionStatusGroup, "Y Offset", 200, -500, 500, 1, false, true)
    AF.SetPoint(actionStatusOffsetY, "TOPLEFT", actionStatusOffsetX, "TOPRIGHT", 10, 0)
    actionStatusOffsetY:SetValue(SwirlUIDB.uiSettings.actionStatus.offsetY)
    actionStatusOffsetY:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.actionStatus.offsetY = value
        AF.Fire("SwirlUI_ActionStatus_Changed")
        SwirlUI.SettingsChanged = true
    end)

    return actionStatusGroup
end

local function CreateQuestObjectivesGroup(scrollContent, previousGroup, borderedFrameWidth)
    local questObjectivesGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 82, "background2", "black")
    questObjectivesGroup:SetLabel("Quest Objectives")
    AF.SetPoint(questObjectivesGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(questObjectivesGroup)

    local questObjectivesEnabled = AF.CreateCheckButton(questObjectivesGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.questObjectives.enabled = checked
        AF.Fire("SwirlUI_QuestObjectives_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(questObjectivesEnabled, "TOPLEFT", questObjectivesGroup, "TOPLEFT", 5, -10)
    questObjectivesEnabled:SetChecked(SwirlUIDB.uiSettings.questObjectives.enabled)

    local questObjectivesRemoveGraphics = AF.CreateCheckButton(questObjectivesGroup, "Remove Graphics", function(checked)
        SwirlUIDB.uiSettings.questObjectives.removeGraphics = checked
        AF.Fire("SwirlUI_QuestObjectives_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(questObjectivesRemoveGraphics, "LEFT", questObjectivesEnabled, "RIGHT", 75, 0)
    questObjectivesRemoveGraphics:SetChecked(SwirlUIDB.uiSettings.questObjectives.removeGraphics)

    local questObjectivesFontSize = AF.CreateSlider(questObjectivesGroup, "Font Size", 200, 8, 24, 1, false, true)
    AF.SetPoint(questObjectivesFontSize, "TOPLEFT", questObjectivesEnabled, "BOTTOMLEFT", 0, -25)
    questObjectivesFontSize:SetValue(SwirlUIDB.uiSettings.questObjectives.fontSize)
    questObjectivesFontSize:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.questObjectives.fontSize = value
        AF.Fire("SwirlUI_QuestObjectives_Changed")
        SwirlUI.SettingsChanged = true
    end)

    return questObjectivesGroup
end

local function CreateChatGroup(scrollContent, previousGroup, borderedFrameWidth)
    local chatGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 34, "background2", "black")
    chatGroup:SetLabel("Chat")
    AF.SetPoint(chatGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(chatGroup)

    local chatEnabled = AF.CreateCheckButton(chatGroup, "Remove Text Shadows", function(checked)
        SwirlUIDB.uiSettings.chat.disableChatShadows = checked
        AF.Fire("SwirlUI_Chat_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(chatEnabled, "TOPLEFT", chatGroup, "TOPLEFT", 5, -10)
    chatEnabled:SetChecked(SwirlUIDB.uiSettings.chat.disableChatShadows)

    return chatGroup
end

local function CreateMouseClickGroup(scrollContent, previousGroup, borderedFrameWidth)
    local mouseClickGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 58, "background2", "black")
    mouseClickGroup:SetLabel("Mouse Click")
    AF.SetPoint(mouseClickGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(mouseClickGroup)

    local extraActionButtonCheckbox = AF.CreateCheckButton(mouseClickGroup, "Remove Empty Spacing around Extra Action Button", function(checked)
        if not SwirlUIDB.uiSettings.mouseClick then
            SwirlUIDB.uiSettings.mouseClick = { extraActionButton = false, lfgListFrame = false }
        end
        SwirlUIDB.uiSettings.mouseClick.extraActionButton = checked
        AF.Fire("SwirlUI_MouseClick_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(extraActionButtonCheckbox, "TOPLEFT", mouseClickGroup, "TOPLEFT", 5, -10)

    local lfgListFrameCheckbox = AF.CreateCheckButton(mouseClickGroup, "Enable Click-Through in LFG", function(checked)
        if not SwirlUIDB.uiSettings.mouseClick then
            SwirlUIDB.uiSettings.mouseClick = { extraActionButton = false, lfgListFrame = false }
        end
        SwirlUIDB.uiSettings.mouseClick.lfgListFrame = checked
        AF.Fire("SwirlUI_MouseClick_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(lfgListFrameCheckbox, "TOPLEFT", extraActionButtonCheckbox, "BOTTOMLEFT", 0, -10)

    if SwirlUIDB.uiSettings.mouseClick then
        if SwirlUIDB.uiSettings.mouseClick.extraActionButton then
            extraActionButtonCheckbox:SetChecked(true)
        end
        if SwirlUIDB.uiSettings.mouseClick.lfgListFrame then
            lfgListFrameCheckbox:SetChecked(true)
        end
    end

    return mouseClickGroup
end

local function CreateAurasGroup(scrollContent, previousGroup, borderedFrameWidth)
    local aurasGroup = AF.CreateBorderedFrame(scrollContent, nil, borderedFrameWidth, 82, "background2", "black")
    aurasGroup:SetLabel("Skin Buffs & Debuffs")
    AF.SetPoint(aurasGroup, "TOPLEFT", previousGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(aurasGroup)

    local aurasEnabled = AF.CreateCheckButton(aurasGroup, "Enable", function(checked)
        if not SwirlUIDB.uiSettings.skinAuras then
            SwirlUIDB.uiSettings.skinAuras = { enabled = false, width = 32, height = 32 }
        end
        SwirlUIDB.uiSettings.skinAuras.enabled = checked
        AF.Fire("SwirlUI_Auras_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(aurasEnabled, "TOPLEFT", aurasGroup, "TOPLEFT", 5, -10)
    aurasEnabled:SetChecked(SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.enabled or false)

    local auraWidth = AF.CreateSlider(aurasGroup, "Width", 200, 16, 64, 1, false, true)
    AF.SetPoint(auraWidth, "TOPLEFT", aurasEnabled, "BOTTOMLEFT", 0, -25)
    auraWidth:SetValue(SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.width or 32)
    auraWidth:SetAfterValueChanged(function(value)
        if not SwirlUIDB.uiSettings.skinAuras then
            SwirlUIDB.uiSettings.skinAuras = { enabled = false, width = 32, height = 32 }
        end
        SwirlUIDB.uiSettings.skinAuras.width = value
        AF.Fire("SwirlUI_Auras_Changed")
        SwirlUI.SettingsChanged = true
    end)

    local auraHeight = AF.CreateSlider(aurasGroup, "Height", 200, 16, 64, 1, false, true)
    AF.SetPoint(auraHeight, "TOPLEFT", auraWidth, "TOPRIGHT", 10, 0)
    auraHeight:SetValue(SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.height or 32)
    auraHeight:SetAfterValueChanged(function(value)
        if not SwirlUIDB.uiSettings.skinAuras then
            SwirlUIDB.uiSettings.skinAuras = { enabled = false, width = 32, height = 32 }
        end
        SwirlUIDB.uiSettings.skinAuras.height = value
        AF.Fire("SwirlUI_Auras_Changed")
        SwirlUI.SettingsChanged = true
    end)

    return aurasGroup
end

local function CreateOptionsTab()
    optionsTab = AF.CreateFrame(SwirlUI.frames.optionsFrame, "SwirlUI_OptionsTab", nil, nil, true)
    optionsTab:SetAllPoints(SwirlUI.frames.optionsFrame)
    SwirlUI.frames.optionsTab = optionsTab

    local width = 440
    local borderedFrameWidth = width - 15
    local scrollFrame = AF.CreateScrollFrame(SwirlUI.frames.optionsTab, nil, width, 380, "none", "black")
    AF.SetPoint(scrollFrame, "TOPLEFT", SwirlUI.frames.optionsTab, "TOPLEFT", 0, -20)

    local availableWidgetWidth = borderedFrameWidth - 10

    local uiScaleGroup = CreateUIScaleGroup(scrollFrame.scrollContent, borderedFrameWidth, availableWidgetWidth)
    local chatBubblesGroup = CreateChatBubblesGroup(scrollFrame.scrollContent, uiScaleGroup, borderedFrameWidth)
    local uiErrorsGroup = CreateUIErrorsGroup(scrollFrame.scrollContent, chatBubblesGroup, borderedFrameWidth)
    local actionStatusGroup = CreateActionStatusGroup(scrollFrame.scrollContent, uiErrorsGroup, borderedFrameWidth)
    local questObjectivesGroup = CreateQuestObjectivesGroup(scrollFrame.scrollContent, actionStatusGroup, borderedFrameWidth)
    local chatGroup = CreateChatGroup(scrollFrame.scrollContent, questObjectivesGroup, borderedFrameWidth)
    local mouseClickGroup = CreateMouseClickGroup(scrollFrame.scrollContent, chatGroup, borderedFrameWidth)
    local aurasGroup = CreateAurasGroup(scrollFrame.scrollContent, mouseClickGroup, borderedFrameWidth)

    scrollFrame:SetContentHeight(960)
end

local function ShowTab(callback, tab)
    if tab == "Options" then
        if not optionsTab then
            CreateOptionsTab()
        end
        optionsTab:Show()
    else
        if optionsTab then
            optionsTab:Hide()
        end
    end
end

AF.RegisterCallback("ShowOptionsTab", ShowTab, "medium")
