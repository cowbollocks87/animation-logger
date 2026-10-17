local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = {
    BgTop = Color3.fromRGB(52, 58, 78),
    BgBottom = Color3.fromRGB(18, 20, 28),
    HeaderTop = Color3.fromRGB(68, 74, 98),
    HeaderBottom = Color3.fromRGB(42, 46, 62),
    Surface = Color3.fromRGB(48, 52, 68),
    SurfaceHover = Color3.fromRGB(62, 68, 88),
    Stroke = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(245, 247, 252),
    TextDim = Color3.fromRGB(160, 165, 185),
    Accent = Color3.fromRGB(140, 170, 255),
    Success = Color3.fromRGB(120, 220, 160),
    Danger = Color3.fromRGB(245, 130, 140),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

local connections = {}
local destroyed = false
local currentAnimatorConn = nil
local entries = {}

local function track(connection)
    connections[#connections + 1] = connection
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)
    if currentAnimatorConn and currentAnimatorConn.Connected then
        currentAnimatorConn:Disconnect()
    end
    currentAnimatorConn = nil
end

local function tween(instance, props, duration, style, direction)
    return TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.25,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ),
        props
    ):Play()
end

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    elseif syn and syn.write_clipboard then
        syn.write_clipboard(text)
    else
        warn("Clipboard API not supported by this executor.")
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationLogger"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local function destroy()
    if destroyed then return end
    destroyed = true
    disconnectAll()
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(380, 520)
main.Position = UDim2.new(0.5, -190, 0.5, -260)
main.BackgroundColor3 = Color3.new(1, 1, 1)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.BgTop),
    ColorSequenceKeypoint.new(1, Theme.BgBottom),
})
mainGradient.Rotation = 135
mainGradient.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1
mainStroke.Transparency = 0.9
mainStroke.Parent = main

local mainShadow = Instance.new("UIShadow")
mainShadow.BlurRadius = UDim.new(0, 24)
mainShadow.Color = Color3.fromRGB(0, 0, 0)
mainShadow.Transparency = 0.55
mainShadow.Offset = UDim2.fromOffset(0, 8)
mainShadow.Spread = UDim2.fromOffset(0, 4)
mainShadow.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = Color3.new(1, 1, 1)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Name = "Cover"
headerCover.Size = UDim2.new(1, 0, 0, 16)
headerCover.Position = UDim2.new(0, 0, 1, -16)
headerCover.BackgroundColor3 = Theme.HeaderBottom
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.HeaderTop),
    ColorSequenceKeypoint.new(1, Theme.HeaderBottom),
})
headerGradient.Rotation = 135
headerGradient.Parent = header

local headerSeparator = Instance.new("Frame")
headerSeparator.Name = "Separator"
headerSeparator.Size = UDim2.new(1, 0, 0, 1)
headerSeparator.Position = UDim2.new(0, 0, 1, -1)
headerSeparator.BackgroundColor3 = Color3.new(1, 1, 1)
headerSeparator.BackgroundTransparency = 0.9
headerSeparator.BorderSizePixel = 0
headerSeparator.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "Animation Logger"
title.TextColor3 = Theme.Text
title.TextSize = 15
title.Font = Theme.FontBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local indicator = Instance.new("Frame")
indicator.Name = "Indicator"
indicator.Size = UDim2.fromOffset(7, 7)
indicator.Position = UDim2.new(1, -92, 0.5, -3)
indicator.BackgroundColor3 = Theme.Accent
indicator.BorderSizePixel = 0
indicator.Parent = header

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = indicator

local indicatorGlow = Instance.new("UIStroke")
indicatorGlow.Color = Theme.Accent
indicatorGlow.Thickness = 3
indicatorGlow.Transparency = 0.7
indicatorGlow.Parent = indicator

task.spawn(function()
    while indicator.Parent and not destroyed do
        tween(indicator, { BackgroundTransparency = 0.5 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(indicatorGlow, { Transparency = 0.85 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(0.9)
        if destroyed or not indicator.Parent then break end
        tween(indicator, { BackgroundTransparency = 0 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(indicatorGlow, { Transparency = 0.6 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(0.9)
    end
end)

local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.fromOffset(32, 32)
minBtn.Position = UDim2.new(1, -76, 0.5, -16)
minBtn.BackgroundColor3 = Color3.new(1, 1, 1)
minBtn.BackgroundTransparency = 1
minBtn.Text = "−"
minBtn.TextColor3 = Theme.TextDim
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
minBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -44, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Theme.TextDim
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

track(minBtn.MouseEnter:Connect(function()
    if destroyed then return end
    tween(minBtn, { BackgroundTransparency = 0.85, TextColor3 = Theme.Accent }, 0.15)
end))

track(minBtn.MouseLeave:Connect(function()
    if destroyed then return end
    tween(minBtn, { BackgroundTransparency = 1, TextColor3 = Theme.TextDim }, 0.15)
end))

track(closeBtn.MouseEnter:Connect(function()
    if destroyed then return end
    tween(closeBtn, { BackgroundTransparency = 0.85, TextColor3 = Theme.Danger }, 0.15)
end))

track(closeBtn.MouseLeave:Connect(function()
    if destroyed then return end
    tween(closeBtn, { BackgroundTransparency = 1, TextColor3 = Theme.TextDim }, 0.15)
end))

track(closeBtn.MouseButton1Click:Connect(destroy))

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, -32, 1, -80)
scroll.Position = UDim2.fromOffset(16, 64)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Theme.Stroke
scroll.ScrollBarImageTransparency = 0.85
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingBottom = UDim.new(0, 16)
listPad.PaddingTop = UDim.new(0, 4)
listPad.Parent = scroll

local emptyLabel = Instance.new("TextLabel")
emptyLabel.Name = "Empty"
emptyLabel.Size = UDim2.new(1, 0, 0, 40)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "Waiting for animations…"
emptyLabel.TextColor3 = Theme.TextDim
emptyLabel.TextSize = 12
emptyLabel.Font = Theme.Font
emptyLabel.Parent = scroll

local minimized = false
local originalSize = UDim2.fromOffset(380, 520)
local minimizedSize = UDim2.fromOffset(380, 56)
local sizeTween = nil

local function toggleMinimize()
    if destroyed then return end
    minimized = not minimized
    if sizeTween then sizeTween:Cancel() end
    if minimized then
        scroll.Visible = false
        sizeTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = minimizedSize})
        sizeTween:Play()
        minBtn.Text = "□"
    else
        sizeTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = originalSize})
        sizeTween:Play()
        task.delay(0.3, function()
            if not destroyed and not minimized then
                scroll.Visible = true
            end
        end)
        minBtn.Text = "−"
    end
end

track(minBtn.MouseButton1Click:Connect(toggleMinimize))

local entryCount = 0

local function logAnimation(animationTrack)
    if destroyed or not animationTrack then return end
    local animation = animationTrack.Animation
    if not animation then return end
    local id = animation.AnimationId
    if not id or id == "" or id == "rbxassetid://0" then return end
    local name = animation.Name
    if not name or name == "" then
        name = "Unnamed"
    end

    local existing = entries[id]
    if existing then
        existing.count += 1
        existing.countLabel.Text = "×" .. existing.count
        local stroke = existing.countBadge:FindFirstChildOfClass("UIStroke")
        if stroke then
            tween(stroke, { Transparency = 0, Color = Theme.Accent }, 0.1)
            task.delay(0.15, function()
                if destroyed then return end
                if stroke.Parent then
                    tween(stroke, { Transparency = 0.5, Color = Theme.Accent }, 0.5)
                end
            end)
        end
        return
    end

    entryCount += 1

    local entry = Instance.new("Frame")
    entry.Name = "Entry_" .. entryCount
    entry.Size = UDim2.new(1, -4, 0, 64)
    entry.BackgroundColor3 = Theme.Surface
    entry.BackgroundTransparency = 0.2
    entry.BorderSizePixel = 0
    entry.ClipsDescendants = true
    entry.LayoutOrder = -entryCount
    entry.Active = true
    entry.Parent = scroll

    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 12)
    entryCorner.Parent = entry

    local entryGradient = Instance.new("UIGradient")
    entryGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.15),
    })
    entryGradient.Rotation = 135
    entryGradient.Parent = entry

    local entryStroke = Instance.new("UIStroke")
    entryStroke.Color = Theme.Stroke
    entryStroke.Thickness = 1
    entryStroke.Transparency = 0.92
    entryStroke.Parent = entry

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -110, 0, 20)
    nameLabel.Position = UDim2.fromOffset(16, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 14
    nameLabel.Font = Theme.FontBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = entry

    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "Id"
    idLabel.Size = UDim2.new(1, -110, 0, 16)
    idLabel.Position = UDim2.fromOffset(16, 34)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = id
    idLabel.TextColor3 = Theme.TextDim
    idLabel.TextSize = 11
    idLabel.Font = Theme.Font
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.TextTruncate = Enum.TextTruncate.AtEnd
    idLabel.Parent = entry

    local countBadge = Instance.new("Frame")
    countBadge.Name = "CountBadge"
    countBadge.AnchorPoint = Vector2.new(1, 0)
    countBadge.Position = UDim2.new(1, -16, 0, 12)
    countBadge.Size = UDim2.fromOffset(0, 20)
    countBadge.AutomaticSize = Enum.AutomaticSize.X
    countBadge.BackgroundColor3 = Theme.Accent
    countBadge.BackgroundTransparency = 0.82
    countBadge.BorderSizePixel = 0
    countBadge.Parent = entry

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 10)
    badgeCorner.Parent = countBadge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Theme.Accent
    badgeStroke.Thickness = 1
    badgeStroke.Transparency = 0.5
    badgeStroke.Parent = countBadge

    local badgePad = Instance.new("UIPadding")
    badgePad.PaddingLeft = UDim.new(0, 8)
    badgePad.PaddingRight = UDim.new(0, 8)
    badgePad.Parent = countBadge

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "Count"
    countLabel.Size = UDim2.fromOffset(0, 20)
    countLabel.AutomaticSize = Enum.AutomaticSize.X
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "×1"
    countLabel.TextColor3 = Theme.Accent
    countLabel.TextSize = 11
    countLabel.Font = Theme.FontBold
    countLabel.Parent = countBadge

    local copyBtn = Instance.new("TextButton")
    copyBtn.Name = "CopyBtn"
    copyBtn.AnchorPoint = Vector2.new(1, 0)
    copyBtn.Position = UDim2.new(1, -16, 0, 36)
    copyBtn.Size = UDim2.fromOffset(56, 20)
    copyBtn.BackgroundColor3 = Theme.Accent
    copyBtn.BackgroundTransparency = 0.85
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = Theme.Accent
    copyBtn.TextSize = 10
    copyBtn.Font = Theme.FontBold
    copyBtn.AutoButtonColor = false
    copyBtn:SetAttribute("Copied", false)
    copyBtn.Parent = entry

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn

    entries[id] = {
        count = 1,
        name = name,
        countLabel = countLabel,
        countBadge = countBadge,
        frame = entry,
    }

    if emptyLabel.Parent then
        emptyLabel.Visible = false
    end

    entry.BackgroundTransparency = 1
    nameLabel.TextTransparency = 1
    idLabel.TextTransparency = 1

    tween(entry, { BackgroundTransparency = 0.2 }, 0.35)
    tween(nameLabel, { TextTransparency = 0 }, 0.35)
    tween(idLabel, { TextTransparency = 0 }, 0.35)

    if scroll.CanvasPosition.Y > 0 then
        tween(scroll, { CanvasPosition = Vector2.new(0, 0) }, 0.3)
    end

    track(entry.MouseEnter:Connect(function()
        if destroyed then return end
        tween(entry, { BackgroundColor3 = Theme.SurfaceHover, BackgroundTransparency = 0.1 }, 0.2)
        tween(entryStroke, { Transparency = 0.78 }, 0.2)
        tween(copyBtn, { BackgroundTransparency = 0.55, TextTransparency = 0 }, 0.2)
    end))

    track(entry.MouseLeave:Connect(function()
        if destroyed then return end
        tween(entry, { BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.2 }, 0.2)
        tween(entryStroke, { Transparency = 0.92 }, 0.2)
        if not copyBtn:GetAttribute("Copied") then
            tween(copyBtn, { BackgroundTransparency = 0.85, TextTransparency = 0 }, 0.2)
        end
    end))

    track(copyBtn.MouseEnter:Connect(function()
        if destroyed or copyBtn:GetAttribute("Copied") then return end
        tween(copyBtn, { BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1) }, 0.15)
    end))

    track(copyBtn.MouseLeave:Connect(function()
        if destroyed or copyBtn:GetAttribute("Copied") then return end
        tween(copyBtn, { BackgroundTransparency = 0.55, TextColor3 = Theme.Accent }, 0.15)
    end))

    track(copyBtn.MouseButton1Click:Connect(function()
        if destroyed then return end
        copyBtn:SetAttribute("Copied", true)
        copyToClipboard(id)
        copyBtn.Text = "Copied"
        tween(copyBtn, { BackgroundColor3 = Theme.Success, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 }, 0.15)
        task.delay(1.2, function()
            if destroyed then return end
            if copyBtn.Parent then
                copyBtn:SetAttribute("Copied", false)
                copyBtn.Text = "Copy"
                tween(copyBtn, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Accent, BackgroundTransparency = 0.85 }, 0.2)
            end
        end)
    end))
end

local function setupCharacter(character)
    if destroyed then return end
    if currentAnimatorConn and currentAnimatorConn.Connected then
        currentAnimatorConn:Disconnect()
    end
    currentAnimatorConn = nil
    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid or destroyed then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = humanoid:WaitForChild("Animator", 5)
        end
        if not animator or destroyed then return end
        currentAnimatorConn = animator.AnimationPlayed:Connect(logAnimation)
    end)
end

track(player.CharacterAdded:Connect(setupCharacter))

if player.Character then
    setupCharacter(player.Character)
end

local dragging = false
local dragStartPos = Vector2.new()
local dragStartOffset = UDim2.new()

track(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        dragStartOffset = main.Position
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

track(UserInputService.InputChanged:Connect(function(input)
    if not dragging or destroyed then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
        main.Position = UDim2.new(
            dragStartOffset.X.Scale,
            dragStartOffset.X.Offset + delta.X,
            dragStartOffset.Y.Scale,
            dragStartOffset.Y.Offset + delta.Y
        )
    end
end))
