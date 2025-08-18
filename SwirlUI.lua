local _, SwirlUI = ...
local SUI = LibStub("AceAddon-3.0"):NewAddon("SwirlUI")

function SUI:OnEnable()
    if not (SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence) then
        print(string.format("%s » %s for config", SwirlUI.HeaderNoColon, SwirlUI.ApplyColor("/swirlui", "00ff96")))
    end
    SwirlUI:Initialize()
end