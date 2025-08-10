local _, SwirlUI = ...
local SUI = LibStub("AceAddon-3.0"):NewAddon("SwirlUI")

function SUI:OnEnable()
    print(string.format("%s » %s for config", SwirlUI.HeaderNoColon, SwirlUI.ApplyColor("/swirlui", "00ff96")))
    SwirlUI:Initialize()
end