AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/starwars/atat.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 10000
ENT.HullType = HULL_LARGE
ENT.TurningSpeed = 2
local STOPDIST = 6000
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_SW_GALACTICEMPIRE","CLASS_STORMTROOPER"}
ENT.Bleeds = false -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.HasRangeAttack = false -- Should the SNPC have a range attack?
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Bullet = true -- Immune to bullet type damages
ENT.Immune_Fire = true -- Immune to fire-type damages
ENT.Immune_Melee = true -- Immune to melee-type damage | Example: Crowbar, slash damages
ENT.Immune_Physics = true -- Immune to physics impacts, won't take damage from props
ENT.PoseParameterLooking_TurningSpeed = 18 -- How fast does the parameter turn?
ENT.PoseParameterLooking_Names = {pitch={"lgun_aim_pitch","rgun_aim_pitch"},yaw={},roll={}}
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = STOPDIST -- How close does it have to be until it starts to face the enemy?
ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = STOPDIST -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = 0 -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "Regular" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack
ENT.WaitBeforeDeathTime = 2
ENT.HasDeathRagdoll = false
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"cpthazama/atat_walk.mp3"}
ENT.SoundTbl_Move = {"cpthazama/atat_move.mp3"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit step" then
		VJ_EmitSound(self,self.SoundTbl_FootStep,105,self:VJ_DecideSoundPitch(self.FootStepPitch1,self.FootStepPitch2))
		util.ScreenShake(self:GetPos(), 100, 200, 2, 3000)
	end
	if key == "event_emit move" then
		VJ_EmitSound(self,self.SoundTbl_Move,95,self:VJ_DecideSoundPitch(self.FootStepPitch1,self.FootStepPitch2))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPosTwin(TheProjectile,att)
	return (self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() -(self:GetAttachment(self:LookupAttachment(att)).Pos)):GetNormal() *150000
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(390,390,1070), Vector(-390,-390,0))
	self.NextGunAttackT = CurTime()
	self.NextTwinGunAttackT = CurTime() +2
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Veh_CanFire(ent)
	local pospara = self:GetPoseParameter("aim_yaw")
	local viewcode = ((ent:GetPos() +ent:OBBCenter()) - (self:GetPos() +self:OBBCenter())):Angle()
	local viewcheck = math.abs(viewcode.y -(self:GetAngles().y +pospara))
	if viewcheck >= 330 then
		viewcheck = viewcheck -360
	end
	if math.abs(viewcheck) <= 10 then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LeftCannon(enemy)
	if CurTime() > self.NextGunAttackT then
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self:GetAttachment(self:LookupAttachment("left_cannon")).Pos
		bullet.Dir = (enemy:GetPos() +enemy:OBBCenter()) -self:GetAttachment(self:LookupAttachment("left_cannon")).Pos
		bullet.Spread = 0.001
		bullet.Tracer = 1
		bullet.TracerName = "VJ_Laserrod_Red"
		bullet.Force = 5
		bullet.Damage = 8
		bullet.AmmoType = "AR2"
		self:FireBullets(bullet)
		VJ_EmitSound(self,{"vj_weapons/blaster/starwars_fire.wav"},90,self:VJ_DecideSoundPitch(100,110))
		self.NextGunAttackT = CurTime() +0.2
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TwinCannon(enemy,ovtime)
	if ovtime == nil then
		ovtime = math.Rand(4,6)
	end
	if CurTime() > self.NextTwinGunAttackT then
		local proj = ents.Create("obj_vj_sw_twinblast")
		proj:SetPos(self:GetAttachment(self:LookupAttachment("cannonA")).Pos)
		proj:SetAngles((enemy:GetPos() -proj:GetPos()):Angle())
		proj:Spawn()
		proj:Activate()
		proj:SetOwner(self)
		proj:SetPhysicsAttacker(self)
		local phys = proj:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetVelocity(self:RangeAttackCode_GetShootPosTwin(proj,"cannonA"))
		end
		VJ_EmitSound(self,{"cpthazama/atst_shoot.wav"},100,self:VJ_DecideSoundPitch(100,110))
		local proj = ents.Create("obj_vj_sw_twinblast")
		proj:SetPos(self:GetAttachment(self:LookupAttachment("cannonB")).Pos)
		proj:SetAngles((self:GetEnemy():GetPos() -proj:GetPos()):Angle())
		proj:Spawn()
		proj:Activate()
		proj:SetOwner(self)
		proj:SetPhysicsAttacker(self)
		local phys = proj:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetVelocity(self:RangeAttackCode_GetShootPosTwin(proj,"cannonB"))
		end
		VJ_EmitSound(self,{"cpthazama/atst_shoot.wav"},100,self:VJ_DecideSoundPitch(100,110))
		self.NextTwinGunAttackT = CurTime() +ovtime
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	local enemy
	local dist
	local vis
	local canfire
	local cont
	local pKey
	local twinKey
	local grenKey
	local gunDist = 3000
	local twinGunDist = 15000
	local grenGunDist = 2000
	local grenGunMinDist = 1200
	if IsValid(self:GetEnemy()) then
		enemy = self:GetEnemy()
		dist = self:VJ_GetNearestPointToEntityDistance(enemy)
		vis = self:Visible(enemy)
		canfire = self:Veh_CanFire(enemy)
		if self.VJ_IsBeingControlled then
			cont = self.VJ_TheController
			enemy = self.VJ_TheControllerBullseye
			pKey = cont:KeyDown(IN_ATTACK)
			twinKey = cont:KeyDown(IN_ATTACK2)
			grenKey = cont:KeyDown(IN_JUMP)
			-- if pKey then
				-- self:LeftCannon(enemy)
			-- end
			if pKey then
				self:TwinCannon(enemy,4)
			end
			-- if grenKey then
				-- self:GrenadeCannon(enemy,5)
			-- end
			return
		end
		-- self.ConstantlyFaceEnemy = canfire
		-- if vis && canfire && dist <= gunDist then
			-- self:LeftCannon(enemy)
		-- end
		if vis && canfire && dist <= twinGunDist then
			self:TwinCannon(enemy)
		end
		-- if vis && canfire && dist <= grenGunDist && dist >= grenGunMinDist then
			-- self:GrenadeCannon(enemy)
		-- end
	end
	-- self.ConstantlyFaceEnemy = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
	timer.Simple(0,function()
		if self:IsValid() then
			VJ_EmitSound(self,"vj_mili_tank/tank_death2.wav",100,100)
			util.BlastDamage(self,self,self:GetPos() +self:OBBCenter() +self:GetUp() *50,200,40)
			util.ScreenShake(self:GetPos(), 100, 200, 1, 2500)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil) end
		end
	end)

	timer.Simple(0.5,function()
		if self:IsValid() then
			VJ_EmitSound(self,"vj_mili_tank/tank_death2.wav",100,100)
			util.BlastDamage(self,self,self:GetPos() +self:OBBCenter() +self:GetUp() *50,200,40)
			util.ScreenShake(self:GetPos(), 100, 200, 1, 2500)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil) end
		end
	end)

	timer.Simple(1,function()
		if self:IsValid() then
			VJ_EmitSound(self,"vj_mili_tank/tank_death2.wav",100,100)
			util.BlastDamage(self,self,self:GetPos() +self:OBBCenter() +self:GetUp() *50,200,40)
			util.ScreenShake(self:GetPos(), 100, 200, 1, 2500)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil) end
		end
	end)

	timer.Simple(1.5,function()
		if self:IsValid() then
			VJ_EmitSound(self,"vj_mili_tank/tank_death2.wav",100,100)
			VJ_EmitSound(self,"vj_mili_tank/tank_death3.wav",100,100)
			util.BlastDamage(self,self,self:GetPos() +self:OBBCenter() +self:GetUp() *50,200,40)
			util.ScreenShake(self:GetPos(), 100, 200, 1, 2500)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil) end
		end
	end)
	
	timer.Simple(2,function()
		if self:IsValid() then
			VJ_EmitSound(self,"vj_mili_tank/tank_death2.wav",100,100)
			VJ_EmitSound(self,"vj_mili_tank/tank_death3.wav",100,100)
			ParticleEffect("vj_explosion3",self:GetPos(),Angle(0,0,0),nil)
			ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil)
			ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter() +self:GetUp() *50,Angle(0,0,0),nil)
			local explosioneffect = EffectData()
			explosioneffect:SetOrigin(self:GetPos() +self:OBBCenter() +self:GetUp() *50)
			util.Effect("VJ_Medium_Explosion1",explosioneffect)
			util.Effect("Explosion", explosioneffect)
			local dusteffect = EffectData()
			dusteffect:SetOrigin(self:GetPos() +self:OBBCenter() +self:GetUp() *50)
			dusteffect:SetScale(800)
			util.Effect("ThumperDust",dusteffect)
		end
	end)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/