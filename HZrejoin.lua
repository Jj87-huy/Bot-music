-- 🔁 Auto Rejoin Game (Hidden Start Version by ChatGPT)
-- ✅ Mặc định ẩn giao diện, có nút bật/tắt, rejoin an toàn, fix lỗi nhân vật

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- 🧭 Cấu hình
local targetPlaceId = 103754275310547 -- ⚠️ Thay bằng ID game muốn vào
local delayTime = 300 -- 10 phút = 600 giây

-- ==============================
-- 🪟 GIAO DIỆN
-- ==============================
local gui = Instance.new("ScreenGui")
gui.Name = "SafeRejoinUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- 🔲 Khung UI chính (ẩn mặc định)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.5, -140, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Visible = false -- ⚙️ Ẩn khi vừa vào
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.Text = "🔁 Safe Auto Rejoin"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local countdownLabel = Instance.new("TextLabel", frame)
countdownLabel.Size = UDim2.new(1, -20, 0, 60)
countdownLabel.Position = UDim2.new(0, 10, 0, 50)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Text = "Time Remaining: 10:00"
countdownLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
countdownLabel.Font = Enum.Font.GothamBold
countdownLabel.TextSize = 22
countdownLabel.TextWrapped = true

local cancelBtn = Instance.new("TextButton", frame)
cancelBtn.Size = UDim2.new(0.6, 0, 0, 35)
cancelBtn.Position = UDim2.new(0.2, 0, 1, -45)
cancelBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.Text = "Cancel Rejoin"
cancelBtn.TextColor3 = Color3.new(1, 1, 1)
cancelBtn.TextSize = 18
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

-- ==============================
-- 🎛️ NÚT ẨN / HIỆN
-- ==============================
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 25, 0.85, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
toggleBtn.Image = "rbxassetid://3926307971"
toggleBtn.ImageRectOffset = Vector2.new(964, 324)
toggleBtn.ImageRectSize = Vector2.new(36, 36)
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Draggable = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", toggleBtn)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.4

local hidden = true -- ⚙️ Ban đầu ẩn UI
toggleBtn.MouseButton1Click:Connect(function()
	hidden = not hidden
	if hidden then
		TweenService:Create(frame, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -140, 1, 200)}):Play()
		task.wait(0.25)
		frame.Visible = false
	else
		frame.Visible = true
		TweenService:Create(frame, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -140, 0.5, -80)}):Play()
	end
end)

-- ==============================
-- ⏱️ LOGIC ĐẾM NGƯỢC
-- ==============================
local cancelled = false
local function formatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

cancelBtn.MouseButton1Click:Connect(function()
	cancelled = true
	countdownLabel.Text = "❌ Rejoin Cancelled"
	cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	cancelBtn.Text = "Cancelled"
end)

for i = delayTime, 0, -1 do
	if cancelled then break end
	countdownLabel.Text = "Time Remaining: " .. formatTime(i)
	task.wait(1)
end

-- ==============================
-- 🔄 SAFE TELEPORT
-- ==============================
if not cancelled then
	countdownLabel.Text = "🧹 Cleaning character..."
	task.wait(1)

	pcall(function()
		if player.Character then
			player.Character:Destroy()
		end
	end)
	task.wait(2)

	countdownLabel.Text = "🔁 Rejoining safely..."
	task.wait(1)

	local success, err = pcall(function()
		TeleportService:Teleport(targetPlaceId, player)
	end)

	if not success then
		warn("[Teleport Error]:", err)
		countdownLabel.Text = "⚠️ Teleport failed, retrying..."
		task.wait(3)
		TeleportService:Teleport(targetPlaceId, player)
	end
end

TeleportService.TeleportInitFailed:Connect(function(_, result, message)
	warn("⚠️ Teleport failed:", result, message)
	task.wait(2)
	TeleportService:Teleport(targetPlaceId, player)
end)
