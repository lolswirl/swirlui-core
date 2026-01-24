local _, SwirlUI = ...

local PLAYER_CLASS = select(2, UnitClass("player"))
local PLAYER_CLASS_COLOR = RAID_CLASS_COLORS[PLAYER_CLASS]
local PLAYER_CLASS_COLOR_HEX = CreateColor(PLAYER_CLASS_COLOR.r, PLAYER_CLASS_COLOR.g, PLAYER_CLASS_COLOR.b):GenerateHexColor()

local function ChatRemoveShadows()
    if not C_AddOns.IsAddOnLoaded("Prat-3.0") then return end
    if not SwirlUIDB or not SwirlUIDB.uiSettings or not SwirlUIDB.uiSettings.chat.disableChatShadows then return end
    for i = 1, NUM_CHAT_WINDOWS do
       local chatFrame = _G["ChatFrame" .. i]
        chatFrame:SetShadowColor(0, 0, 0, 1)
        chatFrame:SetShadowOffset(0, 0) 
    end
    CommunitiesFrame.Chat.MessageFrame:SetShadowOffset(0, 0)
end

local function AddOnSetups()
    ChatRemoveShadows()
end

local function BugSackMinimapButton()
    if not C_AddOns.IsAddOnLoaded("BugSack") then return end
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end

    local bugSackLDB = LDB:GetDataObjectByName("BugSack")
    if not bugSackLDB then return end

    local bugAddon = _G["BugSack"]
    if not bugAddon or not bugAddon.UpdateDisplay or not bugAddon.GetErrors then return end

    if _G["SwirlUIBugSackButton"] then return end
    local SwirlUIBugSackButton = CreateFrame("Button", "SwirlUIBugSackButton", UIParent, "BackdropTemplate")
    SwirlUIBugSackButton:SetSize(16, 16)
    SwirlUIBugSackButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 1.5, 1.5)
    SwirlUIBugSackButton.Text = SwirlUIBugSackButton:CreateFontString(nil, "OVERLAY")
    SwirlUIBugSackButton.Text:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    SwirlUIBugSackButton.Text:SetPoint("CENTER", SwirlUIBugSackButton, "CENTER", 0, 0)
    SwirlUIBugSackButton.Text:SetTextColor(1, 1, 1)
    SwirlUIBugSackButton.Text:SetText("|cFF49AF4C0|r")
    SwirlUIBugSackButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    SwirlUIBugSackButton:SetBackdropColor(6/255, 8/255, 8/255, 0.75)
    SwirlUIBugSackButton:SetBackdropBorderColor(0, 0, 0, 1)

    SwirlUIBugSackButton:SetScript("OnClick", function(self, mouseButton)
        if bugSackLDB.OnClick then
            bugSackLDB.OnClick(self, mouseButton)
        end
    end)

    SwirlUIBugSackButton:SetScript("OnEnter", function(self)
        if bugSackLDB.OnTooltipShow then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            SwirlUIBugSackButton:SetBackdropBorderColor(PLAYER_CLASS_COLOR.r, PLAYER_CLASS_COLOR.g, PLAYER_CLASS_COLOR.b, 1)
            bugSackLDB.OnTooltipShow(GameTooltip)
            GameTooltip:Show()
        end
    end)

    SwirlUIBugSackButton:SetScript("OnLeave", function()
        SwirlUIBugSackButton:SetBackdropBorderColor(0, 0, 0, 1)
        GameTooltip:Hide()
    end)

    hooksecurefunc(bugAddon, "UpdateDisplay", function()
        local count = #bugAddon:GetErrors(BugGrabber:GetSessionId())
        if count == 0 then
            SwirlUIBugSackButton.Text:SetText("|cFF49AF4C" .. count .. "|r")
        else
            SwirlUIBugSackButton.Text:SetText("|cFFC63F3F" .. count .. "|r")
        end
    end)
end

local function DurabilityMinimapDataText()
    if not _G["SwirlUIBugSackButton"] then return end
    
    local function FormatMoney(amount)
        if not amount or amount == 0 then return "0|cffeda55fc|r" end
        
        local gold = math.floor(amount * 0.0001)
        local silver = math.floor((amount * 0.01) % 100)
        local copper = math.floor(amount % 100)
        
        local str = ""
        if gold > 0 then
            str = string.format("%d|cffffd700g|r", gold)
            if silver > 0 or copper > 0 then str = str .. " " end
        end
        if silver > 0 then
            str = str .. string.format("%d|cffc7c7cfs|r", silver)
            if copper > 0 then str = str .. " " end
        end
        if copper > 0 or amount == 0 then
            str = str .. string.format("%d|cffeda55fc|r", copper)
        end
        
        return str
    end
    
    local function GetDurabilityColor(percentage)
        if percentage < 25 then
            return "|cFFC63F3F"
        elseif percentage < 50 then
            return "|cFFFFA12C"
        elseif percentage < 85 then
            return "|cFF49AF4C"
        else
            return "|cFFFFFFFF"
        end
    end
    
    local function CalculateDurability()
        local totalDurability, currentDurability = 0, 0
        local totalRepairCost = 0
        local slotData = {}
        
        for slotID = 1, 18 do
            local slotDurability, slotMaxDurability = GetInventoryItemDurability(slotID)
            if slotDurability and slotMaxDurability then
                totalDurability = totalDurability + slotMaxDurability
                currentDurability = currentDurability + slotDurability
                
                local repairCost = 0
                local tooltipData = C_TooltipInfo.GetInventoryItem("player", slotID)
                if tooltipData and tooltipData.repairCost then
                    repairCost = tooltipData.repairCost
                    totalRepairCost = totalRepairCost + repairCost
                end
                
                slotData[slotID] = {
                    current = slotDurability,
                    max = slotMaxDurability,
                    percentage = (slotDurability / slotMaxDurability) * 100,
                    repairCost = repairCost
                }
            end
        end
        
        local totalPercentage = totalDurability > 0 and (currentDurability / totalDurability) * 100 or 0
        
        return {
            total = totalDurability,
            current = currentDurability,
            percentage = totalPercentage,
            repairCost = totalRepairCost,
            slots = slotData,
            hasEquipment = totalDurability > 0
        }
    end
    
    local SwirlUIDurabilityFrame = CreateFrame("Frame", "SwirlUIDurabilityFrame", _G["SwirlUIBugSackButton"])
    SwirlUIDurabilityFrame:SetSize(20, SwirlUI.FontSize)
    SwirlUIDurabilityFrame:SetPoint("LEFT", _G["SwirlUIBugSackButton"], "RIGHT", 2, 0)
    SwirlUIDurabilityFrame:SetFrameStrata("HIGH")
    SwirlUIDurabilityFrame.Text = SwirlUIDurabilityFrame:CreateFontString(nil, "OVERLAY")
    SwirlUIDurabilityFrame.Text:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    SwirlUIDurabilityFrame.Text:SetShadowOffset(0, 0)
    SwirlUIDurabilityFrame.Text:SetPoint("LEFT", SwirlUIDurabilityFrame, "LEFT", 0, 0)

    SwirlUIDurabilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    SwirlUIDurabilityFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    SwirlUIDurabilityFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_INVENTORY_DURABILITY" then
            local durability = CalculateDurability()
            
            if durability.hasEquipment then
                local color = GetDurabilityColor(durability.percentage)
                SwirlUIDurabilityFrame.Text:SetText(string.format("%s%.0f%%|r", color, durability.percentage))
            else
                SwirlUIDurabilityFrame.Text:SetText("|cFFFFA12Cnaked:3|r")
            end
        end
    end)
    
    SwirlUIDurabilityFrame:SetScript("OnEnter", function(self)
        local durability = CalculateDurability()
        
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetText(string.format("|c%sDurability|r", PLAYER_CLASS_COLOR_HEX), 1, 1, 1)
        GameTooltip:AddLine(" ")
        
        if durability.hasEquipment then
            local slotNames = {
                [1] = "Head", [2] = "Neck", [3] = "Shoulder", [4] = "Shirt", [5] = "Chest",
                [6] = "Waist", [7] = "Legs", [8] = "Feet", [9] = "Wrist", [10] = "Hands",
                [11] = "Ring 1", [12] = "Ring 2", [13] = "Trinket 1", [14] = "Trinket 2",
                [15] = "Back", [16] = "Main Hand", [17] = "Off Hand", [18] = "Ranged"
            }
            
            for slotID = 1, 18 do
                local slot = durability.slots[slotID]
                if slot then
                    local color = GetDurabilityColor(slot.percentage)
                    GameTooltip:AddDoubleLine(
                        slotNames[slotID] or ("Slot " .. slotID),
                        string.format("%s%.0f%%|r", color, slot.percentage),
                        0.9, 0.9, 0.9, 1, 1, 1
                    )
                end
            end
            
            local totalColor = GetDurabilityColor(durability.percentage)
            GameTooltip:AddDoubleLine(
                string.format("|c%sTotal|r", PLAYER_CLASS_COLOR_HEX),
                string.format("%s%.0f%%|r", totalColor, durability.percentage),
                1, 1, 1, 1, 1, 1
            )
            
            if durability.repairCost > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(
                    string.format("|c%sCost|r", PLAYER_CLASS_COLOR_HEX),
                    FormatMoney(durability.repairCost),
                    0.6, 0.8, 1, 1, 1, 1
                )
            end
        else
            GameTooltip:AddLine("hehe ur naked", 0.8, 0.8, 0.8)
        end
        
        GameTooltip:Show()
    end)
    
    SwirlUIDurabilityFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    SwirlUI.SwirlUIDurabilityFrame = SwirlUIDurabilityFrame
    SwirlUIDurabilityFrame:GetScript("OnEvent")(SwirlUIDurabilityFrame, "UPDATE_INVENTORY_DURABILITY")
end

local function MailMinimapDataText()
    local SwirlUIMailButton = CreateFrame("Frame", "SwirlUIMailButton", UIParent)
    SwirlUIMailButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -2)

    SwirlUIMailButton.texture = SwirlUIMailButton:CreateTexture(nil, "OVERLAY")
    SwirlUIMailButton.texture:SetAllPoints(SwirlUIMailButton)
    SwirlUIMailButton.texture:SetTexture("Interface\\AddOns\\SwirlUI\\media\\mail.tga")
    SwirlUIMailButton:SetSize(16, 16)

    SwirlUIMailButton:RegisterEvent("UPDATE_PENDING_MAIL")
    
    function SwirlUIMailButton:UpdateMailVisibility()
        if HasNewMail() then
            self:Show()
        else
            self:Hide()
        end
    end

    SwirlUIMailButton:SetScript("OnEvent", function(self, event)
        if event == "UPDATE_PENDING_MAIL" then
            self:UpdateMailVisibility()
        end
    end)

    SwirlUIMailButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddLine("Unread mail from:")
        local m1, m2, m3 = GetLatestThreeSenders()
        GameTooltip:AddLine(m1)
        GameTooltip:AddLine(m2)
        GameTooltip:AddLine(m3)
        GameTooltip:Show()
    end)

    SwirlUIMailButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    SwirlUIMailButton:UpdateMailVisibility()
end

local function MinimapData()
    BugSackMinimapButton()
    DurabilityMinimapDataText()
    MailMinimapDataText()
end

local function SetupFrameAlphas()
    local Frames = {
        ZoneTextFrame,
        SubZoneTextFrame,
        ObjectiveTrackerFrame.Header.Background,
        QuestObjectiveTracker.Header.Background,
        WorldQuestObjectiveTracker.Header.Background,
        ScenarioObjectiveTracker.Header.Background,
        MonthlyActivitiesObjectiveTracker.Header.Background,
        BonusObjectiveTracker.Header.Background,
        ProfessionsRecipeTracker.Header.Background,
        AchievementObjectiveTracker.Header.Background,
        CampaignQuestObjectiveTracker.Header.Background,
    }
    for _, Frame in pairs(Frames) do
        Frame:SetAlpha(0)
        Frame:Hide()
        Frame:SetScript("OnShow", function(Frame) 
            Frame:SetAlpha(0)
            Frame:Hide()
        end)
    end
end

local function ApplyChatBubbleSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.chatBubbles.enabled then
        ChatBubbleFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.chatBubbles.fontSize, "OUTLINE")
    end
end

local function ApplyUIErrorsSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.uiErrors.enabled then
        UIErrorsFrame:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.uiErrors.fontSize, "OUTLINE")
        UIErrorsFrame:SetShadowOffset(0, 0)
        UIErrorsFrame:ClearAllPoints()
        UIErrorsFrame:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.uiErrors.offsetX, SwirlUIDB.uiSettings.uiErrors.offsetY)
    end
end

local function ApplyActionStatusSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.actionStatus.enabled then
        ActionStatus.Text:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.actionStatus.fontSize, "OUTLINE")
        ActionStatus.Text:SetShadowOffset(0, 0)
        ActionStatus.Text:ClearAllPoints()
        ActionStatus.Text:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.actionStatus.offsetX, SwirlUIDB.uiSettings.actionStatus.offsetY)
    end
end

local function ApplyQuestObjectivesSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.questObjectives.enabled then
        ObjectiveTrackerLineFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.questObjectives.fontSize, "OUTLINE")
        ObjectiveTrackerLineFont:SetShadowOffset(0, 0)
        ObjectiveTrackerHeaderFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.questObjectives.fontSize, "OUTLINE")
        ObjectiveTrackerHeaderFont:SetShadowOffset(0, 0)
        if SwirlUIDB.uiSettings.questObjectives.removeGraphics then
            SetupFrameAlphas()
        end
    end
end

local function MoveAbstractFrameworkPopups()
    if AFConfig then
        if SwirlUIDB.uiSettings.moveAFPopups then
            AFConfig["popups"] = {
                ["orientation"] = "top_to_bottom",
                ["position"] = {
                    "TOP",
                    0,
                    -100,
                },
            }
        else
            AFConfig["popups"] = nil
        end
    end
end

function ApplyMouseClickSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.mouseClick then
        if SwirlUIDB.uiSettings.mouseClick.lfgListFrame then
            local frame = LFGListFrame.ApplicationViewer.UnempoweredCover
            if frame then
                frame:EnableMouse(false)
                frame:EnableMouseWheel(false)
                frame:SetToplevel(false)
            end
        end
        if SwirlUIDB.uiSettings.mouseClick.extraActionButton then
            ExtraActionBarFrame:EnableMouse(false)
            ExtraAbilityContainer:EnableMouse(false)
        end
    end
end

local function CreateAuraBorder(auraFrame)
    if auraFrame.Border then return end

    local border = CreateFrame("Frame", nil, auraFrame)
    border:SetAllPoints(auraFrame.Icon)
    border:SetFrameLevel(auraFrame:GetFrameLevel() - 1)
    auraFrame.Border = border

    local borders = {
        {points = {"TOPLEFT", "TOPRIGHT"}, size = "Height"},
        {points = {"BOTTOMLEFT", "BOTTOMRIGHT"}, size = "Height"},
        {points = {"TOPLEFT", "BOTTOMLEFT"}, size = "Width"},
        {points = {"TOPRIGHT", "BOTTOMRIGHT"}, size = "Width"},
    }

    for _, borderData in ipairs(borders) do
        local edge = border:CreateTexture(nil, "OVERLAY")
        edge:SetColorTexture(0, 0, 0, 1)
        edge:SetPoint(borderData.points[1], 0, 0)
        edge:SetPoint(borderData.points[2], 0, 0)
        edge["Set" .. borderData.size](edge, 1)
    end
end

local function SkinAuras(auraFrame)
    if auraFrame.isAuraAnchor or not auraFrame.Icon then return end

    auraFrame.Icon:SetSize(32, 32)
    auraFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    if auraFrame.DebuffBorder then
        auraFrame.DebuffBorder:Hide()
        auraFrame.DebuffBorder:SetAlpha(0)
        auraFrame.DebuffBorder:SetTexture(nil)
    elseif auraFrame.BuffBorder then
        auraFrame.BuffBorder:SetTexture(nil)
    end

    if not auraFrame.Border then
        CreateAuraBorder(auraFrame)
    end

    local width, height = auraFrame:GetSize()
    if width and height and width > 0 and height > 0 then
        auraFrame.Border:ClearAllPoints()
        auraFrame.Border:SetPoint("TOPLEFT", auraFrame.Icon, "TOPLEFT", -1, 1)
        auraFrame.Border:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 1, -1)
    end

    if auraFrame.Duration then
        auraFrame.Duration:ClearAllPoints()
        auraFrame.Duration:SetPoint("CENTER", auraFrame.Icon, "CENTER", 0, 0)
        auraFrame.Duration:SetFont(SwirlUI.Font, SwirlUI.FontSize + 1, "OUTLINE")
        auraFrame.Duration:SetShadowOffset(0, 0)
    end

    if auraFrame.Count then
        auraFrame.Count:ClearAllPoints()
        auraFrame.Count:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 0, 1)
        auraFrame.Count:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    end
end

local function SkinAuraFrames()
    local frames = {BuffFrame, DebuffFrame}
    for _, frame in pairs(frames) do
        if frame and frame.auraFrames then
            if frame.CollapseAndExpandButton then
                frame.CollapseAndExpandButton:SetAlpha(0)
                frame.CollapseAndExpandButton:SetScript("OnClick", nil)
            end

            for _, auraFrame in pairs(frame.auraFrames) do
                SkinAuras(auraFrame)
            end
        end
    end
end

local function SetupAuraHooks()
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(DebuffFrame, "UpdateAuraButtons", function() SkinAuraFrames() end)
end

local function ApplyAuraSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.enabled then
        SkinAuraFrames()
        SetupAuraHooks()
    end
end

local function ApplyUISettings()
    ApplyChatBubbleSettings()
    ApplyUIErrorsSettings()
    ApplyActionStatusSettings()
    ApplyQuestObjectivesSettings()
    ApplyMouseClickSettings()
    ApplyAuraSettings()
end

local function RegisterUISettingsCallbacks()
    local AF = _G.AbstractFramework
    if not AF then return end

    AF.RegisterCallback("SwirlUI_ChatBubbles_Changed", ApplyChatBubbleSettings, "medium", "ChatBubblesUpdate")
    AF.RegisterCallback("SwirlUI_UIErrors_Changed", ApplyUIErrorsSettings, "medium", "UIErrorsUpdate")
    AF.RegisterCallback("SwirlUI_ActionStatus_Changed", ApplyActionStatusSettings, "medium", "ActionStatusUpdate")
    AF.RegisterCallback("SwirlUI_QuestObjectives_Changed", ApplyQuestObjectivesSettings, "medium", "QuestObjectivesUpdate")
    AF.RegisterCallback("SwirlUI_Chat_Changed", ChatRemoveShadows, "medium", "ChatUpdate")
    AF.RegisterCallback("SwirlUI_AbstractFrameworkPopups_Changed", MoveAbstractFrameworkPopups, "medium", "AbstractFrameworkPopupsUpdate")
    AF.RegisterCallback("SwirlUI_MouseClick_Changed", ApplyMouseClickSettings, "medium", "MouseClickUpdate")
    AF.RegisterCallback("SwirlUI_Auras_Changed", ApplyAuraSettings, "medium", "AurasUpdate")
end

local function CheckProfileVersionUpdates()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if (profile.string or profile.data) and IsAddOnLoaded(profile.name) then
            local currentVersion = profile.version
            local storedVersion = SwirlUIDB.profileVersions[profile.name]
            
            if storedVersion and storedVersion ~= currentVersion then
                local addonColor = SwirlUI.ApplyColor(profile.name, profile.color)
                local versionColor = SwirlUI.ApplyColor(currentVersion, SwirlUI.Friendly)
                SwirlUI.Utils:Print(string.format("Update available for %s to v%s", addonColor, versionColor))
            end
        end
    end
end

local function CheckProfilesReady()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    local readyProfiles = {}
    
    for _, profile in ipairs(SwirlUI.Utils:GetAllProfiles()) do
        local status = SwirlUI.Utils:GetAddonStatus(profile)
        if status == SwirlUI.STATUS.READY then
            table.insert(readyProfiles, profile)
        end
    end
    
    if #readyProfiles > 0 then
        local readyCount = #readyProfiles
        local readyColor = SwirlUI.ApplyColor(readyCount, SwirlUI.Neutral)
        SwirlUI.Utils:Print(string.format("Profiles ready: %s", readyColor))
    end
end

local function SetupDB()
    if not SwirlUIDB then
        SwirlUIDB = {
            profileVersions = {},
            uiSettings = {},
        }
    end

    if not SwirlUIDB.profileVersions then
        SwirlUIDB.profileVersions = {}
    end

    local defaultUiSettings = {
        silence = false,
        moveAFPopups = true,
        chatBubbles = { enabled = true, fontSize = 8 },
        uiErrors = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        actionStatus = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        questObjectives = { enabled = true, fontSize = 12, removeGraphics = true },
        chat = { disableChatShadows = true },
        mouseClick = { extraActionButton = true, lfgListFrame = true },
        skinAuras = { enabled = true, width = 32, height = 32 },
    }

    if not SwirlUIDB.uiSettings then
        SwirlUIDB.uiSettings = {}
    end

    for key, defaultValue in pairs(defaultUiSettings) do
        if SwirlUIDB.uiSettings[key] == nil then
            SwirlUIDB.uiSettings[key] = defaultValue
        elseif type(defaultValue) == "table" and type(SwirlUIDB.uiSettings[key]) == "table" then
            for subKey, subDefault in pairs(defaultValue) do
                if SwirlUIDB.uiSettings[key][subKey] == nil then
                    SwirlUIDB.uiSettings[key][subKey] = subDefault
                end
            end
        elseif type(defaultValue) ~= type(SwirlUIDB.uiSettings[key]) then
            SwirlUIDB.uiSettings[key] = defaultValue
        end
    end

    -- setting default popup location instead of asking user
    MoveAbstractFrameworkPopups()
end

function SwirlUI:Initialize()
    SetupDB()

    ApplyUISettings()
    RegisterUISettingsCallbacks()
    AddOnSetups()
    MinimapData()

    CheckProfileVersionUpdates()
    CheckProfilesReady()
end