AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/Barney.mdl" ) 
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX ) 
	self:CapabilitiesAdd( CAP_ANIMATEDFACE ) 
	self:SetUseType( SIMPLE_USE ) 
	self:DropToFloor()
    self:SetTrigger(true)
end


function ENT:SpawnFunction(ply, tr, classname)
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create(classname)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Think()
	if ( SERVER ) then 
		self:NextThink( CurTime() ) 
		return true 
	end
end

function ENT:Use(Ply)
	Ply:InteractNPC(self)
end


function ENT:OnTakeDamage()
   	local npcid = self:GetNpc()
   	local npctable = HLXNPC[npcid] or nil 
    npctable.onTakeDamage(self)
end

function ENT:PlayNPCAnimation(sequence,time)
   	local npcid = self:GetNpc()
   	local npctable = HLXNPC[npcid] or nil 

    local seq = self:LookupSequence(sequence)
    local duration = time or self:SequenceDuration( seq )
    local idlesequence = npctable.sequence

    if seq and seq > 0 then
        self:ResetSequence(seq)
        self:SetCycle(0)
        self:SetPlaybackRate(1)
        timer.Create("reset_"..self:EntIndex().."_anim", duration, 1, function() self:ResetSequence(self:LookupSequence(idlesequence)) end)
    end
end

function ENT:IsNearPlayer(player,distance)
    distance = distance or 100
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), distance)) do
        if v:IsPlayer() then
            return true, v
        end
    end
    return false
end
