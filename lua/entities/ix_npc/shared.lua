ENT.Base = "base_anim"
ENT.Type = "ai"
ENT.PrintName		= "NPC"
ENT.Category		= "Helix NPC" 
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminOnly = true
ENT.Editable = true

function ENT:SetupDataTables()

    self:NetworkVar( "String",0, "DisplayName",{ KeyName = "displayname",Edit = { type = "String",order = 1,category = "General"} } )	
    self:NetworkVar( "String",1, "Description",{ KeyName = "description",Edit = { type = "String",order = 2,category = "General"} } )		
	self:NetworkVar( "String",2, "Model",{ KeyName = "model",Edit = { type = "String",order = 3,category = "General"} } )      
    self:NetworkVar( "String",3, "Npc",{ KeyName = "Npc",Edit = { type = "String",order = 4,category = "General"} } )     
    self:NetworkVar("Int", 4, "IdleSequence", {
        KeyName = "IdleSequence",
        Edit = {
            type = "Number",
            order = 5,
            category = "General"
        }
    })

    -- Appelé automatiquement quand IdleSequence change
    self:NetworkVarNotify("IdleSequence", function(ent, name, old, new)
        if not IsValid(ent) then return end
        if new < 0 then return end

        ent:ResetSequence(new)
    end)
end

