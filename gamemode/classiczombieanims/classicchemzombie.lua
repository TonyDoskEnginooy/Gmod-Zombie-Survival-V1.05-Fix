function CLASS.CalcMainActivity(ply, velocity)
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
