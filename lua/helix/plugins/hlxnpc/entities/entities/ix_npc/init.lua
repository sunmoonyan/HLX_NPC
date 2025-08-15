AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/Barney.mdl" ) -- Sets the model of the NPC.
	self:SetHullType( HULL_HUMAN ) -- Sets the hull type, used for movement calculations amongst other things.
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX ) -- This entity uses a solid bounding box for collisions.
	self:CapabilitiesAdd( CAP_ANIMATEDFACE ) -- Adds what the NPC is allowed to do ( It cannot move in this case ).
	self:SetUseType( SIMPLE_USE ) -- Makes the ENT.Use hook only get called once at every use.
	self:DropToFloor()
	self:SetMaxYawSpeed( 90 ) --Sets the angle by which an NPC can rotate at once.
    self:SetTrigger(true)
end

local PLUGIN = PLUGIN
function ENT:SpawnFunction(ply, tr, classname)
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create(classname)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end



function ENT:Use(Ply)

Ply:InteractNPC(self:GetNpc())

net.Start("ix_npc_focus")
net.WriteVector(self:LocalToWorld(Vector(25, 10, 65)))
net.WriteAngle(self:LocalToWorldAngles(Angle(10, 170, 0)))
net.Send(Ply)

end





