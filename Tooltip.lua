local _, SwirlUI = ...

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local function ApplyFontSettings(fontString)
    if not fontString then return end
    fontString:SetFont(SwirlUI.Font, SwirlUI.FontSize, "OUTLINE")
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(0, 0)
end

local function UpdateFonts()
    for i = 1, 20 do
        ApplyFontSettings(_G["GameTooltipTextLeft" .. i])
        ApplyFontSettings(_G["GameTooltipTextRight" .. i])
    end
end

function SwirlUI:StyleTooltip()
    local regions = {
        "BottomEdge", "BottomLeftCorner", "BottomRightCorner",
        "Center", "LeftEdge", "RightEdge",
        "TopEdge", "TopLeftCorner", "TopRightCorner",
    }

    for _, region in ipairs(regions) do
        local tooltipRegion = GameTooltip.NineSlice[region]
        if tooltipRegion then
            tooltipRegion:SetAlpha(0)
            tooltipRegion:Hide()
        end
    end

    local tooltip = CreateFrame("Frame", nil, GameTooltip, "BackdropTemplate")
    tooltip:SetAllPoints(GameTooltip)
    tooltip:SetBackdrop(BACKDROP)
    tooltip:SetBackdropColor(0.024, 0.031, 0.031, 0.875)
    tooltip:SetBackdropBorderColor(0, 0, 0, 1)
    tooltip:SetFrameLevel(GameTooltip:GetFrameLevel() - 1)
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, _)
    if tooltip ~= GameTooltip then return end
    tooltip.StatusBar:SetAlpha(0)
    tooltip.StatusBar:Hide()
    UpdateFonts()
end)