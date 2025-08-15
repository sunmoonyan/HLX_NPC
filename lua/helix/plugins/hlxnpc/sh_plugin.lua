--[[
 ________  ___  ___  ________   ________  ___  ___  ___     
|\   ____\|\  \|\  \|\   ___  \|\   ____\|\  \|\  \|\  \    
\ \  \___|\ \  \\\  \ \  \\ \  \ \  \___|\ \  \\\  \ \  \   
 \ \_____  \ \  \\\  \ \  \\ \  \ \_____  \ \   __  \ \  \  
  \|____|\  \ \  \\\  \ \  \\ \  \|____|\  \ \  \ \  \ \  \ 
    ____\_\  \ \_______\ \__\\ \__\____\_\  \ \__\ \__\ \__\
   |\_________\|_______|\|__| \|__|\_________\|__|\|__|\|__|
   \|_________|                   \|_________|              
                                                            
                                                            
]]--

local PLUGIN = PLUGIN

PLUGIN.name = "Helix NPC"
PLUGIN.author = "Sunshi"
PLUGIN.description = "."



if SERVER then
 AddCSLuaFile("hlxnpc_config.lua")
 AddCSLuaFile("cl_npc.lua")
 include("sv_npc.lua")
 include("hlxnpc_config.lua")



    function PLUGIN:SaveData()
        local data = {}
        -----[Jobs]----
        for _, entity in ipairs(ents.FindByClass("ix_npc")) do
            local bodygroups = {}
            for _, v in ipairs(entity:GetBodyGroups() or {}) do
                bodygroups[v.id] = entity:GetBodygroup(v.id)
            end
            data[#data + 1] = {
                name = entity:GetDisplayName(),
                description = entity:GetDescription(),
                pos = entity:GetPos(),
                angles = entity:GetAngles(),
                model = entity:GetModel(),
                skin = entity:GetSkin(),
                bodygroups = bodygroups,
                npc = entity:GetNpc(),
                ent = "ix_npc",
            }
        end
        self:SetData(data)
       -- HLXRP_PluginSaved("HLXNPC")
    end




    function PLUGIN:LoadData()
      --  HLXRP_LoadingBar("HLXNPC")   
        for _, v in ipairs(self:GetData() or {}) do
        -----[Jobs]----
         if v.ent == "ix_npc" then
            local entity = ents.Create("ix_npc")
            entity:SetPos(v.pos)
            entity:SetAngles(v.angles)
            entity:Spawn()
            entity:SetModel(v.model)
            entity:SetSkin(v.skin or 0)
            entity:SetDisplayName(v.name)
            entity:SetDescription(v.description)
            entity:SetNpc(v.npc)
            for id, bodygroup in pairs(v.bodygroups or {}) do
                entity:SetBodygroup(id, bodygroup)
            end
        end
       end

      --  HLXRP_PluginLoaded("HLXNPC")

     end





 
else
 IncludeCS("cl_npc.lua")
 IncludeCS("hlxnpc_config.lua")
end



