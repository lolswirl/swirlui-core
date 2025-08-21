local _, SwirlUI = ...
local AF = _G.AbstractFramework

local profilesTab
local statusScrollLists = {}
local importAllBtn, applyAllBtn

local function CreateProfilesTab()
    profilesTab = AF.CreateFrame(SwirlUI.frames.optionsFrame, "SwirlUI_ProfilesTab", nil, nil, true)
    profilesTab:SetAllPoints(SwirlUI.frames.optionsFrame)
    SwirlUI.frames.profilesTab = profilesTab
    
    local allProfiles = SwirlUI.Utils:GetAllProfiles()
    local statusListHeight = (#allProfiles * 22) + (#allProfiles - 1) * 2
    local statusGroupHeight = statusListHeight + 35 + 35

    local statusGroup = AF.CreateTitledPane(profilesTab, "Profile Status", 430, statusGroupHeight)
    AF.SetPoint(statusGroup, "TOPLEFT", profilesTab, "TOPLEFT", 5, -25)

    importAllBtn = AF.CreateButton(statusGroup, "Import All Profiles", "accent_hover", 210, 24)
    AF.SetPoint(importAllBtn, "BOTTOMLEFT", statusGroup, "BOTTOMLEFT", 0, 0)
    importAllBtn:SetOnClick(function()
        SwirlUI.Imports:ImportAll()
        SwirlUI.CreateStatusDisplay_AF()
    end)

    applyAllBtn = AF.CreateButton(statusGroup, "Apply All Profiles", "accent_hover", 210, 24)
    AF.SetPoint(applyAllBtn, "BOTTOMRIGHT", statusGroup, "BOTTOMRIGHT", 0, 0)
    applyAllBtn:SetOnClick(function()
        SwirlUI.Imports:ApplyProfiles()
        SwirlUI.CreateStatusDisplay_AF()
    end)

    local generalSettings = AF.CreateTitledPane(profilesTab, "General Settings", 430, 65)
    AF.SetPoint(generalSettings, "TOPLEFT", importAllBtn, "BOTTOMLEFT", 0, -5)

    local silenceCheckbox = AF.CreateCheckButton(generalSettings, string.format("Silence %s Chat Messages", SwirlUI.NameNoCore), function(checked)
        SwirlUIDB.uiSettings.silence = checked
        SwirlUI.SettingsChanged = true
    end)
    AF.SetPoint(silenceCheckbox, "TOPLEFT", generalSettings, "TOPLEFT", 0, -30)
    silenceCheckbox:SetChecked(SwirlUIDB.uiSettings.silence)

    local moveAFPopupsCheckbox = AF.CreateCheckButton(generalSettings, string.format("Move %s Popups", AF.GetGradientText("AbstractFramework", "blazing_tangerine", "vivid_raspberry")), function(checked)
        SwirlUIDB.uiSettings.moveAFPopups = checked
        SwirlUI.SettingsChanged = true
        AF.Fire("SwirlUI_AbstractFrameworkPopups_Changed")
    end)
    AF.SetPoint(moveAFPopupsCheckbox, "TOPLEFT", silenceCheckbox, "TOPLEFT", 0, -25)
    moveAFPopupsCheckbox:SetChecked(SwirlUIDB.uiSettings.moveAFPopups)

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

        for i, status in ipairs(newStatusList) do
            local profiles = newStatusGroups[status]
            local color = SwirlUI.Utils:GetAddonStatusColor(profiles[1])
            
            local xOffset = math.floor((i - 1) * (columnWidth + spacing))
            
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
            
            local scrollList = AF.CreateScrollList(statusGroup, nil, 0, 0, #newAllProfiles, 22, 2, "background2", color)
            AF.SetPoint(scrollList, "TOPLEFT", statusGroup, "TOPLEFT", xOffset, -40)
            AF.SetSize(scrollList, columnWidth, statusListHeight)
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
                            SwirlUI.Imports[importFunction](SwirlUI.Imports, true)
                            SwirlUI.CreateStatusDisplay_AF()
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

        if applyAllBtn then
            local allApplied = SwirlUI.Imports:AreAllProfilesApplied()
            applyAllBtn:SetEnabled(not allApplied)
            if allApplied then
                applyAllBtn:SetText("All Profiles Applied")
            else
                applyAllBtn:SetText("Apply All Profiles")
            end
        end
    end

    SwirlUI.CreateStatusDisplay_AF()
end

local function ShowTab(callback, tab)
    if tab == "profiles" then
        if not profilesTab then
            CreateProfilesTab()
        end
        profilesTab:Show()
        SwirlUI.CreateStatusDisplay_AF()
    else
        if profilesTab then
            profilesTab:Hide()
        end
    end
end

AF.RegisterCallback("ShowOptionsTab", ShowTab, "medium")
