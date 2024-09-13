function CLASS.CalcMainActivity(pl, velocity)
	if pl:OnGround() then
		if velocity:Length2D() > 1 then
			return ACT_RUN, -1
		end

		return 1, 1
	end

	if pl:WaterLevel() >= 3 then
		return 1, 6
	end

	return 1, 5
end

function CLASS.UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local seq = pl:GetSequence()
	if seq == 5 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		pl:SetPlaybackRate(1.5)

		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end

	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(len2d / 100)
	else
		pl:SetPlaybackRate(1)
	end

	return true
end
