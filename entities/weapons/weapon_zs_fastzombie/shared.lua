SWEP.Author = "JetBoom"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.ViewModel = "models/weapons/v_fza.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Spawnable = true
SWEP.AdminSpawnable	= true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.4

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0.22
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

function SWEP:GetClimbing()
	return self:GetDTBool(0)
end

function SWEP:Reload()
	return false
end

-- Shutup.
function SWEP:Precache()
	util.PrecacheSound("npc/fast_zombie/fz_scream1.wav")
	util.PrecacheSound("npc/zombie/claw_strike1.wav")
	util.PrecacheSound("npc/zombie/claw_strike2.wav")
	util.PrecacheSound("npc/zombie/claw_strike3.wav")
	util.PrecacheSound("npc/zombie/claw_miss1.wav")
	util.PrecacheSound("npc/zombie/claw_miss2.wav")
	util.PrecacheSound("npc/zombie/zo_attack1.wav")
	util.PrecacheSound("npc/fast_zombie/fz_alert_close1.wav")
	util.PrecacheSound("npc/zombie/zombie_die1.wav")
	util.PrecacheSound("npc/fast_zombie/fz_frenzy1.wav")
	util.PrecacheSound("physics/flesh/flesh_strider_impact_bullet1.wav")
	util.PrecacheSound("player/footsteps/metalgrate1.wav")
	util.PrecacheSound("player/footsteps/metalgrate2.wav")
	util.PrecacheSound("player/footsteps/metalgrate3.wav")
	util.PrecacheSound("player/footsteps/metalgrate4.wav")
end
