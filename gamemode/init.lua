util.AddNetworkString("RcHCScale")
util.AddNetworkString("SetInf")
util.AddNetworkString("SetInfInit")
util.AddNetworkString("RcTopTimes")
util.AddNetworkString("RcTopZombies")
util.AddNetworkString("RcTopHumanDamages")
util.AddNetworkString("RcTopZombieDamages")
util.AddNetworkString("PlayerKilledSelf")
util.AddNetworkString("PlayerKilledByPlayer")
util.AddNetworkString("PlayerKilled")
util.AddNetworkString("PlayerRedeemed")
util.AddNetworkString("PlayerKilledNPC")
util.AddNetworkString("NPCKilledNPC")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_spawnmenu.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_spawnmenu.lua")
AddCSLuaFile("cl_hudpickup.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("cl_scoreboard.lua" )
AddCSLuaFile("cl_postprocess.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("gravitygun.lua")

AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_weapon_extend.lua")

do
	local files, directories = file.Find("gamemodes/nvts-gmod13-zombiesurvival_v1.05/gamemode/classiczombieanims/*.lua", "GAME")

	for k, _file in ipairs(files) do
		AddCSLuaFile("classiczombieanims/" .. _file)
	end
end
AddCSLuaFile("animations.lua")

AddCSLuaFile("zs_options.lua")

AddCSLuaFile("scoreboard/scoreboard.lua")

include("shared.lua")
include("powerups.lua")

function gmod.BroadcastLua(lua)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lua)
	end
end

GM.PlayerSpawnTime = {}

LASTHUMAN = false
CAPPED_INFLICTION = 0

function GM:Initialize()
	resource.AddFile("sound/ecky.wav")
	resource.AddFile("sound/beat9.wav")
	resource.AddFile("sound/beat8.wav")
	resource.AddFile("sound/beat7.wav")
	resource.AddFile("sound/beat6.wav")
	resource.AddFile("sound/beat5.wav")
	resource.AddFile("sound/beat4.wav")
	resource.AddFile("sound/beat3.wav")
	resource.AddFile("sound/beat2.wav")
	resource.AddFile("sound/beat1.wav")
	resource.AddFile("materials/zombohead.vmt")
	resource.AddFile("materials/zombohead.vtf")
	resource.AddFile("materials/humanhead.vmt")
	resource.AddFile("materials/humanhead.vtf")
	resource.AddFile("materials/killicon/zs_zombie.vtf")
	resource.AddFile("materials/killicon/zs_zombie.vmt")
	resource.AddFile("materials/killicon/redeem.vtf")
	resource.AddFile("materials/killicon/redeem.vmt")
	resource.AddFile("models/Weapons/v_zombiearms.mdl")
	resource.AddFile("models/Weapons/v_zombiearms.vvd")
	resource.AddFile("models/Weapons/v_zombiearms.sw.vtx")
	resource.AddFile("models/Weapons/v_zombiearms.dx90.vtx")
	resource.AddFile("models/Weapons/v_zombiearms.dx80.vtx")
	resource.AddFile("materials/Models/Weapons/v_zombiearms/Zombie_Classic_sheet.vmt")
	resource.AddFile("materials/Models/Weapons/v_zombiearms/Zombie_Classic_sheet.vtf")
	resource.AddFile("materials/Models/Weapons/v_zombiearms/Zombie_Classic_sheet_normal.vtf")
	resource.AddFile("models/Weapons/v_fza.mdl")
	resource.AddFile("models/Weapons/v_fza.vvd")
	resource.AddFile("models/Weapons/v_FZA.sw.vtx")
	resource.AddFile("models/Weapons/v_FZA.dx90.vtx")
	resource.AddFile("models/Weapons/v_FZA.dx80.vtx")
	resource.AddFile("materials/Models/Weapons/v_fza/fast_zombie_sheet.vmt")
	resource.AddFile("materials/Models/Weapons/v_fza/fast_zombie_sheet.vtf")
	resource.AddFile("materials/Models/Weapons/v_fza/fast_zombie_sheet_normal.vtf")
	resource.AddFile("sound/"..LASTHUMANSOUND)
	resource.AddFile("sound/"..ALLLOSESOUND)
	resource.AddFile("sound/"..HUMANWINSOUND)
	resource.AddFile("sound/"..DEATHSOUND)
end

/*
	Created by Heox (STEAM_0:1:8901195)
*/

--

local function CheckIfPlayerStuck()
		for k,v in pairs(player.GetAll()) do
			if IsValid(v) and v:IsPlayer() and v:Alive() then
				if !v:InVehicle() then
					local Offset = Vector(5, 5, 5)
					local Stuck = false
					
					if v.Stuck == nil then
						v.Stuck = false
					end
					
					if v.Stuck then
						Offset = Vector(2, 2, 2)
					end

					for _,ent in pairs(ents.FindInBox(v:GetPos() + v:OBBMins() + Offset, v:GetPos() + v:OBBMaxs() - Offset)) do
						if IsValid(ent) and ent ~= v and ent:IsPlayer() and ent:Alive() then
						
							v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
							v:SetVelocity(Vector(-10, -10, 0) * 20)
							
							ent:SetVelocity(Vector(10, 10, 0) * 20)
							
							Stuck = true
						end
					end
				   
					if !Stuck then
						v.Stuck = false
						v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
					end
				else
					v:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				end	
			end
		end
end
timer.Create("CheckIfPlayerStuck", 0.1, 0, CheckIfPlayerStuck)

function GM:ShowHelp(pl)
	pl:SendLua("GAMEMODE:ScoreboardShow() SCOREBOARD:SetMode(3)")
end

local function GlitchedShowHelpAlias(sender, command, arguments)
	GAMEMODE:ShowHelp(sender)
end
concommand.Add("gm_help", GlitchedShowHelpAlias)

function GM:ShowTeam(pl)
	if not REDEEM then return end
	if AUTOREDEEM then return end
	if pl:Team() ~= TEAM_UNDEAD then return end
	if pl:Frags() < REDEEM_KILLS then return end
	pl:Redeem()
end

function GM:ShowSpare1(pl)
	if pl:Team() == TEAM_HUMAN then return end
	pl:SendLua("GAMEMODE:ScoreboardShow() SCOREBOARD:SetMode(2)")
end

HEAD_NPC_SCALE = math.Clamp(3 - DIFFICULTY, 1.5, 4)
function GM:InitPostEntity()
	self.UndeadSpawnPoints = {}
	self.UndeadSpawnPoints = ents.FindByClass("info_player_undead")
	self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_zombie"))
	self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_rebel"))

	self.HumanSpawnPoints = {}
	self.HumanSpawnPoints = ents.FindByClass("info_player_human")
	self.HumanSpawnPoints = table.Add( self.HumanSpawnPoints, ents.FindByClass("info_player_combine"))

	local mapname = game.GetMap()
	-- Terrorist spawns are usually in some kind of house or a main base in CS_  in order to guard the hosties. Put the humans there.
	if string.find(mapname, "cs_") or string.find(mapname, "zs_") then
		self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_counterterrorist"))
		self.HumanSpawnPoints = table.Add( self.HumanSpawnPoints, ents.FindByClass("info_player_terrorist"))
	else -- Otherwise, this is probably a DE_, ZM_, or ZH_ map. In DE_ maps, the T's spawn away from the main part of the map and are zombies in zombie plugins so let's do the same.
		self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_terrorist"))
		self.HumanSpawnPoints = table.Add(self.HumanSpawnPoints, ents.FindByClass("info_player_counterterrorist"))
	end

	-- Add all the old ZS spawns.
	for _, oldspawn in pairs(ents.FindByClass("gmod_player_start")) do
		if oldspawn.BlueTeam then
			table.insert(self.HumanSpawnPoints, oldspawn)
		else
			table.insert(self.UndeadSpawnPoints, oldspawn)
		end
	end

	-- You shouldn't play a DM map since spawns are shared but whatever. Let's make sure that there aren't team spawns first.
	if #self.HumanSpawnPoints <= 0 then
		self.HumanSpawnPoints = ents.FindByClass("info_player_start")
	end
	if #self.UndeadSpawnPoints <= 0 then
		self.UndeadSpawnPoints = ents.FindByClass("info_player_start")
	end

	game.ConsoleCommand("sk_zombie_health "..math.ceil(50 + 50 * DIFFICULTY).."\n")
	game.ConsoleCommand("sk_zombie_dmg_one_slash "..math.ceil(20 + DIFFICULTY * 10).."\n")
	game.ConsoleCommand("sk_zombie_dmg_both_slash "..math.ceil(30 + DIFFICULTY * 12).."\n")

	local destroying = ents.FindByClass("prop_ragdoll") // These seem to cause server crashes if a zombie attacks them. They cause pointless lag, too.
	--[[if not USE_NPCS then
		destroying = table.Add(destroying, ents.FindByClass("npc_zombie"))
		destroying = table.Add(destroying, ents.FindByClass("npc_maker"))
		destroying = table.Add(destroying, ents.FindByClass("npc_template_maker"))
		destroying = table.Add(destroying, ents.FindByClass("npc_maker_template"))
	end]]--
	if DESTROY_DOORS then
		destroying = table.Add(destroying, ents.FindByClass("func_door_rotating"))
		destroying = table.Add(destroying, ents.FindByClass("func_door"))
	end
	if DESTROY_PROP_DOORS then
		destroying = table.Add(destroying, ents.FindByClass("prop_door_rotating"))
	end
	destroying = table.Add(destroying, ents.FindByClass("weapon_physicscannon"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_crowbar"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_stunstick"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_357"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_pistol"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_smg1"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_ar2"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_crossbow"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_shotgun"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_rpg"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_slam"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_pumpshotgun"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_ak47"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_deagle"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_fiveseven"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_glock"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_m4"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_mac10"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_mp5"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_para"))
	destroying = table.Add(destroying, ents.FindByClass("weapon_tmp"))

	destroying = table.Add(destroying, ents.FindByClass("weapon_frag"))

	for _, ent in pairs(destroying) do
		ent:Remove()
	end

	local ammoreplace = ents.FindByClass("item_ammo_smg1")
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_357"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_357_large"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_pistol"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_pistol_large"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_buckshot"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_ar2"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_ar2_large"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_ar2_altfire"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_crossbow"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_smg1"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_ammo_smg1_large"))
	ammoreplace = table.Add(ammoreplace, ents.FindByClass("item_box_buckshot"))
	for _, ent in pairs(ammoreplace) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("prop_door_rotating")) do
		ent.AntiDoorSpam = 0
	end
end

LastHumanSpawnPoint = Entity(1)
LastZombieSpawnPoint = Entity(1)
-- Returning nil on this fucking crashes the game.
function GM:PlayerSelectSpawn(pl)
	if pl:Team() == TEAM_UNDEAD then
		local Count = #self.UndeadSpawnPoints
		if Count == 0 then return pl end
		for i=0, 20 do
			local ChosenSpawnPoint = self.UndeadSpawnPoints[math.random(1, Count)]
			if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() and ChosenSpawnPoint ~= LastZombieSpawnPoint then
				local blocked = false
				for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, 0), ChosenSpawnPoint:GetPos() + Vector(48, 48, 60))) do
					if ent and ent:IsPlayer() then
						blocked = true
					end
				end
				if not blocked then
					LastZombieSpawnPoint = ChosenSpawnPoint
					return ChosenSpawnPoint
				end
			end
		end
		return LastZombieSpawnPoint
	else
		local Count = #self.HumanSpawnPoints
		if Count == 0 then return pl end
		for i=0, 20 do
			local ChosenSpawnPoint = self.HumanSpawnPoints[math.random(1, Count)]
			if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() and ChosenSpawnPoint ~= LastHumanSpawnPoint then
				local blocked = false
				for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, 0), ChosenSpawnPoint:GetPos() + Vector(48, 48, 60))) do
					if ent and ent:IsPlayer() then
						blocked = true
					end
				end
				if not blocked then
					LastHumanSpawnPoint = ChosenSpawnPoint
					return ChosenSpawnPoint
				end
			end
		end
		return LastHumanSpawnPoint
	end
	return pl
end

GM.AmmoTranslations = {}
GM.AmmoTranslations["weapon_physcannon"] = "pistol"
GM.AmmoTranslations["weapon_ar2"] = "ar2"
GM.AmmoTranslations["weapon_shotgun"] = "buckshot"
GM.AmmoTranslations["weapon_smg1"] = "smg1"
GM.AmmoTranslations["weapon_pistol"] = "pistol"
GM.AmmoTranslations["weapon_357"] = "357"
GM.AmmoTranslations["weapon_slam"] = "pistol"
GM.AmmoTranslations["weapon_crowbar"] = "pistol"
GM.AmmoTranslations["weapon_stunstick"] = "pistol"

function GM:SendInfliction(to)
	net.Start("SetInf")
		net.WriteFloat(INFLICTION)
	if IsValid(to) then
		net.Send(to)
	else
		net.Broadcast()
	end
end

function GM:SendInflictionInit(to)
	net.Start("SetInfInit")
		net.WriteFloat(INFLICTION)
	if IsValid(to) then
		net.Send(to)
	else
		net.Broadcast()
	end
end

NextAmmoDropOff = AMMO_REGENERATE_RATE
function GM:Think()
	if player.GetCount() >= 2 and team.NumPlayers(TEAM_HUMAN) <= 0 then
		self:EndRound(TEAM_UNDEAD)
	end
	if CurTime() >= ROUNDTIME then
	    self:EndRound(TEAM_HUMAN)
	elseif CurTime() >= NextAmmoDropOff then
	    NextAmmoDropOff = CurTime() + AMMO_REGENERATE_RATE
		INFLICTION = math.max(INFLICTION, CurTime() / ROUNDTIME)
		CAPPED_INFLICTION = INFLICTION
		self:SendInfliction()
	    local plays = player.GetAll()
	    if INFLICTION >= 0.75 then plays = table.Add(plays, player.GetAll()) end -- Double ammo on horde conditions
	    for _, pl in pairs(plays) do
	        if pl:Team() == TEAM_HUMAN then
	            local wep = pl:GetActiveWeapon()
	            if wep:IsValid() and wep:IsWeapon() then
					local typ = wep:GetPrimaryAmmoTypeString()
					if typ == "none" then
						if pl.HighestAmmoType == "none" then
							pl.HighestAmmoType = "pistol"
						end
						pl:GiveAmmo(AmmoRegeneration[pl.HighestAmmoType], pl.HighestAmmoType)
					else
						pl:GiveAmmo(AmmoRegeneration[typ], typ)
					end
	        	end
	        end
	    end
	end
end

function GM:EntityKeyValue(ent, key, value)
end

function GM:ShutDown()
end

DeadSteamIDs = {}
function GM:CalculateInfliction()
	if ENDROUND then return end
	local players = 0
	local zombies = 0
	for _, pl in pairs(player.GetAll()) do
		if pl:Team() == TEAM_UNDEAD then
			zombies = zombies + 1
		end
		players = players + 1
	end
	INFLICTION = math.max(math.Clamp(zombies / players, 0.01, 1), CAPPED_INFLICTION)
	CAPPED_INFLICTION = INFLICTION

	--self:SendInfliction()
	--wtf i am doing!!!!!!!!!!!!!
	if team.NumPlayers(TEAM_HUMAN) == 1 and team.NumPlayers(TEAM_UNDEAD) > 2 then
		self:LastHuman()
	end
end

function GM:OnNPCKilled(ent, attacker, inflictor)
	if NPCS_COUNT_AS_KILLS and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		attacker:AddFrags(1)
		self:CheckPlayerScore(attacker)
	end
end

function quicksort(q, cmp)
	if #q <= 1 then
		return q
	end
	if not cmp then
		cmp = function (a, b) return a < b end
	end
	local lower, higher, pivot = {}, {}, nil
	for i, v in ipairs(q) do
		if not pivot then
			pivot = v
		elseif cmp(v, pivot) then
			table.insert(lower, v)
		else
			table.insert(higher, v)
		end
	end
	local r = quicksort(lower, cmp)
	table.insert(r, pivot)
	table.Add(r, quicksort(higher, cmp))
	return r
end 

function GM:SendTopTimes(to)
	local PlayerSorted = {}

	for k, v in ipairs(player.GetAll()) do
		if v.SurvivalTime then
			table.insert(PlayerSorted, v)
		end
	end

	if #PlayerSorted <= 0 then return end -- Don't bother sending it, the cleint gamemode won't display anything.
	table.sort(PlayerSorted,
	function(a, b)
		return a.SurvivalTime > b.SurvivalTime
	end)

	local x = 0
	for _, pl in ipairs(PlayerSorted) do
		if x < 5 then
			x = x + 1
			net.Start("RcTopTimes")
				net.WriteInt(x, 16)
				net.WriteString(pl:Name()..": "..ToMinutesSeconds(pl.SurvivalTime))
			if IsValid(to) then
				net.Send(to)
			else
				net.Broadcast()
			end
		end
	end
end

function GM:SendTopZombies(to)
	local PlayerSorted = {}

	for k, v in ipairs(player.GetAll()) do
		if v.BrainsEaten and v.BrainsEaten > 0 then
			table.insert(PlayerSorted, v)
		end
	end

	if #PlayerSorted <= 0 then return end -- Don't bother sending it, the cleint gamemode won't display anything.
	table.sort(PlayerSorted,
	function(a, b)
		if a.BrainsEaten == b.BrainsEaten then
			return a:Deaths() < b:Deaths()
		end
		return a.BrainsEaten > b.BrainsEaten
	end)

	local x = 0
	for _, pl in ipairs(PlayerSorted) do
		if x < 5 then
			x = x + 1
			net.Start("RcTopZombies")
				net.WriteInt(x, 16)
				net.WriteString(pl:Name()..": "..pl.BrainsEaten)
			if IsValid(to) then
				net.Send(to)
			else
				net.Broadcast()
			end
		end
	end
end

function GM:SendTopHumanDamages(to)
	local PlayerSorted = {}

	for _, pl in ipairs(player.GetAll()) do
		if pl.DamageDealt and pl.DamageDealt[TEAM_HUMAN] and pl.DamageDealt[TEAM_HUMAN] > 0 then
			table.insert(PlayerSorted, pl)
		end
	end

	if #PlayerSorted <= 0 then return end
	table.sort(PlayerSorted,
	function(a, b)
		if a.DamageDealt[TEAM_HUMAN] == b.DamageDealt[TEAM_HUMAN] then
			return a:UserID() > b:UserID()
		end
		return a.DamageDealt[TEAM_HUMAN] > b.DamageDealt[TEAM_HUMAN]
	end
	)

	local x = 0
	for _, pl in ipairs(PlayerSorted) do
		if x < 5 then
			x = x + 1
			net.Start("RcTopHumanDamages")
				net.WriteInt(x, 16)
				net.WriteString(pl:Name()..": "..math.ceil(pl.DamageDealt[TEAM_HUMAN]))
			if IsValid(to) then
				net.Send(to)
			else
				net.Broadcast()
			end
		end
	end
end

function GM:SendTopZombieDamages(to)
	local PlayerSorted = {}

	for _, pl in ipairs(player.GetAll()) do
		if pl.DamageDealt and pl.DamageDealt[TEAM_UNDEAD] and pl.DamageDealt[TEAM_UNDEAD] > 0 then
			table.insert(PlayerSorted, pl)
		end
	end

	if #PlayerSorted <= 0 then return end
	table.sort(PlayerSorted,
	function(a, b)
		if a.DamageDealt[TEAM_UNDEAD] == b.DamageDealt[TEAM_UNDEAD] then
			return a:UserID() > b:UserID()
		end
		return a.DamageDealt[TEAM_UNDEAD] > b.DamageDealt[TEAM_UNDEAD]
	end)

	local x = 0
	for _, pl in ipairs(PlayerSorted) do
		if x < 5 then
			x = x + 1
			net.Start("RcTopZombieDamages")
				net.WriteInt(x, 16)
				net.WriteString(pl:Name()..": "..math.ceil(pl.DamageDealt[TEAM_UNDEAD]))
			if IsValid(to) then
				net.Send(to)
			else
				net.Broadcast()
			end
		end
	end
end

function GM:EndRound(winner)
	if ENDROUND then return end
	timer.Stop("Last Human Loop")
	RunConsoleCommand("stopsound")
	ROUNDWINNER = winner
	if winner == TEAM_HUMAN then
		for _, pl in pairs(player.GetAll()) do
			if pl.SpawnedTime and pl:Team() == TEAM_HUMAN then
				pl.SurvivalTime = CurTime() - pl.SpawnedTime
			end
		end
	end
	local nextmap = game.GetMapNext()
	timer.Simple(INTERMISSION_TIME*0.55, function() hook.Run("LoadNextMap") end)
	ENDROUND = true
	for _, pl in pairs(player.GetAll()) do
		pl:Lock()
		pl.NextSpawnTime = 99999
	end
	hook.Add("PlayerInitialSpawn", "LateJoin", function(pl)
		pl:SendLua("Intermission('"..game.GetMapNext().."', "..ROUNDWINNER..")")
		GAMEMODE:SendTopTimes(pl)
		GAMEMODE:SendTopZombies(pl)
		GAMEMODE:SendTopHumanDamages(pl)
		GAMEMODE:SendTopZombieDamages(pl)
	end)
	hook.Add("PlayerSpawn", "LateJoin2", function(pl)
		pl:Lock()
	end)
	gmod.BroadcastLua("Intermission('"..nextmap.."', "..winner..")")
	timer.Simple(1, function()
	GAMEMODE:SendTopTimes()
	GAMEMODE:SendTopZombies()
	GAMEMODE:SendTopHumanDamages()
	GAMEMODE:SendTopZombieDamages()
	end)
end

function GM:PlayerInitialSpawn(pl)
	pl:SetZombieClass(1)
	self:SendInflictionInit(pl)
	pl.Gibbed = false
	pl.BrainsEaten = 0
	pl.ZombiesKilled = 0
	pl.NextPainSound = 0
	pl.HighestAmmoType = "pistol"
	pl.DamageDealt = {}
	pl.DamageDealt[TEAM_UNDEAD] = 0
	pl.DamageDealt[TEAM_HUMAN] = 0

	if DeadSteamIDs[pl:SteamID64()] then
		pl:SetTeam(TEAM_UNDEAD)
	elseif team.NumPlayers(TEAM_UNDEAD) < 1 and team.NumPlayers(TEAM_HUMAN) > 2 then
		pl:SetTeam(TEAM_UNDEAD)
		DeadSteamIDs[pl:SteamID64()] = true
	elseif INFLICTION >= 0.5 or (CurTime() > ROUNDTIME*0.5 and HUMAN_DEADLINE) or LASTHUMAN then
		pl:SetTeam(TEAM_UNDEAD)
		DeadSteamIDs[pl:SteamID64()] = true
	else
		pl:SetTeam(TEAM_HUMAN)
		pl.SpawnedTime = CurTime()
	end
	self:CalculateInfliction()

	-- We're going to play a little trick on these dumbshits.
	-- OUTDATED BY SCRIPT ENFORCER
	/*
	pl:SendLua([[PLAYERmeta=FindMetaTable("Player")]])
	pl:SendLua([[ENTITYmeta=FindMetaTable("Entity")]])
	local timername = pl:UniqueID().."AntiHack"
	timer.Create(timername, math.random(14, 22), 3, AntiHack, pl, timername)
	*/
end

/*
function AntiHack(pl, timername)
	if pl:IsValid() and pl:IsPlayer() then
		pl:SendLua([[function ENTITYmeta:GetAttachment(i) LocalPlayer():ConCommand("~Z_~_ban_me\n") end]])
		pl:SendLua([[function PLAYERmeta:SetEyeAngles() LocalPlayer():ConCommand("~Z_~_ban_me\n") end]])
	else
		timer.Destroy(timername)
	end
end
*/

function GM:CheckPlayerScore(pl)
	local score = pl:Frags()
	if Rewards[score] then
		local reward = Rewards[score][math.random(1, #Rewards[score])]
		if string.sub(reward, 1, 1) == "_" then
			PowerupFunctions[reward](pl)
			pl:SendLua("rW()")
		else
			pl:Give(reward)
			local wep = pl:GetWeapon(reward)
			if wep:IsValid() then
				pl.HighestAmmoType = wep:GetPrimaryAmmoTypeString() or pl.HighestAmmoType
			end
		end
	end
end

function GM:PlayerNoClip(pl, on)
	return pl:IsAdmin() and ALLOW_ADMIN_NOCLIP
end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
end

function GM:OnPhysgunReload(weapon, pl)
end

function GM:PlayerDisconnected(pl)
	DeadSteamIDs[pl:SteamID64()] = true
	timer.Simple(2, function()
		if IsValid(self) then
			self:CalculateInfliction()
		end
	end)
end

function GM:PlayerSay(player, text, teamonly)
	return text
end

function GM:PlayerDeathThink(pl)
	if CurTime() > pl.NextSpawnTime then
		if pl:Team() == TEAM_UNDEAD then
			if pl:KeyDown(IN_ATTACK) then
				pl:Spawn()
			end
		else
			pl:Spawn()
		end
	end
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	if attacker.SendLua then
		if attacker:Team() == pl:Team() then
			return attacker == pl
		end
	end
	return true
end

function GM:EntityTakeDamage(ent, amount)
	local attacker = amount:GetAttacker()
	local damage = amount:GetDamage()
	if ent:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() and attacker:Team() ~= ent:Team() then
		ent:PlayPainSound()
		ent.LastAttacker = attacker
		attacker.DamageDealt[attacker:Team()] = attacker.DamageDealt[attacker:Team()] + damage
	end
end


function GM:PlayerUse(pl, entity)
	if not entity then return end
	if not entity:IsValid() then return end
	if pl:Team() == TEAM_UNDEAD then
		if entity:GetName() == "gib" then
			entity:Remove()
		end
	end
	if entity:GetClass() == "prop_door_rotating" then
		if CurTime() > entity.AntiDoorSpam then
			entity.AntiDoorSpam = CurTime() + 0.85
			return true
		else
			return false
		end
	end
	return true
end

function SecondWind(pl)
	if pl and pl:IsValid() and pl:IsPlayer() and not pl.DeathClass then
		if pl.Gibbed or pl:Alive() or pl:Team() ~= TEAM_UNDEAD then return end
		local pos = pl:GetPos()
		local eyeangles = pl:GetAngles()
		pl:Spawn()
		DeSpawnProtection(pl)
		pl:SetPos(pos)
		pl:SetEyeAngles(eyeangles)
		pl:SetHealth(pl:Health() * 0.2)
		pl:EmitSound("npc/zombie/zombie_voice_idle"..math.random( 1, 14 )..".wav", 100, 85)
	end
end

function GM:PlayerDeath(victim, inflictor, attacker)
end

function GM:PlayerDeathSound()
end

-- TODO: Make this code shorter.
function GM:DoPlayerDeath(pl, attacker, dmginfo)
	local headshot
	local attach = pl:GetAttachment(1)
	if attach then
		headshot = dmginfo:IsBulletDamage() and math.abs(dmginfo:GetDamagePosition().z - pl:GetAttachment(1).Pos.z) < 13
	end
	local revive = false
	local inflictor = NULL
	local suicide = false

	if attacker and attacker:IsValid() then
		if (attacker == pl or attacker:IsWorld()) and pl.LastAttacker and pl.LastAttacker:IsValid() and pl.LastAttacker:Team() ~= pl:Team() then
			attacker = pl.LastAttacker
			inflictor = attacker:GetActiveWeapon()
			suicide = true
			pl.LastAttacker = nil
		elseif attacker:IsPlayer() then
			inflictor = attacker:GetActiveWeapon()
		elseif attacker:GetOwner():IsValid() then -- For NPC's with owners
			local owner = attacker:GetOwner()
			inflictor = attacker
			attacker = owner
		end
	end
	if inflictor == NULL then inflictor = attacker end

	if pl.Headcrabz then
		for _, headcrab in pairs(pl.Headcrabz) do
			if headcrab:IsValid() and headcrab:IsNPC() then
				headcrab:Fire("sethealth", "0", 5)
			end
		end
	end

	pl.NextSpawnTime = CurTime() + 4
	pl:AddDeaths(1)
	if pl.Class == 4 and pl:Team() == TEAM_UNDEAD and attacker ~= pl and not suicide then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
		util.Effect("chemzombieexplode", effectdata)
		pl:Gib(dmginfo)
		pl.Gibbed = true
		timer.Simple(0.05, function() 
			util.BlastDamage(pl, pl, pl:GetPos() + Vector(0,0,16), 150, 40)
		end )
	elseif pl:Health() < -24 or dmginfo:IsExplosionDamage() or dmginfo:IsFallDamage() then
		pl:Gib(dmginfo)
		pl.Gibbed = true
	else
		pl:CreateRagdoll()
	end
	if pl:Team() == TEAM_UNDEAD then
		if attacker:IsValid() and attacker:IsPlayer() and attacker ~= pl then
			if ZombieClasses[pl.Class].Revives then
				if not pl.Gibbed and not headshot and math.random(1, 4) ~= 1 then
					if pl.Class == 1 then
						if math.random(1, 3) == 3 then
							timer.Simple(0, function()
								if IsValid(pl) then
									SecondWind(pl)
								end
							end)
							revive = true
							pl.Class = 6
							pl:LegsGib()
						else
							timer.Create(pl:UniqueID().."secondwind", 2, 1, function()
								if IsValid(pl) then
									SecondWind(pl)
								end
							end)
							revive = true
						end
					else
						timer.Create(pl:UniqueID().."secondwind", 2, 1, function()
							if IsValid(pl) then
								SecondWind(pl)
							end
						end)
						revive = true
					end
				else
					attacker:AddFrags(1)
					attacker.ZombiesKilled = attacker.ZombiesKilled + 1
					pl:PlayZombieDeathSound()
					self:CheckPlayerScore(attacker)
				end
			else
				attacker:AddFrags(1)
				attacker.ZombiesKilled = attacker.ZombiesKilled + 1
				pl:PlayZombieDeathSound()
				self:CheckPlayerScore(attacker)
			end
		else
			pl:PlayZombieDeathSound()
		end
	else
		pl:PlayDeathSound()
		if attacker:IsPlayer() and attacker ~= pl then
			attacker:AddFrags(1)
			attacker.BrainsEaten = attacker.BrainsEaten + 1
			if REDEEM and AUTOREDEEM then
				if attacker:Frags() >= REDEEM_KILLS then
					attacker:Redeem()
				end
			end
			if not pl.Gibbed then
				timer.Simple(2.5, function() 
					SecondWind(pl)
				end )
			end
		end
		if #player.GetAll() > 1 then
			pl:SetTeam(TEAM_UNDEAD)
			DeadSteamIDs[pl:SteamID64()] = true
		end
		pl:SendLua("Died()")
		pl:SetFrags(0)
		if pl.SpawnedTime then
			local survtime = CurTime() - pl.SpawnedTime
			if pl.SurvivalTime then
				if survtime > pl.SurvivalTime then
					pl.SurvivalTime = survtime
				end
			else
				pl.SurvivalTime = CurTime() - pl.SpawnedTime
			end
		end
		pl.SpawnedTime = nil
		self:CalculateInfliction()
	end

	if revive then return end
	if attacker == pl then
		net.Start("PlayerKilledSelf")
			net.WriteEntity(pl)
		net.Broadcast()
	end

	if attacker:IsPlayer() then
		local getclass = inflictor:GetClass()
		if headshot then
			pl:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
			local effectdata = EffectData()
				effectdata:SetOrigin(pl:GetAttachment(1).Pos)
				effectdata:SetNormal(dmginfo:GetDamageForce())
				effectdata:SetMagnitude(dmginfo:GetDamageForce():Length() * 3)
			util.Effect("headshot", effectdata)
		end
		net.Start("PlayerKilledByPlayer")
			net.WriteEntity(pl)
			net.WriteString(inflictor:GetClass())
			net.WriteEntity(attacker)
			net.WriteInt(pl:Team(), 16)
			net.WriteInt(attacker:Team(), 16)
			net.WriteBool(headshot)
		net.Broadcast()
	else

		net.Start("PlayerKilled")
			net.WriteEntity(pl)
			net.WriteString(inflictor:GetClass())
			net.WriteString(attacker:GetClass())
		net.Broadcast()
	end
end

function GM:PlayerCanPickupWeapon(pl, entity)
	if pl:Team() == TEAM_UNDEAD then return entity:GetClass() == ZombieClasses[pl.Class].SWEP end
	return true
end

hook.Add( "AllowPlayerPickup", "AllowSurvivorsPickUp", function( pl, ent )
    return pl:Team() == TEAM_HUMAN
end )

function SpawnProtection(pl, tim)
	GAMEMODE:SetPlayerSpeed(pl, ZombieClasses[pl:GetZombieClass()].Speed * 1.5)
	timer.Create(pl:UserID().."SpawnProtection", tim, 1, function()
		if IsValid(pl) then
			DeSpawnProtection(pl)
		end
	end)
end

function DeSpawnProtection(pl)
	GAMEMODE:SetPlayerSpeed(pl, ZombieClasses[pl.Class].Speed)
end

function GM:PlayerSpawn(pl)
	pl:UnSpectate()
	pl.Gibbed = false
	timer.Remove(pl:UserID().."SpawnProtection")
	if pl:Team() == TEAM_UNDEAD then
		if pl.DeathClass then
			pl:SetZombieClass(pl.DeathClass)
			pl.DeathClass = nil
		end
		local class = pl:GetZombieClass()
		pl:SetModel(ZombieClasses[class].Model)
		if team.NumPlayers(TEAM_UNDEAD) <= 1 then
			pl:SetHealth(ZombieClasses[class].Health * 2)
		else
			pl:SetHealth(ZombieClasses[class].Health)
		end
		local swep = ZombieClasses[class].SWEP
		pl:Give(swep)
		self:SetPlayerSpeed(pl, ZombieClasses[class].Speed)
		pl:SetNoTarget(true)
		pl:SendLua("ZomC()")
		pl:SetMaxHealth(1) -- To prevent picking up health packs
		SpawnProtection(pl, 5 - INFLICTION*5) -- Less infliction, more spawn protection.
		pl.Female = false
	else
		local modelname = player_manager.TranslatePlayerModel(pl:GetInfo("cl_playermodel"))
		if RestrictedModels[modelname] then
			pl:SetModel(Model("models/player/alyx.mdl"))
		else
			pl:SetModel(Model(modelname))
		end
		pl:SetFemale()
		pl:Give("weapon_zs_battleaxe")
		pl:Give("weapon_zs_swissarmyknife")
		self:SetPlayerSpeed(pl, 170)
		pl:SetNoTarget(false)
		pl:SendLua("HumC()")
		pl:SetMaxHealth(100)
		local hands = ents.Create("zs_hands")
		if hands:IsValid() then
			hands:DoSetup(pl)
			hands:Spawn()
		end
	end
	pl.LastHealth = pl:Health()
end

function GM:WeaponEquip(weapon)
end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(HEAD_NPC_SCALE)
	end
	return dmginfo
end

function GM:ScalePlayerDamage(npc, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(2.5)
	end
	return dmginfo
end

function ThrowHeadcrab(owner, wep)
	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	if not wep.Weapon then return end
	if owner:Alive() and owner:Team() == TEAM_UNDEAD and owner.Class == 3 then
		GAMEMODE:SetPlayerSpeed(owner, ZombieClasses[3].Speed)
		wep.Headcrabs = wep.Headcrabs - 1
		local eyeangles = owner:EyeAngles()
		local vel = eyeangles:Forward():GetNormalized()
		eyeangles.pitch = 0
		local ent = ents.Create("npc_headcrab_black")
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(eyeangles)
			ent:SetOwner(owner)
			ent:SetKeyValue("spawnflags", "4")
			ent:Spawn()
			if not ent:IsInWorld() then
				wep.Headcrabs = wep.Headcrabs + 1
				ent:Remove()
				return
			end
			for _, pl in pairs(player.GetAll()) do
				if pl:Team() == TEAM_UNDEAD then
					ent:AddEntityRelationship(pl, D_LI, 99)
				else
					ent:AddEntityRelationship(pl, D_HT, 99)
				end
			end
			vel = vel * 450
			vel.z = math.max(100, vel.z)
			ent:SetVelocity(vel)
			ent:EmitSound("npc/headcrab_poison/ph_jump"..math.random(1,3)..".wav")
			owner.Headcrabz = owner.Headcrabz or {}
			table.insert(owner.Headcrabz, ent)
		end
	end
end

local function SelectZombieClass(sender, command, arguments)
	if arguments[1] == nil then return end
	if sender:Team() ~= TEAM_UNDEAD or not sender:Alive() then return end
	arguments = table.concat(arguments, " ")
	for i=1, #ZombieClasses do
		if string.lower(ZombieClasses[i].Name) == string.lower(arguments) then
			if ZombieClasses[i].Hidden then
				sender:PrintMessage(3, "STOP SHOUTING!")
			elseif ZombieClasses[i].Threshold > INFLICTION then
				sender:PrintMessage(3, "There are too many living to use that class.")
			elseif sender.Class == i then
				sender:PrintMessage(3, "You are already a "..ZombieClasses[i].Name.."!")
			else
				sender:PrintMessage(3, "You will respawn as a "..ZombieClasses[i].Name..".")
				sender.DeathClass = i
			end
		    return
		end
	end
end
concommand.Add("zs_class", SelectZombieClass)

local function KickMe(sender, command, arguments)
	game.ConsoleCommand("kickid "..sender:SteamID64().." Aimbot / using walk.\n")
end
concommand.Add("kick_me", KickMe)

local function BanMe(sender, command, arguments)
	timer.Remove(sender:UniqueID().."AntiHack")
	game.ConsoleCommand("banid 2880 "..sender:SteamID64().."\n")
	game.ConsoleCommand("kickid "..sender:SteamID64().." 48 hour ban for client hacks.\n")
	game.ConsoleCommand("writeid\n")
end
concommand.Add("~Z_~_ban_me", BanMe)

local function WateryDeath(sender, command, arguments)
	sender:Kill()
	sender:EmitSound("player/pl_drown"..math.random(1, 3)..".wav")
end
concommand.Add("~Z_~_water_death", WateryDeath)

local function WateryDeath(sender, command, arguments)
	sender:TakeDamage(200, NULL)
	for _, pl in pairs(player.GetAll()) do
		pl:PrintMessage(3, sender:Name().."'s spine crumbled in to dust.")
	end
end
concommand.Add("~Z_~_cramped_death", WateryDeath)
