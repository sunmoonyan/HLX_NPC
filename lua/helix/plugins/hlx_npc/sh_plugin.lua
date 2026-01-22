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
PLUGIN.description = "Helix NPC V2.0"



if SERVER then

HLXNPC = {}

include("sv_npc.lua")
include("hlx_npc.lua")
AddCSLuaFile("cl_npc.lua")

  function PLUGIN:SaveData()
      local data = {}
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
              idlesequence = entity:GetIdleSequence(),
          }
      end
      self:SetData(data)
  end




  function PLUGIN:LoadData()
      for _, v in ipairs(self:GetData() or {}) do
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
          entity:SetIdleSequence(v.idlesequence)
          for id, bodygroup in pairs(v.bodygroups or {}) do
              entity:SetBodygroup(id, bodygroup)
          end

      end
     end

   end

else

include("cl_npc.lua")

end




properties.Add("npc_sequences", {
    MenuLabel = "Sequences List",
    Order = 400,
    MenuIcon = "icon16/group_gear.png",

    Filter = function(self, entity, client)
        if not IsValid(entity) then return false end
        if entity:GetClass() ~= "ix_npc" then return false end
        if not gamemode.Call("CanProperty", client, "npc_sequences", entity) then return false end
        return true
    end,

    Action = function(self, entity)
        if not IsValid(entity) then return end

        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 550)
        frame:Center()
        frame:SetTitle("NPC Sequences")
        frame:MakePopup()

        local search = vgui.Create("DTextEntry", frame)
        search:Dock(TOP)
        search:SetTall(24)
        search:SetPlaceholderText("Search sequence...")

        local list = vgui.Create("DListView", frame)
        list:Dock(FILL)
        list:AddColumn("ID"):SetFixedWidth(50)
        list:AddColumn("Sequence name")

        local buttons = vgui.Create("DPanel", frame)
        buttons:Dock(BOTTOM)
        buttons:SetTall(40)

        local btnApply = vgui.Create("DButton", buttons)
        btnApply:Dock(LEFT)
        btnApply:SetWide(150)
        btnApply:SetText("Apply")

        local btnCopy = vgui.Create("DButton", buttons)
        btnCopy:Dock(RIGHT)
        btnCopy:SetWide(150)
        btnCopy:SetText("Copy ID")

        local sequences = {}

        for i = 0, entity:GetSequenceCount() - 1 do
            local name = entity:GetSequenceName(i)
            if name and name ~= "Unknown" then
                sequences[#sequences + 1] = {
                    id = i,
                    name = name
                }
            end
        end

        local function Populate(filter)
            list:Clear()
            filter = string.lower(filter or "")

            for _, seq in ipairs(sequences) do
                if filter == "" or string.find(string.lower(seq.name), filter, 1, true) then
                    list:AddLine(seq.id, seq.name)
                end
            end
        end

        Populate()

        search.OnChange = function()
            Populate(search:GetValue())
        end

        local function GetSelectedID()
            local lineID = list:GetSelectedLine()
            if not lineID then return end
            local line = list:GetLine(lineID)
            if not line then return end
            return tonumber(line:GetColumnText(1))
        end

        btnApply.DoClick = function()
            local id = GetSelectedID()
            if not id then return end

            self:MsgStart()
                net.WriteEntity(entity)
                net.WriteUInt(id, 16)
            self:MsgEnd()
        end

        btnCopy.DoClick = function()
            local id = GetSelectedID()
            if not id then return end
            SetClipboardText(tostring(id))
        end
    end,

    Receive = function(self, length, client)
        local ent = net.ReadEntity()
        local id = net.ReadUInt(16)

        if not IsValid(ent) then return end
        if ent:GetClass() ~= "ix_npc" then return end
        if not client:IsAdmin() then return end

        ent:SetIdleSequence(id)
    end
})

