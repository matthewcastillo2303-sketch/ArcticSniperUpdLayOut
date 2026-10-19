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
local prefs = {scan = false, scope = false, spam = false, hideUser = false, auto = 5, scale = 1}
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
 local base = color or C.ROW
 b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.HOVER}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = base}):Play() end)
 b.Activated:Connect(function() if callback then callback() end end)
 return b
end

local gui = make("ScreenGui", {
 Name = "ArcticSniperMain", ResetOnSpawn = false, IgnoreGuiInset = true,
 DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)
local main = make("Frame", {
 Name = "Main", AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
 Size = UDim2.fromOffset(510, 360), BackgroundColor3 = C.BG,
 BorderSizePixel = 0, Active = true, ClipsDescendants = true
}, gui)
corner(main, 13); outline(main, C.BORDER, 1.4)
local uiScale = make("UIScale", {Scale = 1}, main)
local function resize()
 local camera = workspace.CurrentCamera
 if not camera then return end
 local v = camera.ViewportSize
 uiScale.Scale = math.clamp(math.min((v.X - 18)/510, (v.Y - 18)/360, prefs.scale), .55, 1)
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

-- Compact left rail: visual navigation only; all controls remain on Main.
local rail = make("Frame", {Position = UDim2.fromOffset(7,49), Size = UDim2.new(0,68,1,-56), BackgroundColor3 = C.PANEL, BorderSizePixel = 0}, main)
corner(rail, 9); outline(rail)
text(rail, "ARCTIC", UDim2.new(1,0,0,18), UDim2.fromOffset(0,7), 7, C.MUTED, true, Enum.Font.GothamBold)
local selectedRail
for i, item in ipairs({"MAIN", "CONSOLE", "TRAITFARMER", "SETTINGS"}) do
 local b = button(rail, item, UDim2.new(1,-10,0,27), UDim2.fromOffset(5,30+(i-1)*33), function()
  if item == "MAIN" then
   if selectedRail then selectedRail.BackgroundColor3 = C.ROW end
   b = nil
  else
   -- These are intentionally labels only; this redesign keeps all controls on Main.
  end
 end, item == "MAIN" and C.BLUE_DARK or C.ROW)
 b.TextSize = item == "TRAITFARMER" and 6 or 7
 b.TextColor3 = item == "MAIN" and C.WHITE or C.MUTED
 if item == "MAIN" then selectedRail = b end
end
text(rail, "❄", UDim2.new(1,0,0,20), UDim2.new(0,0,1,-24), 12, C.BLUE, true)

local content = make("Frame", {Name = "MainContent", Position = UDim2.fromOffset(82,49), Size = UDim2.new(1,-90,1,-56), BackgroundTransparency = 1}, main)

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

toggleRow(97, "scan announcements", "Local test only; not connected to other games", prefs.scan, function(v) prefs.scan=v end)
toggleRow(135, "auto scope", "Preference toggle only", prefs.scope, function(v) prefs.scope=v end)
toggleRow(173, "spam redeem", "Preview preference; no redemption calls", prefs.spam, function(v) prefs.spam=v end)
toggleRow(211, "hide user", "Visual preference only", prefs.hideUser, function(v) prefs.hideUser=v end)

-- Auto submit selector
local autoRow = make("Frame", {Position = UDim2.fromOffset(0,249), Size = UDim2.new(1,0,0,30), BackgroundColor3 = C.ROW, BorderSizePixel = 0}, content)
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
button(bottom, "FEEDBACK", UDim2.new(.48,-3,1,0), UDim2.new(), function()
 codeHint.Text = "Feedback: use your project/community channel"; codeHint.TextColor3 = C.BLUE
end, C.ROW)
button(bottom, "CLEAR TEXTBOX", UDim2.new(.48,-3,1,0), UDim2.new(.52,3,0,0), function()
 currentCode = ""; codeLabel.Text = "waiting..."; codeHint.Text = "Local preview cleared"; codeHint.TextColor3 = C.MUTED
end, C.ROW)

-- Local-only testing hook: clicking the code display cycles sample pieces and combines them.
local samplePieces = {"FRO", "ST", "99"}
local sampleIndex = 0
local sampleButton = button(codeCard, "TEST", UDim2.fromOffset(40,18), UDim2.new(1,-52,1,-25), function()
 sampleIndex = sampleIndex % #samplePieces + 1
 currentCode = currentCode .. samplePieces[sampleIndex]
 codeLabel.Text = currentCode
 codeHint.Text = "Test piece added: " .. samplePieces[sampleIndex]
 codeHint.TextColor3 = C.GREEN
 if sampleIndex == #samplePieces then
  codeHint.Text = "Test complete • " .. currentCode
  currentCode = ""
 end
end, C.ROW)
sampleButton.TextSize = 7

-- Reopen button when minimized
local mini = button(gui, "❄ AS", UDim2.fromOffset(66,32), UDim2.new(0,12,.5,-16), function()
 main.Visible = true; mini.Visible = false
end, C.PANEL)
mini.Visible = false; outline(mini, C.BLUE)
local minimize = button(header, "—", UDim2.fromOffset(22,22), UDim2.new(1,-55,0,9), function()
 main.Visible = false; mini.Visible = true
end, C.ROW)

print("Arctic Sniper Main Screen loaded (local UI demo)")
