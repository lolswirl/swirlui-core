local _, SwirlUI = ...
local FONT = "Interface\\AddOns\\SharedMedia_SwirlUI\\font\\Swirl.ttf"
local FONT_SIZE = 12
local FONT_SIZE_SMALL = 8

local PLAYER_CLASS = select(2, UnitClass("player"))
local PLAYER_CLASS_COLOR = RAID_CLASS_COLORS[PLAYER_CLASS]
local PLAYER_CLASS_COLOR_HEX = CreateColor(PLAYER_CLASS_COLOR.r, PLAYER_CLASS_COLOR.g, PLAYER_CLASS_COLOR.b):GenerateHexColor()

local function PratRemoveShadows()
    if not C_AddOns.IsAddOnLoaded("Prat-3.0") then return end
    for i = 1, NUM_CHAT_WINDOWS do
       local chatFrame = _G["ChatFrame" .. i]
        chatFrame:SetShadowColor(0, 0, 0, 1)
        chatFrame:SetShadowOffset(0, 0) 
    end
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
    SwirlUIBugSackButton.Text:SetFont(FONT, FONT_SIZE, "OUTLINE")
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
    SwirlUIDurabilityFrame:SetSize(20, FONT_SIZE)
    SwirlUIDurabilityFrame:SetPoint("LEFT", _G["SwirlUIBugSackButton"], "RIGHT", 2, 0)
    SwirlUIDurabilityFrame:SetFrameStrata("HIGH")
    SwirlUIDurabilityFrame.Text = SwirlUIDurabilityFrame:CreateFontString(nil, "OVERLAY")
    SwirlUIDurabilityFrame.Text:SetFont(FONT, FONT_SIZE, "OUTLINE")
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

local function AddOnSetups()
    PratRemoveShadows()
    BugSackMinimapButton()
    DurabilityMinimapDataText()
end

local function SetupActionStatusFont()
    ActionStatus.Text:SetFont(FONT, FONT_SIZE, "OUTLINE")
    ActionStatus.Text:SetShadowOffset(0, 0)
    ActionStatus.Text:ClearAllPoints()
    ActionStatus.Text:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
end

local function SetupUIErrorsFrameFont()
    UIErrorsFrame:SetFont(FONT, FONT_SIZE, "OUTLINE")
    UIErrorsFrame:SetShadowOffset(0, 0)
    UIErrorsFrame:ClearAllPoints()
    UIErrorsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
end

local function SetupChatBubbleFont()
    ChatBubbleFont:SetFont(FONT, FONT_SIZE_SMALL, "OUTLINE")
end

local function SetupObjectiveTrackerFont()
    ObjectiveTrackerLineFont:SetFont(FONT, FONT_SIZE, "OUTLINE")
    ObjectiveTrackerLineFont:SetShadowOffset(0, 0)
    ObjectiveTrackerHeaderFont:SetFont(FONT, FONT_SIZE, "OUTLINE")
    ObjectiveTrackerHeaderFont:SetShadowOffset(0, 0)
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

local function BlizzardSetups()
    SetupActionStatusFont()
    SetupUIErrorsFrameFont()
    SetupChatBubbleFont()
    SetupObjectiveTrackerFont()
    SetupFrameAlphas()
end

function SwirlUI:Initialize()
    BlizzardSetups()
    AddOnSetups()
end