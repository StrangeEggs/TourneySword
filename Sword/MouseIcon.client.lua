local MOUSE_ICON = "rbxasset://textures/GunCursor.png"
local RELOADING_ICON = "rbxasset://textures/GunWaitCursor.png"

local tool = script.Parent
local mouse

local function UpdateIcon()
	if mouse then
		mouse.Icon = if tool.Enabled then MOUSE_ICON else RELOADING_ICON
	end
end

tool.Equipped:Connect(function(toolMouse)
	mouse = toolMouse
	UpdateIcon()
end)

tool.Changed:Connect(function(property)
	if property == "Enabled" then
		UpdateIcon()
	end
end)