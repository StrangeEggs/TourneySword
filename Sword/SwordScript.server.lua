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
local healAmount = config.HealAmount

local sounds = {
	Slash = handle.Slash;
	Lunge = handle.Lunge;
	Unsheath = handle.Unsheath;
}

-- Checks if two players are teammates
local function isTeammate(player1: Player, player2: Player): boolean
	return player1 and player2 and not player1.Neutral and not player2.Neutral and player1.TeamColor == player2.TeamColor
end

-- Use tourney teammate function if TourneyMode is enabled
if config.TourneyMode and shared.IsTeammateFunction then
	isTeammate = shared.IsTeammateFunction
end

-- Damage validation
local function canDamage(hit: BasePart)
	local character = hit.Parent

	-- Make sure the character still has a Humanoid and HumanoidRootPart
	if character:FindFirstChild("Humanoid") == nil or character:FindFirstChild("HumanoidRootPart") == nil then
		return false
	end

	-- Check if it's a player or an NPC
	local hitPlayer = Players:GetPlayerFromCharacter(character)
	if hitPlayer == nil and not config.DamageNPCs then
		return false
	end

	-- Check if they are already dead
	if character:FindFirstChildWhichIsA("Humanoid").Health <= 0 then
		return false
	end

	-- Check sword distance
	local distance = (handle.Position - hit.Position).Magnitude
	if config.MaxDistance > 0 and distance > config.MaxDistance then
		return false
	end

	-- Check if player is a teammate
	if hitPlayer and isTeammate(wielder, hitPlayer) then
		return false
	end

	return true
end

local function tagHumanoid(humanoid: Humanoid, player: Player, hit: BasePart?)
	local tag = Instance.new("ObjectValue")
	tag.Name = config.TourneyMode and "SwordDmgTag" or "creator"
	tag.Value = player
	tag.Parent = humanoid
	Debris:AddItem(tag, 2)
	if handle and hit then
		tag:SetAttribute("Distance", (handle.Position - hit.Position).Magnitude)
	end
end

local function untagHumanoid(humanoid: Humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and (v.Name == "SwordDmgTag" or v.Name == "creator") then
			v:Destroy()
		end
	end
end

local function slash()
	damage = config.Damage.Slash
	sounds.Slash:Play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool
end

local function lunge()
	damage = config.Damage.Lunge
	sounds.Lunge:Play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = tool
	if config.Float and wielder then
		local force = Instance.new("BodyVelocity")
		force.Velocity = Vector3.new(0, 10, 0)
		force.MaxForce = Vector3.new(0, 2900, 0)
		force.Parent = wielder.Character.HumanoidRootPart
		Debris:AddItem(force, 0.5)
	end
	task.wait(0.25)
	tool.Grip = config.Grips.Out
	task.wait(0.75)
	tool.Grip = config.Grips.Up
end

local function takeDamage(wielder: Player, humanoid: Humanoid, damage: IntValue)
	humanoid:TakeDamage(damage)

	-- Heal the player
	if humanoid.Health <= 0 and wielder and healAmount > 0 then
		local currentHealth = wielder.Character.Humanoid.Health
		wielder.Character.Humanoid.Health = math.min(currentHealth + healAmount, 100)
	end
end

local function blow(hit)
	local character = tool.Parent
	local humanoid = hit.Parent:FindFirstChild("Humanoid")

	if not wielder or not humanoid or (character.Humanoid.Health <= 0 and not config.ForceTie) or not character:FindFirstChild("Right Arm") then
		return
	end

	if not config.ForceFieldDamage and character:FindFirstChildOfClass("ForceField") then
		return
	end
	if humanoid and humanoid ~= character.Humanoid and canDamage(hit) then
		untagHumanoid(humanoid)
		tagHumanoid(humanoid, wielder, hit)
		takeDamage(wielder, humanoid, damage)
	end
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

local diedConnection: RBXScriptConnection?;
tool.Equipped:Connect(function()
	wielder = Players:GetPlayerFromCharacter(tool.Parent)
	local humanoid = tool.Parent.Humanoid

	sounds.Unsheath:Play()
	diedConnection = humanoid.Died:Connect(function()
		Debris:AddItem(tool, 0.75)
	end)
end)

tool.Unequipped:Connect(function()
	diedConnection:Disconnect()
end)

tool.Activated:Connect(onActivate)
handle.Touched:Connect(blow)