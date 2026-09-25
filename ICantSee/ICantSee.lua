local CLEAR = 100000
local DEFAULT_INTERVAL = 0.0001
local flip, acc = false, 0

local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:SetScript("OnEvent", function(_, _, name)
    if name ~= "ICantSee" then return end
    ICantSeeDB = ICantSeeDB or {}
    if ICantSeeDB.interval == nil then ICantSeeDB.interval = DEFAULT_INTERVAL end
end)

CreateFrame("Frame"):SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < (ICantSeeDB and ICantSeeDB.interval or DEFAULT_INTERVAL) then return end
    acc = 0
    flip = not flip
    SetCVar("volumeFog", flip and 1 or 0)
    SetCVar("horizonStart", CLEAR)
    SetCVar("disableHorizonStart", 1)
    SetCVar("horizonClip", 10000)
    SetCVar("farclip", 10000)
end)

local panel
local function buildUI()
    panel = CreateFrame("Frame", "ICantSeePanel", UIParent, "BackdropTemplate")
    panel:SetSize(300, 130)
    panel:SetPoint("CENTER")
    panel:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    panel:SetMovable(true); panel:EnableMouse(true); panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14); title:SetText("I Can't See!")
    CreateFrame("Button", nil, panel, "UIPanelCloseButton"):SetPoint("TOPRIGHT", 2, 2)

    local slider = CreateFrame("Slider", "ICantSeeSlider", panel, "OptionsSliderTemplate")
    slider:SetPoint("TOP", 0, -56); slider:SetWidth(240)
    slider:SetMinMaxValues(0.0001, 1.0)
    slider:SetValueStep(0.0001)
    slider:SetObeyStepOnDrag(true)
    _G["ICantSeeSliderLow"]:SetText("0.0001s")
    _G["ICantSeeSliderHigh"]:SetText("1s")
    _G["ICantSeeSliderText"]:SetText("Oscillation interval")

    local val = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    val:SetPoint("TOP", slider, "BOTTOM", 0, -8)
    local function showVal(v) val:SetText(("oscillate every %.4fs"):format(v)) end

    slider:SetValue(ICantSeeDB.interval)
    showVal(ICantSeeDB.interval)
    slider:SetScript("OnValueChanged", function(_, v)
        ICantSeeDB.interval = v
        showVal(v)
    end)
end

SLASH_ICANTSEE1 = "/ics"
SLASH_ICANTSEE2 = "/icantsee"
SlashCmdList.ICANTSEE = function()
    if not panel then buildUI() else panel:SetShown(not panel:IsShown()) end
end
