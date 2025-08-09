local _, SwirlUI = ...
local SUI = LibStub("AceAddon-3.0"):NewAddon("SwirlUI")

function SUI:OnEnable()
    print("|cff02fd98Swirl|rUI Core Loaded")
    SwirlUI:Initialize()
end