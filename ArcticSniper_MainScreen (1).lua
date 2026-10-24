--[[
ARCTIC SNIPER — SINGLE MAIN SCREEN
Oxide-inspired compact layout with Arctic icy-blue branding.
Local UI/demo only: announcement scanning is not connected to another game's private UI,
redeeming is not implemented, and toggles without backing systems are visual preferences.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("ArcticSniperMain")
if old then old:Destroy() end

local C = {
 BG = Color3.fromRGB(4, 9, 16), PANEL = Color3.fromRGB(10, 18, 29),
 ROW = Color3.fromRGB(16, 29, 43), HOVER = Color3.fromRGB(24, 43, 60),
 BLUE = Color3.fromRGB(80, 190, 255), BLUE_DARK = Color3.fromRGB(20, 79, 117),
 WHITE = Color3.fromRGB(239, 248, 255), MUTED = Color3.fromRGB(126, 157, 181),
 GREEN = Color3.fromRGB(125, 232, 197), BORDER = Color3.fromRGB(39, 83, 111)
}
local BLUE_PALETTE = {
 BLUE = Color3.fromRGB(80, 190, 255), BLUE_DARK = Color3.fromRGB(20, 79, 117),
 BORDER = Color3.fromRGB(39, 83, 111), ROW = Color3.fromRGB(16, 29, 43),
 HOVER = Color3.fromRGB(24, 43, 60), MUTED = Color3.fromRGB(126, 157, 181)
}
local HALLOWEEN_PALETTE = {
 BLUE = Color3.fromRGB(255, 137, 43), BLUE_DARK = Color3.fromRGB(126, 55, 14),
 BORDER = Color3.fromRGB(130, 68, 27), ROW = Color3.fromRGB(35, 24, 20),
 HOVER = Color3.fromRGB(57, 34, 22), MUTED = Color3.fromRGB(190, 151, 122)
}
local currentTheme = "BLUE"
local prefs = {scan = false, scope = false, spam = false, hideUser = false, auto = 5, scale = 0.76}
local currentCode = ""

local function make(className, props, parent)
 local obj = Instance.new(className)
 for k, v in pairs(props or {}) do obj[k] = v end
 obj.Parent = parent
 return obj
end
local function corner(obj, radius)
 make("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, obj)
end
local function outline(obj, color, thickness)
 make("UIStroke", {Color = color or C.BORDER, Thickness = thickness or 1, Transparency = 0.15}, obj)
end
local function text(parent, value, size, pos, fontSize, color, centered, font)
 return make("TextLabel", {
  BackgroundTransparency = 1, Text = value or "", Size = size, Position = pos,
  Font = font or Enum.Font.Gotham, TextSize = fontSize or 11,
  TextColor3 = color or C.WHITE,
  TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = true
 }, parent)
end
local function button(parent, value, size, pos, callback, color)
 local b = make("TextButton", {
  Size = size, Position = pos, BackgroundColor3 = color or C.ROW,
  BorderSizePixel = 0, Text = value, TextColor3 = C.WHITE,
  TextSize = 10, Font = Enum.Font.GothamSemibold, AutoButtonColor = false
 }, parent)
 corner(b, 7); outline(b)
 local isAccent = color == C.BLUE_DARK
 b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.HOVER}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = isAccent and C.BLUE_DARK or C.ROW}):Play() end)
 b.Activated:Connect(function() if callback then callback() end end)
 return b
end

local gui = make("ScreenGui", {
 Name = "ArcticSniperMain", ResetOnSpawn = false, IgnoreGuiInset = true,
 DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)
local main = make("Frame", {
 Name = "Main", AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
 Size = UDim2.fromOffset(480, 340), BackgroundColor3 = C.BG,
 BorderSizePixel = 0, Active = true, ClipsDescendants = true
}, gui)
corner(main, 13); outline(main, C.BORDER, 1.4)
local uiScale = make("UIScale", {Scale = 1}, main)
local function resize()
 local camera = workspace.CurrentCamera
 if not camera then return end
 local v = camera.ViewportSize
 uiScale.Scale = math.clamp(math.min((v.X - 18)/480, (v.Y - 18)/340, prefs.scale), .55, 1)
end
resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end

-- Header
local header = make("Frame", {Size = UDim2.new(1,0,0,43), BackgroundColor3 = C.PANEL, BorderSizePixel = 0, Active = true}, main)
local logo = make("Frame", {Size = UDim2.fromOffset(27,27), Position = UDim2.fromOffset(9,8), BackgroundColor3 = C.BLUE_DARK, BorderSizePixel = 0}, header)
corner(logo, 8); outline(logo, C.BLUE)
text(logo, "A", UDim2.fromScale(1,1), UDim2.new(), 17, C.BLUE, true, Enum.Font.GothamBlack)
text(header, "ARCTIC SNIPER", UDim2.new(0,170,0,18), UDim2.fromOffset(44,5), 11, C.WHITE, false, Enum.Font.GothamBold)
text(header, "FROST EDITION", UDim2.new(0,140,0,13), UDim2.fromOffset(45,22), 7, C.MUTED)
local statusDot = make("Frame", {Size = UDim2.fromOffset(6,6), Position = UDim2.new(1,-105,0,13), BackgroundColor3 = C.GREEN, BorderSizePixel = 0}, header)
corner(statusDot, 5)
text(header, "LOCAL DEMO", UDim2.fromOffset(64,15), UDim2.new(1,-94,0,9), 7, C.MUTED)
local closeButton = button(header, "×", UDim2.fromOffset(23,23), UDim2.new(1,-29,0,9), function() gui:Destroy() end, C.BLUE_DARK)
closeButton.TextSize = 16

-- Drag window by the header.
do
 local dragging, startPoint, startPos, dragType = false, nil, nil, nil
 header.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
   dragging = true; startPoint = input.Position; startPos = main.Position; dragType = input.UserInputType
  end
 end)
 UIS.InputChanged:Connect(function(input)
  if not dragging then return end
  local moving = (dragType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
   or (dragType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)
  if moving then
   local delta = input.Position - startPoint
   main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
  end
 end)
 UIS.InputEnded:Connect(function(input)
  if (dragType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
   or (dragType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch) then
   dragging = false; dragType = nil
  end
 end)
end

-- Minimal rail: only Main and Settings remain.
local rail = make("Frame", {Position = UDim2.fromOffset(7,49), Size = UDim2.new(0,56,1,-56), BackgroundColor3 = C.PANEL, BorderSizePixel = 0}, main)
corner(rail, 9); outline(rail)
text(rail, "ARCTIC", UDim2.new(1,0,0,18), UDim2.fromOffset(0,7), 7, C.MUTED, true, Enum.Font.GothamBold)
local content
local settingsPanel
button(rail, "MAIN", UDim2.new(1,-8,0,28), UDim2.fromOffset(4,31), function()
 if content then content.Visible = true end
 if settingsPanel then settingsPanel.Visible = false end
end, C.BLUE_DARK).TextSize = 7
button(rail, "SETTINGS", UDim2.new(1,-8,0,28), UDim2.fromOffset(4,64), function()
 if settingsPanel then settingsPanel.Visible = not settingsPanel.Visible end
end, C.ROW).TextSize = 6
text(rail, "❄", UDim2.new(1,0,0,20), UDim2.new(0,0,1,-24), 12, C.BLUE, true)

content = make("Frame", {Name = "MainContent", Position = UDim2.fromOffset(69,49), Size = UDim2.new(1,-77,1,-56), BackgroundTransparency = 1}, main)

-- Top row and sniped-code card
local topRow = make("Frame", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1}, content)
text(topRow, "●  ARCTIC STATUS: READY", UDim2.new(.65,0,1,0), UDim2.new(), 8, C.GREEN)
text(topRow, "AUTO SUBMIT "..prefs.auto, UDim2.new(.35,0,1,0), UDim2.new(.65,0,0,0), 8, C.BLUE, true)

local codeCard = make("Frame", {Position = UDim2.fromOffset(0,22), Size = UDim2.new(1,0,0,69), BackgroundColor3 = C.PANEL, BorderSizePixel = 0}, content)
corner(codeCard, 9); outline(codeCard)
text(codeCard, "SNIPED CODE", UDim2.new(1,-90,0,13), UDim2.fromOffset(9,5), 7, C.BLUE, false, Enum.Font.GothamBold)
local codeLabel = text(codeCard, "waiting...", UDim2.new(1,-100,0,24), UDim2.fromOffset(9,20), 16, C.WHITE, false, Enum.Font.GothamBold)
local codeHint = text(codeCard, "Local preview • no live game connection", UDim2.new(1,-100,0,13), UDim2.fromOffset(9,45), 7, C.MUTED)
button(codeCard, "RESET", UDim2.fromOffset(52,21), UDim2.new(1,-61,0,8), function()
 currentCode = ""; codeLabel.Text = "waiting..."; codeHint.Text = "Local preview • reset"; codeHint.TextColor3 = C.MUTED
end, C.BLUE_DARK)

local function toggleRow(y, titleText, subtitle, initial, onChanged)
 local row = make("Frame", {Position = UDim2.fromOffset(0,y), Size = UDim2.new(1,0,0,34), BackgroundColor3 = C.ROW, BorderSizePixel = 0}, content)
 corner(row, 7); outline(row)
 text(row, titleText, UDim2.new(1,-62,0,15), UDim2.fromOffset(9,3), 8, C.WHITE, false, Enum.Font.GothamSemibold)
 text(row, subtitle, UDim2.new(1,-62,0,11), UDim2.fromOffset(9,18), 6, C.MUTED)
 local on = initial == true
 local track = make("TextButton", {Size = UDim2.fromOffset(32,17), Position = UDim2.new(1,-40,.5,-8), BackgroundColor3 = on and C.BLUE or C.BG, BorderSizePixel = 0, Text = "", AutoButtonColor = false}, row)
 corner(track, 10)
 local knob = make("Frame", {Size = UDim2.fromOffset(11,11), Position = on and UDim2.new(1,-14,.5,-5) or UDim2.fromOffset(3,3), BackgroundColor3 = C.WHITE, BorderSizePixel = 0}, track)
 corner(knob, 7)
 track.Activated:Connect(function()
  on = not on
  track.BackgroundColor3 = on and C.BLUE or C.BG
  TweenService:Create(knob, TweenInfo.new(.12), {Position = on and UDim2.new(1,-14,.5,-5) or UDim2.fromOffset(3,3)}):Play()
  if onChanged then onChanged(on) end
 end)
 return row
end

toggleRow(91, "scan announcements", "Paste fragments below; scanner does not read private game UI", prefs.scan, function(v)
 prefs.scan = v
 codeHint.Text = v and "Paste fragments below, then press SCAN TEXT" or "Scanner paused"
 codeHint.TextColor3 = v and C.BLUE or C.MUTED
end)
toggleRow(127, "auto scope", "Preference toggle only", prefs.scope, function(v) prefs.scope=v end)
toggleRow(163, "spam redeem", "Preview preference; no redemption calls", prefs.spam, function(v) prefs.spam=v end)
toggleRow(199, "hide user", "Visual preference only", prefs.hideUser, function(v) prefs.hideUser=v end)

-- Auto submit selector
local autoRow = make("Frame", {Position = UDim2.fromOffset(0,222), Size = UDim2.new(1,0,0,27), BackgroundColor3 = C.ROW, BorderSizePixel = 0}, content)
corner(autoRow, 7); outline(autoRow)
text(autoRow, "auto submit", UDim2.new(.42,0,0,13), UDim2.fromOffset(9,3), 8, C.WHITE, false, Enum.Font.GothamSemibold)
text(autoRow, "pieces per code", UDim2.new(.42,0,0,10), UDim2.fromOffset(9,16), 6, C.MUTED)
local choices = make("Frame", {Position = UDim2.new(.44,0,0,4), Size = UDim2.new(.54,-5,0,22), BackgroundTransparency = 1}, autoRow)
local choiceButtons = {}
local function setAuto(n)
 prefs.auto = n
 for i, b in ipairs(choiceButtons) do
  b.BackgroundColor3 = i == n and C.BLUE_DARK or C.PANEL
  b.TextColor3 = i == n and C.WHITE or C.MUTED
 end
 topRow:FindFirstChildWhichIsA("TextLabel", true).Text = "●  ARCTIC STATUS: READY"
 local labels = topRow:GetChildren()
 for _, child in ipairs(labels) do
  if child:IsA("TextLabel") and child.Text:find("AUTO SUBMIT") then child.Text = "AUTO SUBMIT "..n end
 end
end
for i=1,5 do
 local b = button(choices, tostring(i), UDim2.new(.2,-2,1,0), UDim2.new((i-1)*.2, i == 1 and 0 or 1, 0, 0), function() setAuto(i) end, i == prefs.auto and C.BLUE_DARK or C.PANEL)
 b.TextSize = 8; b.TextColor3 = i == prefs.auto and C.WHITE or C.MUTED
 table.insert(choiceButtons, b)
end

-- Bottom action buttons
local bottom = make("Frame", {Position = UDim2.new(0,0,1,-27), Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1}, content)
local fragmentBox = make("TextBox", {
 Size = UDim2.new(.68,-4,1,0), Position = UDim2.new(0,0,0,0),
 BackgroundColor3 = C.ROW, BorderSizePixel = 0, ClearTextOnFocus = false,
 PlaceholderText = "Paste fragments: ABC 12 XY", Text = "", TextColor3 = C.WHITE,
 PlaceholderColor3 = C.MUTED, TextSize = 8, Font = Enum.Font.Gotham,
 TextXAlignment = Enum.TextXAlignment.Left
}, bottom)
corner(fragmentBox, 7); outline(fragmentBox)
button(bottom, "SCAN TEXT", UDim2.new(.32,0,1,0), UDim2.new(.68,4,0,0), function()
 local raw = string.upper(fragmentBox.Text or "")
 local pieces = {}
 for piece in string.gmatch(raw, "[A-Z0-9]+") do
  table.insert(pieces, piece)
 end
 if #pieces < 2 then
  codeHint.Text = "Enter 2+ fragments separated by spaces"
  codeHint.TextColor3 = C.MUTED
  return
 end
 currentCode = table.concat(pieces, "")
 codeLabel.Text = currentCode
 codeHint.Text = "Scanned supplied text • verify the result"
 codeHint.TextColor3 = C.GREEN
end, C.BLUE_DARK)

-- This scans text the user supplies; it does not read another game's private banner UI.

-- Settings panel: choose between standard blue and Halloween orange.
settingsPanel = make("Frame", {
 Name = "SettingsPanel", Position = UDim2.fromOffset(0,0), Size = UDim2.fromScale(1,1),
 BackgroundColor3 = C.BG, BorderSizePixel = 0, Visible = false, ZIndex = 20
}, content)
corner(settingsPanel, 9); outline(settingsPanel, C.BORDER, 1.2)
text(settingsPanel, "SETTINGS", UDim2.new(1,-20,0,26), UDim2.fromOffset(10,8), 12, C.WHITE, false, Enum.Font.GothamBold).ZIndex = 21
text(settingsPanel, "Choose your Arctic Sniper color theme", UDim2.new(1,-20,0,20), UDim2.fromOffset(10,35), 8, C.MUTED).ZIndex = 21

local function applyTheme(theme)
 local oldPalette = currentTheme == "BLUE" and BLUE_PALETTE or HALLOWEEN_PALETTE
 local newPalette = theme == "BLUE" and BLUE_PALETTE or HALLOWEEN_PALETTE
 for _, obj in ipairs(gui:GetDescendants()) do
  for _, prop in ipairs({"BackgroundColor3", "TextColor3", "PlaceholderColor3"}) do
   local ok, value = pcall(function() return obj[prop] end)
   if ok and typeof(value) == "Color3" then
    for role, oldColor in pairs(oldPalette) do
     if value == oldColor then
      pcall(function() obj[prop] = newPalette[role] end)
      break
     end
    end
   end
  end
  if obj:IsA("UIStroke") then
   for role, oldColor in pairs(oldPalette) do
    if obj.Color == oldColor then obj.Color = newPalette[role]; break end
   end
  end
 end
 C.BLUE = newPalette.BLUE
 C.BLUE_DARK = newPalette.BLUE_DARK
 C.BORDER = newPalette.BORDER
 C.ROW = newPalette.ROW
 C.HOVER = newPalette.HOVER
 C.MUTED = newPalette.MUTED
 currentTheme = theme
end

local themeButton
themeButton = button(settingsPanel, "Switch to Halloween Orange", UDim2.new(1,-20,0,34), UDim2.fromOffset(10,66), function()
 local nextTheme = currentTheme == "BLUE" and "HALLOWEEN" or "BLUE"
 applyTheme(nextTheme)
 themeButton.Text = nextTheme == "BLUE" and "Switch to Halloween Orange" or "Switch to Arctic Blue"
end, C.BLUE_DARK)
themeButton.ZIndex = 21
local backButton = button(settingsPanel, "BACK TO MAIN", UDim2.new(1,-20,0,30), UDim2.fromOffset(10,109), function()
 settingsPanel.Visible = false
end, C.ROW)
backButton.ZIndex = 21
text(settingsPanel, "Halloween palette: orange accents and dark charcoal panels.", UDim2.new(1,-20,0,30), UDim2.fromOffset(10,148), 8, C.MUTED).ZIndex = 21

-- Reopen button when minimized
local mini = button(gui, "❄ AS", UDim2.fromOffset(66,32), UDim2.new(0,12,.5,-16), function()
 main.Visible = true; mini.Visible = false
end, C.PANEL)
mini.Visible = false; outline(mini, C.BLUE)
local minimize = button(header, "—", UDim2.fromOffset(22,22), UDim2.new(1,-55,0,9), function()
 main.Visible = false; mini.Visible = true
end, C.ROW)

print("Arctic Sniper Main Screen loaded (local UI demo)")
