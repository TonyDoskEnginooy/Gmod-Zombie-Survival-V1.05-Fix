AddCSLuaFile("zs_options.lua")
AddCSLuaFile("init.lua")
include("zs_options.lua")

local ActCalcs = {}
local UpdateAnims = {}
local AnimEvents = {}

for classnum, ZombieClass in ipairs(ZombieClasses) do
	CLASS = {}
	include("classiczombieanims/" .. ZombieClass["ANIMATE"] .. ".lua")
	ActCalcs[classnum] = CLASS.CalcMainActivity
	UpdateAnims[classnum] = CLASS.UpdateAnimation
	AnimEvents[classnum] = CLASS.DoAnimationEvent
	CLASS = nil
end

function GM:CalcMainActivity(pl, velocity)
	local plTab = pl:GetTable()

	if pl:Team() == TEAM_UNDEAD and pl.Class and ActCalcs[pl.Class] then
		local ideal, override = ActCalcs[pl.Class](pl, velocity)
		if ideal then
			return ideal, override
		end
	end

	-- Handle landing
	local onground = pl:OnGround()
	if onground and not plTab.m_bWasOnGround then
		pl:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
		plTab.m_bWasOnGround = true
	end
	--

	-- Handle jumping
	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	local waterlevel = pl:WaterLevel()
	if plTab.m_bJumping then
		if plTab.m_bFirstJumpFrame then
			plTab.m_bFirstJumpFrame = false
			pl:AnimRestartMainSequence()
		end

		if waterlevel >= 2 or CurTime() - plTab.m_flJumpStartTime > 0.2 and onground then
			plTab.m_bJumping = false
			plTab.m_fGroundTime = nil
			pl:AnimRestartMainSequence()
		else
			return ACT_MP_JUMP, -1
		end
	elseif not onground and waterlevel <= 0 then
		if not plTab.m_fGroundTime then
			plTab.m_fGroundTime = CurTime()
		elseif CurTime() > plTab.m_fGroundTime and velocity:Length2D() < 0.5 then
			plTab.m_bJumping = true
			plTab.m_bFirstJumpFrame = false
			plTab.m_flJumpStartTime = 0
		end
	end
	--

	-- Handle ducking
	if pl:Crouching() then
		if velocity:Length2DSqr() >= 1 then
			return ACT_MP_CROUCHWALK, -1
		end

		return ACT_MP_CROUCH_IDLE, -1
	end
	--

	-- Handle swimming
	if not onground and waterlevel >= 2 then
		return ACT_MP_SWIM, -1
	end
	--

	local len2d = velocity:Length2DSqr()
	if len2d >= 22500 then -- 150^2
		return ACT_MP_RUN, -1
	end

	if len2d >= 1 then
		return ACT_MP_WALK, -1
	end

	return ACT_MP_STAND_IDLE, -1
end

function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:Team() == TEAM_UNDEAD and pl.Class and UpdateAnims[pl.Class] then
		if UpdateAnims[pl.Class](pl, velocity, maxseqgroundspeed) then
			return
		end
	end

	local len = velocity:LengthSqr()
	local rate

	if len > 1 then
		rate = math.min(len / maxseqgroundspeed ^ 2, 2)
	else
		rate = 1
	end

	-- if we're under water we want to constantly be swimming..
	if pl:WaterLevel() >= 2 then
		rate = math.max(rate, 0.5)
	end

	pl:SetPlaybackRate(rate)

	if CLIENT then
		GAMEMODE:GrabEarAnimation(pl)
		--GAMEMODE:MouthMoveAnimation(pl) -- Broken?
	end
end

function GM:DoAnimationEvent(pl, event, data)
	if pl:Team() == TEAM_UNDEAD and pl.Class and AnimEvents[pl.Class] then
		local eact = AnimEvents[pl.Class](pl, event, data)
		if eact then
			return eact
		end
	end

	if event == PLAYERANIMEVENT_FLINCH_HEAD then
		return pl:DoFlinchAnim(data)
	end

	return self.BaseClass:DoAnimationEvent(pl, event, data)
end