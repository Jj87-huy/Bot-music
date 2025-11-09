-- 🔁 Minimal Auto Rejoin Toolbar (by ChatGPT)
-- ✅ Gọn gàng: chỉ có 1 nút bật/tắt và thanh thời gian đếm ngược

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ⚙️ Cấu hình
local targetPlaceId = 103754275310547 -- 👈 ID game muốn rejoin
local delayTime = 60 -- 1 phút = 60 giây (thay tuỳ ý)

-- ==============================
-- 🧱 GIAO DIỆN TOOLBAR
-- ==============================
local gui = Instance.new("ScreenGui")
gui.Name = "RejoinToolbar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local toolbar = Instance.new("Frame", gui)
toolbar.Size = UDim2.new(1, 0, 0, 40)
toolbar.Position = UDim2.new(0, 0, 0, 0)
toolbar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toolbar.BorderSizePixel = 0

local stroke = Instance.new("UIStroke", toolbar)
stroke.Color = Color3.fromRGB(90, 150, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.5

-- Nút bật/tắt 🔁 / ❌
local toggleBtn = Instance.new("TextButton", toolbar)
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
toggleBtn.Text = "🔁"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 20
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- Đồng hồ đếm ngược
local countdownLabel = Instance.new("TextLabel", toolbar)
countdownLabel.Size = UDim2.new(0, 150, 0, 30)
countdownLabel.Position = UDim2.new(1, -160, 0.5, -15)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.GothamBold
countdownLabel.Text = "00:00"
countdownLabel.TextSize = 22
countdownLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
countdownLabel.TextXAlignment = Enum.TextXAlignment.Right

-- ==============================
-- ⚙️ LOGIC
-- ==============================
local active = false
local remaining = delayTime

local function formatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

-- Cập nhật đồng hồ đếm ngược
task.spawn(function()
	while task.wait(1) do
		if active then
			if remaining > 0 then
				remaining -= 1
				countdownLabel.Text = formatTime(remaining)
			else
				countdownLabel.Text = "🔁 Rejoining..."
				task.wait(1)

				pcall(function()
					if player.Character then player.Character:Destroy() end
				end)
				task.wait(1)

				local success, err = pcall(function()
					TeleportService:Teleport(targetPlaceId, player)
				end)
				if not success then
					warn("[Teleport Error]:", err)
					countdownLabel.Text = "⚠️ Retry..."
					task.wait(3)
					TeleportService:Teleport(targetPlaceId, player)
				end
				break
			end
		end
	end
end)

-- ==============================
-- 🔘 NÚT BẬT / TẮT
-- ==============================
toggleBtn.MouseButton1Click:Connect(function()
	active = not active
	if active then
		remaining = delayTime
		toggleBtn.Text = "❌"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		countdownLabel.Text = formatTime(remaining)
	else
		toggleBtn.Text = "🔁"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
		countdownLabel.Text = "00:00"
	end
end)

-- Nếu teleport lỗi → thử lại
TeleportService.TeleportInitFailed:Connect(function(_, result, message)
	warn("⚠️ Teleport failed:", result, message)
	task.wait(2)
	TeleportService:Teleport(targetPlaceId, player)
end)
