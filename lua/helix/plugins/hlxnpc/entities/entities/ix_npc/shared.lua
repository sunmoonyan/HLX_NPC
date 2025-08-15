ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName		= "Hlx NPC"
ENT.Category		= "Helix Npc" 
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminOnly = true
ENT.Editable = true

function ENT:SetupDataTables()

    self:NetworkVar( "String",0, "DisplayName",{ KeyName = "displayname",Edit = { type = "String",order = 1,category = "General"} } )	
    self:NetworkVar( "String",1, "Description",{ KeyName = "description",Edit = { type = "String",order = 2,category = "General"} } )		
	self:NetworkVar( "String",2, "Model",{ KeyName = "model",Edit = { type = "String",order = 3,category = "General"} } )      
    self:NetworkVar( "String",3, "Npc",{ KeyName = "Npc",Edit = { type = "String",order = 3,category = "General"} } )      

end

