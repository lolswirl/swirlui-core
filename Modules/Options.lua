local _, SwirlUI = ...
local AF = _G.AbstractFramework

local optionsTab

local function SetGroupHoverEffect(group)
    group:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(AF.GetColorRGB("accent"))
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

local function CreateOptionsTab()
    optionsTab = AF.CreateFrame(SwirlUI.frames.optionsFrame, "SwirlUI_OptionsTab", nil, nil, true)
    optionsTab:SetAllPoints(SwirlUI.frames.optionsFrame)
    SwirlUI.frames.optionsTab = optionsTab

    local width = 440
    local borderedFrameWidth = width - 15
    local scrollFrame = AF.CreateScrollFrame(SwirlUI.frames.optionsTab, nil, width, 380, "none", "black")
    AF.SetPoint(scrollFrame, "TOPLEFT", SwirlUI.frames.optionsTab, "TOPLEFT", 0, -20)

    local availableWidgetWidth = borderedFrameWidth - 10
    local firstWidgetStartX = 5
    local firstWidgetStartY = -10

    local checkboxOnlyHeight = 34
    local doubleWidgetHeight = 82
    local tripleWidgetHeight = 127

    -- ui scale
    local uiScaleGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, doubleWidgetHeight - 2, "background2", "black")
    uiScaleGroup:SetLabel("UI Scale")
    AF.SetPoint(uiScaleGroup, "TOPLEFT", scrollFrame.scrollContent, "TOPLEFT", 5, -20)
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
        local scaleBtn = AF.CreateButton(uiScaleGroup, tostring(scale), "accent_hover", buttonWidth, 22)
        AF.SetPoint(scaleBtn, "TOPLEFT", uiScaleSlider, "BOTTOMLEFT", (i-1) * (buttonWidth + 5), -20)
        scaleBtn:SetOnClick(function()
            SetCVar("UIScale", scale)
            UIParent:SetScale(scale)
            uiScaleSlider:SetValue(scale)
            SwirlUI.SettingsChanged = true
        end)
    end

    -- chat bubbles
    local chatBubblesGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, doubleWidgetHeight, "background2", "black")
    chatBubblesGroup:SetLabel("Chat Bubbles")
    AF.SetPoint(chatBubblesGroup, "TOPLEFT", uiScaleGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(chatBubblesGroup)

    local chatBubblesEnabled = AF.CreateCheckButton(chatBubblesGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.chatBubbles.enabled = checked
        AF.Fire("SwirlUI_ChatBubbles_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(chatBubblesEnabled, "TOPLEFT", chatBubblesGroup, "TOPLEFT", firstWidgetStartX, firstWidgetStartY)
    chatBubblesEnabled:SetChecked(SwirlUIDB.uiSettings.chatBubbles.enabled)

    local chatBubblesFontSize = AF.CreateSlider(chatBubblesGroup, "Font Size", 200, 2, 24, 1, false, true)
    AF.SetPoint(chatBubblesFontSize, "TOPLEFT", chatBubblesEnabled, "BOTTOMLEFT", 0, -25)
    chatBubblesFontSize:SetValue(SwirlUIDB.uiSettings.chatBubbles.fontSize)
    chatBubblesFontSize:SetAfterValueChanged(function(value)
        SwirlUIDB.uiSettings.chatBubbles.fontSize = value
        AF.Fire("SwirlUI_ChatBubbles_Changed")
        SwirlUI.SettingsChanged = true
    end)

    -- ui errors
    local uiErrorsGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, tripleWidgetHeight, "background2", "black")
    uiErrorsGroup:SetLabel("UI Errors")
    AF.SetPoint(uiErrorsGroup, "TOPLEFT", chatBubblesGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(uiErrorsGroup)

    local uiErrorsEnabled = AF.CreateCheckButton(uiErrorsGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.uiErrors.enabled = checked
        AF.Fire("SwirlUI_UIErrors_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(uiErrorsEnabled, "TOPLEFT", uiErrorsGroup, "TOPLEFT", firstWidgetStartX, firstWidgetStartY)
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

    -- action status
    local actionStatusGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, tripleWidgetHeight, "background2", "black")
    actionStatusGroup:SetLabel("Action Status")
    AF.SetPoint(actionStatusGroup, "TOPLEFT", uiErrorsGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(actionStatusGroup)

    local actionStatusEnabled = AF.CreateCheckButton(actionStatusGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.actionStatus.enabled = checked
        AF.Fire("SwirlUI_ActionStatus_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(actionStatusEnabled, "TOPLEFT", actionStatusGroup, "TOPLEFT", firstWidgetStartX, firstWidgetStartY)
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

    -- quest objectives
    local questObjectivesGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, doubleWidgetHeight, "background2", "black")
    questObjectivesGroup:SetLabel("Quest Objectives")
    AF.SetPoint(questObjectivesGroup, "TOPLEFT", actionStatusGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(questObjectivesGroup)

    local questObjectivesEnabled = AF.CreateCheckButton(questObjectivesGroup, "Enable", function(checked)
        SwirlUIDB.uiSettings.questObjectives.enabled = checked
        AF.Fire("SwirlUI_QuestObjectives_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(questObjectivesEnabled, "TOPLEFT", questObjectivesGroup, "TOPLEFT", firstWidgetStartX, firstWidgetStartY)
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

    -- chat
    local chatGroup = AF.CreateBorderedFrame(scrollFrame.scrollContent, nil, borderedFrameWidth, checkboxOnlyHeight, "background2", "black")
    chatGroup:SetLabel("Chat")
    AF.SetPoint(chatGroup, "TOPLEFT", questObjectivesGroup, "BOTTOMLEFT", 0, -25)
    SetGroupHoverEffect(chatGroup)

    local chatEnabled = AF.CreateCheckButton(chatGroup, "Remove Text Shadows", function(checked)
        SwirlUIDB.uiSettings.chat.disableChatShadows = checked
        AF.Fire("SwirlUI_Chat_Changed")
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(chatEnabled, "TOPLEFT", chatGroup, "TOPLEFT", firstWidgetStartX, firstWidgetStartY)
    chatEnabled:SetChecked(SwirlUIDB.uiSettings.chat.disableChatShadows)

    scrollFrame:SetContentHeight(680)
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
