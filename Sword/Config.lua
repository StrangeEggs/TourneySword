return {
	Damage = {
		Idle = 5; -- Idle damage
		Slash = 10; -- Slash damage
		Lunge = 30; -- Lunge damage
	};
	MaxDistance = 10; -- Max distance for damage, set to 0 to disable
	ForceTie = false; -- Force tie (allows sword to still do damage after a player dies)
	DamageNPCs = true; -- Allows the sword to damage non-players
	ForceFieldDamage = false; -- Ability to damage while having a forcefield
	HealAmount = 25; -- Amount of HP given after a kill (0 If you want heals off)
	Float = false; -- Sword lunge float
	TourneyMode = false; -- Tourney only functionality, this will break the sword outside of the tourney place!
	Grips = {
		Up = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0),
		Out = CFrame.new(0, 0, -1.5, 0, -1, -0, -1, 0, -0, 0, 0, -1),
	};
}