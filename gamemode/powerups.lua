PowerupFunctions = {}

PowerupFunctions["_Heal"] = function(pl)
	pl:SetHealth(math.min(pl:Health() + 30, 100))
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_heal", effectdata)
end

PowerupFunctions["_Shell"] = function(pl)
	pl:SetArmor(pl:Armor() + 25)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_shell", effectdata)
end

PowerupFunctions["_Regeneration"] = function(pl)
	timer.Create("regeneration"..pl:UniqueID(), 3, 0, function()
		if IsValid(pl) then
			RegenerationTimer(pl, pl:UniqueID())
		end
	end)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,48))
	util.Effect("powerup_regeneration", effectdata)
end

function RegenerationTimer(pl, uid)
	if IsValid(pl) and pl:Team() == TEAM_HUMAN then
		pl:SetHealth(math.min(pl:Health() + 1, 100))
	else
		timer.Remove("regeneration"..uid)
	end
end
