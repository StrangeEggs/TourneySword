--[[
	stfo tourney swords
	written by StrangeEggs
	2023-11-20
--]]

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local wielder: Player?;
local tool = script.Parent
local handle = tool.Handle
local config = require(tool.Config)
local damage = config.Damage.Idle
local character

local function slash()
	damage = config.Damage.Slash
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
	Debris:AddItem(anim, 1)
end

local function lunge()
	damage = config.Damage.Lunge
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = tool
	Debris:AddItem(anim, 1)
	task.wait(0.25)
	tool.GripUp = Vector3.new(1, 0, 0)
	task.wait(0.75)
	tool.GripUp = Vector3.new(0, 0, 1)
end

local lastAttack = 0
local function onActivate()
	if not tool.Enabled then
		return
	end
	tool.Enabled = false

	local cooldown = RunService.Stepped:Wait()
	if (cooldown - lastAttack) < 0.2 then
		lunge()
	else
		slash()
	end
	lastAttack = cooldown
	damage = config.Damage.Idle
	tool.Enabled = true
end

-- Events

tool.Equipped:Connect(function()
	character = tool.Parent
	wielder = Players:GetPlayerFromCharacter(tool.Parent)
end)

tool.Activated:Connect(onActivate)

local function isTeammate(player1: Player, player2: Player): boolean
	return player1 and player2 and not player1.Neutral and not player2.Neutral and player1.TeamColor == player2.TeamColor
end

if config.TourneyMode and shared.TeammateCheck then
	isTeammate = shared.TeammateCheck
end

-- Damage validation
local function canDamage(hit: BasePart)
	local character = hit.Parent

	-- Check if player is a teammate
	local hitPlayer = Players:GetPlayerFromCharacter(character)
	if hitPlayer and isTeammate(wielder, hitPlayer) then
		return false
	end

	if hitPlayer and wielder:DistanceFromCharacter(hit.Position) > config.MaxDistance then
		return false
	end

	return true
end

handle.Touched:Connect(function(hit)
	if hit.Parent == nil then return end
	local humanoid = hit.Parent:FindFirstChild("Humanoid")

	-- Check if RightGrip still exists
	if character == nil or character:FindFirstChild("Right Arm") == nil or character["Right Arm"]:FindFirstChild("RightGrip") == nil then
		return false
	end

	if not wielder or not humanoid or (character.Humanoid.Health <= 0 and not config.ForceTie) then
		return
	end

	if not config.ForceFieldDamage and character:FindFirstChildOfClass("ForceField") then
		return
	end

	if humanoid ~= character.Humanoid and humanoid.Health > 0 and canDamage(hit) then
		humanoid:TakeDamage(damage)
		if humanoid.Health <= 0 and not hit.Parent:GetAttribute("Dead") then
			hit.Parent:SetAttribute("Dead", true)
			local hitPlayer = Players:GetPlayerFromCharacter(humanoid.Parent)
			if hitPlayer then
				local distance = wielder:DistanceFromCharacter(hit.Position)
				local creatorTag = Instance.new("ObjectValue")
				creatorTag.Name = "creator"
				creatorTag.Value = wielder
				creatorTag:SetAttribute("Distance", distance)
				creatorTag.Parent = humanoid
				Debris:AddItem(creatorTag, 1)
			end
		end
	end
end)
