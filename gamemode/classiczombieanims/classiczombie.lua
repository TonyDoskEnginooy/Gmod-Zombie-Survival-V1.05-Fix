function CLASS.CalcMainActivity(ply, velocity)
	local wep = ply:GetActiveWeapon()
	if wep.GetNextYell and CurTime() < wep:GetNextYell() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_IDLE_ON_FIRE, -1
		end
		
		return ACT_WALK_ON_FIRE, -1
	end

	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return ACT_WALK, -1
end

function CLASS.UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		ply:SetPlaybackRate(len2d / 100)
	else
		ply:SetPlaybackRate(1)
	end

	return true
end

function CLASS.DoAnimationEvent(ply, event, data)
    if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end