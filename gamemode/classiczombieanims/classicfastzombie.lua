function CLASS.CalcMainActivity(ply, velocity)
	local wep = ply:GetActiveWeapon()

	if not wep:IsValid() or not wep.GetClimbing then return end

	if wep:GetClimbing() then
		return ACT_CLIMB_UP, -1
	end

	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return ACT_RUN, -1
end

function CLASS.UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()

	local wep = ply:GetActiveWeapon()

	if not wep:IsValid() or not wep.GetClimbing then return end

	if wep:GetClimbing() then
		ply:SetPlaybackRate(2)
		return
	end

	if len2d > 1 then
		ply:SetPlaybackRate( math.min(len2d / 250, 1.5) )
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
